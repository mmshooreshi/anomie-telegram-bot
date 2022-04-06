
require 'dotenv'
Dotenv.load

$logVar=1
$image_file
$token=ENV["API_TOKEN"]
$bot_username = ENV["BOT_USERNAME"]


def resetVars
    $isWaiting=0
    $newText=""
    $singleTxt=0
    $waitingLockId=0
    $isText=0
    $message_orig={}
    $showMsg=0
    $msg=0
    $isPhoto=0
    $toSecure=0
    $fileid_toshow=""
    $isMD=0
    $codeVar_toshow=0
    $condom_protection= true

end
resetVars

# admin
def checkLogStatus
    if $msg.text == "off1"
      $logVar=0
    elsif $msg.text == "on1"
      $logVar=1
    end
end



