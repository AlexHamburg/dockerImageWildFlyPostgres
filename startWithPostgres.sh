#!/bin/bash

if [ ! -f wildfly.started ]; then
JBOSS_CLI=$WILDFLY_HOME/bin/jboss-cli.sh

function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    echo "Waiting"
    sleep 1
  done
}

echo "=> Starting WildFly server"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -c standalone.xml > /dev/null &

echo "=> Waiting for the server to boot"
wait_for_server

echo "=> Setup Datasource"
$JBOSS_CLI -c << EOF
batch
# Add PostgreSQL driver
module add --name=org.postgresql --resources=/tmp/postgresql-42.2.5.jar --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=postgres:add(driver-name="postgres",driver-module-name="org.postgresql",driver-class-name=org.postgresql.Driver)
# Add the datasource
data-source add --jndi-name=$DATASOURCE_JNDI --name=$DATASOURCE_NAME --connection-url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME --driver-name=postgres --user-name=$DB_USER --password=$DB_PASS
# Execute the batch
run-batch
EOF

FILES=$CLI_DIR/*.cli
for f in $FILES
do
  echo "Processing $f file..."
  $JBOSS_CLI -c --file=$f
done

echo "=> Shutdown Wildfly"
$JBOSS_CLI -c ":shutdown"

echo "=> DEPLOY WARs"
cp ${DEPLOY_DIR}/* ${WILDFLY_HOME}/standalone/deployments/

touch wildfly.started
fi

echo "=> Start Wildfly"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -c standalone.xml