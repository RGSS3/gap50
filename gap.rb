require 'gap50/preload'
require 'gap50/cache'
require 'gap50/samsara'
require 'gap50/gap'
require 'gap50/ext'

ruby = Gap::Ruby25.provide
system %{#{ruby} -e "puts RUBY_DESCRIPTION"}

# r = nil
# Gap::Maker.new do
#   FROM "7za.sam"
#   COPY "E:/7za.exe", "7za.exe"
#   r = asMarshal
# end

# File.write "7za.txt", Zlib::Deflate.deflate(r).inspect