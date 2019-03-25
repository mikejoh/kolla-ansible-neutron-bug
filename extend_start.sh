#!/bin/bash

#set -x

# Migrate database and exit if KOLLA_UPGRADE variable is set. This catches all cases
# of the KOLLA_UPGRADE variable being set, including empty.
if [[ "${!KOLLA_UPGRADE[@]}" ]]; then
    if [[ "${!NEUTRON_DB_EXPAND[@]}" ]]; then
        DB_ACTION="--expand"
        echo "Expanding database"
    fi
    if [[ "${!NEUTRON_DB_CONTRACT[@]}" ]]; then
        DB_ACTION="--contract"
        echo "Contracting database"
    fi
    
    # Workaround:
    #NEUTRON_ROLLING_UPGRADE_SERVICES=$(echo $NEUTRON_ROLLING_UPGRADE_SERVICES | tr -d '[],')

    if [[ "${!NEUTRON_ROLLING_UPGRADE_SERVICES[@]}" ]]; then
        for service in ${NEUTRON_ROLLING_UPGRADE_SERVICES}; do
            echo "neutron-db-manage --subproject $service upgrade $DB_ACTION"
        done
    fi
    exit 0
fi