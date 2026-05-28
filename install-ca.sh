#!/bin/bash
# Install custom CA certificates if present in /app-data/
CA_DIR="/app-data"
CA_DEST_DIR="/usr/local/share/ca-certificates"

if ls "$CA_DIR"/*.crt >/dev/null 2>&1; then
    echo "Installing custom CA certificates from $CA_DIR..."
    cp "$CA_DIR"/*.crt "$CA_DEST_DIR/"
    update-ca-certificates
    echo "Custom CA certificates installed successfully."
else
    echo "No custom CA certificates (*.crt) found in $CA_DIR, skipping."
fi
