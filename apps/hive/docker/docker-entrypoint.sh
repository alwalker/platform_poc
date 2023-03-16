#!/bin/bash

echo "Checking if db is already initialized..."
/opt/hive/bin/schematool --verbose -dbType postgres -validate

if [[ $? != "0" ]]; then
    echo "No, initializing database..."
    /opt/hive/bin/schematool --verbose -dbType postgres -initSchema
else
    echo "Yes, checking for upgrades..."
    /opt/hive/bin/schematool --verbose -dbType postgres -upgradeSchema
fi

echo "Starting metastore..."
/opt/hive/bin/hive --verbose --service metastore
