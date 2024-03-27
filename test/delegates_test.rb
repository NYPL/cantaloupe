# delegates_test.rb
require 'minitest/autorun'
require_relative '../delegates'

class YourClassTest < Minitest::Test
  def setup
    @delegates = CustomDelegate.new
  end

  def test_get_rights_with_homepage_image_id
    # Mocking homepage_image_rights_hash method to return rights for a specific image_id
    def @delegates.homepage_image_rights_hash
      { "58270299" => "rights for image 58270299" }
    end
    
    assert_equal "rights for image 58270299", @delegates.get_rights("58270299", "123.123.123.123")
  end

  def test_get_rights_with_non_homepage_image_id
    # Stubbing fetch method to return rights for a non-homepage image id
    def @delegates.fetch(path, ip)
      "rights for image 123456"
    end

    assert_equal "rights for image 123456", @delegates.get_rights("123456", "123.123.123.123")
  end
  
  def test_derivative_type
    size = { 'height' => 100, 'width' => 90 }
    assert_equal 'b', @delegates.derivative_type(size)

    size = { 'height' => 45, 'width' => 50 }
    assert_equal 'b', @delegates.derivative_type(size)

    size = { 'height' => 140, 'width' => 200 }
    assert_equal 'f', @delegates.derivative_type(size)

    size = { 'height' => 139, 'width' => 101 }
    assert_equal 'f', @delegates.derivative_type(size)

    size = { 'height' => 145, 'width' => 150 }
    assert_equal 't', @delegates.derivative_type(size)

    size = { 'height' => 149, 'width' => 101 }
    assert_equal 't', @delegates.derivative_type(size)

    size = { 'height' => 300, 'width' => 200 }
    assert_equal 'r', @delegates.derivative_type(size)

    size = { 'height' => 250, 'width' => 299 }
    assert_equal 'r', @delegates.derivative_type(size)

    size = { 'height' => 480, 'width' => 760 }
    assert_equal 'w', @delegates.derivative_type(size)

    size = { 'height' => 520, 'width' => 758 }
    assert_equal 'w', @delegates.derivative_type(size)

    size = { 'height' => 1600, 'width' => 1200 }
    assert_equal 'q', @delegates.derivative_type(size)

    size = { 'height' => 249, 'width' => 1597 }
    assert_equal 'q', @delegates.derivative_type(size)

    size = { 'height' => 2247, 'width' => 2560 }
    assert_equal 'v', @delegates.derivative_type(size)

    size = { 'height' => 2400, 'width' => 1800 }
    assert_equal 'v', @delegates.derivative_type(size)

    size = { 'height' => 3000, 'width' => 2000 }
    assert_equal 'full_res', @delegates.derivative_type(size)

    size = { 'height' => 2561, 'width' => 2345 }
    assert_equal 'full_res', @delegates.derivative_type(size)
  end
end
