# Adscreen — Design Spec

**Datum:** 2026-04-13  
**Status:** Genehmigt

---

## Überblick

Adscreen ist ein Digital-Signage-System für Schaufenster-Displays. Mehrere Monitore hängen an Raspberry Pis und zeigen rotierende Medien-Playlists (Fotos, Videos) an. Der Betreiber kann Inhalte jederzeit remote aktualisieren — ohne Vor-Ort-Zugang. Das System wird in zwei Phasen gebaut.

---

## Ziele

- Medien (Fotos, Videos) auf einem oder mehreren Screens anzeigen
- Playlists mit individuellen Anzeigedauern pro Asset konfigurieren
- Inhalte jederzeit remote aktualisieren, ohne physischen Zugang zum Pi
- Skalierbar von 2 auf viele Screens
- Später: individuelle Steuerung pro Screen von einem zentralen Dashboard

---

## Nicht-Ziele (vorerst)

- Keine Echtzeit-Statistiken oder Wiedergabe-Logs
- Kein Nutzer-Rechtesystem (Single-Operator)
- Kein öffentlich zugängliches Admin-Panel (nur über Tailscale erreichbar)

---

## Architektur

### Phase 1: Anthias pro Pi (eigenständig)

```
[Operator Laptop/PC]
     │ Tailscale VPN
     ▼
[Pi #1 — Anthias :8080]  ──→  [Monitor #1, Schaufenster]
[Pi #2 — Anthias :8080]  ──→  [Monitor #2, Schaufenster]
     ...
[Pi #n — Anthias :8080]  ──→  [Monitor #n]
```

Jeder Pi ist ein eigenständiges System. Anthias läuft als Docker-Container auf dem Pi und steuert Chromium im Kiosk-Modus. Inhalte werden direkt über die Anthias-Web-UI verwaltet.

Der Zugriff erfolgt ausschließlich über **Tailscale** — kein Port-Forwarding, kein öffentlicher Zugang nötig.

### Phase 2: Zentrales Adscreen Dashboard

```
[Adscreen Central Dashboard]
     │ Anthias REST API (über Tailscale)
     ├──→ Pi #1
     ├──→ Pi #2
     └──→ Pi #n
```

Eine eigene Web-Applikation aggregiert alle Pis und ermöglicht zentrales Management: Medien einmal hochladen, Playlists erstellen, auf beliebige Screens oder Screen-Gruppen pushen.

---

## Phase 1 — Anthias Setup

### Komponenten

| Komponente | Beschreibung |
|---|---|
| Raspberry Pi OS | Basis-Betriebssystem (64-bit Lite empfohlen) |
| Anthias | Open-Source Digital Signage, läuft als Docker-Container |
| Chromium | Wird von Anthias im Kiosk-Modus gesteuert |
| Tailscale | VPN für sicheren Remote-Zugriff |

### Pi-Setup pro Gerät

1. Raspberry Pi OS installieren
2. Tailscale installieren und authentifizieren (`tailscale up`)
3. Anthias über das offizielle Installer-Skript installieren
4. Anthias-Web-UI erreichbar unter `http://<tailscale-ip>:8080`
5. Autostart sicherstellen (Anthias und Chromium starten bei Boot automatisch)

### Inhalte verwalten (Phase 1 Workflow)

1. Browser öffnen → `http://<tailscale-ip-des-pi>:8080`
2. Medien hochladen (Foto oder Video per Web-UI)
3. Playlist erstellen: Reihenfolge festlegen, Anzeigedauer pro Asset in Sekunden
4. Playlist dem Screen zuweisen → sofortige Aktualisierung
5. Für jeden Pi separat wiederholen

### Unterstützte Medientypen

- Bilder: JPEG, PNG, GIF
- Videos: MP4 (H.264 empfohlen für Pi-Hardware-Dekodierung)
- Optional: Webseiten als Asset (URL)

---

## Phase 2 — Adscreen Central Dashboard

### Zweck

Ein zentrales Tool, das die Anthias-APIs aller Pis zusammenfasst. Der Operator hat eine einzige Oberfläche für alle Screens.

### Technologie-Stack (Vorschlag)

- **Frontend:** SvelteKit oder React
- **Backend:** Node.js (Express oder Fastify)
- **Datenhaltung:** SQLite (für Screen-Registry, Playlist-Zuordnungen)
- **Deployment:** Läuft lokal auf dem Operator-Laptop oder auf einem kleinen VPS

### Kernfunktionen

| Feature | Beschreibung |
|---|---|
| Screen-Registry | Liste aller Pis mit Name, Tailscale-IP, Standort |
| Media Library | Zentrales Medien-Upload, einmal hochladen — überall nutzbar |
| Playlist-Editor | Playlists erstellen, Reihenfolge und Dauer festlegen |
| Screen-Zuweisung | Playlist einem einzelnen Screen oder einer Screen-Gruppe zuweisen |
| Screen-Gruppen | Mehrere Screens gleichzeitig mit identischem Content bespielen |
| Status-Anzeige | Zeigt an, ob ein Pi erreichbar ist (Ping via Tailscale) |

### Anthias API-Integration

Anthias bietet eine REST-API. Das Dashboard nutzt diese API, um:
- Assets hochzuladen
- Playlists zu erstellen und zu bearbeiten
- Playlists Screens zuzuweisen

Die API-Aufrufe erfolgen über die jeweilige Tailscale-IP des Pi.

---

## Netzwerk & Sicherheit

- **Tailscale** wird auf allen Pis und dem Operator-Gerät installiert
- Die Anthias-Web-UI ist **nicht** öffentlich erreichbar — nur innerhalb des Tailscale-Netzwerks
- Kein Port-Forwarding am Router nötig
- Bei Ausfall der Internetverbindung läuft die zuletzt geladene Playlist weiter (lokale Wiedergabe)

---

## Skalierung

| Phase | Screens | Management |
|---|---|---|
| Phase 1 | 2–5 | Je Pi eine Anthias-URL |
| Phase 2 | 5+ | Zentrales Adscreen Dashboard |

Der Übergang von Phase 1 zu Phase 2 ist fließend — Anthias bleibt auf jedem Pi, nur die Steuerungsebene wird ergänzt.

---

## Projektstruktur (geplant)

```
Adscreen/
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-04-13-adscreen-design.md
├── pi-setup/
│   └── setup.sh          # Automatisiertes Setup-Skript für neue Pis
└── dashboard/            # Phase 2: Zentrale Web-App
    ├── frontend/
    └── backend/
```

---

## Offene Punkte (für Phase 2)

- Hosting-Entscheidung für das Dashboard (lokal vs. VPS)
- Authentifizierung für das Dashboard (Login oder IP-basiert über Tailscale)
- Medien-Synchronisation zwischen Dashboard und Pis (Push vs. Pull)
