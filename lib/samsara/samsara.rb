module Gap
    class Samsara
        Meta = Struct.new :meta
        attr_accessor :filepath
        def initialize(name, filepath = "samfile")
            @cache = Gap::Cache.new name
            @filepath = filepath
        end

        
        #
        #   gen : [Any] -> ([Any] -> Any) -> Any
        #
        def gen(*path)
            if @cache.has?(path)
                @cache[path]
            else
                @cache.transaction do |db|
                    db[path] = yield path
                    db[path]
                end
            end
        end

        #
        #   genfile : filename -> [Any] -> (filename -> [Any] -> Any) -> Any
        #
        def genfile(filename, args = nil, &block)
            realpath = file(filename)
            md5key =  [Meta.new(:filemd5), filename]
            filekey = [Meta.new(:file), filename]
            if @cache.has?(md5key) && 
               @cache.has?(filekey) &&
               FileTest.file?(realpath) && 
               MD5.filehex(realpath) == @cache[md5key]
            elsif @cache.has?(filekey)
                _writefile realpath, @cache[filekey]
            else
                u = gen(filename, *args, &block)
                @cache.transaction do |db|
                    db[md5key]  = MD5.hexdigest u
                    db[filekey] = u
                    _writefile realpath, @cache[filekey]
                end
            end
            realpath
        end

        def has_file_in?(filename) 
            md5key =  [Meta.new(:filemd5), filename]
            filekey = [Meta.new(:file), filename]
            @cache.has?(md5key) && 
            @cache.has?(filekey) && 
            @cache[md5key] != nil &&
            MD5.hexdigest(@cache[filekey]) == @cache[md5key]
        end

        def need_update_file?(filename, realfile)
            if has_file_in?(filename)
                md5key =  [Meta.new(:filemd5), filename]
                MD5.filehex(realfile) != @cache[md5key]
            else
                true
            end
        end

        def file(name)
            _file(name)
        end

        def writefile(a, b)
            _writefile a, b
        end

        def readfile(a)
            _readfile a
        end

        def mangle(name)
            _mangle(name)
        end

    private
        def _file(name)
            File.join(@filepath, _mangle(name))
        end

        def _mangle(name)
            name.gsub("://", "$SEP$/").gsub(/[:"']/){ "$#{$&.unpack("H")}$" }
        end

        def _mkdirp(name)
            names = name.tr("\\", "/").split("/")[0..-2]
            names.inject(""){|a, b|
                if a == ""
                    path = b
                else
                    path = a + "/" + b
                end
                if !FileTest.directory?(path)
                    Dir.mkdir(path)
                end
                path
            }
        end

        def _readfile(name)
            open(name, 'rb') do |f|
                f.read
            end
        end
        def _writefile(name, val)
            _mkdirp(name)
            open(name, "wb") do |f|
                f.write val
            end
        end

    end
end