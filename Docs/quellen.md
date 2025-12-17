<<<<<<< HEAD
# Projekt: Automatisierte Nextcloud-Infrastruktur auf AWS

In diesem Projekt haben wir eine Nextcloud-Umgebung in der AWS-Cloud aufgebaut. Die gesamte Infrastruktur wurde mit PowerShell-Skripten erstellt.

## Team-Reflexion

### Alim
**Meine Schwerpunkte:**
Ich war für die Skripte verantwortlich. Mein Ziel war eine einfache Installation von Webserver, Datenbank und Nextcloud.

**Lernerfahrungen:**
* Es war spannend zu sehen, wie viele Schritte in einem Skript zusammenkommen.
* Kleine Fehler in der Konfiguration können die Automatisierung sofort stoppen.
* Die Kommunikation zwischen Webserver und Datenbank war eine grosse Aufgabe.

**Herausforderung Zeit:**
Wir hatten ein grosses Problem mit der Zeit. Die Planung war am Anfang nicht gut genug. Deshalb wurde es am Ende sehr hektisch.

**Zukünftige Verbesserungen:**
* Ich würde die Skripte modularer bauen.
* Ein besseres Logging würde die Fehlersuche erleichtern.
* Ich werde die Zeit für die Arbeit früher und besser planen.

---

### Emre
**Meine Schwerpunkte:**
Ich habe die Skripte geprüft und dokumentiert. So bleibt der Aufbau für andere klar.

**Lernerfahrungen:**
* Gemeinsam mit Alim habe ich Fehler bei der Verbindung gesucht.
* Die Einstellungen der Security Groups in AWS waren sehr wichtig.
* Ich habe gelernt: Man braucht für jede Änderung einen Test.

**Herausforderung Zeit:**
Unsere Zeitplanung war leider schlecht. Wir haben am Anfang zu viel Zeit verloren. Das war ein grosser Fehler im Projekt.

**Zukünftige Verbesserungen:**
* Ich möchte früher eine Struktur für Dokumente und Tests festlegen.
* Mehr Zeit für die Recherche von Sicherheit wäre gut.
* Wir müssen die Aufgaben im Team früher verteilen, damit kein Zeitdruck entsteht.

---

## Fazit
Die Zusammenarbeit im Team war gut, aber die Zeitplanung war ein Problem. Wir haben gelernt, dass eine gute Vorbereitung und Automatisierung die Basis für Erfolg sind.
=======
# Quellenverzeichnis

## AWS Nextcloud 2-Server Deployment Scripts
*PowerShell-basierte Automatisierung für AWS EC2*

---

## Verwendete Technologien und Dokumentationen

### Cloud-Infrastruktur
- **Amazon Web Services (AWS) EC2**  
  AWS Documentation: EC2 User Guide  
  https://docs.aws.amazon.com/ec2/  
  *Verwendung: Virtuelle Server-Instanzen, Security Groups, Key Pairs*

- **AWS CLI (Command Line Interface)**  
  AWS CLI Command Reference  
  https://docs.aws.amazon.com/cli/  
  *Verwendung: Automatisierte Ressourcenverwaltung via PowerShell*

### Server-Software

- **Nextcloud Server**  
  Nextcloud Documentation  
  https://docs.nextcloud.com/  
  *Version: Latest (Download-Link im Script)*  
  *Verwendung: Self-Hosted Cloud-Plattform*

- **Apache HTTP Server**  
  Apache HTTP Server Documentation  
  https://httpd.apache.org/docs/  
  *Verwendung: Webserver für Nextcloud*

- **MariaDB**  
  MariaDB Knowledge Base  
  https://mariadb.com/kb/  
  *Verwendung: Relationale Datenbank für Nextcloud*

- **PHP**  
  PHP Documentation  
  https://www.php.net/docs.php  
  *Verwendung: Server-seitige Scriptsprache für Nextcloud*

### Betriebssystem

- **Ubuntu Linux**  
  Ubuntu Server Documentation  
  https://ubuntu.com/server/docs  
  *AMI: ami-08c40ec9ead489470*  
  *Verwendung: Basis-Betriebssystem für beide EC2-Instanzen*

### Scripting & Automatisierung

- **PowerShell**  
  Microsoft PowerShell Documentation  
  https://learn.microsoft.com/powershell/  
  *Verwendung: Deployment- und Cleanup-Automatisierung*

---

## Script-Komponenten und Referenzen

### install.ps1 - Deployment Script

**Verwendete AWS CLI Befehle:**
- `aws ec2 create-key-pair` - SSH-Schlüssel erstellen
- `aws ec2 create-security-group` - Firewall-Regeln definieren
- `aws ec2 authorize-security-group-ingress` - Port-Freigaben
- `aws ec2 run-instances` - EC2-Instanzen starten
- `aws ec2 describe-instances` - Instanz-Informationen abrufen
- `aws ec2 wait instance-running` - Status-Überwachung

**Konfigurierte Ports und Protokolle:**
- Port 80 (HTTP) - Nextcloud Web-Interface
- Port 22 (SSH) - Server-Administration
- Port 3306 (MySQL) - Datenbank-Kommunikation

### uninstall.ps1 - Cleanup Script

**Verwendete AWS CLI Befehle:**
- `aws ec2 terminate-instances` - Instanzen beenden
- `aws ec2 wait instance-terminated` - Terminierung abwarten
- `aws ec2 delete-security-group` - Security Groups löschen
- `aws ec2 delete-key-pair` - SSH-Schlüssel entfernen

---

## Externe Ressourcen

### Downloads
- **Nextcloud Server:**  
  https://download.nextcloud.com/server/releases/latest.zip

### CDN & Repositories
- **Cloudflare CDN:**  
  https://cdnjs.cloudflare.com  
  *Potenzielle Verwendung für externe Bibliotheken*

---

## Sicherheitshinweise

Die in den Scripts verwendeten Passwörter dienen ausschliesslich Demonstrations- und Testzwecken:
- `Nextcloud2024!Secure` - Nextcloud DB-Benutzer
- `RootPass2024!Secure` - MariaDB Root-Benutzer

**⚠️ WICHTIG:** Diese Passwörter sind öffentlich und dürfen NICHT in Produktionsumgebungen verwendet werden!

---

## Best Practices und Referenzen

### AWS Security Best Practices
- AWS Security Best Practices Whitepaper  
  https://aws.amazon.com/security/best-practices/

### Nextcloud Installation Best Practices
- Nextcloud Administration Manual  
  https://docs.nextcloud.com/server/latest/admin_manual/

---

## Entwicklungsumgebung

- **Entwicklungsplattform:** Windows PowerShell 5.1+
- **Cloud-Provider:** Amazon Web Services (AWS)
- **Region:** Variable (abhängig von AWS CLI Konfiguration)
- **Instance Types:**
  - Webserver: t2.small (2 vCPUs, 2 GB RAM)
  - DB-Server: t2.micro (1 vCPU, 1 GB RAM)

---

## Zusätzliche Hilfsmittel

### Code-Verbesserung und Dokumentation

Für die Verbesserung der Code-Struktur, Lesbarkeit und die Erstellung dieser Dokumentation wurde **Claude** (Anthropic) verwendet:

- Optimierung der PowerShell-Script-Formatierung
- Verbesserung der Fehlerbehandlung und Logging-Funktionen
- Erstellung von visuellen Fortschrittsanzeigen (Box-Drawing-Characters)
- Strukturierung und Dokumentation des Codes
- Erstellung dieses Quellenverzeichnisses

**Claude by Anthropic**  
https://www.anthropic.com/claude  
*KI-Assistent für Code-Analyse, -Optimierung und technische Dokumentation*

---

*Stand: Dezember 2024*  
*Erstellt für Bildungs- und Demonstrationszwecke*
>>>>>>> 62e9008bab64f19a96b5813d5f760a779672c147
