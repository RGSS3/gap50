require 'lib/preload'
require 'lib/cache'
require 'lib/samsara'
require 'lib/gap'
Gap::Maker.new do
    FROM  "test.sam"
    WRITE "b.txt", "Hello world"
    RUN   %{ruby -e "p 'Hello world'" > c.txt}
    CXX "arith", %{
      GAPI(int) add(int a, int b) {
        return a + b;
      }
      GAPI(int) sub(int a, int b) {
        return a - b;
      }
    }
end

s = Gap::Samsara.new "test.sam"
s.each{|k, v|
  #
}

r = Gap::DLL.new "cpp/arith.dll", s
p r.add(3, 5)
p r.sub(4, 3)

