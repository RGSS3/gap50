module Gap
    class Samsara
        Meta = Struct.new :meta
        MetaFile = Meta.new :file
        MetaMD5  = Meta.new :filemd5
        attr_accessor :filepath
        def initialize(name, filepath = "samfile")
            @cache = Gap::Cache.new name
            @filepath = filepath
        end

        def fromBase64(b64)
            @cache.fromBase64 b64
        end

        def toBase64
            @cache.toBase64
        end

        def fromMarshal(text)
            @cache.fromMarshal text
        end

        def toMarshal
            @cache.toMarshal
        end

        def each(&block)
            @cache.each(&block)
        end

        def export(file, dir)
            _export file, dir
        end

        def import(file, dir)
            _import file, dir
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
            md5key =  [MetaMD5, filename]
            filekey = [MetaFile, filename]
            if @cache.has?(md5key) && 
               @cache.has?(filekey) &&
               FileTest.file?(realpath) && 
               MD5.filehex(realpath) == @cache[md5key]
            elsif @cache.has?(filekey)
                _writefile realpath, @cache[filekey]
            else
                u = yield filekey
                @cache.transaction do |db|
                    db[md5key]  = MD5.hexdigest u
                    db[filekey] = u
                    _writefile realpath, @cache[filekey]
                end
            end
            realpath
        end

        def has_file_in?(filename) 
            md5key =  [MetaMD5, filename]
            filekey = [MetaFile, filename]
            @cache.has?(md5key) && 
            @cache.has?(filekey) && 
            @cache[md5key] != nil &&
            MD5.hexdigest(@cache[filekey]) == @cache[md5key]
        end

        def need_update_file?(filename, realfile)
            if has_file_in?(filename)
                md5key =  [MetaMD5, filename]
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

        def rmdir_p(name)
            _rmdir_p(name)
        end

        
    private
        def _file(name)
            File.join(@filepath, _mangle(name))
        end

        def _mangle(name)
            name.gsub("://", "$SEP$/").gsub(/[:"']/){ "$#{$&.unpack("H")}$" }
        end

        def _demangle(name)
            name.gsub("$SEP$/", "://").gsub(/\$([a-f0-9]+)\$/) { [$1].pack("H") }
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

        def _export(file, dir)
            if has_file_in?(file)
                name = _mangle(dir + "/" + file)
                filekey = [MetaFile, file]
                _writefile(name, @cache[filekey])
            else
                raise "File not found #{file}"
            end
        end

        def _import(file, dir)
            name = _mangle(dir + "/" + file)
            @cache.transaction do |db|
                filekey = [MetaFile, file]
                md5key =  [MetaMD5, file]
                db.remove filekey
                db.remove md5key
                content = _readfile name
                db[md5key] = MD5.hexdigest(content)
                db[filekey] = content
            end
        end

        def _rmdir_p(name)
            raise if name == nil || name[0] == "/"
            files = [name]
            Dir.glob(name + "/**/*") do |f|
                files << f
            end
            files.sort!{|a, b| b.length <=> a.length}
            files.each{|x|
                if FileTest.file?(x)
                    File.delete x
                else
                    Dir.delete x
                end
            }
        end
    end
end