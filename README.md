# Mongo DB Cron Backup

Simple docker iamge to create sheduled backups from momgo db.


## Configuration

Name|Default|Description
-|-|-
CRON_TIME | 4 2 * * * | cron schedule expression
MAX_BACKUPS | 7 | How many backups should be preserved? If 0 unlimet
EXTRA_ARGUMENTS | ```--gzip``` | Additional arguments for ```mongodunp```
EXTRA_OPTS_RESTORE | ```--gzip``` | Additional arguments for ```mongorestore```
MONGODB_HOST | mongo | Database host
MONGODB_HOST_FILE | | Like MONGODB_HOST from file
MONGODB_PORT | 27017 | Database port
MONGODB_PORT_FILE | | Like MONGODB_PORT from file
MONGODB_DB | | Database name
MONGODB_DB_FILE | | Like MONGODB_DB from file
MONGODB_USER | | Database username
MONGODB_USER_FILE | | Like MONGODB_USER from file
MONGODB_PASS | | Database password
MONGODB_PASS_FIL | | Like MONGODB_PASS from file


## Usage

### docker-compose

```yml
version: "3.7"

networks:
  mongo-internal:
    internal: true

volumes:
  mongo-data:

services:
  mongo:
    image: mongo
    networks:
      - mongo-internal
    volumes:
    - mongo-data:/data/db
    secrets:
    - mongo-db-passwd
    environment:
      MONGO_INITDB_DATABASE: db
      MONGO_INITDB_ROOT_USERNAME: user
      MONGO_INITDB_ROOT_PASSWORD: "secure password"

  mongo-dumper:
    image: scarbous/mongo-cron-dumper
    networks:
      - mongo-internal
    volumes:
      - ./mongo-dumps:/backup
    environment: 
      MONGODB_HOST: mongo
      MONGODB_USER: user
      MONGODB_PASS: "secure password"
```

Create a dump.

```docker-compose run --rm mongo-dumper backup```

Restore a dump.

```docker-compose run --rm mongo-dumper restore```

List created backups

```docker-compose run --rm mongo-dumper list```

### docker cli

Run the container to schedule dumps.

```sh
docker run -d \
  --restart=always \
	--link web_db_1:mongo \
	-e MONGODB_USER="user" \
	-e MONGODB_PASS="secure password" \
  -v /local/file/path:/backup \
  scarbous/mongo-cron-backup
```

Create a dump.

```sh
docker run --rm \
	--link web_db_1:mongo \
	-e MONGODB_USER="user" \
	-e MONGODB_PASS="secure password" \
  -v /local/file/path:/backup \
  scarbous/mongo-cron-backup \
  backup
```

Restore a dump.

```sh
docker run --rm \
	--link web_db_1:mongo \
	-e MONGODB_USER="user" \
	-e MONGODB_PASS="secure password" \
  -v /local/file/path:/backup \
  scarbous/mongo-cron-backup \
  restore 2022.02.25.103100
```

List created backups

```sh
docker run --rm \
  -v /local/file/path:/backup \
  scarbous/mongo-cron-backup \
  list
```
