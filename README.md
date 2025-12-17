# Nextcloud auf AWS EC2

![Emre](https://img.shields.io/badge/Emre-4A90E2?style=for-the-badge)
![Alim](https://img.shields.io/badge/Alim-9B59B6?style=for-the-badge)

Automatisiertes Deployment von Nextcloud auf AWS mit zwei EC2-Instanzen (Webserver + Datenbankserver).

## Voraussetzungen

- AWS Account mit Berechtigungen
- AWS CLI installiert und konfiguriert
- PowerShell ISE (als Administrator)
- Git

> **Wichtig:** PowerShell ISE muss als **Administrator** gestartet werden!

## Schnellstart

```powershell
# 1. Repository klonen
git clone https://github.com/Alim-EDU/M346.git
cd M346

# 2. Installation starten
.\Skripts\install.ps1
```

Das Skript erstellt automatisch:
- EC2 Webserver (Apache + Nextcloud)
- EC2 DB-Server (MariaDB)
- Security Groups
- SSH Key Pair

Nach ca. 5-10 Minuten öffnet sich Nextcloud im Browser.

## Nextcloud einrichten

Im Installationsassistenten die angezeigten Datenbank-Zugangsdaten eingeben:

- **Datenbanktyp:** MySQL/MariaDB
- **Name:** nextcloud
- **Benutzer:** nextcloud
- **Passwort:** Nextcloud2024!Secure
- **Host:** Private IP des DB-Servers (wird im Skript angezeigt)
- **Data-Ordner:** /var/www/nextcloud-data

> **Hinweis:** Die Private IP wird am Ende des Skripts angezeigt. Sie sieht etwa so aus: `10.0.x.x` oder `172.x.x.x`

## Ressourcen löschen

Nach dem Testen unbedingt alle AWS-Ressourcen löschen, um Kosten zu vermeiden:

```powershell
.\Skripts\uninstall.ps1
```

## Dokumentation

Weitere Details findest du in der [Projektdokumentation](Docs/dokumentation.md).
