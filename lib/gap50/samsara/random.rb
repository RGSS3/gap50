module Gap
    CR_ACQUIRE   = Win32API.new("ADVAPI32", "CryptAcquireContext", "pLLLL", "L")
    CR_GENRANDOM = Win32API.new("ADVAPI32", "CryptGenRandom", "LLp", "L")
    CR_RELEASE   = Win32API.new("ADVAPI32", "CryptReleaseContext", "LL", "L")
    class Random
        REG = {}
        def self.auto_release_proc
            proc{|id|
                if REG.include? id
                    _dispose REG[id]
                    REG.delete id
                end
            }
        end
        
        def self.register_auto_release(id, ptr)
            REG[object_id] = ptr
            ObjectSpace.define_finalizer self, auto_release_proc
        end

        def initialize
            buf = "\0" * 4
            CR_ACQUIRE.call buf, 0, 0, 1, -268435456
            @ptr, = buf.unpack("L")
            self.class.register_auto_release object_id, @ptr
        end

        def bytes(len = 16)
            buf = "\0" * len
            CR_GENRANDOM.call @ptr, len, buf
            buf
        end

        def hex(len = 16)
            bytes(len).unpack("H*").first
        end

        def next_int
            bytes(4).unpack("L").first
        end

        def self._dispose(ptr)
            if ptr
                CR_RELEASE.call ptr, 0
            end
        end

        def dispose
           self.class._dispose @ptr
           @ptr = nil
        end
    end
end