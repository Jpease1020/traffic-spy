require "./test/test_helper"

class ProcessPayloadTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TrafficSpy::Server
  end

  def setup
    DatabaseCleaner.start

    attributes = { identifier: "jumpstartlab",
                   rootUrl: "http://jumpstartlab.com" }
    post "/sources", attributes

    assert_equal 1, Source.count
    assert_equal 200, last_response.status

    payload_1 = 'payload={"eventName":"addedSocialThroughPromptA","ip":"63.29.38.211"}'
    payload_2 = 'payload={"eventName":"addedSocialThroughPromptA","ip":"63.29.38.212"}'
    payload_3 = 'payload={"eventName":"addedSocialThroughPromptB","ip":"63.29.38.213"}'


    post "/sources/jumpstartlab/data", payload_1
    post "/sources/jumpstartlab/data", payload_2
    post "/sources/jumpstartlab/data", payload_3
  end

  def test_it_registers_a_new_campaign_with_proper_error_messages

    incomplete_attributes = 'campaignName=socialSignup'

    post "/sources/jumpstartlab/campaigns", incomplete_attributes

    assert_equal 400, last_response.status
    assert_equal 0, Campaign.count

    attributes = 'campaignName=socialSignup
                  &eventNames[]=addedSocialThroughPromptA
                  &eventNames[]=addedSocialThroughPromptB'

    post "/sources/jumpstartlab/campaigns", attributes

    assert_equal 200, last_response.status
    assert_equal 1, Campaign.count

    post "/sources/jumpstartlab/campaigns", attributes

    assert_equal 403, last_response.status
    assert_equal 1, Campaign.count
  end

  def teardown
    DatabaseCleaner.clean
  end
end
