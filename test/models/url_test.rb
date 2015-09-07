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
    assert_equal 0, Url.count

    url = Url.new(url: "http://jumpstartlab.com/blog")
    url.save

    assert_equal 1, Url.count
    assert_equal "http://jumpstartlab.com/blog", url.url
  end

  def test_it_displays_the_most_requested_urls
    @payload_1 = 'payload={"url":"http://jumpstartlab.com/blog","ip":"63.29.38.211"}'
    @payload_2 = 'payload={"url":"http://jumpstartlab.com/blog","ip":"63.29.38.212"}'
    @payload_3 = 'payload={"url":"http://jumpstartlab.com/story","ip":"63.29.38.213"}'

    source = Source.first

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3
    url = Url.new.most_requested(source)

    assert_equal "http://jumpstartlab.com/blog" , url[0]
    assert_equal "http://jumpstartlab.com/story" , url[1]
  end

  def test_it_displays_url_specific_data
    @payload_1 = 'payload={"url":"http://jumpstartlab.com/blog","ip":"63.29.38.211"}'
    @payload_2 = 'payload={"url":"http://jumpstartlab.com/blog","ip":"63.29.38.212"}'
    @payload_3 = 'payload={"url":"http://jumpstartlab.com/story","ip":"63.29.38.213"}'

    source = Source.first

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3
    url = Url.new.path_parser(source)

    assert_equal ["/blog", "/blog", "/story"] , url
  end

  def teardown
    DatabaseCleaner.clean
  end
end

