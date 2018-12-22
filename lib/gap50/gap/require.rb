module Gap
    class Require
        def initialize(sam = Gap::Main, strict = true)
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
        ensure
            $@.replace caller if $@
        end

        ORIGIN = Kernel.method(:require)
        INSTANCE_ORIGIN = Kernel.instance_method(:require)
        DEFAULT_REQUIRE = Require.new
        REQUIRE_STACK = [[INSTANCE_ORIGIN, Kernel]]

        
        def replace_kernel!
            that = self
            REQUIRE_STACK.push [self.class.instance_method(:require), self]
            _fix_kernel
        ensure
            $@.replace caller if $@
        end

        def back_require!
            REQUIRE_STACK.pop
            _fix_kernel
        ensure
            $@.replace caller if $@
        end

        def use_kernel!
            Kernel.send :define_method, INSTANCE_ORIGIN
        ensure
            $@.replace caller if $@
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
            [file, file + ".rb"].each{|x|
                begin
                    if @sam.has_file_in?(x)
                        path = "./" + @sam.genfile(x)
                        return ORIGIN.call path
                    end
                rescue LoadError
                ensure
                    $@.replace caller if $@
                end
            }
            ORIGIN.call file
        ensure
            $@.replace caller if $@
        end

        def _fix_kernel
            if REQUIRE_STACK[-1]
                m, o = REQUIRE_STACK[-1]
                if o == Kernel
                    use_kernel!
                else
                    Kernel.send :define_method, :require do |*args|
                        m.bind(o).call(*args)
                    end
                end
            else
                use_kernel!
            end
        ensure
            $@.replace caller if $@
        end        
    end
end