module Gap
    class Exec
        def initialize(sam = Gap::Main)
            @sam = sam
        end

        def exec(cmdline, input)
            md5 = MD5.hexdigest(cmdline) + MD5.hexdigest(input)
            inputfile  = _file md5, ".input"
            outputfile = _file md5, ".output"
            outf = md5 + ".output"
            key = [Samsara::Meta.new(:Exec), outf]
            @sam.gen key do
                @sam.writefile inputfile, input
                system "#{cmdline} < #{inputfile} > #{outputfile}"
                @sam.readfile outputfile
            end
        end

        def marshal(cmdline, input)
            Marshal.load exec(cmdline, input)
        end

        DEFAULT_EXEC = Exec.new
        def self.exec(*a)
            DEFAULT_EXEC.exec(*a)
        end

        def self.marshal(*a)
            DEFAULT_EXEC.marshal(*a)
        end

        private
        def _file(name, ext = "")
            "temp/exec_" << name << ext
        end

    end
end