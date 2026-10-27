# Sul primo terminale avvia l'interfaccia grafica di Nido.
# Se il browser viene chiuso, la sessione si chiude e il login automatico la riapre.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec cage -s -- /usr/local/bin/nido-session
fi
