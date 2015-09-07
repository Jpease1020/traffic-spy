require "./test/test_helper"

class EvenPageTest < FeatureTest
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
    end

    def test_page_shows_header
      visit '/sources/jumpstartlab/events'
      within("#header") do
        assert page.has_content?("Events Dashboard")
        assert page.has_content?("Jumpstartlab")
      end
    end

    def test_page_shows_most_received_to_least_received
      visit '/sources/jumpstartlab/events'
      within("#most_received_events") do
        assert page.has_content?("Most Received to Least Received Events")
        # save_and_open_page
        assert page.has_content?("socialLogin")
      end
    end

    def test_page_shows_even_specific_data
      visit '/sources/jumpstartlab/events'
      within("#event_specific_data") do
        assert page.has_content?("Event Specifc Data")
        assert page.has_content?("http://localhost:9393/sources/jumpstartlab/events/socialLogin")
      end
    end

    def teardown
      DatabaseCleaner.clean
    end

end
