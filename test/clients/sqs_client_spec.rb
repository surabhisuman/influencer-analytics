require "rails_helper"

RSpec.describe SqsClient, type: :clients do
    SQSResponse = Struct.new(:messages)
    SQSMessage = Struct.new(:body, :receipt_handle, :message_id)
    QueueURL = Struct.new(:queue_url)

    let(:sqs_client) { instance_double(Aws::SQS::Client) }
    let(:response) { SQSResponse.new([SQSMessage.new({"data": "test_data"}.to_json, "receipt_handle", "message_id")]) }
    let(:empty_response) { SQSResponse.new([]) }
    
    before do
        allow(Aws::SQS::Client).to receive(:new).and_return(sqs_client)
        allow(sqs_client).to receive(:get_queue_url).and_return(QueueURL.new("mock_queue_url"))
    end

    context '#read' do
        before do
            allow(sqs_client).to receive(:receive_message).
                            and_return(response, empty_response)
            allow(sqs_client).to receive(:delete_message_batch).and_return(nil)
        end
        it 'should read message from queue successfully' do
            object = SqsClient.new("http://test-server", "test-queue", {
                :idle_timeout => 5
            })
            object.read do |message|
                data = JSON.parse(message.body)
                expect(data).to eq({"data" => "test_data"})
            end
        end
    end

    context '#write' do
        it 'should write message to sqs successfully' do
            object = SqsClient.new("http://test-server", "test-queue")
            expect(sqs_client).to receive(:send_message).and_return(nil)
            expect(object.write({})).to be_truthy
        end

        it 'should fail to write message to sqs' do
            object = SqsClient.new("http://test-server", "test-queue")
            expect(sqs_client).to receive(:send_message).and_raise(StandardError)
            expect(object.write({})).to be_falsey
        end
    end
end
