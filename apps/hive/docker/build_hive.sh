if [[ -z $HADOOP_VERSION ]]; then
    HADOOP_VERSION=$(curl -sS https://archive.apache.org/dist/hadoop/core/stable/ \
        | egrep -o "hadoop-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz" \
        | sed 's/hadoop-//' \
        | sed 's/\.tar\.gz//' \
        | sort \
        | uniq \
        | tail -n 1)
fi
if [[ -z $HIVE_VERSION ]]; then
    HIVE_VERSION=3.1.2
fi
if [[ -z $POSTGRES_DRIVER_VERSION ]]; then
    POSTGRES_DRIVER_VERSION=$(curl -sS https://jdbc.postgresql.org/download.html \
        | egrep -o "Current Version.*[0-9]+\.[0-9]+\.[0-9]+" \
        | egrep -o "[0-9]+\.[0-9]+\.[0-9]+")
fi

echo "Using version $HADOOP_VERSION of Hadoop"
echo "Using version $HIVE_VERSION of Hive"
echo "Using version $POSTGRES_DRIVER_VERSION of the Postgres JDBC Driver"

docker build \
    --build-arg=HADOOP_VERSION=$HADOOP_VERSION \
    --build-arg=HIVE_VERSION=$HIVE_VERSION \
    --build-arg=POSTGRES_DRIVER_VERSION=$POSTGRES_DRIVER_VERSION \
    -t someregistry.azurecr.io/hive-metastore:$HIVE_VERSION .

