require 'aws-sdk-sqs'

class SqsClient < InfluencerIdStore
    def initialize(endpoint, queue, options={}, queue_url=nil)
        @sqs = Aws::SQS::Client.new(
            endpoint: endpoint,
            region: 'ap-south-1'
            # http_wire_trace: true
        )
        @queue_url = queue_url || @sqs.get_queue_url(queue_name: queue).queue_url
        @poller = Aws::SQS::QueuePoller.new(@queue_url)
        @options = options
    end

    def read
        @poller.poll(@options) do |messages|
            Parallel.map(messages, in_process: 10, in_threads: 50) do |message|
                begin
                    yield message
                rescue StandardError => e
                    Rails.logger.error "message processing failed #{e.message}"
                end
            end
        end
    end

    def read_in_batches
        @poller.poll(@options) do |messages|
            yield messages
        end
    end

    def write(data)
        @sqs.send_message(queue_url: @queue_url, message_body: data.to_json)
        return true
    rescue StandardError => e
        Rails.logger.error "failed to write message to SQS #{e.message}"
        return false
    end
end