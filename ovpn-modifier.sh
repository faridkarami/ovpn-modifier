#!/bin/bash

# Check if input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input-ovpn-file>"
    exit 1
fi

suffix="modified"
input_file="$1"

filename="${input_file%.*}"
extension="${input_file##*.}"

output_file="${filename}.$suffix.${extension}"

echo "Input file: $input_file"
echo "Output file: $output_file"

# Read the input file and make modifications
{
    echo "# Configuration"
    echo "client"
    echo "dev tun"
    echo "proto tcp-client"
    
    # Directly include the remote line from the original file
    awk '/^remote / {print $0}' "$input_file"

    # Directly include the port line from the original file
    awk '/^port / {print $0}' "$input_file"

    echo "nobind"
    echo "persist-key"
    echo "persist-tun"
    echo "tls-client"
    echo "remote-cert-tls server"
    echo "verb 4"
    echo "mute 10"

    # Modern ciphers and encryption
    echo "cipher AES-256-GCM"
    echo "ncp-ciphers AES-256-GCM:AES-128-GCM"
    echo "auth SHA256"

    # Authentication and security
    echo "auth-user-pass"
    echo "auth-nocache"
    echo "tls-version-min 1.2"
    echo "tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384"

    # Redirect traffic through VPN
    echo "redirect-gateway def1"

    echo ""

    # Extract and append original <ca>, <cert>, and <key> sections
    awk '/^<ca>/,/<\/ca>/ {print $0} /^<cert>/,/<\/cert>/ {print $0} /^<key>/,/<\/key>/ {print $0}' "$input_file"
} > "$output_file"

echo "Updated configuration saved to $output_file"