Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "I am the Amirrbot bot, My commands are /sitepoint /map")
    when '/sitepoint'
      bot.api.send_message(chat_id: message.chat.id, text: "Welcome to http://sitepoint.com")
    when '/map'
      bot.api.send_location(chat_id: message.chat.id, latitude: 3.0696169, longitude:101.50376370000004)
   end
  end
end