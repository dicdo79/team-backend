FROM centos:7

# CentOS 패키지 업데이트 및 wget 설치
RUN yum -y update && yum clean all && \
    yum -y install wget

# JDK 설치
RUN mkdir -p /sw && cd /sw && \
    wget -P /sw --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn/java/jdk/8u381-b09/8c876547113c4e4aab3c868e9e0ec572/jdk-8u381-linux-x64.tar.gz && \
    tar -zxvf jdk-8u381-linux-x64.tar.gz && \
    rm -f jdk-8u381-linux-x64.tar.gz

ENV JAVA_HOME=/sw/jdk1.8.0_381 
ENV PATH=$PATH:$JAVA_HOME/bin

# Tomcat 설치
RUN wget -P /sw https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz --no-check-certificate && \
    cd /sw && \
    tar -zvxf apache-tomcat-9.0.85.tar.gz && \
    rm -f apache-tomcat-9.0.85.tar.gz

ENV CATALINA_HOME=/sw/apache-tomcat-9.0.85
ENV PATH=$PATH:$CATALINA_HOME/bin

# ADD 설정 변경
ADD ./conf/server.xml $CATALINA_HOME/conf/server.xml

# MariaDB 커넥터 설치
RUN wget -P ~/ https://dlm.mariadb.com/1965742/Connectors/java/connector-java-2.7.5/mariadb-java-client-2.7.5.jar --no-check-certificate && \
    cd ~ && \
    cp -p ~/mariadb-java-client-2.7.5.jar $JAVA_HOME/jre/lib && \
    cp -p ~/mariadb-java-client-2.7.5.jar $CATALINA_HOME/lib

# 포트 80로 노출
EXPOSE 80

# HEALTHCHECK 추가
HEALTHCHECK --interval=1m --timeout=3s CMD curl -f http://localhost:80/ || exit 1

# ENTRYPOINT 변경
ENTRYPOINT ["/sw/apache-tomcat-9.0.85/bin/catalina.sh", "run"]
