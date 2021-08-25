#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- nomad "$@"
fi

if [ "$1" = 'agent' ]; then
    shift
    set -- nomad agent "$@"
elif [ "$1" = 'version' ]; then
    set -- nomad "$@"
elif nomad --help "$1" 2>&1 | grep -q "nomad $1"; then
    set -- nomad "$@"
fi

exec "$@"
