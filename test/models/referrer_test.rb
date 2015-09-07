require_relative "../test_helper"

class ReferrerTest < Minitest::Test
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

  def test_it_stores_the_correct_attributes
    assert_equal 0, Referrer.count
    Referrer.create(referred_by: "http://jumpstartlab.com")
    assert_equal 1, Referrer.count
  end

  def test_it_finds_the_most_popular_referrers
    @payload_1 = 'payload={"url":"http://jumpstartlab.com/blog","referredBy":"http://facebook.com/bad6e","ip":"63.29.38.213"}'
    @payload_2 = 'payload={"url":"http://jumpstartlab.com/blog","referredBy":"http://jumpstartlab.com","ip":"63.29.38.211"}'
    @payload_3 = 'payload={"url":"http://jumpstartlab.com/blog","referredBy":"http://jumpstartlab.com","ip":"63.29.38.212"}'

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3

    url = Url.find_by(url: "http://jumpstartlab.com/blog")

    assert_equal ["http://jumpstartlab.com", 2, "http://facebook.com/bad6e", 1],  Referrer.new.most_popular_referrers(url)

    assert_equal 3, Payload.count
    assert_equal 2, Referrer.count
  end

  def teardown
    DatabaseCleaner.clean
  end

end
