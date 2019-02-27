#!/bin/sh
set -e

#check env to get the configuration path and copy to haproxy dir
if [ -z "$CONF_FILE" ]; then
  echo "configuration file env not set";
else
  echo "copy file"
  cp -f $CONF_FILE /usr/local/etc/haproxy/haproxy.cfg
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	# if the user wants "haproxy", let's use "haproxy-systemd-wrapper" instead so we can have proper reloadability implemented by upstream
	shift # "haproxy"
	set -- "$(which haproxy-systemd-wrapper)" -p /run/haproxy.pid "$@"
fi

exec "$@"
