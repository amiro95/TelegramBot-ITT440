#!/usr/bin/ruby
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'telegram/bot'
require 'weather.rb'
require 'db.rb'

env = ENV["TG_WEATHER_BOT"]
arg = ARGV[0]
token = ""

if !env.nil? and !env.empty?
  token = env
elsif !arg.nil? and !arg.empty?
  token = arg
else
  puts "Usage:\n\tTG_WEATHER_BOT=\"bot_token\" ./#{$0}\n\t./#{$0} \"bot_token\""
  exit
end

db = WeatherBase.new('weatherbot.db')

weather = Weather.new('http://api.openweathermap.org/data/2.5/weather')

HELLO = <<-HELLOSTRING
Hello! I'm yet another weather telegram bot!
Usage:
      city_name               - city name and country code divided by comma, use ISO 3166 country codes
      city_code               - City ID
      coordinates             - lon, lat coordinates of the location of your interest
      /history [all, integer] - get your history
      /help                   - this text
HELLOSTRING

  Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    send = lambda { |answer| bot.api.sendMessage(chat_id: message.chat.id, text: answer) }
    if !message.text.nil?
      case
      when message.text.start_with?("/start")
        send.(HELLO)
      when message.text.start_with?("/history")
        p = message.text.delete("/history ")
        if !p.empty?
          send.(db.get_history(message.from.id, p))
        else
          send.(db.get_history(message.from.id))
        end
      when message.text.start_with?("/help")
        send.(HELLO)
      else
        begin
          weather_answer = weather.request(message.text)
          send.(weather_answer)
          db.record(message.text, weather_answer, message.from.id)
        rescue WeatherError => weather_error
          send.(weather_error)
        end
      end
    else
      send.("Supports only text messages.")
    end
  end
end