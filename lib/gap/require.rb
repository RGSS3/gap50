module Gap
    class Require
        def initialize(strict = true, sam = Gap::Main)
            @strict = strict
            @sam = sam
        end

        def require(*args)
            if @strict
                args.each{|x|
                    _require_strict x
                }
            else
                args.each{|x|
                    _require x
                }
            end
        end

        ORIGIN = Kernel.method(:require)
        INSTANCE_ORIGIN = Kernel.instance_method(:require)
        DEFAULT_REQUIRE = Require.new
        def self.require(*args)
            DEFAULT_REQUIRE.require *args
        end

        def self.replace_kernel!
            that = self
            Kernel.send :define_method, :require do |*args|
                that.require *args
            end
        end

        def self.use_kernel!
            Kernel.send :define_method, INSTANCE_ORIGIN
        end

        private
        def _require(a)
            ORIGIN.call a
        rescue
            if ex.to_s =~ /^LoadError: .*? -- (.*)$/
                file = $1
                path = "./" + @sam.genfile(file)
                ORIGIN.call path
            else
                raise ArgumentError, "Can't load #{a}"
            end
        end

        def _require_strict(file)
            if @sam.has_file_in?(file)
                path = "./" + @sam.genfile(file)
                ORIGIN.call path
            else
                ORIGIN.call file
            end
        end

        
    end
end