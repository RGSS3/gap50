module Gap
    MD5_INIT   = Win32API.new("ADVAPI32", "MD5Init", "p", "L")
    MD5_UPDATE = Win32API.new("ADVAPI32", "MD5Update", "ppL", "L")
    MD5_FINAL  = Win32API.new("ADVAPI32", "MD5Final", "p", "L")
    class MD5
        def initialize
            @ctx = "\0" * 128 # buf
            MD5_INIT.call(@ctx)
        end

        def update(str)
            MD5_UPDATE.call(@ctx, str, str.unpack("C*").size)
        end

        def digest
            MD5_FINAL.call(@ctx)
            @ctx[88, 16]
        end

        def self.digest(a)
            x = MD5.new
            x.update a
            x.digest
        end

        def self.hexdigest(a)
            digest(a).unpack("H*").first
        end

        def self.file(fn)
            open(fn, 'rb') do |f|
                x = MD5.new
                while (r = f.read(10240))
                    x.update(r)
                end
                x.digest
            end
        end

        def self.filehex(fn)
            file(fn).unpack("H*").first
        end
    end
end