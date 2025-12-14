# Fehlermeldung Fortsetzung
$env:AWS_PAGER = ""
 
# Key Pair erstellen 
Write-Host "Erstelle Key Pair..." -ForegroundColor Yellow
aws ec2 create-key-pair --key-name aws-gbs-cli --key-type rsa --query 'KeyMaterial' --output text | out-file -encoding ascii -filepath ~/.ssh/aws-gbs-cli.pem
 
# Security Group erstellen und ID speichern
Write-Host "Erstelle Security Group..." -ForegroundColor Yellow
$sgId = (aws ec2 create-security-group `
  --group-name gbs-sec-group `
  --description "EC2-Webserver-SG" `
  --query 'GroupId' `
  --output text)
 
Write-Host "Security Group ID: $sgId" -ForegroundColor Cyan
 
# Regeln hinzufügen
Write-Host "Füge Firewall-Regeln hinzu..." -ForegroundColor Yellow
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 80 --cidr 0.0.0.0/0 
aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 22 --cidr 0.0.0.0/0
 
# Warte kurz
Start-Sleep -Seconds 3
 
# Ordner für die EC2 Instanz erstellen 
Write-Host "Erstelle Ordner..." -ForegroundColor Yellow
mkdir ec2webserver -Force -ErrorAction SilentlyContinue
cd ec2webserver
 
# Config Datei für EC2 Instanz erstellen  
Write-Host "Erstelle User-Data Script..." -ForegroundColor Yellow
@'
#!/bin/bash
exec > /var/log/user-data.log 2>&1
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello World!</h1>" | sudo tee /var/www/html/index.html
'@ | Out-File -FilePath initial.txt -Encoding ASCII
 
# EC2 Instanz erstellen 
Write-Host "Erstelle EC2 Instanz..." -ForegroundColor Yellow
$instanceId = (aws ec2 run-instances `
  --image-id ami-08c40ec9ead489470 `
  --count 1 `
  --instance-type t2.micro `
  --key-name aws-gbs-cli `
  --security-group-ids $sgId `
  --iam-instance-profile Name=LabInstanceProfile `
  --user-data file://initial.txt `
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Webserver}]' `
  --query 'Instances[0].InstanceId' `
  --output text)
 
Write-Host "Instance ID: $instanceId" -ForegroundColor Green
 
# Warten bis die Instanz läuft
Write-Host "Warte bis die Instanz läuft..." -ForegroundColor Yellow
aws ec2 wait instance-running --instance-ids $instanceId
Write-Host "Instanz läuft!" -ForegroundColor Green
 
# Public IP holen mit Retry-Logik
Write-Host "Hole Public IP..." -ForegroundColor Yellow
$publicIp = $null
$maxRetries = 15
 
for ($i = 0; $i -lt $maxRetries; $i++) {
    $publicIp = (aws ec2 describe-instances `
      --instance-ids $instanceId `
      --query "Reservations[0].Instances[0].PublicIpAddress" `
      --output text)
    if ($publicIp -and $publicIp -ne "None" -and $publicIp -ne "") {
        Write-Host "Public IP gefunden: $publicIp" -ForegroundColor Green
        break
    }
    Write-Host "Warte auf Public IP... Versuch $($i+1)/$maxRetries" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}
 
# Überprüfen ob IP vorhanden
if ([string]::IsNullOrWhiteSpace($publicIp) -or $publicIp -eq "None") {
    Write-Host "FEHLER: Keine Public IP gefunden!" -ForegroundColor Red
    exit 1
}
 
# Datei-Berechtigungen
Write-Host "Setze Datei-Berechtigungen..." -ForegroundColor Yellow
icacls $env:USERPROFILE\.ssh\aws-gbs-cli.pem /inheritance:r /grant:r "$($env:USERNAME):(R)" | Out-Null
 
# Warte auf Webserver
Write-Host "`nWarte auf Webserver (max 2 Minuten)..." -ForegroundColor Yellow
$webReady = $false
 
for ($i = 0; $i -lt 120; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://$publicIp" -TimeoutSec 3 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "`n✅ WEBSERVER IST ERREICHBAR!" -ForegroundColor Green
            $webReady = $true
            break
        }
    } catch {
        if ($i % 10 -eq 0) {
            Write-Host "Noch $($120-$i) Sekunden..." -ForegroundColor Yellow
        }
        Start-Sleep -Seconds 1
    }
}
 
# Nach der Schleife automatisch weitermachen
if (-not $webReady) {
    Write-Host "`n⚠️ Timeout erreicht - Webserver möglicherweise noch nicht bereit" -ForegroundColor Yellow
}
 
# Ergebnis anzeigen
Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "Instance ID: $instanceId" -ForegroundColor White
Write-Host "Public IP:   $publicIp" -ForegroundColor White
Write-Host "Web-URL:     http://$publicIp" -ForegroundColor Green
Write-Host "================================================`n" -ForegroundColor Cyan
 
# SSH Verbindung (interaktiv - du kannst arbeiten)
Write-Host "Starte SSH-Verbindung..." -ForegroundColor Cyan
Write-Host "(Tippe 'exit' um die Verbindung zu beenden)`n" -ForegroundColor Gray
ssh -i "$env:USERPROFILE\.ssh\aws-gbs-cli.pem" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "ubuntu@$publicIp"
 
# NACH SSH exit - Browser öffnen
Write-Host "`nSSH-Verbindung beendet." -ForegroundColor Yellow
Write-Host "Öffne Webserver im Browser..." -ForegroundColor Green
Start-Process "http://$publicIp"
 
