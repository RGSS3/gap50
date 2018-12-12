require 'lib/gap/gap.rb'
require 'lib/gap/copy.rb'
require 'lib/gap/dll.rb'
require 'lib/gap/cfunc.rb'
require 'lib/gap/require.rb'

sam = Gap::Samsara.new "support.sam"
copy = Gap::Copy.new sam
copy.copy "rexml", 'D:/ruby24/lib/ruby/2.4.0/rexml', '**/*' do Graphics.update end

req = Gap::Require.new sam
req.replace_kernel!
require 'rexml/document'