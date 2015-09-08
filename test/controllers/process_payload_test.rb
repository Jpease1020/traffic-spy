require "./test/test_helper"

class ProcessPayloadTest < Minitest::Test
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


    @payload = 'payload={"url":"http://jumpstartlab.com/blog","userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"ip":"63.29.38.211","referredBy":"http://jumpstartlab.com","requestType":"POST","eventName":"socialLogin"}'
  end

  def test_it_checks_a_payloads_is_processed_correctly
    post "/sources/jumpstartlab/data", @payload

    assert_equal 1, Payload.count
    assert_equal 200, last_response.status
  end

  def test_it_checks_a_payloads_uniqueness
    post "/sources/jumpstartlab/data", @payload

    assert_equal 1, Payload.count
    assert_equal 200, last_response.status

    post "/sources/jumpstartlab/data", @payload

    assert_equal 1, Payload.count
    assert_equal 403, last_response.status
    assert_equal 'Forbidden - Must be unique payload', last_response.body
  end

  def test_payload_must_be_from_a_registered_source
    post "/sources/cakeisawesome/data", @payload

    assert_equal 403, last_response.status
    assert_equal 'Forbidden - Must have registered identifier', last_response.body
  end

  def test_process_must_contain_a_payload
    post "/sources/jumpstartlab/data"

    assert_equal 0, Payload.count
    assert_equal 400, last_response.status
    assert_equal 'Bad Request - Needs a payload', last_response.body
  end

  def test_data_is_populated_when_payload_is_saved
    assert_equal 0, Url.count
    assert_equal 0, Resolution.count
    assert_equal 0, Response.count
    assert_equal 0, Browser.count
    assert_equal 0, Referrer.count
    assert_equal 0, Event.count

    post "/sources/jumpstartlab/data", @payload
    assert_equal 1, Url.count
    assert_equal 1, Resolution.count
    assert_equal 1, Response.count
    assert_equal 1, Browser.count
    assert_equal 1, Referrer.count
    assert_equal 1, Event.count

    get "/sources/jumpstartlab"
  end

  def test_it_checks_a_url_exists
    post "/sources/jumpstartlab/data", @payload
    get "/sources/jumpstartlab/urls/blog"

    assert_equal 200, last_response.status

    get "/sources/jumpstartlab/urls/dog"

    assert_equal 404, last_response.status
  end

  def test_it_checks_for_if_an_event_exists
    @payload_two = 'payload={"url":"http://jumpstartlab.com/blog","userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"ip":"63.29.38.211","referredBy":"http://jumpstartlab.com","requestType":"POST"}'

    post "/sources/jumpstartlab/data", @payload_two
    get "/sources/jumpstartlab/events"

    assert_equal 404, last_response.status

    post "/sources/jumpstartlab/data", @payload
    get "/sources/jumpstartlab/events"

    assert_equal 200, last_response.status
  end

  def test_without_authentication
    get '/sources/jumpstartlab'
    assert_equal 401, last_response.status
  end

  def test_with_bad_credentials
    authorize 'bad', 'boy'
    get '/sources/jumpstartlab'
    assert_equal 401, last_response.status
  end

  def test_with_proper_credentials
    authorize 'hello1', 'hello4'
    get '/sources/jumpstartlab'
    assert_equal 200, last_response.status
  end

  def teardown
    DatabaseCleaner.clean
  end
end
