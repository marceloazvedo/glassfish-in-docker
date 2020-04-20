FROM        openjdk:8-jdk

ENV         JAVA_HOME         /usr/lib/jvm/java-8-openjdk-amd64
ENV         GLASSFISH_HOME    /usr/local/glassfish4
ENV         PATH              $PATH:$JAVA_HOME/bin:$GLASSFISH_HOME/bin

RUN         apt-get update

RUN         apt-get install -y curl
RUN         apt-get install -y unzip
RUN         apt-get install -y zip
RUN         apt-get install -y inotify-tools
RUN         rm -rf /var/lib/apt/lists/*

RUN         curl -L -o /tmp/glassfish-4.1.zip http://download.java.net/glassfish/4.1/release/glassfish-4.1.zip && \
            unzip /tmp/glassfish-4.1.zip -d /usr/local && \
            rm -f /tmp/glassfish-4.1.zip

EXPOSE      8080 4848 8181

WORKDIR     /usr/local/glassfish4/bin

# User: admin / Pass: glassfish
RUN         echo "admin;{SSHA256}80e0NeB6XBWXsIPa7pT54D9JZ5DR5hGQV1kN1OAsgJePNXY6Pl0EIw==;asadmin" > /usr/local/glassfish4/glassfish/domains/domain1/config/admin-keyfile
RUN         echo "AS_ADMIN_PASSWORD=glassfish" > pwdfile

COPY        postgresql-9.4.1209.jar /usr/local/glassfish4/glassfish/domains/domain1/lib/

# verbose causes the process to remain in the foreground so that docker can track it
# Default to admin/glassfish as user/pass
RUN \
  ./asadmin start-domain && \
  ./asadmin --user admin --passwordfile pwdfile enable-secure-admin && \
  ./asadmin stop-domain

# need to know where is the user path to add bashrc
#RUN echo "export PATH=$PATH:/usr/local/glassfish4/bin" >> /opt/glassfish/.bashrc

# Default command to run on container boot
CMD ["/usr/local/glassfish4/glassfish/bin/asadmin", "start-domain", "--verbose=true"]