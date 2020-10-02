module VenueDecorator

  def label
    name || street
  end

  def location_label
    "#{city || province_name || street || name}, #{translate country_code.downcase, scope: 'map.short_country_names', default: country_code}"
  end

  def address_text
    @address_text ||= [street, city, province_name, country_code].compact.join(', ')
  end

  def address
    {
      building: name,
      street: street,
      city: city,
      province: province_code,
      country: country_code,
      postcode: postcode,
    }
  end

  def directions_url
    if place_id?
      "https://www.google.com/maps/search/?api=1&query=#{address_text}>&query_place_id=#{place_id}"
    else
      "http://www.google.com/maps/place/#{latitude},#{longitude}"
    end
  end

  def province_name
    ProvinceDecorator.get_name(province_code, country_code) if province_code && country_code
  end

  def country_name
    CountryDecorator.get_label(country_code) if country_code
  end

  def distance(coordinates)
    @distance ||= distance_from(coordinates)
  end

  def distance_in_words(coordinates)
    I18n.translate('api.distance', distance: distance(coordinates).to_i)
  end

  def as_json(_context = nil)
    {
      id: id,
      label: label,
      latitude: latitude,
      longitude: longitude,
      directions_url: directions_url,
      events: events.publicly_visible.map { |event| event.extend(EventDecorator).as_json },
    }
  end

end
