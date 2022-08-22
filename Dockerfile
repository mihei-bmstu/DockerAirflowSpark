FROM apache/airflow:2.3.3
USER root

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y software-properties-common \
  && apt-get install -y gnupg2 \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB9B1D8886F44E2A \
  && add-apt-repository "deb http://security.debian.org/debian-security stretch/updates main" \ 
  && apt-get update \
  && apt-get install -y openjdk-8-jdk \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /opt/bitnami \
  && cp -r /usr/lib/jvm/java-8-openjdk-amd64 /opt/bitnami/ \
  && mv /opt/bitnami/java-8-openjdk-amd64 /opt/bitnami/java
USER airflow
ENV JAVA_HOME=/opt/bitnami/java
RUN export JAVA_HOME

ENV SPARK_HOME /usr/local/spark

USER root
# Spark submit binaries and jars (Spark binaries must be the same version of spark cluster)
RUN cd "/tmp" && \
        wget --no-verbose "https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz" && \
        tar -xvzf "spark-3.1.2-bin-hadoop3.2.tgz" && \
        mkdir -p "${SPARK_HOME}/bin" && \
        mkdir -p "${SPARK_HOME}/assembly/target/scala-2.12/jars" && \
        cp -a "spark-3.1.2-bin-hadoop3.2/bin/." "${SPARK_HOME}/bin/" && \
        cp -a "spark-3.1.2-bin-hadoop3.2/jars/." "${SPARK_HOME}/assembly/target/scala-2.12/jars/" && \
        rm "spark-3.1.2-bin-hadoop3.2.tgz"

USER airflow
# Create SPARK_HOME env var
RUN export SPARK_HOME
ENV PATH $PATH:/usr/local/spark/bin

RUN pip install --no-cache-dir apache-airflow-providers-apache-spark==3.0.0
RUN pip install --no-cache-dir xmltodict
