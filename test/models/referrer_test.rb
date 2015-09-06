require_relative "../test_helper"

class ReferrerTest < Minitest::Test
  def test_it_stores_the_correct_attributes
    assert_equal 0, Referrer.count
    Referrer.create(referred_by: "http://jumpstartlab.com")
    assert_equal 1, Referrer.count
  end
end
