# ============================================================
# AWS Nextcloud 2-Server Deployment Script
# Webserver (Apache + Nextcloud) + DB-Server (MariaDB)
# ============================================================

$ErrorActionPreference = "Continue"
$env:AWS_PAGER = ""

# Farben für bessere Lesbarkeit
function Write-Step { param($msg) Write-Host "`n>>> $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "  $msg" -ForegroundColor Yellow }
function Write-Error-Custom { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║     Nextcloud 2-Server Deployment auf AWS EC2           ║
║     Webserver + Datenbank-Server                        ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# ============================================================
# PHASE 1: VORBEREITUNG
# ============================================================

Write-Step "Phase 1: Erstelle Arbeitsverzeichnis und SSH-Key"

# Projektordner erstellen
$projectDir = "nextcloud-deployment"
if (Test-Path $projectDir) {
    Write-Info "Ordner existiert bereits, wird verwendet"
} else {
    New-Item -ItemType Directory -Path $projectDir | Out-Null
    Write-Success "Ordner '$projectDir' erstellt"
}
Set-Location $projectDir

# Log-Datei erstellen
$logFile = "deployment-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
Start-Transcript -Path $logFile

# SSH Key Pair erstellen oder wiederverwenden
Write-Info "Prüfe SSH Key Pair..."
$existingKeys = aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='nextcloud-key'].KeyName" --output text 2>$null

if ($existingKeys -match "nextcloud-key") {
    Write-Info "Key Pair 'nextcloud-key' existiert bereits - wird wiederverwendet"
} else {
    Write-Info "Erstelle neues Key Pair..."
    try {
        aws ec2 create-key-pair --key-name nextcloud-key --key-type rsa --query 'KeyMaterial' --output text 2>&1 | Out-File -Encoding ascii -FilePath ~/.ssh/nextcloud-key.pem
        Write-Success "SSH Key erstellt: ~/.ssh/nextcloud-key.pem"
    } catch {
        Write-Error-Custom "Fehler beim Erstellen des Key Pairs: $_"
        Stop-Transcript
        exit 1
    }
}

# ============================================================
# PHASE 2: SECURITY GROUPS
# ============================================================

Write-Step "Phase 2: Erstelle Security Groups (Firewall-Regeln)"

# Security Group für Webserver
Write-Info "Prüfe Security Group für Webserver..."
$webSgId = (aws ec2 describe-security-groups --filters "Name=group-name,Values=nextcloud-web-sg" --query "SecurityGroups[0].GroupId" --output text 2>$null)

if ($webSgId -and $webSgId -ne "None" -and $webSgId -match "^sg-") {
    Write-Info "Webserver SG existiert bereits: $webSgId"
} else {
    Write-Info "Erstelle neue Security Group für Webserver..."
    $webSgId = (aws ec2 create-security-group `
        --group-name nextcloud-web-sg `
        --description "Security Group fuer Nextcloud Webserver" `
        --query 'GroupId' `
        --output text 2>&1)
    
    if ($webSgId -match "^sg-") {
        Write-Success "Webserver SG erstellt: $webSgId"
        Start-Sleep -Seconds 2
    } else {
        Write-Error-Custom "Fehler beim Erstellen der Webserver Security Group: $webSgId"
        Stop-Transcript
        exit 1
    }
}

# Firewall-Regeln für Webserver hinzufügen (falls noch nicht vorhanden)
Write-Info "Füge Firewall-Regeln für Webserver hinzu..."
aws ec2 authorize-security-group-ingress --group-id $webSgId --protocol tcp --port 80 --cidr 0.0.0.0/0 2>$null
aws ec2 authorize-security-group-ingress --group-id $webSgId --protocol tcp --port 22 --cidr 0.0.0.0/0 2>$null
Write-Success "Webserver Firewall-Regeln gesetzt (Port 80, 22)"

# Security Group für DB-Server
Write-Info "Prüfe Security Group für DB-Server..."
$dbSgId = (aws ec2 describe-security-groups --filters "Name=group-name,Values=nextcloud-db-sg" --query "SecurityGroups[0].GroupId" --output text 2>$null)

if ($dbSgId -and $dbSgId -ne "None" -and $dbSgId -match "^sg-") {
    Write-Info "DB-Server SG existiert bereits: $dbSgId"
} else {
    Write-Info "Erstelle neue Security Group für DB-Server..."
    $dbSgId = (aws ec2 create-security-group `
        --group-name nextcloud-db-sg `
        --description "Security Group fuer MariaDB Server" `
        --query 'GroupId' `
        --output text 2>&1)
    
    if ($dbSgId -match "^sg-") {
        Write-Success "DB-Server SG erstellt: $dbSgId"
        Start-Sleep -Seconds 2
    } else {
        Write-Error-Custom "Fehler beim Erstellen der DB-Server Security Group: $dbSgId"
        Stop-Transcript
        exit 1
    }
}

# Firewall-Regeln für DB-Server hinzufügen
Write-Info "Füge Firewall-Regeln für DB-Server hinzu..."
aws ec2 authorize-security-group-ingress --group-id $dbSgId --protocol tcp --port 3306 --source-group $webSgId 2>$null
aws ec2 authorize-security-group-ingress --group-id $dbSgId --protocol tcp --port 22 --cidr 0.0.0.0/0 2>$null
Write-Success "DB-Server Firewall-Regeln gesetzt (Port 3306 von Webserver, Port 22)"

Start-Sleep -Seconds 2

# ============================================================
# PHASE 3: USER-DATA SCRIPTS
# ============================================================

Write-Step "Phase 3: Erstelle Installations-Scripts"

# DB-Server User-Data Script
$dbUserData = @'
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

echo "=== DB-Server Installation gestartet um $(date) ==="

# System aktualisieren
apt-get update -y
apt-get upgrade -y

# MariaDB installieren
apt-get install -y mariadb-server

# MariaDB konfigurieren für Remote-Zugriff
cat > /etc/mysql/mariadb.conf.d/60-nextcloud.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
max_connections = 200
innodb_buffer_pool_size = 512M
EOF

# MariaDB neustarten
systemctl restart mariadb
systemctl enable mariadb

# Datenbank und Benutzer erstellen
mysql -e "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'nextcloud'@'%' IDENTIFIED BY 'Nextcloud2024!Secure';"
mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Root-Passwort setzen
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RootPass2024!Secure';"
mysql -e "FLUSH PRIVILEGES;"

echo "=== DB-Server Installation abgeschlossen um $(date) ==="
'@

$dbUserData | Out-File -FilePath db-init.txt -Encoding ASCII
Write-Success "DB-Server Script erstellt: db-init.txt"

Write-Info "Webserver Script wird nach DB-Server Erstellung generiert..."

# ============================================================
# PHASE 4: DB-SERVER STARTEN
# ============================================================

Write-Step "Phase 4: Starte DB-Server EC2 Instanz"

Write-Info "Erstelle DB-Server Instanz (t2.micro)..."
$dbInstanceId = (aws ec2 run-instances `
    --image-id ami-08c40ec9ead489470 `
    --count 1 `
    --instance-type t2.micro `
    --key-name nextcloud-key `
    --security-group-ids $dbSgId `
    --iam-instance-profile Name=LabInstanceProfile `
    --user-data file://db-init.txt `
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Nextcloud-DB-Server}]' `
    --query 'Instances[0].InstanceId' `
    --output text 2>&1)

if ($dbInstanceId -match "^i-") {
    Write-Success "DB-Server Instance ID: $dbInstanceId"
} else {
    Write-Error-Custom "Fehler beim Starten des DB-Servers: $dbInstanceId"
    Stop-Transcript
    exit 1
}

Write-Info "Warte bis DB-Server läuft..."
aws ec2 wait instance-running --instance-ids $dbInstanceId
Write-Success "DB-Server läuft!"

# Private IP des DB-Servers holen
Write-Info "Hole private IP des DB-Servers..."
$dbPrivateIp = $null
for ($i = 0; $i -lt 10; $i++) {
    $dbPrivateIp = (aws ec2 describe-instances `
        --instance-ids $dbInstanceId `
        --query "Reservations[0].Instances[0].PrivateIpAddress" `
        --output text 2>$null)
    
    if ($dbPrivateIp -and $dbPrivateIp -ne "None" -and $dbPrivateIp -match "^\d+\.\d+\.\d+\.\d+$") {
        Write-Success "DB-Server private IP: $dbPrivateIp"
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $dbPrivateIp -or $dbPrivateIp -eq "None" -or $dbPrivateIp -notmatch "^\d+\.\d+\.\d+\.\d+$") {
    Write-Error-Custom "Konnte private IP des DB-Servers nicht ermitteln!"
    Stop-Transcript
    exit 1
}

# Public IP für SSH-Zugriff
$dbPublicIp = (aws ec2 describe-instances `
    --instance-ids $dbInstanceId `
    --query "Reservations[0].Instances[0].PublicIpAddress" `
    --output text 2>$null)
Write-Info "DB-Server public IP (für SSH): $dbPublicIp"

# ============================================================
# PHASE 5: WEBSERVER USER-DATA MIT DB-IP
# ============================================================

Write-Step "Phase 5: Erstelle Webserver Script mit DB-Verbindung"

$webUserData = @"
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

echo "=== Webserver Installation gestartet um `$(date) ==="

# System aktualisieren
apt-get update -y
apt-get upgrade -y

# Apache, PHP und Module installieren
apt-get install -y apache2 libapache2-mod-php php-gd php-mysql \
php-curl php-mbstring php-intl php-gmp php-bcmath php-xml \
php-imagick php-zip php-bz2 php-ldap php-apcu unzip wget

# Apache Module aktivieren
a2enmod rewrite headers env dir mime

# Nextcloud herunterladen und entpacken
cd /tmp
wget -q https://download.nextcloud.com/server/releases/latest.zip
unzip -q latest.zip

# Alte HTML-Dateien löschen
rm -rf /var/www/html/*

# Nextcloud-Dateien verschieben
cp -r nextcloud/* /var/www/html/
rm -rf nextcloud latest.zip

# Data-Verzeichnis außerhalb von html erstellen (sicherer)
mkdir -p /var/www/nextcloud-data

# Config-Verzeichnis erstellen
mkdir -p /var/www/html/config

# Berechtigungen korrekt setzen
chown -R www-data:www-data /var/www/html/
chown -R www-data:www-data /var/www/nextcloud-data/
chmod -R 750 /var/www/html/
chmod -R 770 /var/www/nextcloud-data/

# Spezielle Nextcloud-Verzeichnisse
chmod 770 /var/www/html/config
chmod 770 /var/www/html/apps
chmod 770 /var/www/html/apps-appstore

# Apache VirtualHost konfigurieren
cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    
    <Directory /var/www/html/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>
    
    ErrorLog `${APACHE_LOG_DIR}/error.log
    CustomLog `${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# PHP Einstellungen optimieren
PHP_INI=`$(find /etc/php -name php.ini | grep apache2)
sed -i 's/memory_limit = .*/memory_limit = 512M/' `$PHP_INI
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' `$PHP_INI
sed -i 's/post_max_size = .*/post_max_size = 512M/' `$PHP_INI
sed -i 's/max_execution_time = .*/max_execution_time = 300/' `$PHP_INI

# Apache neustarten
systemctl restart apache2
systemctl enable apache2

# Installationshinweis erstellen
cat > /var/www/html/INSTALLATION.txt <<EOF
╔══════════════════════════════════════════════════════════╗
║          NEXTCLOUD DATENBANK-VERBINDUNG                 ║
╚══════════════════════════════════════════════════════════╝

Beim Nextcloud Setup-Assistenten diese Daten eingeben:

┌─────────────────────────────────────────────────────────┐
│ DATENBANK-KONFIGURATION:                                │
├─────────────────────────────────────────────────────────┤
│ Datenbanktyp:    MySQL/MariaDB                          │
│ Datenbankname:   nextcloud                              │
│ Datenbankhost:   $dbPrivateIp:3306                      │
│ Benutzername:    nextcloud                              │
│ Passwort:        Nextcloud2024!Secure                   │
│                                                         │
│ WICHTIG: Data-Ordner ändern auf:                        │
│          /var/www/nextcloud-data                        │
└─────────────────────────────────────────────────────────┘

WICHTIG: 
1. Verwende die interne IP-Adresse ($dbPrivateIp)
2. Ändere den Data-Ordner auf /var/www/nextcloud-data
EOF

echo "=== Webserver Installation abgeschlossen um `$(date) ==="
"@

$webUserData | Out-File -FilePath web-init.txt -Encoding ASCII
Write-Success "Webserver Script erstellt mit DB-IP: $dbPrivateIp"

# ============================================================
# PHASE 6: WEBSERVER STARTEN
# ============================================================

Write-Step "Phase 6: Starte Webserver EC2 Instanz"

# Warte kurz damit DB-Server vollständig initialisiert ist
Write-Info "Warte 30 Sekunden damit DB-Server initialisiert..."
Start-Sleep -Seconds 30

Write-Info "Erstelle Webserver Instanz (t2.small)..."
$webInstanceId = (aws ec2 run-instances `
    --image-id ami-08c40ec9ead489470 `
    --count 1 `
    --instance-type t2.small `
    --key-name nextcloud-key `
    --security-group-ids $webSgId `
    --iam-instance-profile Name=LabInstanceProfile `
    --user-data file://web-init.txt `
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Nextcloud-Webserver}]' `
    --query 'Instances[0].InstanceId' `
    --output text 2>&1)

if ($webInstanceId -match "^i-") {
    Write-Success "Webserver Instance ID: $webInstanceId"
} else {
    Write-Error-Custom "Fehler beim Starten des Webservers: $webInstanceId"
    Stop-Transcript
    exit 1
}

Write-Info "Warte bis Webserver läuft..."
aws ec2 wait instance-running --instance-ids $webInstanceId
Write-Success "Webserver läuft!"

# Public IP des Webservers holen
Write-Info "Hole Public IP des Webservers..."
$webPublicIp = $null
for ($i = 0; $i -lt 15; $i++) {
    $webPublicIp = (aws ec2 describe-instances `
        --instance-ids $webInstanceId `
        --query "Reservations[0].Instances[0].PublicIpAddress" `
        --output text 2>$null)
    
    if ($webPublicIp -and $webPublicIp -ne "None" -and $webPublicIp -match "^\d+\.\d+\.\d+\.\d+$") {
        Write-Success "Webserver Public IP: $webPublicIp"
        break
    }
    Start-Sleep -Seconds 2
}

# Private IP für Dokumentation
$webPrivateIp = (aws ec2 describe-instances `
    --instance-ids $webInstanceId `
    --query "Reservations[0].Instances[0].PrivateIpAddress" `
    --output text 2>$null)

# ============================================================
# PHASE 7: SSH KEY BERECHTIGUNGEN
# ============================================================

Write-Step "Phase 7: Setze SSH-Key Berechtigungen"

if (Test-Path "$env:USERPROFILE\.ssh\nextcloud-key.pem") {
    icacls $env:USERPROFILE\.ssh\nextcloud-key.pem /inheritance:r /grant:r "$($env:USERNAME):(R)" 2>$null | Out-Null
    Write-Success "SSH-Key Berechtigungen gesetzt"
} else {
    Write-Info "SSH-Key Datei nicht gefunden (wahrscheinlich existierte der Key bereits)"
}

# ============================================================
# PHASE 8: WARTEN AUF NEXTCLOUD
# ============================================================

Write-Step "Phase 8: Warte auf Nextcloud Installation (5-10 Minuten)"

$webReady = $false
$startTime = Get-Date

for ($i = 0; $i -lt 600; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://$webPublicIp" -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $elapsed = ((Get-Date) - $startTime).TotalMinutes
            Write-Success "Nextcloud ist erreichbar! (nach $([math]::Round($elapsed, 1)) Minuten)"
            $webReady = $true
            break
        }
    } catch {
        if ($i % 30 -eq 0 -and $i -gt 0) {
            $remaining = [math]::Round((600 - $i) / 60, 1)
            Write-Info "Installation läuft... noch ca. $remaining Minuten"
        }
        Start-Sleep -Seconds 1
    }
}

if (-not $webReady) {
    Write-Info "Timeout erreicht - Installation läuft möglicherweise noch"
    Write-Info "Überprüfe den Status später mit: http://$webPublicIp"
}

# ============================================================
# PHASE 9: DEPLOYMENT-INFORMATIONEN SPEICHERN
# ============================================================

Write-Step "Phase 9: Speichere Deployment-Informationen"

$deploymentInfo = @"
╔══════════════════════════════════════════════════════════╗
║     NEXTCLOUD DEPLOYMENT ERFOLGREICH ABGESCHLOSSEN      ║
╚══════════════════════════════════════════════════════════╝

DEPLOYMENT ZEITPUNKT: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')

┌─────────────────────────────────────────────────────────┐
│ WEBSERVER (Nextcloud + Apache)                          │
├─────────────────────────────────────────────────────────┤
│ Instance ID:     $webInstanceId
│ Public IP:       $webPublicIp
│ Private IP:      $webPrivateIp
│ Instance Type:   t2.small
│ Security Group:  $webSgId
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ DB-SERVER (MariaDB)                                     │
├─────────────────────────────────────────────────────────┤
│ Instance ID:     $dbInstanceId
│ Public IP:       $dbPublicIp (nur für SSH)
│ Private IP:      $dbPrivateIp (für DB-Verbindung)
│ Instance Type:   t2.micro
│ Security Group:  $dbSgId
│ MySQL Port:      3306
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ NEXTCLOUD ZUGRIFF                                       │
├─────────────────────────────────────────────────────────┤
│ URL:             http://$webPublicIp
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ DATENBANK-ZUGANGSDATEN (für Nextcloud Setup)           │
├─────────────────────────────────────────────────────────┤
│ Datenbanktyp:    MySQL/MariaDB                          │
│ Datenbankname:   nextcloud                              │
│ Datenbankhost:   $dbPrivateIp:3306                      │
│ Benutzername:    nextcloud                              │
│ Passwort:        Nextcloud2024!Secure                   │
│                                                         │
│ Root-Passwort:   RootPass2024!Secure                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ SSH-VERBINDUNGEN                                        │
├─────────────────────────────────────────────────────────┤
│ Webserver:                                              │
│   ssh -i ~/.ssh/nextcloud-key.pem ubuntu@$webPublicIp
│                                                         │
│ DB-Server:                                              │
│   ssh -i ~/.ssh/nextcloud-key.pem ubuntu@$dbPublicIp
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ NÄCHSTE SCHRITTE                                        │
├─────────────────────────────────────────────────────────┤
│ 1. Öffne http://$webPublicIp im Browser
│ 2. Erstelle deinen Admin-Account                       │
│ 3. Wähle "MySQL/MariaDB" als Datenbank                 │
│ 4. Gib die oben aufgeführten DB-Zugangsdaten ein       │
│ 5. Klicke auf "Installation abschließen"               │
└─────────────────────────────────────────────────────────┘

LOG-DATEIEN:
- Deployment-Log: $logFile
- Webserver-Log:  /var/log/user-data.log (auf Webserver)
- DB-Server-Log:  /var/log/user-data.log (auf DB-Server)

"@

$deploymentInfo | Out-File -FilePath "deployment-info.txt" -Encoding UTF8
Write-Host $deploymentInfo -ForegroundColor White

# ============================================================
# PHASE 10: BROWSER ÖFFNEN & SSH OPTIONEN
# ============================================================

Write-Step "Phase 10: Starte Browser und biete SSH-Zugriff an"

Write-Info "Öffne Nextcloud im Browser..."
Start-Process "http://$webPublicIp"

Write-Host "`nMöchtest du dich per SSH verbinden?" -ForegroundColor Cyan
Write-Host "  [1] Webserver" -ForegroundColor Yellow
Write-Host "  [2] DB-Server" -ForegroundColor Yellow
Write-Host "  [3] Beide nacheinander" -ForegroundColor Yellow
Write-Host "  [0] Nein, beenden" -ForegroundColor Gray

$choice = Read-Host "`nDeine Wahl"

switch ($choice) {
    "1" {
        Write-Info "Verbinde zum Webserver..."
        ssh -i "$env:USERPROFILE\.ssh\nextcloud-key.pem" -o StrictHostKeyChecking=no "ubuntu@$webPublicIp"
    }
    "2" {
        Write-Info "Verbinde zum DB-Server..."
        ssh -i "$env:USERPROFILE\.ssh\nextcloud-key.pem" -o StrictHostKeyChecking=no "ubuntu@$dbPublicIp"
    }
    "3" {
        Write-Info "Verbinde zum Webserver... (tippe 'exit' für DB-Server)"
        ssh -i "$env:USERPROFILE\.ssh\nextcloud-key.pem" -o StrictHostKeyChecking=no "ubuntu@$webPublicIp"
        Write-Info "Verbinde zum DB-Server..."
        ssh -i "$env:USERPROFILE\.ssh\nextcloud-key.pem" -o StrictHostKeyChecking=no "ubuntu@$dbPublicIp"
    }
    default {
        Write-Info "Keine SSH-Verbindung. Deployment abgeschlossen."
    }
}

Stop-Transcript

Write-Host "`n" -NoNewline
Write-Success "DEPLOYMENT ERFOLGREICH ABGESCHLOSSEN! 🎉"
Write-Host "`nAlle Informationen wurden gespeichert in:" -ForegroundColor Cyan
Write-Host "  - deployment-info.txt" -ForegroundColor White
Write-Host "  - $logFile" -ForegroundColor White
Write-Host "`n"