require 'date'

def replyText_gen (typeVar)
  if typeVar=="done"
    $reply_text = "متن نهایی ساخته شد.
      
      برای اشتراک این متن می‌توانید از این لینک استفاده نمایید:
      https://t.me/#{$bot_username}?start=#{Digest::MD5.hexdigest("#{$waitingLockId}")[0...8]}

      تعداد متن‌ها: #{$messages_count}
      تعداد حروف: #{$newText.length}
      ---

      پیام نهایی:

      #{$newText}
      
      "
  elsif typeVar=="single_text"
    $reply_text = "این متن اضافه شد و متن نهایی ساخته شد. 
      تعداد حروف: #{$newText.length}
      ---
     
      برای اشتراک این متن می‌توانید از این لینک استفاده نمایید:
      https://t.me/#{$bot_username}?start=#{Digest::MD5.hexdigest("#{$waitingLockId}")[0...8]}

      پیام نهایی:

      #{$newText}

      [Code: #{$waitingLockId}]
      "
  elsif typeVar=="start"
    $reply_text = "سلام! خوش‌اومدی #{$msg.from.first_name}. 🤖. روی لینکی که داخل پیامت هست کلیک کن وگرنه پیامت رو فوروارد کن." 
  elsif typeVar=="show_long_msg"
    if $long_message_to_show!=" "
      begin
        $reply_text = "پیام کامل که دنبالش بودی:
        
        ----
        #{$long_message_to_show}"
        
        puts "time_check: #{$time_check}"
        puts $codeVar_toshow
        puts "file to show: ", $time_check["#{$codeVar_toshow}"][:file_id]
        if $codeVar_toshow.length>0
          if $time_check["#{$codeVar_toshow}"][:time_remaining].to_i <=0  
            $reply_text="این پیام دیگه قابل نمایش نیست :(‌"
          else
            varTemp = photo_message("", $time_check["#{$codeVar_toshow}"][:file_id] ,$bot_is,1)
            puts "varTemp #{varTemp}"
            $time_check["#{$codeVar_toshow}"][:message_id]=varTemp[0]
            $time_check["#{$codeVar_toshow}"][:chat_id]=varTemp[1]
            $time_check["#{$codeVar_toshow}"][:date]=varTemp[2]
            $time_check["#{$codeVar_toshow}"][:startedTime]=DateTime.now.to_time.to_i
            time_qeue()
          end
        end
      rescue => e
        puts e
      end
    else
      $reply_text = "نتونستم پیامی که دنبالشی رو پیدا کنم :("
    end
  elsif typeVar=="no_response"
    $reply_text = " #{$msg.text.delete_prefix("/start ")} 
    متاسفانه این پیام رو پیدا نکردم :(" 
  elsif typeVar=="merge"
    $reply_text = "الان برات متنت رو کوتاه می‌کنم. فقط برام دونه دونه پیام‌هاتو بفرست تا همه رو برات ترکیب کنم.!"
  elsif typeVar=="text2link"
    $reply_text = "متن خود را ارسال کنید"
  elsif typeVar=="links"
    $reply_text = "متن‌هایی که شما ایجاد کرده‌اید:

    #{$user_links_text}
    
    "
  end
end


def gen_msgObj (hashVar,isExport,is_secured,timer,txt2png)
  
  $data_hash["#{hashVar}"] = {
    "code": "#{hashVar}",
    "is_secured": "#{is_secured}", 
    "timer": timer , 
    "txt2png": "#{txt2png}",
    "chat_id": $msg.chat.id,
    "message_id": $waitingLockId,
    "shorten_text": $newText.slice(0..5),
    "full_text":$newText
  }
  if isExport=="export"
    sendJson JSON.dump($data_hash)
  end
  
end


def waitingResponse
  if $msg.text != "/merge" && $msg.text != "/text2link" 
    $messages_count=$messages_count+1
    $newText = "#{$newText} 
    #{$msg.text}"
    $reply_text = "این متن اضافه شد. 
    تعداد متن‌ها: #{$messages_count}
    تعداد حروف: #{$newText.length}
    ---
    در صورتی که متن دیگری برای ارسال ندارید، بر روی /done کلیک کنید.

    [Code: #{$waitingLockId}]
    "
    $codeVar_generated = "#{Digest::MD5.hexdigest("#{$waitingLockId}")[0...8]}"
    puts "ina: #{$codeVar_generated} "
    gen_msgObj $codeVar_generated,"hold",$toSecure,30,0
  else
    $reply_text = "در حال ارسال متن هستید. ‍
    تعداد متن‌ها: #{$messages_count}
    تعداد حروف: #{$newText.length}
    ---
    در صورتی که متن دیگری برای ارسال ندارید، بر روی /done کلیک کنید.
    "
  end
end


def photo_message(caption, url,bot,isURLlocal)
  if isURLlocal==0
    photo = Faraday::UploadIO.new(url, 'image/jpeg')
  else
    photo = url
  end
  
  res = bot.api.send_photo(chat_id: $msgChId ,
   photo: photo, caption: caption ,protect_content: true)

  if(isURLlocal==0)
    findHash(res)
  end
  return [res["result"]["message_id"],res["result"]["chat"]["id"],res["result"]["date"]]

end


def findHash(res)
  begin
    $c=0
    last=res["result"].values
    b = last.last(3)
    b[0].each { |x| 
      $c=x
      #puts "x: #{$c}"
      # if x[0]
      #   c=x[0]
      # end
      }

    $text2png_hash = $c['file_id']

    puts "value: " , $data_hash["#{$codeVar_generated}"].values
    $data_hash["#{$codeVar_generated}"][":text2png"]=$text2png_hash
    sendJson JSON.dump($data_hash)
  rescue => e
    puts e
  end
  

end