require 'aws-sdk-sqs'

class SqsClient < InfluencerIdStore
    def initialize(endpoint, queue, options={})
        @sqs = Aws::SQS::Client.new(
            endpoint: endpoint,
            region: 'ap-south-1'
        )
        @queue_url = @sqs.get_queue_url(queue_name: queue).queue_url
        @poller = Aws::SQS::QueuePoller.new(@queue_url)
        @options = options
    end

    def read
        @poller.poll(
            max_number_of_messages: @options[:max_number_of_messages],
            wait_time_seconds: @options[:wait_time_seconds],
            idle_timeout: @options[:idle_timeout]
        ) do |messages|
            messages.each do |message|
                begin
                    yield message
                rescue StandardError => e
                    Rails.logger.info "message processing failed #{e.message}"
                end
            end
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