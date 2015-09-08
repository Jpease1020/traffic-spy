require "./test/test_helper"

class EventPageTest < FeatureTest
  include Rack::Test::Methods

  def app
    TrafficSpy::Server
  end

  def setup
    DatabaseCleaner.start

    attributes = {identifier: "jumpstartlab",
                  rootUrl: "http://jumpstartlab.com"}
    post '/sources', attributes

    assert_equal 1, Source.count
    assert_equal 200, last_response.status

    @payload = 'payload={"url":"http://jumpstartlab.com/blog",
                        "userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
                        "resolutionWidth":"1920",
                        "resolutionHeight":"1280",
                        "referredBy":"http://jumpstartlab.com",
                        "requestType":"GET",
                        "eventName": "socialLogin",
                        "requestedAt":"2013-02-16 21:38:28 -0700",
                        "respondedIn":37,"ip":"63.29.38.211"}'
    post "/sources/jumpstartlab/data", @payload

    visit '/sources/jumpstartlab/events'
  end

  def test_it_shows_a_nav_bar
    within("#top-bar") do
      assert page.has_content?("You are a Spy!")
    end
  end

  def test_page_shows_header
    within("#header") do
      assert page.has_content?("Events Dashboard")
      assert page.has_content?("Jumpstartlab")
    end
  end

  def test_page_shows_most_received_to_least_received
    within("#most_received_events") do
      assert page.has_content?("Most Received to Least Received Events")
      assert page.has_content?("socialLogin: 1")
    end
  end

  def test_page_shows_even_specific_data
    within("#event_specific_data") do
      assert page.has_content?("Event Specifc Data")
      assert page.has_content?("http://localhost:9393/sources/jumpstartlab/events/socialLogin")
    end
  end

  def test_page_has_link_to_dashbaord
    click_link " Dashboard"
    assert "/sources/jumpstartlab/", current_path
  end

  def test_it_shows_a_footer
    within("#footer") do
      assert page.has_content?("LLC")
    end
  end

  def teardown
    DatabaseCleaner.clean
  end
end

