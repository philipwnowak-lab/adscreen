# Adscreen Phase 1 — Pi Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ein automatisiertes Setup-Skript erstellen, das einen Raspberry Pi in ein funktionsfähiges Adscreen-Display verwandelt (Tailscale + Anthias), plus Projektdokumentation.

**Architecture:** Das Setup-Skript (`pi-setup/setup.sh`) wird auf einem frischen Raspberry Pi OS ausgeführt und installiert alle Abhängigkeiten (Docker, Tailscale, Anthias) in der richtigen Reihenfolge. Es ist idempotent — mehrfaches Ausführen schadet nicht. Jeder Pi wird einmal damit eingerichtet und ist danach über Tailscale erreichbar.

**Tech Stack:** Bash, Raspberry Pi OS (64-bit), Docker, Tailscale, Anthias

---

## Dateistruktur

```
Adscreen/
├── README.md                          # Projektübersicht + Schnellstart
├── pi-setup/
│   ├── setup.sh                       # Hauptskript: installiert alles auf dem Pi
│   ├── README.md                      # Detaillierte Pi-Setup-Anleitung
│   └── config.env.example             # Vorlage für Pi-spezifische Konfiguration
└── docs/
    └── superpowers/
        ├── specs/
        │   └── 2026-04-13-adscreen-design.md
        └── plans/
            └── 2026-04-13-phase1-pi-setup.md
```

---

## Vorbedingungen (manuell, vor Plan-Ausführung)

Diese Schritte werden einmalig auf dem Entwicklungsrechner erledigt, nicht durch das Skript:

1. Raspberry Pi OS 64-bit Lite auf SD-Karte flashen (via Raspberry Pi Imager)
2. SSH aktivieren (via Imager: Einstellungen → SSH aktivieren)
3. WLAN konfigurieren (via Imager: Einstellungen → WLAN)
4. Pi booten und SSH-Verbindung testen: `ssh pi@<lokale-ip>`

---

## Task 1: Projektstruktur und README anlegen

**Files:**
- Create: `README.md`
- Create: `pi-setup/README.md`
- Create: `pi-setup/config.env.example`

- [ ] **Step 1: Projekt-README erstellen**

Datei `README.md` anlegen:

```markdown
# Adscreen

Digital Signage System für Schaufenster-Displays.

## Überblick

Adscreen bespielt Monitore in Schaufenstern mit Fotos und Videos über
Raspberry Pis. Inhalte werden remote über Tailscale verwaltet.

## Komponenten

- **Phase 1:** Anthias auf jedem Pi — eigenständige Playlist-Verwaltung
- **Phase 2:** Zentrales Dashboard — alle Screens von einer Oberfläche

## Schnellstart

Neuen Pi einrichten:

```bash
ssh pi@<pi-ip>
curl -sSL https://raw.githubusercontent.com/philipwnowak-lab/adscreen/master/pi-setup/setup.sh | bash
```

Danach erreichbar unter: `http://<tailscale-ip>:8080`

## Dokumentation

- [Design-Spec](docs/superpowers/specs/2026-04-13-adscreen-design.md)
- [Pi-Setup-Anleitung](pi-setup/README.md)
```

- [ ] **Step 2: Pi-Setup-README erstellen**

Datei `pi-setup/README.md` anlegen:

```markdown
# Pi-Setup-Anleitung

## Voraussetzungen

- Raspberry Pi 3B+, 4, oder 5
- Raspberry Pi OS 64-bit (Lite oder Desktop)
- Internetverbindung (WLAN oder LAN)
- SSH-Zugriff auf den Pi

## Einmalige Vorbereitung (auf dem Pi)

1. Pi mit Raspberry Pi Imager flashen:
   - OS: Raspberry Pi OS (64-bit)
   - SSH aktivieren
   - WLAN konfigurieren
   - Hostname setzen (z.B. `adscreen-01`)

2. Pi booten, SSH verbinden:
   ```bash
   ssh pi@<lokale-ip>
   ```

## Automatisiertes Setup ausführen

```bash
curl -sSL https://raw.githubusercontent.com/philipwnowak-lab/adscreen/master/pi-setup/setup.sh | bash
```

Das Skript installiert:
- Docker + Docker Compose
- Tailscale (VPN)
- Anthias (Digital Signage)

Laufzeit: ca. 10–20 Minuten (je nach Pi-Modell und Internetgeschwindigkeit).

## Nach dem Setup

1. **Tailscale authentifizieren** (falls nicht via Auth-Key automatisiert):
   ```bash
   sudo tailscale up
   ```
   Den angezeigten Link im Browser öffnen und einloggen.

2. **Tailscale-IP herausfinden:**
   ```bash
   tailscale ip -4
   ```

3. **Anthias-UI aufrufen:**
   ```
   http://<tailscale-ip>:8080
   ```

## Inhalte verwalten

1. Anthias-UI öffnen: `http://<tailscale-ip>:8080`
2. Asset hochladen: "Add Asset" → Foto oder Video auswählen
3. Playlist anlegen: "Playlists" → Reihenfolge und Dauer pro Asset festlegen
4. Playlist aktivieren: dem Screen zuweisen

## Mehrere Pis

Jeden Pi separat einrichten. Die Tailscale-IPs für alle Pis notieren:

| Pi       | Hostname       | Tailscale-IP  | Standort        |
|----------|----------------|---------------|-----------------|
| Pi #1    | adscreen-01    | 100.x.x.x     | Schaufenster A  |
| Pi #2    | adscreen-02    | 100.x.x.x     | Schaufenster B  |

## Fehlerbehebung

**Anthias startet nicht:**
```bash
cd /home/pi/anthias && docker compose logs
```

**Tailscale nicht verbunden:**
```bash
tailscale status
sudo tailscale up
```

**Display bleibt schwarz:**
```bash
sudo systemctl status anthias-viewer
```
```

- [ ] **Step 3: Konfigurations-Vorlage erstellen**

Datei `pi-setup/config.env.example` anlegen:

```bash
# Adscreen Pi Konfiguration
# Kopieren nach config.env und anpassen

# Name dieses Displays (erscheint in Tailscale und später im Dashboard)
SCREEN_NAME="adscreen-01"

# Standortbeschreibung
SCREEN_LOCATION="Schaufenster A"

# Tailscale Auth-Key (optional — für unbeaufsichtigte Einrichtung)
# Erstellen unter: https://login.tailscale.com/admin/settings/keys
# Wenn leer: manuelle Authentifizierung nach Setup erforderlich
TAILSCALE_AUTHKEY=""

# Anthias Port (Standard: 8080)
ANTHIAS_PORT=8080
```

- [ ] **Step 4: Änderungen committen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add README.md pi-setup/README.md pi-setup/config.env.example
git commit -m "docs: add project README and pi-setup documentation"
git push
```

---

## Task 2: Pi-Setup-Skript — Grundstruktur

**Files:**
- Create: `pi-setup/setup.sh`

- [ ] **Step 1: Skript mit Grundstruktur anlegen**

Datei `pi-setup/setup.sh` erstellen:

```bash
#!/bin/bash
set -euo pipefail

# ============================================================
# Adscreen Pi Setup Script
# Installiert Docker, Tailscale und Anthias auf einem
# frischen Raspberry Pi OS (64-bit).
# Idempotent — mehrfaches Ausführen ist sicher.
# ============================================================

SCRIPT_VERSION="1.0.0"
ANTHIAS_BRANCH="master"

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# ============================================================
# Vorbedingungen prüfen
# ============================================================
check_prerequisites() {
    log_info "Prüfe Vorbedingungen..."

    # Muss auf einem Raspberry Pi laufen
    if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null && \
       ! grep -q "BCM" /proc/cpuinfo 2>/dev/null; then
        log_warn "Kein Raspberry Pi erkannt — Setup wird trotzdem fortgesetzt."
    fi

    # Muss als root oder via sudo laufen
    if [[ $EUID -ne 0 ]]; then
        log_error "Dieses Skript muss mit sudo ausgeführt werden."
        log_error "Ausführen mit: sudo bash setup.sh"
        exit 1
    fi

    # Internetverbindung prüfen
    if ! curl -s --max-time 5 https://google.com > /dev/null 2>&1; then
        log_error "Keine Internetverbindung. Bitte WLAN/LAN konfigurieren."
        exit 1
    fi

    log_success "Vorbedingungen erfüllt."
}

# ============================================================
# Konfiguration laden (falls config.env vorhanden)
# ============================================================
load_config() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_FILE="$SCRIPT_DIR/config.env"

    if [[ -f "$CONFIG_FILE" ]]; then
        log_info "Lade Konfiguration aus $CONFIG_FILE"
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    fi

    SCREEN_NAME="${SCREEN_NAME:-adscreen}"
    TAILSCALE_AUTHKEY="${TAILSCALE_AUTHKEY:-}"
    ANTHIAS_PORT="${ANTHIAS_PORT:-8080}"
}

# ============================================================
# Hauptprogramm
# ============================================================
main() {
    echo ""
    echo "=============================================="
    echo "  Adscreen Pi Setup v${SCRIPT_VERSION}"
    echo "=============================================="
    echo ""

    check_prerequisites
    load_config

    install_dependencies
    install_docker
    install_tailscale
    install_anthias
    configure_autostart

    print_summary
}

main "$@"
```

- [ ] **Step 2: Skript ausführbar machen und committen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
chmod +x pi-setup/setup.sh
git add pi-setup/setup.sh
git commit -m "feat: add pi setup script skeleton"
git push
```

---

## Task 3: Pi-Setup-Skript — Systemabhängigkeiten installieren

**Files:**
- Modify: `pi-setup/setup.sh` (Funktion `install_dependencies` hinzufügen)

- [ ] **Step 1: `install_dependencies` Funktion einfügen**

Vor der `main()`-Funktion in `setup.sh` einfügen:

```bash
# ============================================================
# System-Pakete aktualisieren und Basis-Tools installieren
# ============================================================
install_dependencies() {
    log_info "Aktualisiere System-Pakete..."

    apt-get update -qq
    apt-get upgrade -y -qq

    log_info "Installiere Basis-Tools..."
    apt-get install -y -qq \
        curl \
        wget \
        git \
        ca-certificates \
        gnupg \
        lsb-release \
        apt-transport-https \
        software-properties-common

    log_success "System-Pakete aktualisiert."
}
```

- [ ] **Step 2: Committen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add pi-setup/setup.sh
git commit -m "feat: add system dependency installation to setup script"
git push
```

---

## Task 4: Pi-Setup-Skript — Docker installieren

**Files:**
- Modify: `pi-setup/setup.sh` (Funktion `install_docker` hinzufügen)

Anthias läuft in Docker. Wir verwenden den offiziellen Docker-Installer, der idempotent ist.

- [ ] **Step 1: `install_docker` Funktion einfügen**

Vor der `main()`-Funktion in `setup.sh` einfügen:

```bash
# ============================================================
# Docker installieren (offizielle Installationsmethode)
# ============================================================
install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker bereits installiert ($(docker --version))."
        return
    fi

    log_info "Installiere Docker..."

    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh

    # Pi-Benutzer zur Docker-Gruppe hinzufügen (kein sudo nötig)
    SUDO_USER="${SUDO_USER:-pi}"
    if id "$SUDO_USER" &>/dev/null; then
        usermod -aG docker "$SUDO_USER"
        log_info "Benutzer '$SUDO_USER' zur Docker-Gruppe hinzugefügt."
    fi

    # Docker-Dienst aktivieren
    systemctl enable docker
    systemctl start docker

    log_success "Docker installiert ($(docker --version))."
}
```

- [ ] **Step 2: Committen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add pi-setup/setup.sh
git commit -m "feat: add Docker installation to setup script"
git push
```

---

## Task 5: Pi-Setup-Skript — Tailscale installieren

**Files:**
- Modify: `pi-setup/setup.sh` (Funktion `install_tailscale` hinzufügen)

- [ ] **Step 1: `install_tailscale` Funktion einfügen**

Vor der `main()`-Funktion in `setup.sh` einfügen:

```bash
# ============================================================
# Tailscale installieren und einrichten
# ============================================================
install_tailscale() {
    if command -v tailscale &> /dev/null; then
        log_success "Tailscale bereits installiert ($(tailscale version | head -1))."
    else
        log_info "Installiere Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh
        log_success "Tailscale installiert."
    fi

    # Tailscale-Dienst aktivieren
    systemctl enable tailscaled
    systemctl start tailscaled

    # Mit Auth-Key authentifizieren (falls gesetzt) oder manuelle Anleitung
    if [[ -n "${TAILSCALE_AUTHKEY:-}" ]]; then
        log_info "Authentifiziere Tailscale mit Auth-Key..."
        tailscale up --authkey="$TAILSCALE_AUTHKEY" --hostname="$SCREEN_NAME"
        log_success "Tailscale verbunden."
    else
        log_warn "Kein Tailscale Auth-Key gesetzt."
        log_warn "Nach dem Setup manuell authentifizieren mit: sudo tailscale up"
    fi
}
```

- [ ] **Step 2: Committen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add pi-setup/setup.sh
git commit -m "feat: add Tailscale installation to setup script"
git push
```

---

## Task 6: Pi-Setup-Skript — Anthias installieren

**Files:**
- Modify: `pi-setup/setup.sh` (Funktion `install_anthias` hinzufügen)

Anthias wird über das offizielle Installer-Skript installiert, das Docker Compose verwendet.

- [ ] **Step 1: `install_anthias` Funktion einfügen**

Vor der `main()`-Funktion in `setup.sh` einfügen:

```bash
# ============================================================
# Anthias installieren (Digital Signage)
# ============================================================
install_anthias() {
    ANTHIAS_DIR="/home/${SUDO_USER:-pi}/anthias"

    if [[ -d "$ANTHIAS_DIR" ]]; then
        log_success "Anthias bereits installiert unter $ANTHIAS_DIR."
        return
    fi

    log_info "Installiere Anthias — das kann 10–20 Minuten dauern..."

    # Anthias-Repository klonen
    SUDO_USER="${SUDO_USER:-pi}"
    sudo -u "$SUDO_USER" git clone \
        --branch "$ANTHIAS_BRANCH" \
        --depth 1 \
        https://github.com/Screenly/Anthias.git \
        "$ANTHIAS_DIR"

    # Anthias-Setup-Skript ausführen (Docker-basiert)
    cd "$ANTHIAS_DIR"
    sudo -u "$SUDO_USER" bash bin/install_standalone.sh

    log_success "Anthias installiert."
    log_info "Anthias läuft auf Port $ANTHIAS_PORT."
}
```

- [ ] **Step 2: Committen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add pi-setup/setup.sh
git commit -m "feat: add Anthias installation to setup script"
git push
```

---

## Task 7: Pi-Setup-Skript — Autostart und Abschluss

**Files:**
- Modify: `pi-setup/setup.sh` (Funktionen `configure_autostart` und `print_summary` hinzufügen)

- [ ] **Step 1: `configure_autostart` Funktion einfügen**

Vor der `main()`-Funktion in `setup.sh` einfügen:

```bash
# ============================================================
# Autostart sicherstellen — Pi zeigt Display direkt nach Boot
# ============================================================
configure_autostart() {
    log_info "Konfiguriere Autostart..."

    # Anthias-Dienste beim Boot starten
    ANTHIAS_DIR="/home/${SUDO_USER:-pi}/anthias"
    if [[ -f "$ANTHIAS_DIR/docker-compose.yml" ]]; then
        # Systemd-Service für Anthias Docker Compose anlegen
        cat > /etc/systemd/system/anthias.service << EOF
[Unit]
Description=Anthias Digital Signage
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$ANTHIAS_DIR
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=${SUDO_USER:-pi}

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable anthias.service
        log_success "Anthias Autostart konfiguriert."
    else
        log_warn "Anthias docker-compose.yml nicht gefunden — Autostart übersprungen."
    fi
}
```

- [ ] **Step 2: `print_summary` Funktion einfügen**

Direkt vor der `main()`-Funktion einfügen:

```bash
# ============================================================
# Abschluss-Zusammenfassung anzeigen
# ============================================================
print_summary() {
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "nicht verfügbar")

    echo ""
    echo "=============================================="
    echo "  Setup abgeschlossen!"
    echo "=============================================="
    echo ""
    echo "  Screen-Name:   ${SCREEN_NAME}"
    echo "  Tailscale-IP:  ${TAILSCALE_IP}"
    echo "  Anthias-UI:    http://${TAILSCALE_IP}:${ANTHIAS_PORT}"
    echo ""

    if [[ "$TAILSCALE_IP" == "nicht verfügbar" ]]; then
        echo "  HINWEIS: Tailscale noch nicht authentifiziert."
        echo "  Ausführen: sudo tailscale up"
        echo "  Danach die Tailscale-IP mit 'tailscale ip -4' abfragen."
    fi

    echo ""
    echo "  Nächste Schritte:"
    echo "  1. Tailscale authentifizieren (falls noch nicht geschehen)"
    echo "  2. Anthias-UI im Browser öffnen"
    echo "  3. Medien hochladen und Playlist erstellen"
    echo ""
    echo "  Dokumentation: https://github.com/philipwnowak-lab/adscreen"
    echo "=============================================="
}
```

- [ ] **Step 3: Finales Skript testen (auf dem Pi)**

Das Skript auf einem frischen Pi ausführen:

```bash
# Auf dem Pi:
sudo bash /tmp/setup.sh
```

Erwartete Ausgabe am Ende:
```
==============================================
  Setup abgeschlossen!
==============================================

  Screen-Name:   adscreen-01
  Tailscale-IP:  100.x.x.x
  Anthias-UI:    http://100.x.x.x:8080
...
```

- [ ] **Step 4: Finales Commit und Push**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add pi-setup/setup.sh
git commit -m "feat: add autostart config and setup summary to setup script"
git push
```

---

## Task 8: Anthias-Konfiguration dokumentieren — Erster Screen einrichten

**Files:**
- Modify: `pi-setup/README.md` (Abschnitt "Ersten Content einrichten" ergänzen)

Dieser Task dokumentiert den Workflow für den ersten echten Einsatz — damit du weißt, welche Schritte in der Anthias-UI nötig sind.

- [ ] **Step 1: Abschnitt in pi-setup/README.md ergänzen**

Am Ende der Datei `pi-setup/README.md` anfügen:

```markdown
## Ersten Content einrichten (Schritt-für-Schritt)

### 1. Anthias-UI öffnen

Browser öffnen: `http://<tailscale-ip>:8080`

### 2. Asset hochladen

- "Assets" → "Add Asset" klicken
- Typ wählen: "Image" (JPG/PNG) oder "Video" (MP4)
- Datei auswählen und hochladen
- Dauer festlegen: z.B. 30 Sekunden für ein Bild

Für Videos wird die Dauer automatisch erkannt.

### 3. Playlist erstellen

- In Anthias werden Assets direkt dem aktiven Schedule zugewiesen
- Bei jedem Asset: Zeitplan "Always" aktivieren → Asset rotiert automatisch
- Reihenfolge per Drag & Drop anpassen

### 4. Display-Modus

Anthias öffnet Chromium automatisch im Vollbild-Kiosk-Modus nach dem Boot.
Änderungen in der UI werden innerhalb von 60 Sekunden auf dem Display wirksam.

### 5. Empfohlene Videoformate

Für beste Performance auf dem Raspberry Pi:
- Container: MP4
- Codec: H.264 (wird durch Hardware beschleunigt)
- Auflösung: 1920×1080 (Full HD)
- Bitrate: max. 8 Mbit/s für Pi 4, max. 4 Mbit/s für Pi 3
```

- [ ] **Step 2: Committen und pushen**

```bash
cd /home/philip/Projekte/Coding/Adscreen
git add pi-setup/README.md
git commit -m "docs: add first content setup guide to pi-setup README"
git push
```

---

## Nächste Phase

Nach Abschluss dieses Plans ist Phase 1 vollständig:
- Jeder neue Pi kann mit einem Befehl eingerichtet werden
- Anthias läuft und ist über Tailscale erreichbar
- Playlists können über die Anthias-Web-UI verwaltet werden

**Phase 2 (separater Plan):** Adscreen Central Dashboard — eine Web-App, die alle Pis von einer zentralen Oberfläche aus steuert.
