# Nextcloud auf AWS EC2 — Setup-Anleitung

![Emre](https://img.shields.io/badge/👤%20Emre-4A90E2?style=for-the-badge)
![Alim](https://img.shields.io/badge/👤%20Alim-9B59B6?style=for-the-badge)


##  Überblick

Diese Anleitung beschreibt die Schritte, um eine Nextcloud-Installation in der Amazon Web Services (AWS) Cloud bereitzustellen. Die Infrastruktur besteht aus zwei EC2-Instanzen: einem Webserver mit Apache2 und Nextcloud sowie einem separaten MariaDB-Datenbankserver. Alle notwendigen Konfigurationsdateien und Skripte befinden sich in diesem Repository.


## Inhaltsverzeichnis

- [Überblick](#überblick)
- [Voraussetzungen](#voraussetzungen)
- [Architektur](#architektur)
  - [Webserver (EC2)](#webserver-ec2)
  - [DB-Server (EC2)](#db-server-ec2)
  - [Netzwerk](#netzwerk)
- [Installation](#installation)
- [Repository Struktur](#repository-struktur)
  - [Root-Verzeichnis](#root-verzeichnis)
- [Funktion und Aufgabe der Scripts](#funktion-und-aufgabe-der-scripts)
  - [install.ps1](#installps1)
  - [uninstall.ps1](#uninstallps1)
- [Testfälle](#testfälle)
  - [Test 1: Installation der Nextcloud-Instanz](#test-1-installation-der-nextcloud-instanz)
  - [Test 2: Datenbankverbindung-mariadb](#test-2-datenbankverbindung-mariadb)
  - [Test 3: Nextcloud-Login-und-funktionalität](#test-3-nextcloud-login-und-funktionalität)
- [FAQ](#faq)
- [Reflexion](#reflexion)
  - [Emre](#emre)
  - [Alim](#alim)



##  Voraussetzungen

Bevor Sie starten, stellen Sie sicher, dass folgende Anforderungen erfüllt sind:

-   Ein AWS-Account mit administrativen Berechtigungen
-   AWS CLI ist installiert und konfiguriert
-   Git ist installiert
-   Ein Webbrowser für den Zugriff auf die Nextcloud-Instanz

##  Architektur

Die Infrastruktur besteht aus folgenden Komponenten:

### Webserver (EC2)

-   **Betriebssystem:** Ubuntu
-   **Webserver:** Apache2
-   **Anwendung:** Nextcloud
-   **Zugriff:** HTTP Port 80 (Internet Benutzer)

### DB-Server (EC2)

-   **Betriebssystem:** Ubuntu
-   **Datenbank:** MariaDB Server
-   **Port:** 3306
-   **Verbindung:** Interne IP (MySQL Connection)

### Netzwerk

-   **VPC:** AWS Cloud (VPC)
-   **Kommunikation:** Webserver → MariaDB über interne IP
-   **Externes Zugriff:** Nur über Webserver (HTTP Port 80)

##  Installation

##  Repository Struktur

###  Root-Verzeichnis

-   **install.ps1** - Zentrales Installationsskript
-   **uninstall.ps1** - Deinstallationsskript für alle 

##  Funktion und Aufgabe der Scripts

### install.ps1
### uninstall.ps1


##  Testfälle

### Test 1: Installation der Nextcloud-Instanz

**Testzeitpunkt:**

**Testperson:**

**Testbeschreibung:**

**Ergebnis:**

**Screenshot:**

**Fazit:**

----------

### Test 2: Datenbankverbindung (MariaDB)

**Testzeitpunkt:**

**Testperson:**

**Testbeschreibung:**

**Ergebnis:**

**Screenshot:**

**Fazit:**

----------

### Test 3: Nextcloud-Login und Funktionalität

**Testzeitpunkt:**

**Testperson:**

**Testbeschreibung:**

**Ergebnis:**

**Screenshot:**

**Fazit:**

##  FAQ

### Wie ändere ich die Konfiguration?

##  Reflexion

###  Emre

###  Alim