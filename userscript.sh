#!/usr/bin/with-contenv bash
# Install custom CA certificate if mounted
/install-ca.sh

export HOME=/config
export HILO_HOST=${HILO_HOST%%/}
ILO_VER="${ILO_VERSION:-2}"

SESSION_KEY=""
if [ "$ILO_VER" -ge 4 ]; then
    data="{\"method\":\"login\",\"user_login\":\"${HILO_USER}\",\"password\":\"${HILO_PASS}\"}"
    if [[ -n "${HILO_USER}" && -n "${HILO_PASS}" ]]; then
        echo "Attempting to login to ${HILO_HOST} (iLO 4+ API)..."
        RAW_RESPONSE=$(curl -k -s -S -X POST "${HILO_HOST}/json/login_session" -d "$data")
        echo "API Response: $RAW_RESPONSE"
        SESSION_KEY=$(echo "$RAW_RESPONSE" | grep -Eo '"session_key":"[^"]+' | sed 's/"session_key":"//')
    fi
else
    echo "ILO_VERSION is $ILO_VER. Skipping REST API auto-login."
fi

echo "SESSION_KEY=$SESSION_KEY"

# Determine which URL to open in Firefox
if [ -n "$SESSION_KEY" ]; then
    FF_URL="${HILO_HOST}/html/java_irc.html?sessionKey=${SESSION_KEY}"
else
    echo "No session key found (likely an older iLO). Falling back to main login page."
    FF_URL="${HILO_HOST}"
fi

# Initialize Firefox profile to inject certificate explicitly (fallback if policies.json fails)
FF_PROFILE_DIR="$HOME/.mozilla/firefox/default"
mkdir -p "$FF_PROFILE_DIR"

echo "Copying Firefox profiles.ini..."
cp /profiles.ini "$HOME/.mozilla/firefox/profiles.ini"

if [ ! -f "$FF_PROFILE_DIR/cert8.db" ]; then
    certutil -N -d "$FF_PROFILE_DIR" --empty-password
fi

if ls /app-data/*.crt >/dev/null 2>&1; then
    for cert in /app-data/*.crt; do
        cert_name=$(basename "$cert")
        echo "Adding $cert_name to Firefox NSS database..."
        certutil -A -n "$cert_name" -t "TCu,Cu,Tu" -i "$cert" -d "$FF_PROFILE_DIR" 2>/dev/null || true
        
        echo "Adding $cert_name to Java keystore..."
        /opt/java/jre/bin/keytool -import -trustcacerts -keystore /opt/java/jre/lib/security/cacerts -storepass changeit -noprompt -alias "$cert_name" -file "$cert" 2>/dev/null || true
    done
fi

# Fix permissions so the 'app' user can use the Firefox profile
chown -R ${USER_ID:-1000}:${GROUP_ID:-1000} "$HOME/.mozilla"

# Save the URL for startapp.sh
echo "$FF_URL" > /tmp/ff_url

