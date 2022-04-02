require 'RMagick'
require "bidi"
require 'virastar'
require_relative './persian-connector'
require_relative './resharper'

include Magick
$fontVar =["ANegaar.ttf",
    "DimaTahriri.ttf",
    "DimaShekaste.ttf",
    "Neirizه.ttf",
    "ANegaarBold.ttf",
    "Hekayat.ttf",
    "Shekari.ttf",
    "DigiNofarBold.ttf",
    "IranSens.ttf",
    "Leyla.ttf"]

$fontVar2="DigiNofarBold.ttf"


def word_wrap(text, columns = 80)
    text.split("\n").collect do |line|
      line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
end


def genText(canvas,color,font)
    
    $text.font_weight=900

    $text.gravity = Magick::NorthEastGravity
    $text.text_align(RightAlign)
    $text.fill="#3fcaa9"
    $text.fill="#e73c70"
    $text.fill=color
    
    #$text.annotate(canvas, 0,0,0,0, $textString.connect_persian_letters.reverse ) 
    position = -$line_spacing/2
    $wrap.each do |row|
        #puts row, row =~ /^[\u0600-\u06FF\u0750-\u077F\s]+$/
        row =~ /[\u0621-\u0698\ufe81-\ufef0]/
        words=row.split(" ")
        row=words.join(" ")
        words.each_with_index do |word,index|
            word.match(/[a-z]+(?:'[a-z]+)*/i)
            #words[index]=word.reverse
        end

        
        if  (row =~ /[a-z]+(?:'[a-z]+)*/i)
           
            
            words=row.split(" ")
            words.each_with_index do |word,index|
                if  (word =~ /[a-z]+(?:'[a-z]+)*/i)
                    #puts row,"sss",word
                    words[index]=word.reverse
                end
            end
        end
        row=words.join(" ")
        words=row.split(" ")

        if  !(row =~  /[\u0621-\u0698\ufe81-\ufef0]/)
            #puts row
            row=words.reverse.join(" ")
            #row=row.reverse
            $text.gravity = Magick::NorthWestGravity
            $text.text_align(LeftAlign)
            $text.fill="#3fcaa9"
            $text.annotate(canvas, 0, 0, 30, position += $line_spacing, row.reverse.persian_cleanup(:fix_perfix_spacing=>true, :fix_suffix_spacing=>true))
        else
            
            $text.gravity = Magick::NorthEastGravity
            $text.text_align(RightAlign)
            $text.fill="#e73c70"
            $text.annotate(canvas, 0, 0, 30, position += $line_spacing, row.reverse.persian_cleanup(:fix_perfix_spacing=>true, :fix_suffix_spacing=>true))
        end
    end

    metrics = $text.get_multiline_type_metrics(canvas, $textString)
end

def text2png_arabic(textStringInput,font)
    $textString=textStringInput
    bidi = Bidi.new
    textBidi = bidi.to_visual $textString

    tmpC = Magick::ImageList.new
    tmpC.new_image(670, 888) do |c|
        c.background_color= "#262127"
        c.border_color= "#ffff"
        c.stroke= "#ffff"      
    end

        
    $text = Magick::Draw.new
    $wrap =word_wrap($textString.connect_persian_letters , 50).split("\n")
    $line_spacing=(50/($wrap.size))*5+50
    $text.font = "./Fonts/#{font}"
    $text.pointsize = (2000/($textString.length * 20))+40

    metrics = $text.get_multiline_type_metrics(tmpC, $wrap.join("\n"))
    #puts tmpC.columns, metrics.width, $wrap.size

    $wrap =word_wrap($textString.connect_persian_letters ,Integer(670/metrics.width*50)).split("\n")
    $line_spacing=(50/($wrap.size))*5+50
    #puts $wrap.size,Integer(650/metrics.width*50)

    canvas = Magick::ImageList.new
    canvas.new_image(720,30+ $line_spacing*$wrap.size) do |c|
        c.background_color= "#262127"
        c.background_color= "#1E2b33"
        c.border_color= "#ffff"
        c.stroke= "#ffff"      
    end
    genText(canvas,"#e73c70",font)

    font = font.delete_suffix(".ttf")
    c=  canvas.flatten_images
    c=canvas[0]
    b= c.to_s
    a= c.export_pixels_to_str
    # puts a.length
    c.write("./Outputs/i#{$codeVar_generated}.jpeg")
    return $codeVar_generated

end

# def text2png_start(text)
#     $fontVar.each { |x| 
#         puts x
#         text2png_arabic(text,x)
#     }
# end

text="salam"

def text2png_start(text)
    return text2png_arabic(text,$fontVar2)
end

text2png_start(text)

#text2png_start("    درسته سرویسی به نام realtime بوده اما اون چیزی که اون شخص داره تو کلیپ میگه وجود نداشته، هرگز گوگل سرویسی نداشته که فقط فارسی و انگلیسی باشه، هدفش هم نمایش توییت برای ایرانی ها نبوده. توییتر مگه چندجا فیلتره که بخاطرش بیان همچین کاری کنن؟ ")