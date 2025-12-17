# ============================================================
# AWS Cleanup Script - Löscht alle Nextcloud-Ressourcen
# ============================================================

$ErrorActionPreference = "Continue"
$env:AWS_PAGER = ""

function Write-Step { param($msg) Write-Host "`n>>> $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "  $msg" -ForegroundColor Yellow }
function Write-Error-Custom { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║         AWS CLEANUP - Lösche alle Ressourcen            ║
║                                                          ║
║  WARNUNG: Dies löscht ALLE EC2-Instanzen,               ║
║           Security Groups und Key Pairs!                ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Red

Write-Host "`nBist du sicher? Dies kann nicht rückgängig gemacht werden!" -ForegroundColor Yellow
Write-Host "Tippe 'LÖSCHEN' (in Großbuchstaben) um fortzufahren: " -ForegroundColor Red -NoNewline
$confirm = Read-Host

if ($confirm -ne "LÖSCHEN") {
    Write-Info "Abgebrochen. Keine Ressourcen wurden gelöscht."
    exit 0
}

Write-Host "`n" -NoNewline
Write-Step "Starte Cleanup-Prozess..."

# ============================================================
# PHASE 1: EC2 INSTANZEN FINDEN UND LÖSCHEN
# ============================================================

Write-Step "Phase 1: Suche und lösche EC2 Instanzen"

# Alle laufenden und gestoppten Instanzen finden
$instances = aws ec2 describe-instances `
    --filters "Name=instance-state-name,Values=running,stopped,pending" `
    --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value|[0],State.Name]" `
    --output text

if ($instances) {
    $instanceIds = @()
    $instances -split "`n" | ForEach-Object {
        $parts = $_ -split "`t"
        if ($parts.Count -ge 2) {
            $id = $parts[0]
            $name = $parts[1]
            $state = $parts[2]
            Write-Info "Gefunden: $id - $name ($state)"
            $instanceIds += $id
        }
    }
    
    if ($instanceIds.Count -gt 0) {
        Write-Info "Terminiere $($instanceIds.Count) Instanz(en)..."
        aws ec2 terminate-instances --instance-ids $instanceIds | Out-Null
        Write-Success "Instanzen werden terminiert..."
        
        Write-Info "Warte bis alle Instanzen terminiert sind..."
        foreach ($id in $instanceIds) {
            try {
                aws ec2 wait instance-terminated --instance-ids $id --cli-read-timeout 300
                Write-Success "  $id terminiert"
            } catch {
                Write-Info "  $id - Timeout oder bereits gelöscht"
            }
        }
    }
} else {
    Write-Info "Keine EC2 Instanzen gefunden"
}

# ============================================================
# PHASE 2: SECURITY GROUPS LÖSCHEN
# ============================================================

Write-Step "Phase 2: Lösche Security Groups"

# Kurz warten damit EC2 Instanzen vollständig weg sind
Start-Sleep -Seconds 5

# Alle Security Groups außer 'default' finden
$securityGroups = aws ec2 describe-security-groups `
    --query "SecurityGroups[?GroupName!='default'].[GroupId,GroupName]" `
    --output text

if ($securityGroups) {
    $securityGroups -split "`n" | ForEach-Object {
        $parts = $_ -split "`t"
        if ($parts.Count -ge 2) {
            $sgId = $parts[0]
            $sgName = $parts[1]
            
            Write-Info "Lösche Security Group: $sgName ($sgId)"
            try {
                aws ec2 delete-security-group --group-id $sgId 2>$null
                Write-Success "  $sgName gelöscht"
            } catch {
                Write-Error-Custom "  Konnte $sgName nicht löschen (möglicherweise noch in Verwendung)"
            }
        }
    }
} else {
    Write-Info "Keine Security Groups zum Löschen gefunden"
}

# ============================================================
# PHASE 3: KEY PAIRS LÖSCHEN
# ============================================================

Write-Step "Phase 3: Lösche Key Pairs"

# Alle Key Pairs finden
$keyPairs = aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output text

if ($keyPairs) {
    $keyPairs -split "`s+" | ForEach-Object {
        $keyName = $_
        if ($keyName) {
            Write-Info "Lösche Key Pair: $keyName"
            try {
                aws ec2 delete-key-pair --key-name $keyName
                Write-Success "  $keyName gelöscht"
                
                # Lokale .pem Datei löschen falls vorhanden
                $pemFile = "$env:USERPROFILE\.ssh\$keyName.pem"
                if (Test-Path $pemFile) {
                    Remove-Item $pemFile -Force
                    Write-Success "  Lokale Datei $pemFile gelöscht"
                }
            } catch {
                Write-Error-Custom "  Konnte $keyName nicht löschen"
            }
        }
    }
} else {
    Write-Info "Keine Key Pairs gefunden"
}

# ============================================================
# PHASE 4: LOKALE DATEIEN LÖSCHEN (OPTIONAL)
# ============================================================

Write-Step "Phase 4: Lokale Projektdateien"

Write-Host "`nMöchtest du auch die lokalen Projektordner löschen?" -ForegroundColor Yellow
Write-Host "  [j] Ja, alles löschen" -ForegroundColor Red
Write-Host "  [n] Nein, Dateien behalten" -ForegroundColor Green
$deleteLocal = Read-Host "`nDeine Wahl"

if ($deleteLocal -eq "j" -or $deleteLocal -eq "J") {
    $folders = @("nextcloud-deployment", "ec2nextcloud", "ec2webserver")
    
    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            Write-Info "Lösche Ordner: $folder"
            Remove-Item $folder -Recurse -Force
            Write-Success "  $folder gelöscht"
        }
    }
} else {
    Write-Info "Lokale Dateien bleiben erhalten"
}

# ============================================================
# PHASE 5: ZUSAMMENFASSUNG
# ============================================================

Write-Host "`n" -NoNewline
Write-Step "Cleanup abgeschlossen!"

Write-Host @"

╔══════════════════════════════════════════════════════════╗
║              CLEANUP ERFOLGREICH                        ║
╚══════════════════════════════════════════════════════════╝

Gelöschte Ressourcen:
  ✓ EC2 Instanzen (alle gefundenen)
  ✓ Security Groups (außer 'default')
  ✓ Key Pairs (inkl. .pem Dateien)

"@ -ForegroundColor Green

# Überprüfung ob wirklich alles weg ist
Write-Step "Finale Überprüfung..."

$remainingInstances = aws ec2 describe-instances `
    --filters "Name=instance-state-name,Values=running,stopped,pending" `
    --query "Reservations[*].Instances[*].InstanceId" `
    --output text

$remainingSGs = aws ec2 describe-security-groups `
    --query "SecurityGroups[?GroupName!='default'].GroupId" `
    --output text

$remainingKeys = aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName" --output text

if ($remainingInstances) {
    Write-Info "⚠️  Noch vorhandene Instanzen: $remainingInstances"
} else {
    Write-Success "✓ Keine EC2 Instanzen mehr vorhanden"
}

if ($remainingSGs) {
    Write-Info "⚠️  Noch vorhandene Security Groups: $remainingSGs"
    Write-Info "   (Diese sind möglicherweise noch von anderen Ressourcen abhängig)"
} else {
    Write-Success "✓ Keine benutzerdefinierten Security Groups mehr vorhanden"
}

if ($remainingKeys) {
    Write-Info "⚠️  Noch vorhandene Key Pairs: $remainingKeys"
} else {
    Write-Success "✓ Keine Key Pairs mehr vorhanden"
}

Write-Host "`n✨ AWS Account ist jetzt sauber! Du kannst neu starten.`n" -ForegroundColor Green