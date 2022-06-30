FROM ubuntu:22.04
LABEL maintainer="Mohamed Elashri"


WORKDIR /opt
ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED TRUE
ENV JAVA_HOME /usr/lib/jvm/default-java/

# Install libs
RUN apt-get update \
  && apt-get install -y \
     build-essential \
     curl \
     python3 \
     python3-pip \
     default-jdk


# python packages
RUN pip3 install --upgrade pip \
   && pip3 install \
    ipython \
    jedi==0.18.* \
    jep==3.9.* \
    nbconvert \
    numpy \
    pandas \
    pyspark==3.1.2 \
    virtualenv



# Install polynote and scala
RUN curl -L https://github.com/polynote/polynote/releases/download/0.4.5/polynote-dist.tar.gz | tar -xzvpf - 
RUN curl -L https://dlcdn.apache.org/spark/spark-3.1.3/spark-3.1.3-bin-hadoop3.2.tgz| tar -xzvpf - \
  && mv spark* spark

ENV PYSPARK_ALLOW_INSECURE_GATEWAY 1
ENV SPARK_HOME /opt/spark
ENV PATH "$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin"

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

CMD polynote/polynote.py
