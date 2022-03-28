require 'telegram/bot'

require 'json'
file = File.read('./DATA.json')
data_hash = JSON.parse(file)

require 'digest/md5'

require 'dotenv'
Dotenv.load

token=ENV["API_TOKEN"]
puts token
waiting = 0
newText=""
messages_count=0

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    

    codeVar = message.text.delete_prefix("/start ")
    message_orig = data_hash["#{codeVar}"]
    #data_hash["#{codeVar}"]['1'] = 'I, Robot'
    #data_hash['books']['2'] = 'The Caves of Steel'

    puts "@#{message.from.username}: #{message.text}"
    args=message.text.delete_prefix("/start ")

    if waiting==1 && message.text != "/start" && message.text != "/done"
      if message.text != "/shorten"
        messages_count=messages_count+1
        newText = newText+message.text
        reply_text = "این متن اضافه شد. 
        تعداد متن‌ها: #{messages_count}
        تعداد کلمات: #{newText.length}
        ---
        در صورتی که متن دیگری برای ارسال ندارید، بر روی /done کلیک کنید.
        "
        codeVar_generated = "#{Digest::MD5.hexdigest("#{message.id}")}"
        
        data_hash["#{codeVar_generated}"] = {
          "code": "#{codeVar_generated}",
          "chat_id": message.chat.id,
          "message_id": message.id,
          "shorten_text": newText.slice(0..5) ,
          "full_text":newText
        }

      else
        reply_text = "در حال ارسال متن هستید. 
        تعداد متن‌ها: #{messages_count}
        تعداد کلمات: #{newText.length}
        ---
        در صورتی که متن دیگری برای ارسال ندارید، بر روی /done کلیک کنید.
        "
      end
    elsif  message.text == "/done"
      reply_text = "متن نهایی ساخته شد.
      
      برای اشتراک این متن می‌توانید از این لینک استفاده نمایید:
      https://t.me/nextPage_Bchatbot?start=#{Digest::MD5.hexdigest("#{message.id}")}

      تعداد متن‌ها: #{messages_count}
      تعداد کلمات: #{newText.length}
      ---

      پیام نهایی:

      #{newText}
      
      "

      File.write('./DATA.json', JSON.dump(data_hash))


    elsif message.text.include? "/start"
      if message.text.delete_prefix("/start ") == "#{codeVar}"
        reply_text = "ادامه‌ی پیام شما:
           #{message_orig['full_text']} "
      elsif args != "/start"
        reply_text = " #{message.text.delete_prefix("/start ")} 
        متاسفانه این پیام رو پیدا نکردم :(" 
      else 
        reply_text = "سلام! خوش‌اومدی #{message.from.first_name}. 🤖. روی لینکی که داخل پیامت هست کلیک کن وگرنه پیامت رو فوروارد کن." 
      end
    elsif message.text.include? "/shorten"
      reply_text = "الان برات متنت رو کوتاه می‌کنم. فقط برام بفرستش!"
      waiting = 1
      r=0
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

          - message_orig: #{message_orig}
          - codeVar: #{codeVar}
        " )
  end
end
