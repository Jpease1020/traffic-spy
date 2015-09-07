require './test/test_helper'

class UrlSpecificDataPageTest < FeatureTest
  include Rack::Test::Methods

  def app
    TrafficSpy::Server
  end

  def setup
    DatabaseCleaner.start

    attributes = {identifier: "jumpstartlab",
                  rootUrl: "http://jumpstartlab.com"
                }
    post "/sources", attributes

    assert_equal 1, Source.count
    assert_equal 200, last_response.status

    @payload = 'payload={"url":"http://jumpstartlab.com/blog",
                        "userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
                        "resolutionWidth":"1920",
                        "resolutionHeight":"1280",
                        "referredBy":"http://jumpstartlab.com",
                        "requestType":"GET",
                        "requestedAt":"2013-02-16 21:38:28 -0700",
                        "respondedIn":37,"ip":"63.29.38.211"}'
    post "/sources/jumpstartlab/data", @payload

  end

  def test_header_is_displayed
    visit '/sources/jumpstartlab/urls/blog'
    within("#header") do
      assert page.has_content?("Url Specific Data")
    end
  end

  def test_identifier_and_path_are_displayed
    visit '/sources/jumpstartlab/urls/blog'
    within("#source_path") do
      assert page.has_content?("jumpstartlab/blog")
    end
  end

  def test_longest_response_time_header_and_content_is_displayed
    visit '/sources/jumpstartlab/urls/blog'
    within("#longest") do
      assert page.has_content?("Longest Response Time")
      assert page.has_content?("37")
    end
  end

  def test_shortest_response_time_header_and_content_is_displayed
    visit '/sources/jumpstartlab/urls/blog'
    within("#shortest") do
      assert page.has_content?("Shortest Response Time")
      assert page.has_content?("37")
    end
  end

  def test_average_response_time_header_and_content_is_displayed
    visit '/sources/jumpstartlab/urls/blog'
    within("#average") do
      assert page.has_content?("Average Response Time")
      assert page.has_content?("37")
    end
  end

  def test_http_verbs
    visit '/sources/jumpstartlab/urls/blog'
    within("#http_verbs") do
      assert page.has_content?("HTTP Verbs")
      assert page.has_content?("GET")
    end
  end

  def test_page_shows_most_popular_referrers
    visit '/sources/jumpstartlab/urls/blog'
    within("#referrers") do
      assert page.has_content?("Most Popular Referrers")
    end

    within("#referrer") do
      assert page.has_content?("http://jumpstartlab.com")
    end
  end

  #Still need to add in Most Popular Browser  

  def teardown
    DatabaseCleaner.clean
  end
end
