module Gap
    class Copy
        def initialize(sam = Gap::Main)
            @sam = sam
        end

        def copy(dir, basedir, pattern)
            Dir.glob(basedir + "/" + pattern) do |all|
                file = dir + all[basedir.length..-1]
                if @sam.need_update_file?(file, all)
                    @sam.genfile file do 
                        open(all, "rb") do |f|
                            f.read
                        end
                    end
                end
            end
        end

        DEFAULT_COPY = Copy.new
        def self.copy(dir, basedir, pattern)
            DEFAULT_COPY.copy(dir, basedir, pattern)
        end
    end
end