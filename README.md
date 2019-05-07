# The image with WildFly 15 that contains config script for JBDC Postgres Driver

All setups can be made in `docker-compose.yml` file. You have to define the following ENV variables in the application server:
- **DB_HOST** - IP address of database Postgres
- **DB_PORT** - port of database
- **DB_NAME** - name of the database (default: DB_USER)
- **DB_USER** - username used for connection to database
- **DB_PASS** - password user for connection to database The connection string is then created as `jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME`

All variables values must be **same** to variables that you used for Postgres.