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
