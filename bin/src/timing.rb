require 'date'
$STOP=0
def time_qeue
  puts "times: ", $time_check
  iuy=1
  every_so_many_seconds(0.5) do
    puts Time.now
    iuy=iuy+1
    if $time_check.length==0
      #exit
      $STOP=1
    end
     
    if iuy%5 ==0
      sendJson JSON.dump($data_hash)
    end
    $time_check.each_with_index do |x,i|
      begin
      passed = DateTime.now.to_time.to_i - $time_check["#{x[0]}"][:startedTime]
      remaining = $time_check["#{x[0]}"][:time_remaining].to_i

      if passed>remaining
        puts $time_check
        $time_check["#{x[0]}"][:time_remaining] = "0"
        $data_hash["#{x[0]}"]["timer"] = "0"
        sendJson JSON.dump($data_hash)
        res = $bot_is.api.deleteMessage(chat_id: $time_check["#{x[0]}"][:chat_id], message_id: $time_check["#{x[0]}"][:message_id])
        $time_check.delete("#{x[0]}")
        $STOP=1

      end
      break if  $time_check["#{x[0]}"][:time_remaining].to_i<=0

      puts "ina:", x[0],x[1],i,$time_check["#{x[0]}"][:time_remaining]
      puts "passed/remaining:", passed,remaining
      a="#{passed}s/#{remaining}s"
      
      res = $bot_is.api.editMessageCaption(chat_id: $time_check["#{x[0]}"][:chat_id], message_id: $time_check["#{x[0]}"][:message_id], caption:loading(passed,remaining))
        
      rescue => e
        puts e
      end
       
    end
  end
    
end

def every_so_many_seconds(seconds)
    last_tick = Time.now
    $loopTick= Thread::new do
      loop do
        if $STOP==1
          puts "stopped"
          $STOP=0
          $loopTick.terminate
        end
        sleep 0.1
        if Time.now - last_tick >= seconds
          last_tick += seconds
          yield
        end
      end
    end
end


def loading(a,b)

  tem =  (a*15).div(b)
  puts tem
  str1 = "░" *(15-tem)
  str2 = "▓" * tem
  return "#{a}s#{str2}#{str1}#{b}s"
end