module Gap
    class HashChain
        HashNode = Struct.new :hash, :next
        class HashNode
            def initialize(hash = {}, nx = nil)
                super(hash, nx)
            end

            def [](a)
                if self.hash.include?(a)
                    self.hash[a]
                elsif self.next
                    self.next[a]
                else
                    nil
                end
            end

            def []=(a, b)
                self.hash[a] = b
            end

            def include?(a)
                if self.hash.include?(a)
                    true
                elsif self.next
                    self.next.include?(a)
                else
                    false
                end
            end

            def delete(a)
                self.hash.delete a
            end

            def deleteAll(a)
                self.hash.delete a
                self.next.deleteAll a if self.next
            end
        end

        def initialize(hash = {})
            @hashnode = HashNode.new hash
        end

        def append(node = HashNode.new)
            node.next = @hashnode
            @hashnode = node
        end

        def [](a)
            @hashnode[a]
        end

        def []=(a, b)
            @hashnode[a] = b
        end

        def include?(a)
            @hashnode.include?(a)
        end

        def delete(a)
            @hashnode.delete(a)
        end

        def each
            @hashnode.hash.each{|k, v| yield k, v}
        end

        def fromIO(io)
            h = HashNode.new {}
            while lenbuf = io.read(8)
                len, = lenbuf.unpack("Q")
                text = io.read(len)
                hash = Marshal.load Zlib::Inflate.inflate text
                h = HashNode.new hash, h
            end
            @hashnode = h
        end

        def toIO(io)
            ret = []
            h = @hashnode
            while h
                ret << h.hash
                h = h.next
            end
            ret.reverse.each{|h|
                text = Zlib::Deflate.deflate(Marshal.dump(h), 9)
                len  = [text.length].pack("Q")
                io.write len
                io.write text
            }
        end
    end
end