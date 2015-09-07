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

  def test_it_can_calculate_visits_per_hour
    @payload_1 = 'payload={"eventName":"socialA","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"ip":"63.29.38.211"}'
    @payload_2 = 'payload={"eventName":"socialA","requestedAt":"2013-02-16 22:38:28 -0700","respondedIn":37,"ip":"63.29.38.212"}'
    @payload_3 = 'payload={"eventName":"socialA","requestedAt":"2013-02-16 23:38:28 -0700","respondedIn":37,"ip":"63.29.38.213"}'
    @payload_4 = 'payload={"eventName":"socialA","requestedAt":"2013-02-16 22:38:28 -0700","respondedIn":37,"ip":"63.29.38.214"}'
    @payload_5 = 'payload={"eventName":"socialA","requestedAt":"2013-02-16 23:38:28 -0700","respondedIn":37,"ip":"63.29.38.215"}'

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3
    post "/sources/jumpstartlab/data", @payload_4
    post "/sources/jumpstartlab/data", @payload_5

    event = Event.find_by(event_name: "socialA")
    visits_per_hour = Event.new.visits_per_hour(event)

    assert_equal  [0, 0, 1, 2, 2], visits_per_hour.last(5).map { |_, count|
      count }
  end

  def teardown
    DatabaseCleaner.clean
  end
end
