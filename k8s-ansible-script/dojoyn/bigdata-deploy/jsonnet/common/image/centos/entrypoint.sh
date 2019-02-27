#!/bin/bash
if [ ! -d /opt/entry/ ]; then
   mkdir -p /opt/entry/
fi
cp $1 /opt/entry/entrypoint.sh
chmod a+x /opt/entry/entrypoint.sh
exec /opt/entry/entrypoint.sh
