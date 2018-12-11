require 'lib/cache'
require 'lib/samsara'
require 'lib/gap'


Gap::Copy.copy 'fun', "E:/fun/copy", "*.rb"
Gap::Require.replace_kernel!
require "fun/a.rb"