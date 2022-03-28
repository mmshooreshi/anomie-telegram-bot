require 'telegram/bot'

require 'json'
file = File.read('./DATA.json')
data_hash = JSON.parse(file)

require 'dotenv'
Dotenv.load

token=ENV["API_TOKEN"]
puts token

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    codeVar = message.text.delete_prefix("/start ")
    message_orig = data_hash["#{codeVar}"]

    #data_hash["#{codeVar}"]['1'] = 'I, Robot'
    #data_hash['books']['2'] = 'The Caves of Steel'

    puts "@#{message.from.username}: #{message.text}"
    args=message.text.delete_prefix("/start ")

    if  message.text.include? "/start"
      if message.text.delete_prefix("/start ") == "#{'sc-8452-XtoZOCH'}"
        reply_text = "ادامه‌ی پیام شما:
           #{message_orig['full_text']} "
      elsif args != "/start"
        reply_text = " #{message.text.delete_prefix("/start ")} 
        متاسفانه این پیام رو پیدا نکردم :(" 
      else 
        reply_text = "سلام! خوش‌اومدی. روی لینکی که داخل پیامت هست کلیک کن وگرنه پیامت رو فوروارد کن." 
      end
    elsif message.text.include? "/greet"
      reply_text = "سلام #{message.from.first_name}. 🤖"
    else 
      if message.text.length <15
        reply_text = "پیداش نمی‌کنم که #{message.text} یعنی چی :("
      else
        reply_text = "پیداش نمی‌کنم  :("
      end
    end
    puts "sending #{reply_text} to @#{message.from.username}"

    bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: reply_text)
    bot.api.send_message(chat_id: ENV['ADMIN_ID'] , text: "
      🎺
      🕸 New prey: 
      ⌗ Started from: #{message.text.delete_prefix("/start ")}
      

      🃏 User Captured 

          ⮑ 🎯 Chat ID: #{message.chat.id}
          
          ⮑ ☠ Username: 🎯 @#{message.from.username}
          
          ⮑ 🎱 name:  #{message.from.first_name}
        " )
  end
end
