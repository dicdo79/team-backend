FROM centos:7

# tomcat 소스 설치를 위한 패키지
RUN yum -y update && yum clean all 
RUN yum -y install wget

# Install JDK
RUN mkdir -p /sw \
    && cd /sw \
    && wget -P /sw --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn/java/jdk/8u381-b09/8c876547113c4e4aab3c868e9e0ec572/jdk-8u381-linux-x64.tar.gz \
    && tar -zxvf jdk-8u381-linux-x64.tar.gz \  
    && rm -f jdk-8u381-linux-x64.tar.gz

# 다운로드 되는 파일의 버전과 일치
ENV JAVA_HOME=/sw/jdk1.8.0_381 
ENV PATH=$PATH:$JAVA_HOME/bin

# Install tomcat
RUN wget -P /sw https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz --no-check-certificate \
  && cd /sw \
  && tar -zvxf apache-tomcat-9.0.85.tar.gz \
  && rm -f apache-tomcat-9.0.85.tar.gz

ENV CATALINA_HOME=/sw/apache-tomcat-9.0.85
ENV PATH=$PATH:$CATALINA_HOME/bin

# ADD 설정 변경
ADD ./conf/server.xml $CATALINA_HOME/conf/server.xml

# Insatll MariaDB connector 
RUN wget -P ~/ https://dlm.mariadb.com/1965742/Connectors/java/connector-java-2.7.5/mariadb-java-client-2.7.5.jar  --no-check-certificate \
  && cd ~ \
  && cp -p ~/mariadb-java-client-2.7.5.jar $JAVA_HOME/jre/lib \
  && cp -p ~/mariadb-java-client-2.7.5.jar $CATALINA_HOME/lib

# EXPOSE는 Fargate에서 무시됩니다. 사용되지 않는 경우 주석 처리하는 것이 좋습니다.

# HEALTHCHECK 추가
HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -f http://localhost:8009/ || exit 1

# ENTRYPOINT 변경
ENTRYPOINT ["/sw/apache-tomcat-9.0.85/bin/catalina.sh", "run"]
