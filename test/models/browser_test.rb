require_relative "../test_helper"

class BrowserTest < Minitest::Test
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
    assert_equal 0, Browser.count

    browser = Browser.new(browser:'Chrome', operating_system: 'Macintosh')
    browser.save

    assert_equal 1, Browser.count
    assert_equal "Chrome", Browser.find(browser.id).browser
  end

  def test_it_finds_the_web_browser_breakdown
    @payload_1 = 'payload={"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","ip":"63.29.38.211"}'
    @payload_2 = 'payload={"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","ip":"63.29.38.212"}'

    source = Source.first

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    browser = Browser.new.list_browsers(source)

    assert_equal 2 , browser["Chrome"]
  end

  def test_it_finds_the_operating_system_breakdown
    @payload_1 = 'payload={"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","ip":"63.29.38.211"}'
    @payload_2 = 'payload={"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","ip":"63.29.38.212"}'

    source = Source.first

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    browser = Browser.new.list_operating_systems(source)

    assert_equal 2 , browser["Macintosh"]
  end

  def teardown
    DatabaseCleaner.clean
  end

end

