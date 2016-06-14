require 'json'
class Weather
  include HTTParty

  def initialize(url)
    @base_url = url
  end

  def request(message)
    split_message = message.split
    case split_message.size
    when 1
      if message.to_i > 0
        city_id(message.to_i)
      else
        city_name(message)
      end
    when 2
      if split_message[0].to_f > 0 and split_message[1].to_f > 0
        coordinates(split_message[0], split_message[1])
      else
        city_name(message)
      end
    else
      city_name(message)
    end
  end

private

  def from_json(options, func)
    begin
      answer = JSON.parse(self.class.get(@base_url, options).to_json)
    rescue JSON::ParserError
      sleep(5)
    retry
    end
    if answer["cod"] != 200
      raise WeatherError, "#{func.to_s.capitalize.gsub('_', ' ')} incorrect! #{answer["message"]}"
    else
      "Weather for #{answer["name"]}: average temp: #{answer["main"]["temp"]} pressure: #{answer["main"]["pressure"]} humidity: #{answer["main"]["humidity"]}"
    end
  end

  UNITS = { units: "metric" }

  def coordinates(lat, lon)
    options = { query: { lon: lon, lat: lat } }
    options[:query].merge! UNITS
    from_json(options, __callee__)
  end

  def city_name(name)
    options = { query: { q: name } }
    options[:query].merge! UNITS
    from_json(options, __callee__)
  end

  def city_id(id)
    options = { query: { id: id } }
    options[:query].merge! UNITS
    from_json(options, __callee__)
  end

end

class WeatherError < StandardError
end