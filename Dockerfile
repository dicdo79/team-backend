# Use Ubuntu 18.04 as base image
FROM ubuntu:18.04

# Update and install required packages
RUN apt-get update && \
    apt-get install -y wget openjdk-8-jdk

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Download and extract Tomcat
RUN mkdir /sw && \
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz --no-check-certificate \
    && tar -xvf apache-tomcat-9.0.85.tar.gz -C /sw/ \
    && rm apache-tomcat-9.0.85.tar.gz

# Set CATALINA_HOME environment variable
ENV CATALINA_HOME=/sw/apache-tomcat-9.0.85

# Add custom server.xml
ADD ./conf/server.xml $CATALINA_HOME/conf/server.xml

# Install MariaDB connector
RUN wget https://downloads.mariadb.com/Connectors/java/connector-java-2.7.5/mariadb-java-client-2.7.5.jar --no-check-certificate \
    && cp -p mariadb-java-client-2.7.5.jar $JAVA_HOME/jre/lib/ext/ \
    && cp -p mariadb-java-client-2.7.5.jar $CATALINA_HOME/lib \
    && rm mariadb-java-client-2.7.5.jar

# Expose AJP port
EXPOSE 8009

# Start Tomcat
CMD $CATALINA_HOME/bin/catalina.sh run
