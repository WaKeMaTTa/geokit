require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders.provider_order = [:google, :bing, :us]

class MultiGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @failure = Geokit::GeoLoc.new
  end

  def test_successful_first
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address)
  end

  def test_failover
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::BingGeocoder.expects(:geocode).with(@address).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address)
  end

  def test_double_failover
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::BingGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::UsGeocoder.expects(:geocode).with(@address).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address)
  end

  def test_failure
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::BingGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::UsGeocoder.expects(:geocode).with(@address).returns(@failure)
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.geocode(@address)
  end

  def test_invalid_provider
    temp = Geokit::Geocoders.provider_order
    Geokit::Geocoders.provider_order = [:bogus]
    assert_raise Geokit::Geocoders::NoSuchGeocoderError do
      Geokit::Geocoders::MultiGeocoder.geocode(@address)
    end
    Geokit::Geocoders.provider_order = temp
  end

  def test_blank_address
    t1, t2 = Geokit::Geocoders.provider_order, Geokit::Geocoders.ip_provider_order # will need to reset after
    Geokit::Geocoders.provider_order = [:google]
    Geokit::Geocoders.ip_provider_order = [:geo_plugin]
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with('').returns(@failure)
    Geokit::Geocoders::GeoPluginGeocoder.expects(:geocode).never
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.geocode('')
    Geokit::Geocoders.provider_order, Geokit::Geocoders.ip_provider_order = t1, t2 # reset to orig values
  end

  def test_reverse_geocode_successful_first
    Geokit::Geocoders::GoogleGeocoder.expects(:reverse_geocode).with(@latlng).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.reverse_geocode(@latlng)
  end

  def test_reverse_geocode_failover
    Geokit::Geocoders::GoogleGeocoder.expects(:reverse_geocode).with(@latlng).returns(@failure)
    Geokit::Geocoders::BingGeocoder.expects(:reverse_geocode).with(@latlng).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.reverse_geocode(@latlng)
  end

  def test_reverse_geocode_double_failover
    Geokit::Geocoders::GoogleGeocoder.expects(:reverse_geocode).with(@latlng).returns(@failure)
    Geokit::Geocoders::BingGeocoder.expects(:reverse_geocode).with(@latlng).returns(@failure)
    Geokit::Geocoders::UsGeocoder.expects(:reverse_geocode).with(@latlng).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.reverse_geocode(@latlng)
  end

  def test_reverse_geocode_failure
    Geokit::Geocoders::GoogleGeocoder.expects(:reverse_geocode).with(@latlng).returns(@failure)
    Geokit::Geocoders::BingGeocoder.expects(:reverse_geocode).with(@latlng).returns(@failure)
    Geokit::Geocoders::UsGeocoder.expects(:reverse_geocode).with(@latlng).returns(@failure)
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.reverse_geocode(@latlng)
  end

  def test_reverse_geocode_with_invalid_provider
    temp = Geokit::Geocoders.provider_order
    Geokit::Geocoders.provider_order = [:bogus]
    assert_raise Geokit::Geocoders::NoSuchGeocoderError do
      Geokit::Geocoders::MultiGeocoder.reverse_geocode(@latlng)
    end
    Geokit::Geocoders.provider_order = temp
  end

  def test_reverse_geocode_with_blank_latlng
    t1 = Geokit::Geocoders.provider_order # will need to reset after
    Geokit::Geocoders.provider_order = [:google]
    Geokit::Geocoders::GoogleGeocoder.expects(:reverse_geocode).with('').returns(@failure)
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.reverse_geocode('')
    Geokit::Geocoders.provider_order = t1 # reset to orig values
  end

  def test_custom_provider_order
    Geokit::Geocoders::YahooGeocoder.expects(:geocode).with(@address, {}).returns(@success)
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).never
    Geokit::Geocoders::UsGeocoder.expects(:geocode).never
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address, provider_order: [:yahoo, :google, :us])
  end

  def test_mapbox
    # This has its own test file now, is this even necessary?
    # Geokit::Geocoders::MultiGeocoder.geocode(@address, provider_order: [:mapbox])
    # Geokit::Geocoders::MultiGeocoder.reverse_geocode(@latlng, provider_order: [:mapbox])
  end
end
