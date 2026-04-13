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
