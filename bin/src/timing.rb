require 'date'
$STOP=0
$temp=[0]
def time_qeue
  begin
    loading_spinner()
  rescue => e
    puts e
  end

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

        if passed>=remaining
          $busy=0
          $STOP=1
          puts $time_check
          puts "donneeeee #{$temp[3]}"
          
          #$data_hash["#{x[0]}"]["timer"] = "0"
          #sendJson JSON.dump($data_hash)
          begin
            res = $bot_is.api.deleteMessage(chat_id: $time_check["#{x[0]}"][:chat_id], message_id: $time_check["#{x[0]}"][:message_id])
          rescue => e

          end
          $data_hash["#{$temp[3]}"]["timer"] = "0"
          sendJson JSON.dump($data_hash)

          begin
            $time_check["#{x[0]}"][:time_remaining] = "0"
          rescue => e

          end
          # $time_check.delete("#{x[0]}")
          puts "
          #{$time_check}
          #{$data_hash["#{$temp[3]}"]}
          "


        end
        break if  remaining.to_i<=0
          $busy=1
        # puts "ina:", x[0],x[1],i,$time_check["#{x[0]}"][:time_remaining]
        # puts "passed/remaining:", passed,remaining
          a="#{passed}s/#{remaining}s"
        #res = $bot_is.api.editMessageCaption(chat_id: $time_check["#{x[0]}"][:chat_id], message_id: $time_check["#{x[0]}"][:message_id], caption:loading(passed,remaining))
          begin
            $temp=[$time_check["#{x[0]}"][:chat_id],$time_check["#{x[0]}"][:message_id],loading(passed,remaining),x[0]]
          rescue => e
            puts e
          end
        
      rescue => e
        puts e

      end
       
    end
  end
end

$latest=""
def loading_spinner
  $spiner_dots="⠁⠂⠄⡀⢀⠠⠐⠈"
  $i_temp=0
  every_so_many_seconds(0.5) do
    r=$spiner_dots[$i_temp]
    $i_temp=$i_temp+1
    if $i_temp>=$spiner_dots.length
      $i_temp=0
    end
    puts "#{r}"
    if $STOP!=1 && $temp[0]!=0
      begin
        res = $bot_is.api.editMessageCaption(chat_id: $temp[0], message_id: $temp[1],caption:"#{r} #{$temp[2]}")
      rescue => e
        $latest="#{r} #{$temp[2]}"
      end
    end
  end
end 

def every_so_many_seconds(seconds)
    last_tick = Time.now
    loopTick= Thread::new do
      loop do
        if $STOP==1 || $temp==[]
          puts "stopped"
          $STOP=0
          $busy=0
          $temp=[1,1,1,1]
          loopTick.terminate
          #$time_check={}
        end
        sleep 0.1
        if Time.now - last_tick >= seconds
          last_tick += seconds
          yield
        end
      end
    end
end

$block1="□"
$block2="■"
# $block1="░"
# $block2="▓"

def loading(a,b)
  tem =  (a*10).div(b)
  puts tem
  str1 = $block2 *(10-tem)
  str2 = $block1 * tem
  #return "#{a}s#{str2}#{str1}#{b}s"
  return "#{str1}#{str2}"
end