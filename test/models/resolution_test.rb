require_relative "../test_helper"

class ResolutionTest < Minitest::Test
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
    assert_equal 0, Resolution.count

    resolution = Resolution.new(resolution_height: "1920", resolution_width: "1280")
    resolution.save

    assert_equal 1, Resolution.count
    assert_equal "1920", Resolution.find(resolution.id).resolution_height
    assert_equal "1280", Resolution.find(resolution.id).resolution_width
  end

  def test_it_finds_unique_resolution
    @payload_1 = 'payload={"resolutionWidth":"640","resolutionHeight":"480","ip":"63.29.38.213"}'
    @payload_2 = 'payload={"resolutionWidth":"640","resolutionHeight":"480","ip":"63.29.38.211"}'
    @payload_3 = 'payload={"resolutionWidth":"1080","resolutionHeight":"500","ip":"63.29.38.212"}'

    post "/sources/jumpstartlab/data", @payload_1
    post "/sources/jumpstartlab/data", @payload_2
    post "/sources/jumpstartlab/data", @payload_3

    assert_equal 3, Payload.count
    assert_equal 2, Resolution.count
  end

  def teardown
    DatabaseCleaner.clean
  end
end
