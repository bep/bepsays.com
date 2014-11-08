#!/usr/bin/ruby

#
# This script performs replacement of a set of LESS-imports in round-robin style.
#
# @version: 0.1
# @author: Bjørn Erik Pedersen
#
LESS_PATH=File.expand_path('../assets/less', File.dirname(__FILE__))
LESS_VARIANT_PATH=LESS_PATH + '/variants'
LESS_FILE=LESS_PATH + '/bs.less'
VARIANT_PREFIX='bs-variant'

# Get all the variants and sort them
variants ||= Dir.chdir(LESS_VARIANT_PATH) { Dir['*.less'] }
variants.sort

# Replace import with the next LESS file in line
File.open(LESS_FILE, 'r+') { |f|
  new_content = ""
  f.each_line { |line|
    if line.include? VARIANT_PREFIX
      curr_variant = line.match(/import.*(#{VARIANT_PREFIX}.*?\.less)/)[1]
      curr_index = variants.index(curr_variant)
      next_index = (curr_index + 2) > variants.length ? 0 : curr_index + 1
      next_variant = variants[next_index]
      new_content << "@import \"variants/#{next_variant}\";\n"
    else
      new_content << line
    end
  }
  f.rewind
  f.puts new_content
}
