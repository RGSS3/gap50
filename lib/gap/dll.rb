module Gap
    class DLLFunction
        def initialize(path, name)
            @path = path
            @name = name
        end

        def call(*args)
            param = args.map do |x|
                case x
                when Integer
                    "L"
                else
                    "p"
                end
            end
            Win32API.new(@path, @name, param, "L").call(*args)
        end
    end

    class DLL
        def initialize(filename, sam = Gap::Main, &block)
            @sam      = sam
            @filename = filename
            @realpath = @sam.genfile(@filename, &block).tr("/", "\\")
        end

        def [](name)
            DLLFunction.new @realpath, name
        end

        def method_missing(sym, *args)
            self[sym].call(*args)
        end
    end
end