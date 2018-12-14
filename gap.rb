require 'lib/preload'
require 'lib/cache'
require 'lib/samsara'
require 'lib/gap'

Gap::Maker.new do
    FROM  "test.sam"
    WRITE "b.txt", "Hello world"
    COPY  "gap.rb", "gap.rb"
    RUN   %{ruby -e "p 'Hello world'" > c.txt}
end

s = Gap::Samsara.new "test.sam"
s.each{|k, v|
  p [k, v]
}