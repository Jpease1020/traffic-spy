require_relative "../test_helper"

class ResponseTest < Minitest::Test
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
    assert_equal 0, Response.count
    response = Response.new(requested_at: "2013-02-16 21:38:28 -0700",
                            responded_in: 37,
                            ip: "63.29.38.211",
                            request_type: 'POST')
    response.save
    assert_equal 1, Response.count
    assert_equal "2013-02-17 04:38:28 UTC", Response.find(response.id).requested_at.to_s
    assert_equal 37, Response.find(response.id).responded_in
    assert_equal "63.29.38.211", Response.find(response.id).ip.to_s
    assert_equal 'POST', Response.find(response.id).request_type
  end

  def test_it_calculates_the_average_response_time_for_a_specific_url
    assert_equal 0, Response.count
    response_100 = Response.create(requested_at: "2013-02-16 21:38:28 -0700",
                            responded_in: 100,
                            ip: "63.29.38.211",
                            request_type: 'POST')
    response_50 = Response.create(requested_at: "2013-02-16 21:38:28 -0700",
                            responded_in: 50,
                            ip: "63.29.38.212",
                            request_type: 'GET')
    assert_equal 2, Response.count
    # average = Response.new.average_response_time("jumpstartlab")
  end

  def test_it_calculates_the_http_verbs_used

    @payload_50 = 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700",
                "respondedIn":50,"ip":"63.29.38.211","requestType":"POST"}'

    @payload_100 = 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700",
                "respondedIn":100,"ip":"63.29.38.211","requestType":"GET"}'

    post "/sources/jumpstartlab/data", @payload_50

    post "/sources/jumpstartlab/data", @payload_100

    source = Source.first

    assert_equal ['POST', 'GET'], Response.new.http_verbs(source)
    assert_equal 2, Payload.count
    assert_equal 2, Response.count
  end


  def teardown
    DatabaseCleaner.clean
  end
end
