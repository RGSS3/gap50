module Gap
    class Maker
        RND = Random.new
        attr_accessor :temp, :sam


        def initialize(sam = nil, temp = genname, &block)
            @sam = sam
            @temp = temp
            if defined? instance_exec
                transaction do |m|
                    instance_exec &block
                end
            else
                transaction do |m|
                    instance_eval &block
                end
            end
        end

        def path(name)
            @temp + "/" + name
        end

        def readfile(name)
            @sam.readfile path(name)
        end

        def writefile(name, value)
            @sam.writefile path(name), value
        end

        def copyfile(src, dest)
            writefile dest, @sam.readfile(src)
        end

        def exec(cmd)
            system "cd #{@temp} && #{cmd}"            
        end

        def transaction
            ret = yield self
            _import_all
            _cleanup
            ret
        end

        def genlib(name, text)
            writefile "cpp/#{name}.cpp", %{#define GAPI(type) extern "C" type __stdcall
#{text}
}
            exec "g++ cpp/#{name}.cpp -o cpp/#{name}.dll -static -s -shared -m32 -Wl,-add-stdcall-alias"
        end

        def from(name)
            @sam = Samsara.new name
            _export_all
        end

        alias COPY  copyfile
        alias WRITE writefile
        alias READ  readfile
        alias RUN   exec
        alias FROM  from
        alias CXX   genlib
        private
        def _export_all
            @sam.each{|k, v|
                if k[0] == Samsara::MetaFile
                    @sam.export k[1], @temp
                end
            }
        end

        def _import_all
            len = @temp.length + 1
            Dir.glob(@temp + "/**/*") do |f|
                next if FileTest.directory?(f)
                name = f[len..-1]
                @sam.import name, @temp
            end
        end

        def _cleanup
            @sam.rmdir_p(@temp)
        end

        def genname
            while 0
                name = "temp-#{RND.hex(16)}"
                return name if !FileTest.exists?(name)
            end
        end
        
    end
end