# Adscreen Pi Setup

Schritt-für-Schritt-Anleitung für einen neuen Adscreen-Pi (Raspberry Pi 4 oder 400).

---

## Schritt 1 — SD-Karte flashen

Mit **Raspberry Pi Imager** (https://rptl.io/imager):

| Einstellung        | Wert                                        |
|--------------------|---------------------------------------------|
| Gerät              | Raspberry Pi 4 / 400                        |
| OS                 | **Raspberry Pi OS Lite (64-bit)**           |
| SSH                | Aktivieren → Passwort-Authentifizierung     |
| Benutzername       | `pnowi`                                     |
| Passwort           | (eigenes wählen)                            |
| Hostname           | `adscreen-01` (oder `adscreen-02`, etc.)    |
| WLAN               | SSID + Passwort eintragen (falls kein LAN)  |

> **Wichtig:** Unbedingt 64-bit OS — 32-bit wird von Anthias nicht unterstützt.

---

## Schritt 2 — Pi booten & SSH verbinden

```bash
ssh pnowi@adscreen-01.local
```

Falls `.local` nicht auflöst: IP-Adresse im Router nachschauen.

---

## Schritt 3 — config.env anlegen

Auf dem Pi:

```bash
curl -sSL https://raw.githubusercontent.com/philipwnowak-lab/adscreen/master/pi-setup/config.env.example -o config.env
nano config.env
```

Folgende Werte anpassen:

```bash
SCREEN_NAME=adscreen-01          # eindeutiger Name
TAILSCALE_AUTHKEY=tskey-auth-... # aus https://login.tailscale.com/admin/settings/keys
```

Den Tailscale Auth-Key einmalig verwenden (Reusable aktivieren für mehrere Pis).

---

## Schritt 4 — Setup-Script ausführen

```bash
curl -sSL https://raw.githubusercontent.com/philipwnowak-lab/adscreen/master/pi-setup/setup.sh -o setup.sh
sudo bash setup.sh
```

Das Script installiert: Docker, Tailscale (inkl. Authentifizierung), klont Anthias.

Laufzeit: **~2 Minuten**

Am Ende zeigt es Anweisungen für Schritt 5.

---

## Schritt 5 — Anthias installieren (interaktiv)

```bash
bash ~/anthias/bin/install.sh
```

Im Installer auswählen:

| Prompt             | Auswahl          |
|--------------------|------------------|
| Branch/Tag         | `master` (latest)|
| System Upgrade     | Yes              |
| Manage Network     | No               |

Laufzeit: **~15–25 Minuten** (lädt Docker Images).

Am Ende: **Reboot bestätigen** → Pi startet neu.

---

## Schritt 6 — Anthias aufrufen

Nach dem Reboot (~1–2 Minuten warten):

```
http://<tailscale-ip>:8080
```

Tailscale-IP herausfinden:
```bash
ssh pnowi@adscreen-01.local "tailscale ip -4"
```

---

## Inhalte verwalten

1. Anthias-UI öffnen: `http://<tailscale-ip>:8080`
2. **Asset hochladen**: "Assets" → "Add Asset" → Bild (JPG/PNG) oder Video (MP4)
3. **Zeitplan**: bei jedem Asset "Always" aktivieren → rotiert automatisch
4. Reihenfolge per Drag & Drop

Änderungen werden **innerhalb 60 Sekunden** auf dem Display wirksam.

### Empfohlene Videoformate

| Format     | Empfehlung                   |
|------------|------------------------------|
| Container  | MP4                          |
| Codec      | H.264                        |
| Auflösung  | 1920×1080                    |
| Bitrate    | max. 8 Mbit/s                |

---

## Mehrere Pis

Schritte 1–6 für jeden Pi wiederholen. Hostname hochzählen: `adscreen-02`, `adscreen-03`, etc.

| Pi    | Hostname      | Tailscale-IP | Standort       |
|-------|---------------|--------------|----------------|
| Pi #1 | adscreen-01   | 100.x.x.x    | Schaufenster A |
| Pi #2 | adscreen-02   | 100.x.x.x    | Schaufenster B |

---

## Fehlerbehebung

**Script bricht mit "64-bit erforderlich" ab:**
→ OS neu flashen, Raspberry Pi OS Lite **(64-bit)** wählen.

**Tailscale Auth-Key ungültig:**
→ Neuen Key erstellen: https://login.tailscale.com/admin/settings/keys  
→ In `config.env` eintragen, Script erneut ausführen.

**Anthias startet nach Reboot nicht:**
```bash
cd ~/anthias && docker compose logs --tail=50
```

**Tailscale nicht verbunden:**
```bash
tailscale status
sudo tailscale up
```

**Display bleibt schwarz:**
```bash
sudo systemctl status splashscreen.service
sudo systemctl status anthias-viewer.service
```
