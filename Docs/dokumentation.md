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
 
Installation von Nextcloud in der Community-Edition auf AWS EC2 mit folgenden Anforderungen:
 
- Zwei separate Server (Webserver + Datenbankserver)
- Automatisierte Installation via PowerShell-Skript
- Infrastructure as Code (IaC) Ansatz
- Dokumentation in Markdown
 
### Projektteam
 
![Emre](https://img.shields.io/badge/👤%20Emre-4A90E2?style=for-the-badge)
![Alim](https://img.shields.io/badge/👤%20Alim-9B59B6?style=for-the-badge)
 
---
 
## Architektur
 
 
### Komponenten
 
 
## Technologien
 
 
### AWS-Services
 
 
### Entwicklungstools
 
 
## Skript-Dokumentation
 
### install.ps1

### uninstall.ps1
 
 
## Netzwerk und Security Groups
 
### Webserver
 
### DB-Server
 
### Kommunikationsfluss
 
1. Benutzer greift via HTTP (Port 80) auf Webserver zu
2. Webserver verbindet sich via MySQL (Port 3306) zum DB-Server
3. Verbindung erfolgt über private IP-Adresse (interne Kommunikation)
 
---
 
## Datenbank-Konfiguration
 
## Troubleshooting
 
 
 