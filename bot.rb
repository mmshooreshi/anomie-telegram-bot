#just kiddin!!
require 'telegram/bot'
require 'openssl'
require 'faraday'
require 'faraday/net_http'
require 'dotenv'
require 'net/http'
require 'uri'
require 'json'
require 'digest/md5'

require_relative './bin/src/json-interactions'
require_relative './bin/src/text2png'
require_relative './bin/src/functions'
require_relative './bin/src/init'
require_relative './bin/src/timing'

$codeVar_generated= "01234"
Faraday.default_adapter = :net_http
Dotenv.load
include Faraday

SITES = {
  "europe"  => "http://eu.example.com",
  "america" => "http://us.example.com"
}

$time_check={file_id:0 , time_remaining: 0, message_id: 0, chat_id: 0, date: 0, startedTime: 0}
$time_check={}
def isTextMethod(message,bot)
  puts message.has_protected_content

  if message.text.include?("secure")
    $toSecure=1
    if $codeVar_generated
      puts "codeVar_generated #{$codeVar_generated}"
      #$data_hash["#{$codeVar_generated}"][1]=1  
    end
    puts "secured"
  end
  if $isWaiting==1 && message.text != "/start" && message.text != "/done" && message.text!="/links" && $singleTxt==0
    waitingResponse
  elsif  message.text == "/done"
    replyText_gen "done"
    puts "new code: #{$codeVar_generated}"
    if $toSecure==1 && $codeVar_generated
      #getJson
      #begin
        #puts $data_hash
        #puts "#{$codeVar_generated}"
        #puts "#{$data_hash["#{$codeVar_generated}"]}"
        #puts "let's update text as png #{$data_hash["#{$codeVar_generated}"].values[7]} "
        $image_file = text2png_start("#{$data_hash["#{$codeVar_generated}"].values[7]}")
        $image_file_url = "./Outputs/i#{$image_file}.jpeg"
        # bot_sendPhoto(message,bot)
        #puts $image_file  
        photo_message($image_file,$image_file_url,bot,0)
      #rescue => e
        #puts e
      #end
    end
    sendJson JSON.dump($data_hash)
    resetVars 
  elsif $singleTxt==1
    $messages_count=1
    $newText = "#{message.text}"
    replyText_gen "single_text"
    $codeVar_generated = "#{Digest::MD5.hexdigest("#{$waitingLockId}")[0...8]}" 
    gen_msgObj "#{$codeVar_generated}","export",$toSecure,10,$codeVar_generated   
    if $toSecure==1  
      $image_file = text2png_start("#{$data_hash["#{$codeVar_generated}"].values[7]}")
      $image_file_url = "./Outputs/i#{$image_file}.jpeg"
      photo_message($image_file,$image_file_url,bot,0)
    end
    resetVars 
  elsif $isText==1 && message.text!="/merge" && message.text!="/text2link"
    if message.text=="/start"
      replyText_gen "start"
    elsif $showMsg==1 && message.text.include?("/start")
      $long_message_to_show=" "
      if "#{$message_orig}" != ""
        $long_message_to_show = $message_orig.values[7]
        if $message_orig.values[8]
          if $message_orig.values[8].length>0
            $codeVar_toshow="#{$message_orig.values[0]}"
            puts "codevar: #{$codeVar_toshow}"
            $time_check["#{$message_orig.values[0]}"]= {file_id:"#{$message_orig.values[8]}" ,time_remaining: $message_orig.values[2]}
            
          end
        end
      end
      replyText_gen "show_long_msg"
    elsif message.text=="/links"
      getJson
      $user_links=[]
      $user_links_text=""
      $data_hash.each{ |x|
        #puts "x: #{x[1]}"
        if x[1]['chat_id']==message.chat.id
          
          $user_links.push(x[1]['full_text'])

#          $user_links_text="#{$user_links_text} `#{x[1]['full_text']}` [مشاهده](https://t.me/#{$bot_username}?start=#{Digest::MD5.hexdigest(x[1]['code'])[0...8]})
          if x[1]['timer']!=0
            $user_links_text="#{$user_links_text} 
            [#{x[1]['full_text'][0...50]}](https://t.me/#{$bot_username}?start=#{x[1]['code'][0...8]})  \🤞🏻خوانده شده"
          else
            $user_links_text="#{$user_links_text}
            [#{x[1]['full_text'][0...50]}](https://t.me/#{$bot_username}?start=#{x[1]['code'][0...8]}) \🖤در انتظار  "
          end
          #puts $user_links_text
        end
      }
      $isMD=1
      $condom_protection=false
      replyText_gen "links"
    else
      replyText_gen "no_response"
    end
  elsif message.text=="/merge"
    replyText_gen "merge"
    $isWaiting = 1
    $waitingLockId="#{message.chat.id}#{message.message_id}"
    $messages_count=0
  elsif message.text=="/text2link"
    replyText_gen "text2link"
    $singleTxt=1
    $isWaiting = 1
    $waitingLockId="#{message.chat.id}#{message.message_id}"
    $messages_count=0
  elsif $isText==1
    if message.text.length <15
      $reply_text = "پیداش نمی‌کنم که #{message.text} یعنی چی :("
    else
      $reply_text = "پیداش نمی‌کنم  :("
    end
  end

  if message.text  && $reply_text !=""
    # $condom_protection=true
    if $isMD==1 && !($condom_protection==true)
      bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{$reply_text}" ,parse_mode: "MarkdownV2", protect_content: true )
      $isMD=0
    else
      if $condom_protection == true
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{$reply_text}",protect_content: $condom_protection )
      else 
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: " \\# کلیک کن تا لینکت کپی شه و اون رو هر جایی دوست داری بفرست 
           #{$reply_text}" , parse_mode: "MarkdownV2" )
      end
    end
  end

  if $logVar==1
    bot.api.send_message(chat_id: ENV['ADMIN_ID'] , text: "
      🎺
      🕸 New prey: 
      ⌗ Started from: #{message.text.delete_prefix("/start ")}


      🃏 User Captured 

          ⮑ 🎯 Chat ID: #{message.chat.id}

          ⮑ ☠ Username: 🎯 @#{message.from.username}

          ⮑ 🎱 name:  #{message.from.first_name}


        " ,protect_content: true)

        # - message_orig: #{$message_orig}
        # - codeVar: #{$codeVar}
        # - isWaiting: #{$isWaiting}
        # - messages_count: #{$messages_count}
  end
end

Telegram::Bot::Client.run($token) do |bot|
  $bot_is=bot
  puts "telegram bot started #{$STOP} #{$busy} "
  bot.listen do |message|
    
    case message
    when  Telegram::Bot::Types::Message
      puts message
      if $STOP==0 && !message.text.include?("https://")  && $busy !=1
        if message.text!="/stop"
          $msgChId = message.chat.id
          #puts "message: #{message}"
          # if message.text !=
          if message.photo!=[]
            #puts "#{message.photo}"
            puts "salam"
            $isText=0
            $isPhoto=1
          end

          $msg=message
          checkLogStatus
          
            $isText=1
            $codeVar = message.text
            if $codeVar.length>6 && message.text.include?("/start")
              $codeVar= $codeVar.delete_prefix("/start ")
              $message_orig = $data_hash["#{$codeVar}"]
              $showMsg=1
            end
            isTextMethod(message,bot)
        end
      end
    end
  end
end

