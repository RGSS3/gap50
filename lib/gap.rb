require 'lib/gap/gap.rb'
require 'lib/gap/copy.rb'
require 'lib/gap/dll.rb'
require 'lib/gap/cfunc.rb'
require 'lib/gap/require.rb'


Gap::Main.genfile "archive://a/a/a/a/a/!a/!a!/main.rb" do 
    %{
        print "Hello world"
    }
end

Gap::Require.replace_kernel!

require "archive://a/a/a/a/a/!a/!a!/main.rb"

