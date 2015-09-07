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

  def teardown
    DatabaseCleaner.clean
  end
end
