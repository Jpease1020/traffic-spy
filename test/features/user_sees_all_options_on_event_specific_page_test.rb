require './test/test_helper'

class EventSpecificDataPageTest < FeatureTest
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

    visit '/sources/jumpstartlab/events/socialLogin'
  end

  def test_it_shows_a_nav_bar
    within("#top-bar") do
      assert page.has_content?("You are a Spy!")
    end
  end

  def test_page_shows_header
    within("#event-name") do
      assert page.has_content?("Social Login Stats")
    end
  end

  def test_identifier_and_path_are_displayed
    within("#hourly") do
      assert page.has_content?("Total Visits: 1")
    end
  end

  def test_longest_response_time_header_and_content_is_displayed
    within("#visit-table") do
      assert page.has_content?("Hour")
      assert page.has_content?("Visits")
    end

    within_table('hourly-visit') do
      assert page.has_content?("1")
    end
  end

  def test_it_shows_the_event_link
    click_link "Events"
    assert_equal "/sources/jumpstartlab/events", current_path
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
