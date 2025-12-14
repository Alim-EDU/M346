
## Altes Skript Analyse


#### **Stärken des alten Skripts:**

1.  **Klare Struktur** - Gut lesbar und nachvollziehbar
2.  **Automatisierung** - Alles in einem Skript
3.  **Fehlerbehandlung** - Wartet auf Instanz-Status
4.  **User-Data** - Cloud-Init wird korrekt verwendet
5.  **IP-Verwaltung** - Holt automatisch Public IP
6.  **SSH-Integration** - Automatische SSH-Verbindung

#### **Schwächen des alten Skripts:**

1.  **Keine Wiederverwendbarkeit** - Security Groups werden immer neu erstellt
2.  **Keine Fehlerprüfung** - Wenn SG existiert, bricht Skript ab
3.  **Ein-Server-Architektur** - Nur für einzelne Instanz ausgelegt
4.  **Keine Datenbank-Integration** - Keine DB-Server Unterstützung
5.  **Fehlende Logs** - Keine Deployment-Dokumentation

#### **Lessons Learned:**

1. Security Groups sollten wiederverwendbar sein
2. Fehlerbehandlung muss robuster werden
3. Logs müssen automatisch erstellt werden
4. Skript muss für Multi-Server ausgelegt sein
5. Private IPs für Server-zu-Server Kommunikation

---

## Security Group Konfiguration

### Aus altem Skript übernommen und erweitert:

#### **Webserver Security Group**

```
Name: nextcloud-web-sg
Description: "Security Group für Nextcloud Webserver"

Inbound Rules:
┌──────┬─────────┬─────────────┬────────────────┐
│ Type │  Port   │  Protocol   │    Source      │
├──────┼─────────┼─────────────┼────────────────┤
│ HTTP │   80    │     TCP     │   0.0.0.0/0    │
│ SSH  │   22    │     TCP     │   0.0.0.0/0    │
└──────┴─────────┴─────────────┴────────────────┘
```

**Begründung:**

-   Port 80: Nextcloud muss öffentlich erreichbar sein
-   Port 22: SSH für Administration und Testing

#### **DB-Server Security Group**

```
Name: nextcloud-db-sg
Description: "Security Group für MariaDB Server"

Inbound Rules:
┌──────┬─────────┬─────────────┬────────────────────┐
│ Type │  Port   │  Protocol   │      Source        │
├──────┼─────────┼─────────────┼────────────────────┤
│ MySQL│  3306   │     TCP     │  nextcloud-web-sg  │
│ SSH  │   22    │     TCP     │    0.0.0.0/0       │
└──────┴─────────┴─────────────┴────────────────────┘
```

**Begründung:**

-   Port 3306: Nur vom Webserver erreichbar
-   Port 22: SSH für Administration und Testing
-   Keine öffentliche Datenbank-Verbindung möglich