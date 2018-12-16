require 'lib/preload'
require 'lib/cache'
require 'lib/samsara'
require 'lib/gap'
# r = nil
# Gap::Maker.new do
#     FROM  "aria.sam"
#     COPY "aria2c.exe", "aria2c.exe"
#     r = asMarshal
# end
# open("aria.txt", "w") do |f|
#   f.write Zlib::Deflate.deflate(r, 9).inspect
# end

# aria2c = Gap::Samsara.new nil
# aria2c.fromBase64 r
# file = aria2c.genfile "aria2c.exe"
# system "#{file} --version"

require 'lib/ext/aria2c.rb'
aria2c = Gap::Aria2C
file = aria2c.genfile "aria2c.exe"
system "#{file} --version"

