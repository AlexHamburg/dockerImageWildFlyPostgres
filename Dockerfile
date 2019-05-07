FROM airhacks/wildfly

ENV DATASOURCE_NAME ApplicationDS
ENV DATASOURCE_JNDI java:/ApplicationDS

ENV DB_HOST database
ENV DB_PORT 5432
ENV DB_USER postgres
ENV DB_PASS changeit
ENV DB_NAME evetsService

# create temporary deployment dir, because wars can deploy after the datasource is created
RUN mkdir /tmp/deploments
ENV DEPLOY_DIR /tmp/deploments

RUN mkdir /tmp/jboss-cli
ENV CLI_DIR /tmp/jboss-cli

COPY startWithPostgres.sh $WILDFLY_HOME/bin

USER root
RUN chown serveradmin:serveradmin $WILDFLY_HOME/bin/startWithPostgres.sh
RUN chmod 755 $WILDFLY_HOME/bin/startWithPostgres.sh
RUN yum -y install wget
USER serveradmin

RUN wget -P /tmp https://jdbc.postgresql.org/download/postgresql-42.2.5.jar

ENTRYPOINT $WILDFLY_HOME/bin/startWithPostgres.sh