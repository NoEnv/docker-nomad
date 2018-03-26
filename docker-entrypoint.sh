#!/usr/bin/dumb-init /bin/sh
set -e

NOMAD_BIND=
if [ -n "$NOMAD_BIND_INTERFACE" ]; then
  NOMAD_BIND_ADDRESS=$(ip -o -4 addr list $NOMAD_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$NOMAD_BIND_ADDRESS" ]; then
    echo "Could not find IP for interface '$NOMAD_BIND_INTERFACE', exiting"
    exit 1
  fi

  NOMAD_BIND="-bind=$NOMAD_BIND_ADDRESS"
  echo "==> Found address '$NOMAD_BIND_ADDRESS' for interface '$NOMAD_BIND_INTERFACE', setting bind option..."
fi

NOMAD_DATA_DIR=/nomad/data
NOMAD_CONFIG_DIR=/nomad/config

if [ -n "$NOMAD_LOCAL_CONFIG" ]; then
	echo "$NOMAD_LOCAL_CONFIG" > "$NOMAD_LOCAL_CONFIG/local.json"
fi

if [ "${1:0:1}" = '-' ]; then
    set -- nomad "$@"
fi

if [ "$1" = 'agent' ]; then
    shift
    set -- nomad agent \
        -data-dir="$NOMAD_DATA_DIR" \
        -config-dir="$NOMAD_CONFIG_DIR" \
        $NOMAD_BIND \
        "$@"
elif [ "$1" = 'version' ]; then
    set -- nomad "$@"
elif nomad --help "$1" 2>&1 | grep -q "nomad $1"; then
    set -- nomad "$@"
fi

if [ "$1" = 'nomad' ]; then
    if [ "$(stat -c %u /nomad/data)" != "$(id -u nomad)" ]; then
        chown nomad:nomad /nomad/data
    fi
    if [ "$(stat -c %u /nomad/config)" != "$(id -u nomad)" ]; then
        chown nomad:nomad /nomad/config
    fi

    if [ ! -z ${NOMAD_ALLOW_PRIVILEGED_PORTS+x} ]; then
        setcap "cap_net_bind_service=+ep" /bin/nomad
    fi

    set -- su-exec nomad:nomad "$@"
fi

exec "$@"
