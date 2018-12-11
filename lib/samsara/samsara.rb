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
                open(realpath, 'wb') do |f|
                   f.write @cache[filekey]
                end
            else
                u = gen(filename, *args, &block)
                @cache.transaction do |db|
                    db[md5key]  = MD5.hexdigest u
                    db[filekey] = u
                    open(realpath, 'wb') do |f|
                        f.write @cache[filekey]
                    end
                end
            end
            realpath
        end

        def file(name)
            _file(name)
        end

    private
        def _file(name)
            File.join(@filepath, name)
        end

    end
end