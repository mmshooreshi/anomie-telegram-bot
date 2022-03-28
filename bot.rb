require 'telegram/bot'

require 'json'
file = File.read('./DATA.json')
data_hash = JSON.parse(file)

require 'digest/md5'

require 'dotenv'
Dotenv.load

token=ENV["API_TOKEN"]
puts token
newText=""
messages_count=0
isWaiting=0
message_orig={}

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    # isWaiting = ENV["IS_WAITING"]
    puts isWaiting
    
    codeVar = message.text.delete_prefix("/start ")
    if codeVar!="/start"
      message_orig = data_hash[codeVar]
    else
      message_orig={}
    end
    #data_hash["#{codeVar}"]['1'] = 'I, Robot'
    #data_hash['books']['2'] = 'The Caves of Steel'

    puts "@#{message.from.username}: #{message.text}"
    puts "#{codeVar}, #{codeVar.length}, #{message_orig},
    
    #{data_hash}"
    # args=message.text.delete_prefix("/start ")

    if isWaiting==1 && message.text != "/start" && message.text != "/done"
      if message.text != "/shorten"
        messages_count=messages_count+1
        newText = "#{newText} 
        #{message.text}"
        reply_text = "این متن اضافه شد. 
        تعداد متن‌ها: #{messages_count}
        تعداد کلمات: #{newText.length}
        ---
        در صورتی که متن دیگری برای ارسال ندارید، بر روی /done کلیک کنید.
        "
        codeVar_generated = "#{Digest::MD5.hexdigest("#{message.message_id}")}"
        
        data_hash["#{codeVar_generated}"] = {
          "code": "#{codeVar_generated}",
          "chat_id": message.chat.id,
          "message_id": message.message_id,
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
      https://t.me/nextPage_Bchatbot?start=#{Digest::MD5.hexdigest("#{message.message_id}")}

      تعداد متن‌ها: #{messages_count}
      تعداد کلمات: #{newText.length}
      ---

      پیام نهایی:

      #{newText}
      
      "

      File.write('./DATA.json', JSON.dump(data_hash))
      isWaiting=0

    elsif message.text.include? "/start"
      if message.text=="/start"
        reply_text = "سلام! خوش‌اومدی #{message.from.first_name}. 🤖. روی لینکی که داخل پیامت هست کلیک کن وگرنه پیامت رو فوروارد کن." 
      elsif "#{message.text.delete_prefix("/start ")}" == "#{codeVar}"
        if ‍‍‍‍‍‍‍message_orig == {}
          long_message_to_show =  ""
        elsif message_orig.key?(:"full_text")
          long_message_to_show =  ‍‍‍‍‍‍‍message_orig["full_text"]
        end
        reply_text = "پیام کامل که دنبالش بودی:
        ----
        "+long_message_to_show
      else
        reply_text = " #{message.text.delete_prefix("/start ")} 
        متاسفانه این پیام رو پیدا نکردم :(" 
      end
    elsif message.text.include? "/shorten"
      reply_text = "الان برات متنت رو کوتاه می‌کنم. فقط برام دونه دونه پیام‌هاتو بفرست تا همه رو برات ترکیب کنم.!"
      isWaiting = 1
      messages_count=0
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
          - isWaiting: #{isWaiting}
          - messages_count: #{messages_count}
        " )
  end
end
