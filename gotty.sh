#!/bin/sh

rm -rf /var/lib/tor/hidden_service/*

echo "Starting tor ..."
echo > /etc/tor/log
tor -f /etc/tor/torrc | tee /etc/tor/log &

while ! grep -w 'Bootstrapped 100% (done): Done' /etc/tor/log  > /dev/null
do
    sleep 1
    echo ""
    sleep 1
done

USER="${TTY_USER:-ADMIN}"
PASS="${TTY_PASSWORD:-$(dd status=none if=/dev/urandom count=1 bs=16 | sha1sum | awk '{print $1}')}"
PORT="${TTY_PORT:-12345}"

echo USER: $USER
echo PASSWORD: $PASS
echo ONION ADRESS: http://$(cat /var/lib/tor/hidden_service/hostname):$PORT

gotty \
    --credential "${USER}:${PASS}" \
    --port ${PORT} --reconnect -w bash
