module Gap
    class Cache
        def initialize(filename)
            @filename = filename
            _load_or_create
        end

        def [](a)
            @hash[a]
        end

        def has?(a)
            @hash.include?(a)
        end

        def []=(a, b)
            @hash[a] = b
        end

        def load
            _load
        end

        def save
            _save
        end

        def transaction
            load
            yield self
        ensure
            save
        end

    private
        def _load
            @hash = open(@filename, 'rb') do |f|
                Marshal.load Zlib::Inflate.inflate f.read
            end
        end

        def _save
            open(@filename, 'wb') do |f|
                f.write (Zlib::Deflate.deflate Marshal.dump @hash)                
            end
        end

        def _load_or_create
            load
        rescue
            @hash = {}
            save
        end
    end
end
