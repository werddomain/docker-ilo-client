#!/bin/sh
export HOME=/config

# Clean up stale Firefox lock files
find /config/.mozilla/firefox -name "lock" -delete 2>/dev/null
find /config/.mozilla/firefox -name ".parentlock" -delete 2>/dev/null

if [ -f /tmp/ff_url ]; then
    FF_URL=$(cat /tmp/ff_url)
else
    FF_URL="${HILO_HOST}"
fi

# Run firefox in an infinite loop
export MOZ_DISABLE_PANGO=1
export MOZ_CRASHREPORTER_DISABLE=1

# Ensure plugins directory exists and link the Java plugin
mkdir -p /config/.mozilla/plugins
ln -sf /opt/java/jre/lib/i386/libnpjp2.so /config/.mozilla/plugins/libnpjp2.so

while true; do
    # Clean up stale Firefox lock files before EVERY launch
    find /config/.mozilla/firefox -name "lock" -delete 2>/dev/null
    find /config/.mozilla/firefox -name ".parentlock" -delete 2>/dev/null

    /usr/bin/firefox "$FF_URL"
    
    # Firefox 2 forks to the background, so we must wait for its process manually
    while pgrep -x "firefox-bin" > /dev/null; do
        sleep 1
    done
    
    echo "Firefox closed. Restarting in 2 seconds..."
    sleep 2
done
