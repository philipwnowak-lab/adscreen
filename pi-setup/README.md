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

## Optionale Konfiguration

Vor dem Setup kann eine `config.env` Datei angelegt werden, um den Screen-Namen und weitere Einstellungen festzulegen:

```bash
cp config.env.example config.env
# config.env bearbeiten: SCREEN_NAME, SCREEN_LOCATION, TAILSCALE_AUTHKEY anpassen
```

Wenn keine `config.env` vorhanden ist, verwendet das Skript Standardwerte (`SCREEN_NAME=adscreen`, `ANTHIAS_PORT=8080`).

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
   ```text
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
