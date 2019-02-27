#!/bin/bash
set -e
if [ -z "${BD_SUITE_PREFIX}" ]; then
    echo "\${BD_SUITE_PREFIX} not set"
    exit 1
fi
if [ -z "${PLYQL_VERSION}" ]; then
    echo "\${PLYQL_VERSION} not set"
    exit 1
fi
echo "/opt/plyql/bin/plyql -h ${BD_SUITE_PREFIX}-broker:8082 --experimental-mysql-gateway 3306"
/opt/plyql/bin/plyql -h ${BD_SUITE_PREFIX}-broker:8082 --experimental-mysql-gateway 3306
