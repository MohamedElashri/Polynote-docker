FROM alpine:3.10.2
LABEL maintainer="Mohamed Elashri"



WORKDIR /opt
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV SPARK_HOME /opt/spark
ENV PYTHONUNBUFFERED TRUE
ENV SPARK_VERSION=3.3.0
ENV HADOOP_VERSION=3.3.0
ENV SCALA_VERSION=3.1.3
ENV POLYNOTE_VERSION=0.4.2

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
  zlib \

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
    zlib-dev \ 
    tar

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
RUN wget https://dlcdn.apache.org/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz \
&& tar -zxvf spark-3.3.0-bin-hadoop3.tgz \
&& mv spark-3.3.0-bin-hadoop3 spark \
&& mv spark /opt/spark \
&& rm spark-3.3.0-bin-hadoop3.tgz

RUN wget -O- "https://www.scala-lang.org/files/archive/scala-3.1.3.tgz" \
    | tar xzf - -C /usr/local --strip-components=1

RUN wget -c https://www.zlib.net/fossils/zlib-1.2.9.tar.gz -O - | tar -xz  \
&& cd zlib-1.2.9 && ./configure && make && make install \
&& cd /lib/x86_64-linux-gnu && ln -s -f /usr/local/lib/libz.so.1.2.9/lib libz.so.1 \
&& cd ~ && rm -rf zlib-1.2.9

ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"
ENV PYSPARK_ALLOW_INSECURE_GATEWAY=1

# Download and extract polynote
RUN curl -Lk https://github.com/polynote/polynote/releases/download/0.4.2/polynote-dist.tar.gz \
  | tar -xzvpf -

RUN ln -s `which pip` /opt/conda/bin/pip3

RUN  rm -rf \
         /var/lib/apt/lists/* \
         /tmp/* \
         /var/tmp/* \
         /usr/share/man \
         /usr/share/doc \
         /usr/share/doc-base \
         /root/.cache/pip

COPY config.yml ./polynote/config.yml

EXPOSE 8192
CMD bash polynote/polynote
