## Deliverables
- [X]  Architecture Diagram
 - https://excalidraw.com/#json=6200156642869248,aQsoVHVum1FL9nK1G4MVwg
- [X]  A document explaining your design decisions
    - README.md
- [X]  All supporting schema / queries / code
- [X]  Link to a git repository with instructions on how to set it up.
    - https://github.com/surabhisuman/influencer-analytics
    - [Setup Instructions](Installation.md)

## Components
- SQS Client
    - stores influencer id to be processed next
    - read from SQS
    - write to SQS
- MockstagramDataProvider
    - Connects with mockstagram and fetches data for influencer
- Seeder
    - rake script to seed sqs with influencer ids
- Influencer Analytics Service
    - Fetches mockstagram data from MockstagramDataProvider
    - transforms the data
    - write back to SQS
- Data Pipeline
    - Fetch data from Mockstagram
        - rake script to read messages from `influencer_id_store` SQS and forward to `Influencer Analytics Service`
        - Forwards influencer id to Influencer Analytics Service to be pushed again to queue for re-processing at certain interval
    - Ingestion to DB
        - rake script to read messages from `influencer_data_points` SQS and sink to DB
- API Layer
    - API to fetch and display data

## Tech Stack
- Ruby on Rails
- RSpec for Unit Tests
- Faraday gem as HTTP client
- Parallel gem for parallel + concurrent processing
- TimeScale DB as timeseries database
- Mock AWS SQS for stream processing
- Docker for dependencies

## Design tradeoffs

### Database
For this problem statement, where in we have to store some kind of metrics for each influencer over a time period with some resolution I understand TimeSeries Database would be the best fit.

Upon reading of different TSDB, I shortlisted 3 popular dbs.
1. Influx DB
2. Prometheus DB
3. TimeScale DB

While all 3 support timeseries based data storage and retrieval.
Influx DB would have been the best for this use case, I chose to go with TimeScale DB

Reasons:
1. Given it's built on top of PSQL and I have familiarity with it.
2. If I had chosen InfluxDB, there would be some learning curve to understand it's query language but with my understanding with PSQL, it was easy to get started while retaining benefits of TSDB.
3. Since I used Rails to create this project, ActiveRecord ORM works pretty well with PSQL and thus TimeScale is compatible with it.

Based on above reasons and given the time, this was a tradeoff I made.


### Data Pipeline
My understanding for the basic flow was we have to maintain the granularity of data points resolution. To be able to achieve that with fail safe mechanism I need to make sure even if a request fails, it can be retried ASAP.

Here in, I started with a queue that stores influencer_id and a consumer which consumes from the queue, fetches data from Mockstagram and stores to DB. At the end of processing each influencer_id, consumer make sures that it pushes back the same influencer_id to queue for re-processing in a certain time interval.

Here, I realized DB would be the bottleneck which will impact resolution in case it goes down. To decouple the behaviour, I introduced another queue which stores the data points retrieved from Mockstagram and allow another consumer to do a batch insertion to reduce load on DB yet maintaining a suitable latency for data to be available.

Now, even if DB goes down for some reason data won't be lost and we still can retain the intended granularity.

### API

```
GET /influencer_analytics/<influencer_id>?start_time=<epoch_in_seconds>&end_time=<epoch_in_seconds>
```
