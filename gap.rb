require 'lib/preload'
require 'lib/cache'
require 'lib/samsara'
require 'lib/gap'
require 'lib/ext'

ruby = Gap::Ruby25.provide
system %{#{ruby} -e "puts RUBY_DESCRIPTION"}

# r = nil
# Gap::Maker.new do
#   FROM "7za.sam"
#   COPY "E:/7za.exe", "7za.exe"
#   r = asMarshal
# end

# File.write "7za.txt", Zlib::Deflate.deflate(r).inspect