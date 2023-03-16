FROM azul/zulu-openjdk-centos:11

ARG HADOOP_VERSION
ARG HIVE_VERSION
ARG POSTGRES_DRIVER_VERSION

# Download and extract the Hadoop binary package.
RUN curl -sS https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
	| tar xz -C /opt/  \
	&& ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc

# Set necessary environment variables.
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/spark/bin:/opt/hadoop/bin:${PATH}"
ENV HADOOP_OPTIONAL_TOOLS="hadoop-azure"

# Download and install the standalone metastore binary.
RUN curl -sS https://dlcdn.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
	| tar xz -C /opt/ \
	&& ln -s /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive

# Download and install the postgres connector.
RUN curl -sS -o ${HIVE_HOME}/lib/postgresql.jar -L https://jdbc.postgresql.org/download/postgresql-${POSTGRES_DRIVER_VERSION}.jar

COPY docker-entrypoint.sh /usr/bin/

RUN groupadd hive --gid 1000 && \
	useradd hive --uid 1000 --gid 1000 && \
    chown hive:hive -R /opt/* /usr/bin/docker-entrypoint.sh
USER hive

ENTRYPOINT [ "/usr/bin/docker-entrypoint.sh" ]
