require 'lib/gap/gap.rb'
require 'lib/gap/copy.rb'
require 'lib/gap/dll.rb'
require 'lib/gap/exec.rb'
require 'lib/gap/cfunc.rb'
require 'lib/gap/require.rb'

x = Gap::Exec.marshal 'ruby -rjson -e "STDOUT.binmode; STDOUT.write Marshal.dump JSON.parse STDIN.read"', 
  %{{"a": 3, "b": 5}}
p x
x = Gap::Exec.marshal 'ruby -rrexml/document -e "
def node_to_hash(a)
    case a
    when REXML::Element
        {type: :element, name: a.name, attr: a.attributes.map(&:itself), children: a.children.map(&method(:node_to_hash))}
    when REXML::Text
        {type: :text, value: a.to_s}
    when String
        a
    end
end
STDOUT.binmode
STDOUT.write Marshal.dump node_to_hash REXML::Document.new(STDIN.read).root"'.tr("\n", ";"), 
  %{<a c='3'>3<b>6</b>d</a>}

  p x


x = Gap::Exec.marshal 'ruby -ryaml -e "
STDOUT.binmode
STDOUT.write Marshal.dump YAML.load STDIN.read
"'.tr("\n", ";"), 
%{
- a
- b
- :c
- 
   1: 3
   2: 5
   3: 8
}

p x