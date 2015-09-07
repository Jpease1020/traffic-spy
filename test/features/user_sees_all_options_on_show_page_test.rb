require "./test/test_helper"

class ShowPageFeatureTest < FeatureTest
  include Rack::Test::Methods

  def app
    TrafficSpy::Server
  end

  def setup
    DatabaseCleaner.start

    attributes = {identifier: "jumpstartlab",
                  rootUrl: "http://jumpstartlab.com"}
    post "/sources", attributes

    assert_equal 1, Source.count
    assert_equal 200, last_response.status


    @payload = 'payload={"url":"http://jumpstartlab.com/blog",
                        "userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
                        "resolutionWidth":"1920",
                        "resolutionHeight":"1280",
                        "requestedAt":"2013-02-16 21:38:28 -0700",
                        "respondedIn":37,"ip":"63.29.38.211"}'

    post "/sources/jumpstartlab/data", @payload
    visit '/sources/jumpstartlab'
  end

  def test_it_shows_the_header
    within("#header") do
      assert page.has_content?("Dashboard")
      assert page.has_content?("Jumpstartlab")
    end
  end

  def test_it_shows_the_most_urls
    within("#most_viewed") do
      assert page.has_content?("Most Viewed Urls")
      assert page.has_content?("http://jumpstartlab.com/blog")
    end
  end

  def test_it_shows_the_average_response
    within("#average_responses") do
      assert page.has_content?("Average Response Times")
      #THERE STILL NEEDS TO BE ASSERTION HERE
    end
  end

  def test_it_shows_the_web_browser_breakdown_info
    within("#breakdown") do
      assert page.has_content?("Web Broswer Breakdown")
      assert page.has_content?("Chrome: 1")
    end
  end

  def test_it_shows_screen_resultion_info
    within("#resolution") do
      assert page.has_content?("Screen Resolutions")
      assert page.has_content?("1920 x 1280")
    end
  end

  def test_it_shows_the_operating_system_info
    within("#os") do
      assert page.has_content?("Operating System Breakdown")
      assert page.has_content?("Macintosh")
    end
    click_link "Events"
    assert_equal "/sources/jumpstartlab/events", current_path
  end

  def test_page_has_link_to_each_url_to_see_specific_data
    within("#url") do
      assert page.has_content?("http://localhost:9393/sources/jumpstartlab/urls/blog")
    end
    assert find_link("http://localhost:9393/sources/jumpstartlab/urls/blog")
  end

  def test_page_has_link_to_events
    click_link "Events"
    assert "/sources/jumpstartlab/events", current_path
  end

  def teardown
    DatabaseCleaner.clean
  end
end
