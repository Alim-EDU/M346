# Projektdokumentation - M346 Nextcloud auf AWS

## Inhaltsverzeichnis

1. [Projektübersicht](#projektübersicht)
2. [Architektur](#architektur)
3. [Technologien](#technologien)
4. [Skript-Dokumentation](#skript-dokumentation)
5. [Netzwerk und Security Groups](#netzwerk-und-security-groups)
6. [Datenbank-Konfiguration](#datenbank-konfiguration)
7. [Troubleshooting](#troubleshooting)

---

## Projektübersicht

### Ziel

In diesem Projekt installieren wir Nextcloud in der Community-Edition auf AWS EC2. Dabei setzen wir folgende Anforderungen um:

- Zwei separate Server: Ein Webserver und ein Datenbankserver
- Automatisierte Installation via PowerShell-Skript
- Infrastructure as Code (IaC) Ansatz
- Dokumentation in Markdown

### Projektteam

![Emre](https://img.shields.io/badge/👤%20Emre-4A90E2?style=for-the-badge)
![Alim](https://img.shields.io/badge/👤%20Alim-9B59B6?style=for-the-badge)

---

## Architektur

### Übersicht

![Architektur-Konzept](Images/Konzept_M346.pdf)

### Komponenten

**Webserver:** Dieser Server hostet Nextcloud mit Apache. Wir verwenden eine t2.small Instanz mit 2 vCPUs und 2 GB RAM.

**DB-Server:** Der Datenbank-Server läuft mit MariaDB. Hier reicht eine t2.micro Instanz mit 1 vCPU und 1 GB RAM.

**Security Groups:** Die Firewall-Regeln für beide Server sind im Abschnitt [Netzwerk und Security Groups](#netzwerk-und-security-groups) beschrieben.

**Key Pair:** Für den SSH-Zugriff verwenden wir einen RSA-Schlüssel namens `nextcloud-key.pem`.

### Datenfluss

So funktioniert die Kommunikation zwischen den Komponenten:

1. Der Benutzer greift über HTTP (Port 80) auf den Webserver zu
2. Der Webserver verbindet sich über MySQL (Port 3306) mit der Private IP zum DB-Server
3. Administratoren können sich über SSH (Port 22) mit beiden Servern verbinden

---

## Technologien

### AWS-Services

Für dieses Projekt nutzen wir folgende AWS-Dienste:

**EC2:** Virtuelle Server für den Webserver und den DB-Server

**Security Groups:** Firewall-Konfiguration für die Netzwerksicherheit

**Key Pairs:** SSH-Authentifizierung für den Serverzugriff

**VPC:** Netzwerk-Isolation für unsere Infrastruktur

### Software-Stack

Auf den Servern läuft folgende Software:

**Ubuntu Server 22.04 LTS:** Als Betriebssystem verwenden wir das AMI ami-08c40ec9ead489470

**Apache2 (Version 2.4.x):** Der Webserver für Nextcloud

**PHP (Version 8.x):** Die serverseitige Skriptsprache

**MariaDB (Version 10.x):** Die relationale Datenbank für Nextcloud

**Nextcloud (Latest):** Die Cloud-Plattform selbst

### Entwicklungstools

Für die Entwicklung haben wir diese Tools verwendet:

**PowerShell:** Für die Deployment-Automatisierung

**AWS CLI:** Für das Cloud-Ressourcen-Management

**Git/GitHub:** Für die Versionskontrolle

**VS Code:** Als Code-Editor

---

## Skript-Dokumentation

### install.ps1

Das Installations-Skript automatisiert den kompletten Deployment-Prozess. Es ist in 10 Phasen aufgeteilt:

**Phase 1 - Vorbereitung:** Hier erstellt das Skript das Arbeitsverzeichnis `nextcloud-deployment`, generiert oder verwendet ein bestehendes SSH Key Pair und startet das Logging.

**Phase 2 - Security Groups:** Das Skript erstellt die Security Group `nextcloud-web-sg` für den Webserver (Ports 80 und 22) und `nextcloud-db-sg` für den DB-Server (Ports 3306 und 22). Falls diese schon existieren, werden sie wiederverwendet.

**Phase 3 - User-Data Scripts:** Hier wird das `db-init.txt` Script für die MariaDB-Installation generiert. Dieses konfiguriert die automatische Datenbank-Erstellung.

**Phase 4 - DB-Server starten:** Das Skript startet eine EC2-Instanz vom Typ t2.micro, wartet bis sie läuft und ermittelt die Private IP für die Webserver-Verbindung.

**Phase 5 - Webserver User-Data:** Jetzt wird das `web-init.txt` Script mit der DB-Server Private IP generiert. Es konfiguriert Apache, PHP und Nextcloud.

**Phase 6 - Webserver starten:** Eine t2.small EC2-Instanz wird gestartet. Das Skript wartet 30 Sekunden, damit der DB-Server fertig initialisiert ist.

**Phase 7 - SSH-Key Berechtigungen:** Die Dateiberechtigungen für die `.pem`-Datei werden korrekt gesetzt.

**Phase 8 - Warten auf Nextcloud:** Das Skript pollt den HTTP-Endpoint bis Nextcloud erreichbar ist. Nach 10 Minuten gibt es einen Timeout mit Statusmeldung.

**Phase 9 - Deployment-Info:** Alle Verbindungsdaten werden in `deployment-info.txt` gespeichert und im Terminal angezeigt.

**Phase 10 - Browser & SSH:** Nextcloud wird im Browser geöffnet und SSH-Verbindungsoptionen werden angeboten.

### uninstall.ps1

Das Cleanup-Skript entfernt alle AWS-Ressourcen sauber. Es läuft in 5 Phasen:

**Phase 1 - EC2 Instanzen:** Alle laufenden und gestoppten Instanzen werden gefunden und terminiert. Das Skript wartet auf die vollständige Terminierung.

**Phase 2 - Security Groups:** Alle benutzerdefinierten Security Groups werden gelöscht. Nur die Standard-"default" Gruppe bleibt erhalten.

**Phase 3 - Key Pairs:** Alle Key Pairs werden aus AWS gelöscht und die lokalen `.pem`-Dateien entfernt.

**Phase 4 - Lokale Dateien:** Optional fragt das Skript, ob lokale Projektordner wie `nextcloud-deployment` gelöscht werden sollen.

**Phase 5 - Zusammenfassung:** Der Cleanup-Status wird angezeigt und verifiziert, dass alle Ressourcen gelöscht wurden.

---

## Netzwerk und Security Groups

### Webserver Security Group (nextcloud-web-sg)

Für den Webserver haben wir folgende Firewall-Regeln konfiguriert:

**HTTP auf Port 80 (TCP):** Erlaubt von überall (0.0.0.0/0) - damit ist das Nextcloud Web-Interface öffentlich erreichbar.

**SSH auf Port 22 (TCP):** Erlaubt von überall (0.0.0.0/0) - für die Server-Administration.

### DB-Server Security Group (nextcloud-db-sg)

Der Datenbank-Server hat strengere Regeln:

**MySQL auf Port 3306 (TCP):** Erlaubt NUR von der Webserver Security Group - so kann nur der Webserver auf die Datenbank zugreifen.

**SSH auf Port 22 (TCP):** Erlaubt von überall (0.0.0.0/0) - für die Server-Administration.

### Kommunikationsfluss

Die Kommunikation funktioniert folgendermassen:

1. Der Benutzer greift via HTTP (Port 80) auf den Webserver zu
2. Der Webserver verbindet sich via MySQL (Port 3306) zum DB-Server
3. Diese Verbindung erfolgt über die private IP-Adresse (interne Kommunikation)
4. Der DB-Server ist NICHT öffentlich über Port 3306 erreichbar

### Sicherheitskonzept

Unser Sicherheitskonzept folgt dem Principle of Least Privilege:

- Der Webserver ist öffentlich erreichbar (HTTP + SSH)
- Der DB-Server ist nur über die Private IP vom Webserver erreichbar
- Jeder Server hat nur die minimal notwendigen Berechtigungen

---

## Datenbank-Konfiguration

### MariaDB Setup

Die Datenbank wird automatisch während der EC2-Initialisierung konfiguriert. Das Skript führt folgende SQL-Befehle aus:

```sql
-- Datenbank erstellen
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Benutzer erstellen
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'Nextcloud2024!Secure';

-- Berechtigungen vergeben
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
FLUSH PRIVILEGES;
```

### Zugangsdaten

Für die Nextcloud-Installation brauchst du diese Daten:

**Datenbank:** nextcloud

**Benutzer:** nextcloud

**Passwort:** Nextcloud2024!Secure

**Host:** Private IP des DB-Servers (wird im Skript angezeigt)

**Port:** 3306

### MariaDB Konfiguration

Die MariaDB-Konfiguration liegt in `/etc/mysql/mariadb.conf.d/60-nextcloud.cnf`:

```ini
[mysqld]
bind-address = 0.0.0.0          # Remote-Zugriff erlauben
max_connections = 200            # Maximale Verbindungen
innodb_buffer_pool_size = 512M   # Buffer-Pool für Performance
```

---

## Troubleshooting

### Problem 1: Nextcloud ist nicht erreichbar

Wenn der Browser einen Fehler oder Timeout zeigt, kannst du das so debuggen:

```bash
# SSH zum Webserver
ssh -i ~/.ssh/nextcloud-key.pem ubuntu@<WEBSERVER-IP>

# Apache Status prüfen
sudo systemctl status apache2

# User-Data Log prüfen
sudo cat /var/log/user-data.log
```

### Problem 2: Datenbankverbindung fehlgeschlagen

Wenn Nextcloud "Cannot connect to database" zeigt:

```bash
# SSH zum DB-Server
ssh -i ~/.ssh/nextcloud-key.pem ubuntu@<DB-SERVER-IP>

# MariaDB Status prüfen
sudo systemctl status mariadb

# Verbindung testen
mysql -u nextcloud -p -h localhost
# Passwort: Nextcloud2024!Secure
```

### Problem 3: Security Group blockiert Verbindung

Bei Timeout beim Zugriff auf einen Port:

```powershell
# Security Group Regeln prüfen
aws ec2 describe-security-groups --group-names nextcloud-web-sg
aws ec2 describe-security-groups --group-names nextcloud-db-sg
```

### Problem 4: SSH-Verbindung schlägt fehl

Bei "Permission denied" oder "Connection refused":

```powershell
# Key-Berechtigungen prüfen (Windows)
icacls $env:USERPROFILE\.ssh\nextcloud-key.pem

# Instanz-Status prüfen
aws ec2 describe-instances --instance-ids <INSTANCE-ID>
```

### Problem 5: Installation läuft zu lange

Wenn das Script mehr als 10 Minuten wartet:

```bash
# SSH zum Server und Installationslog prüfen
ssh -i ~/.ssh/nextcloud-key.pem ubuntu@<IP>
sudo tail -f /var/log/user-data.log
```

### Log-Dateien

Falls du Logs brauchst, findest du sie hier:

**Deployment-Log:** `./nextcloud-deployment/deployment-*.log` - Die PowerShell Skript-Ausgabe

**Webserver Init:** `/var/log/user-data.log` - Das Cloud-Init Installationslog

**Apache Error:** `/var/log/apache2/error.log` - Webserver-Fehler

**Apache Access:** `/var/log/apache2/access.log` - HTTP-Anfragen

**MariaDB:** `/var/log/mysql/error.log` - Datenbank-Fehler

### Nützliche Befehle

Hier sind einige Befehle, die oft helfen:

```bash
# Apache neustarten
sudo systemctl restart apache2

# MariaDB neustarten
sudo systemctl restart mariadb

# Nextcloud Wartungsmodus
sudo -u www-data php /var/www/html/occ maintenance:mode --on
sudo -u www-data php /var/www/html/occ maintenance:mode --off

# Berechtigungen reparieren
sudo chown -R www-data:www-data /var/www/html/
sudo chown -R www-data:www-data /var/www/nextcloud-data/
```