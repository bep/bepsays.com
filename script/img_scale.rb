require 'RMagick'

static_path=File.expand_path('../static', File.dirname(__FILE__))
content_path=File.expand_path('../content', File.dirname(__FILE__))

Dir.glob(content_path + '/**/*.md').each { |path|
  File.open( path, 'r+' ) { |f|
    replacements = []
    f.grep( /{{<\s.*figure.*small.*}}/ ) { |line|
      matches = line.match(/{{.*src=\"(.*?)\".*}}/)
      img_path = matches[1]
      if img_path.include? "bs400"
        puts "path #{img_path} already converted, skip ..."
        next
      end
      begin
        img = Magick::Image::read(static_path + img_path).first
        if img.columns > 400
          ext = File.extname(img_path)
          scale = 400.0 / img.columns
          scaled_img = img.scale(scale)
          scaled_img_path=img_path.gsub(ext, "-bs400" + ext)
          scaled_img.write(static_path + scaled_img_path)
          replacements << [img_path, scaled_img_path]
        end
      rescue Magick::ImageMagickError
        puts "ERROR: Image " + img_path + " failed"
      end
    }

    if replacements.size > 0
      f.rewind
      new_text = f.read
      replacements.each { | r |
        new_text = new_text.gsub(/#{r[0]}/, r[1])
        puts "replace: #{r[0]} with #{r[1]}"

      }
      f.rewind
      f.puts new_text
    end
  }
}