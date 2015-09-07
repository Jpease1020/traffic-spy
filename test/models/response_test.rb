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
    @payload_1 = 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":50,"ip":"63.29.38.211"}'
    @payload_2 = 'payload={"url":"http://jumpstartlab.com/blog","eventName":"socialA","requestedAt":"2013-02-16 22:38:28 -0700","respondedIn":50,"ip":"63.29.38.212"}'
    @payload_3 = 'payload={"url":"http://jumpstartlab.com/blog","eventName":"socialA","requestedAt":"2013-02-16 23:38:28 -0700","respondedIn":100,"ip":"63.29.38.213"}'
    @payload_4 = 'payload={"url":"http://jumpstartlab.com/lessons/1","eventName":"socialA","requestedAt":"2013-02-16 22:38:28 -0700","respondedIn":100,"ip":"63.29.38.214"}'
    @payload_5 = 'payload={"url":"http://jumpstartlab.com/lessons/1","eventName":"socialA","requestedAt":"2013-02-16 23:38:28 -0700","respondedIn":50,"ip":"63.29.38.215"}'

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3
    post "/sources/jumpstartlab/data", @payload_4
    post "/sources/jumpstartlab/data", @payload_5

    source = Source.find_by(identifier: "jumpstartlab")

    average_response_times = Response.new.average_response_times(source)

    assert_equal [75, 66], average_response_times.map { |_, time| time.to_i }
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
