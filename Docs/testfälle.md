# Testdokumentation - M346 Nextcloud auf AWS

  

## Übersicht

  

Diese Dokumentation enthält alle durchgeführten Tests zur Validierung der Nextcloud-Installation auf AWS EC2.

  

---

  

## Test 1: Deployment der EC2-Instanzen

  

### Testinformationen

  



Testzeitpunkt:

Testperson:


  

### Testbeschreibung

  

Ausführung des `install.ps1` Skripts zur automatisierten Erstellung der beiden EC2-Instanzen (Webserver und DB-Server).

  

### Erwartetes Ergebnis

  

- Zwei EC2-Instanzen werden erstellt

- Beide Instanzen sind im Status "running"

- Public IP-Adressen werden angezeigt

- Keine Fehlermeldungen im Skript

  

### Tatsächliches Ergebnis

  



  

### Screenshot

  

  



  

### Fazit

  



  

---

  

## Test 2: Datenbankverbindung (MariaDB)

  

### Testinformationen

  


Testzeitpunkt: 

Testperson:

  

### Testbeschreibung

  

Überprüfung der MariaDB-Installation und Erreichbarkeit vom Webserver aus.

  

### Testschritte

  

1. SSH-Verbindung zum DB-Server herstellen

2. MariaDB-Status prüfen: `sudo systemctl status mariadb`

3. Datenbank-Verbindung testen: `mysql -u nextcloud -p -h localhost`

4. Nextcloud-Datenbank prüfen: `SHOW DATABASES;`

  

### Erwartetes Ergebnis

  

- MariaDB läuft (active/running)

- Benutzer "nextcloud" kann sich anmelden

- Datenbank "nextcloud" existiert

  

### Tatsächliches Ergebnis

  



  

### Screenshot

  



  



  

### Fazit

  



  

---

  


## Test 3: Nextcloud Login und Funktionalität

  

### Testinformationen

  



Testzeitpunkt:

Testperson:

  

### Testbeschreibung

  

Anmeldung mit dem erstellten Admin-Konto und Test der Grundfunktionen.

  

### Testschritte

  

1. Login mit Admin-Zugangsdaten

2. Dashboard wird angezeigt

3. Neue Datei hochladen

4. Neuen Ordner erstellen

5. Datei herunterladen

  

### Erwartetes Ergebnis

  

- Erfolgreicher Login

- Dashboard wird korrekt angezeigt

- Datei-Upload funktioniert

- Ordner-Erstellung funktioniert

- Download funktioniert

  

### Tatsächliches Ergebnis

  



  

### Screenshots

  



  

### Fazit

  



  

---

  

## Test 4: Cleanup-Skript

  

### Testinformationen

  

Testzeitpunkt:

Testperson:


  

### Testbeschreibung

  

Ausführung des `uninstall.ps1` Skripts zur Bereinigung aller AWS-Ressourcen.

  

### Erwartetes Ergebnis

  

- Alle EC2-Instanzen werden terminiert

- Security Groups werden gelöscht

- Key Pairs werden entfernt

- AWS Console zeigt keine Ressourcen mehr

  

### Tatsächliches Ergebnis

  



  

### Screenshot

  



  

### Fazit

  



  

---

  


 