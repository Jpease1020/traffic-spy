require_relative "../test_helper"

class EventTest < Minitest::Test
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
  end

  def test_it_has_the_correct_attributes
    assert_equal 0, Event.count

    event = Event.new(event_name: "socialLogin")
    event.save

    assert_equal 1, Event.count
    assert_equal "socialLogin", Event.find(event.id).event_name
  end

  def test_it_finds_the_most_to_least_received_events
    @payload_1 = 'payload={"eventName": "socialLogin1","ip":"63.29.38.211"}'
    @payload_2 = 'payload={"eventName": "socialLogin1","ip":"63.29.38.212"}'
    @payload_3 = 'payload={"eventName": "socialLogin2","ip":"63.29.38.213"}'
    @payload_4 = 'payload={"eventName": "socialLogin1","ip":"63.29.38.214"}'
    @payload_5 = 'payload={"eventName": "socialLogin2","ip":"63.29.38.215"}'

    source = Source.first

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3
    post "/sources/jumpstartlab/data", @payload_4
    post "/sources/jumpstartlab/data", @payload_5


    event = Event.new.most_received_events(source)
    assert_equal "socialLogin1", event.first.event_name
    assert_equal "socialLogin2", event.last.event_name

    assert_equal 2, Event.count
    assert_equal 5, Payload.count
  end

  def teardown
    DatabaseCleaner.clean
  end
end
