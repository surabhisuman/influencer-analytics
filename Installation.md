Tools Required:
1. Ruby 2.7.0
2. awscli
3. docker

Steps:
1. Pull docker images
```sh
docker pull pafortin/goaws:latest
docker pull timescale/timescaledb:latest-pg12
```

2. Run docker instances of dependent services
```sh
docker run --name sqs --network host -dit pafortin/goaws:latest
docker run -d --name db --network host -e POSTGRES_PASSWORD=postgres timescale/timescaledb:latest-pg12
```

3. Create SQS queues
```sh
aws configure # set random values for access id and secret key, use any valid region.
aws --endpoint-url http://localhost:4100 sqs create-queue --queue-name influencer_id_store
aws --endpoint-url http://localhost:4100 sqs create-queue --queue-name influencer_data_points
```

4. Start Mockstagram
```sh
cd mockstagram-api-master
npm install
npm start
```

5. Setup rails environment
```sh
ruby -v # 2.7.0
cd influencer_analytics
bundle install
rake db:create db:migrate
```

6. Seed data in SQS
```sh
rake sqs:seed:million_influencer_id
```

7. Start processor pipeline
```sh
rake influencer:processor
```

8. Start sink to db pipeline
```sh
rake influencer:sink_to_db
```

Management Commands
1. Check logs for sqs docker
```sh
docker logs --follow --tail 100 <sqs/db>
```

2. Connect to docker db using psql
```sh
psql -h localhost -U postgres -d postgres # use password provided in docker run command above, default: postgres
```

3. Check rails logs
```sh
cd influencer_analytics
tail -100f log/development.log # use specific environment name for test and production
```