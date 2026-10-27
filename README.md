# Nido

*(nome provvisorio)*

Un sistema operativo leggero, libero e attento alla privacy, che usa il web come interfaccia, nello spirito di ChromeOS Flex. Pensato per ridare vita a computer vecchi e per essere distribuito liberamente.

## Com'è fatto

| Strato | Scelta | Perché |
|---|---|---|
| Base | Debian 13 "trixie" (amd64) | Stabile, libera, aggiornata per anni |
| Grafica | Cage (compositor Wayland "kiosk") | Mostra una sola app a schermo intero, pesa pochissimo |
| Browser | Firefox ESR + uBlock Origin | Pacchetti ufficiali Debian, policy di privacy bloccate |
| Interfaccia | Shell web locale (`/usr/share/nido/shell`) | Home con ricerca, app web, Wi-Fi, volume, spegnimento |
| Servizio di sistema | `nido-shell.py` (Python, solo libreria standard) | Collega la home a Wi-Fi, audio, batteria e alimentazione |

All'avvio: login automatico → Cage → Firefox, che apre la home su `http://127.0.0.1:8088`.

## Privacy, già attiva

- **Browser**: niente telemetria, studi, Pocket o account Mozilla; protezione antitracciamento rigorosa e bloccata; cookie di terze parti isolati; HTTPS-only; Global Privacy Control; ricerca predefinita DuckDuckGo; uBlock Origin preinstallato.
- **DNS cifrato** (DNS-over-TLS verso Quad9) per tutto il sistema.
- **Firewall** che blocca ogni connessione in ingresso.
- **MAC address casuale** durante la ricerca Wi-Fi e diverso per ogni rete; IPv6 con indirizzi temporanei; il nome del computer non viene comunicato al router.
- **Servizio locale protetto**: ascolta solo su 127.0.0.1, verifica Host e Origin e richiede un token generato a ogni avvio, così i siti web non possono comandare il sistema.
- Nessun font o script caricato da server esterni nella home.

## Come costruire l'ISO

### Opzione A – Con GitHub (consigliata se hai un Mac)

1. Crea un repository su GitHub e caricaci questa cartella.
2. Vai su **Actions → Costruisci ISO → Run workflow**.
3. Dopo circa 15–25 minuti scarichi `nido-iso` dagli artefatti della build.

### Opzione B – Su un computer o una VM Debian 13 amd64

```sh
sudo apt install live-build
./build.sh
```

Il risultato è `nido-amd64.iso`.

## Come provarlo

- **Su chiavetta USB**: scrivi l'ISO con balenaEtcher o `dd`, poi avvia il PC dalla chiavetta.
- **In macchina virtuale** (su Linux):
  ```sh
  qemu-system-x86_64 -m 2048 -enable-kvm -cdrom nido-amd64.iso
  ```
- **Su Mac**: con UTM, scegliendo "Emula" e architettura x86_64 (più lento, ma funziona per le prove).

Per sviluppare solo la home web, sul tuo computer basta:

```sh
NIDO_SHELL_DIR=config/includes.chroot/usr/share/nido/shell \
  python3 config/includes.chroot/usr/lib/nido/nido-shell.py
```

e aprire `http://127.0.0.1:8088` (Wi-Fi e volume risulteranno vuoti fuori da Nido).

## Struttura

```
auto/config                     opzioni di live-build
config/package-lists/           pacchetti installati
config/hooks/live/              script eseguiti durante la costruzione
config/includes.chroot/         file copiati così come sono nel sistema
  etc/firefox/policies/         policy di privacy del browser
  etc/nftables.conf             firewall
  etc/NetworkManager/conf.d/    privacy di rete
  etc/systemd/resolved.conf.d/  DNS cifrato
  usr/lib/nido/nido-shell.py    servizio locale
  usr/share/nido/shell/         interfaccia web (HTML/CSS/JS)
.github/workflows/              build automatica dell'ISO
```

## Limiti attuali (versione 0.1)

- Funziona **in modalità live**: le modifiche non restano dopo lo spegnimento. L'installazione su disco arriva nella Fase 4.
- Solo **PC a 64 bit** (amd64): Debian non supporta più l'installazione a 32 bit.
- Include **firmware non libero** (ramo `non-free-firmware`) per far funzionare Wi-Fi e schede video dei portatili più comuni. Va dichiarato chiaramente quando si distribuisce.
- Con il DNS cifrato rigoroso, le reti con pagina di accesso (hotel, treni) possono non aprirsi: vedi `90-nido-privacy.conf`.
- Non è ancora stato provato su hardware reale: la prima build serve proprio a scoprire cosa manca.

## Prossime fasi

1. ~~Prototipo avviabile~~ ← siamo qui
2. Prova su più PC vecchi, aggiunta di firmware e driver mancanti
3. Shell web più completa: impostazioni (lingua, tastiera, luminosità), gestione download, aggiornamenti
4. Installer su disco con cifratura completa (LUKS)
5. Aggiornamenti automatici e sistema di sola lettura con aggiornamenti A/B

## Licenza

Da scegliere prima della distribuzione pubblica. Suggerimento: **GPL-3.0** per il codice di Nido; i pacchetti Debian mantengono le proprie licenze (vedi `/usr/share/doc/*/copyright` nel sistema).
