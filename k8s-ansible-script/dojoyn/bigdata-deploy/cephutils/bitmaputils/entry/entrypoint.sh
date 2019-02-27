#!/bin/bash

set -e
cp -rf /opt/mntcephutils/conf/* /opt/spark/conf/
cp -rf /opt/mntcephutils/conf/* /opt/hadoop/etc/hadoop/
java -Xmx10480m -Xms20480m -cp /opt/bitmap-1.0-SNAPSHOT/lib/cli-1.0-SNAPSHOT.jar:/opt/bitmap-1.0-SNAPSHOT/lib/* io.helium.bitmap.Main /opt/mntcephutils/conf/properties
echo "has finished"
tail -f /etc/hosts
exec "$@"
