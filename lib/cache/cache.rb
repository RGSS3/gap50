module Gap
    class Cache
        def initialize(filename)
            @filename = filename
            _load_or_create
        end

        def [](a)
            @hash[a]
        end

        def remove(key)
            @hash.delete key
        end

        def has?(a)
            @hash.include?(a)
        end

        def []=(a, b)
            @hash[a] = b
        end

        def load
            _load_or_create
        end

        def save
            _save
        end

        def each
            @hash.each{|k, v|
                yield k, v
            }
        end

        def transaction
            load
            ret = yield self
            save
            ret
        end

    private
        def _getdata
            head  = []
            data  = []
            start = 0
            @hash.each{|k, v|
                r = Zlib::Deflate.deflate v, 9
                head << [k, v.size, r.size, start]
                data << r
                start += r.size
            }
            [head, data]
        end
        def _load
            @hash = HashChain.new
            open(@filename, 'rb') do |f|
                @hash.fromIO f
            end
        end

        def _save
            open(@filename, 'wb') do |f|
                @hash.toIO f
            end
        end

        def _load_or_create
            _load
        rescue
            @hash = HashChain.new
            _save
        end
    end
end
