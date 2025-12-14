# Aufgabenverteilung - M346 Nextcloud Projekt

## Alims Aufgaben

### Phase 1: Vorbereitung

- [x] GitHub Repository erstellen

### Phase 2: Skript-Entwicklung

- [x] Alte Skripte aus vorherigen Projekten sammeln
- [x] Alte Skripte analysieren
- [ ] Basis-Struktur für neues Deployment-Skript erstellen
- [x] Security Group Konfiguration aus alten Skripten übernehmen
- [ ] EC2-Instanz Parameter definieren (Instance Type, AMI, etc.)
- [ ] Skripte auf Syntax-Fehler prüfen
- [ ] Skripte committen mit klarer Commit-Message

### Phase 3: Deployment & Testing

- [ ] EC2-Instanzen mit Skript deployen
- [ ] Deployment-Logs speichern
- [ ] Öffentliche IP-Adressen notieren
- [ ] SSH-Verbindung zum Web-Server testen
- [ ] SSH-Verbindung zum DB-Server testen
- [ ] DB-Server Konnektivität prüfen
- [ ] Nextcloud-Verzeichnisse auf Web-Server überprüfen
- [ ] Apache-Status auf Web-Server checken
- [ ] MySQL-Status auf DB-Server checken
- [ ] Firewall-Regeln zwischen Servern testen
- [ ] Bei Problemen: Logs analysieren
- [ ] Bei Problemen: Fehler dokumentieren und beheben
- [ ] Deployment-Skript nach Fixes aktualisieren
- [ ] Screenshot von laufenden EC2-Instanzen machen

### Phase 4: Finalisierung

- [ ] Finale Code-Review durchführen
- [ ] Alle Skripte auf Best Practices prüfen
- [ ] Persönliche Reflexion schreiben (Was gelernt? Herausforderungen?)
- [ ] Quellen für verwendete Tutorials/Dokumentationen hinzufügen
- [ ] README.md formatieren und auf Lesbarkeit prüfen
- [ ] Rechtschreibung in allen Dokumenten prüfen
- [ ] Finalen Commit mit aussagekräftiger Message pushen
- [ ] Mit Emre gemeinsame Abschluss-Review machen

---

## Emres Aufgaben

### Phase 1: Vorbereitung

- [x] Bewertungskriterien aus Aufgabenstellung durchlesen
- [ ] Dokumentations-Template vorbereiten (docs/tests.md)
- [x] Screenshot-Ordner anlegen (docs/images/)
- [ ] Checkliste für Tests erstellen
- [x] Ersten Test-Commit machen (README.md bearbeiten)
- [x] Konzept Architektur-Diagramm erstellen/einfügen
- [x] README.md Grundstruktur erstellen

### Phase 2: Dokumentation während Entwicklung

- [x] Projekt-Übersicht in README.md schreiben
- [x] Ziel des Projekts beschreiben
- [x] Verwendete Technologien auflisten
- [x] Voraussetzungen dokumentieren (AWS Account, CLI, etc.)
- [x] Erste Version committen
- [ ] Entwicklungs-Prozess in eigenen Worten beschreiben
- [ ] Fragen zu unklaren Schritten stellen und dokumentieren
- [ ] Zwischenstände committen

### Phase 3: Installation & Tests

- [ ] Screenshots vom Deployment-Prozess machen
- [ ] Nextcloud IP-Adresse im Browser öffnen
- [ ] Screenshot: Nextcloud Willkommensseite
- [ ] Admin-Konto in Nextcloud erstellen
- [ ] Screenshot: Installationsassistent Schritt 1
- [ ] Datenbank-Verbindung konfigurieren
- [ ] Screenshot: Installationsassistent Schritt 2
- [ ] Installation abschliessen
- [ ] Screenshot: Erfolgsmeldung
- [ ] Screenshot: Nextcloud Dashboard
- [ ] Testfall 1: Benutzer anlegen und dokumentieren
- [ ] Testfall 2: Datei hochladen und dokumentieren
- [ ] Testfall 3: Ordner erstellen und dokumentieren
- [ ] Alle Screenshots umbenennen und in docs/images/ ablegen

### Phase 4: Erweiterte Tests & Dokumentation

- [ ] Testfall 4: Datei teilen mit anderem Benutzer
- [ ] Testfall 5: Kalender-App testen
- [ ] Testfall 6: Kontakte-App testen
- [ ] Testfall 7: Dateien synchronisieren (Desktop-Client optional)
- [ ] Testfall 8: Mobile Ansicht testen
- [ ] docs/tests.md vollständig ausfüllen mit allen Ergebnissen
- [ ] Jeder Test: Beschreibung, Schritte, Erwartung, Ergebnis
- [ ] Bei jedem Test: Screenshot-Referenz einfügen
- [ ] Probleme und Lösungen dokumentieren
- [ ] Tests committen mit klarer Commit-Message

### Phase 5: Dokumentation

- [ ] README.md Struktur planen
- [ ] Deployment-Anleitung in README schreiben
- [ ] PowerShell-Skripte Schritt für Schritt dokumentieren
- [ ] Verwendete AWS-Services beschreiben
- [ ] Security-Gruppen Konfiguration dokumentieren
- [ ] Troubleshooting-Tipps hinzufügen
- [ ] Code-Kommentare in Skripte einfügen
- [ ] Technische Details zu EC2-Instanzen dokumentieren
- [ ] Netzwerk-Architektur erklären

### Phase 6: Finalisierung

- [ ] Alle Screenshots nochmal auf Qualität prüfen
- [ ] Screenshot-Namen auf Konsistenz prüfen
- [ ] docs/tests.md formatieren und lesbar machen
- [ ] Quellen für Nextcloud-Dokumentation hinzufügen
- [ ] Persönliche Reflexion schreiben (Was gelernt? Schwierigkeiten?)
- [ ] Testdokumentation auf Vollständigkeit prüfen
- [ ] Rechtschreibung in allen Dokumenten prüfen
- [ ] Finalen Commit pushen
- [ ] Mit Alim gemeinsame Abschluss-Review machen

---

## Gemeinsame Aufgaben

### Vor jeder Lektion

- [ ] Kurzes Standup (5 Min): Was machen wir heute?
- [ ] GitHub Pull: Neueste Änderungen holen

### Nach jeder Lektion

- [ ] Kurzes Review (5 Min): Was haben wir geschafft?
- [ ] Changes committen und pushen
- [ ] Notizen für nächste Lektion machen

### Vor Abgabe - Finale Checkliste

- [ ] **GitHub Desktop:** Keine uncommitted changes
- [ ] **GitHub Desktop:** Mindestens 8-12 Commits sichtbar
- [ ] **GitHub Desktop:** Commits von beiden Personen vorhanden
- [ ] **GitHub.com:** Alle Dateien sind online
- [ ] **GitHub.com:** README.md wird korrekt angezeigt
- [ ] **GitHub.com:** Screenshots sind sichtbar
- [ ] **GitHub.com:** Lehrperson hat Zugriff auf Repository
- [ ] **Dokumentation:** README.md vollständig
- [ ] **Dokumentation:** Alle Tests dokumentiert 
- [ ] **Dokumentation:** Reflexion von beiden Personen
- [ ] **Dokumentation:** Quellen angegeben
- [ ] **Dokumentation:** Rechtschreibung geprüft
- [ ] **AWS:** Screenshots vom laufenden System vorhanden
- [ ] **AWS:** Nach Tests: Ressourcen gelöscht