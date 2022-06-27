FROM alpine:3.10.3
LABEL maintainer="Mohamed Elashri"


ARG POLYNOTE_VERSION="0.4.2"

WORKDIR /opt
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SPARK_HOME /opt/spark
ENV PYTHONUNBUFFERED TRUE


# Install build dependencies for alpine
RUN apk add --no-cache \
  bash \
  freetype \
  lcms2 \
  libjpeg-turbo \
  libpng \
  libwebp \
  libxml2 \
  libxslt \
  openjdk8 \
  openjpeg \
  python3 \
  tiff \
  zlib

# Install libs
RUN set -e; \
  apk add --no-cache --virtual .build-deps \
    curl \
    freetype-dev \
    g++ \
    gcc \
    lcms2-dev \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    mariadb-dev \
    openjpeg-dev \
    postgresql-dev \
    python3-dev \
    tiff-dev \
    zlib-dev

# python packages
RUN pip3 install --upgrade pip \
   && pip3 install \
      cmocean \
      dask[complete] \
      iso8601 \
      jaydebeapi \
      jedi \
      jep \
      numpy \
      pandas \
      pyspark \
      requests \
      seawater \
      virtualenv \
      xarray    

# Install polynote and scala
RUN curl -L https://github.com/polynote/polynote/releases/download/$POLYNOTE_VERSION/polynote-dist.tar.gz | tar -xzvpf - \
  && curl -L https://www.apache.org/dyn/closer.lua/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz | tar -xzvpf - \
  && mv spark* spark \
  && apk del .build-deps



ENV PATH "$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin"

COPY config.yml ./polynote/config.yml

EXPOSE 8192

CMD bash polynote/polynote
