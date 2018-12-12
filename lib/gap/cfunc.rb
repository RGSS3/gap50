module Gap
    class CFunc
        def initialize(sam = Gap::Main)
            @sam = sam
        end

        def gen(name, args, text)
            cpp = _file name, ".cpp"
            outdll = _file name, ".dll"
            dll = name + ".dll"
            output = @sam.genfile dll do
                @sam.writefile cpp, 
                    %{extern "C" int __stdcall #{name}(#{args}) {
#{text}
}}
                system "g++ #{cpp} -shared -static -s -m32 -o #{outdll} -Wl,-add-stdcall-alias"
                open(outdll, "rb") do |f| f.read end
            end
            Gap::DLL.new(dll)[name]
        end

        def genlib(name, text)
            cpp = _file name, ".cpp"
            outdll = _file name, ".dll"
            dll = name + ".dll"
            output = @sam.genfile dll do
                @sam.writefile cpp, 
                    %{#define GAPI(type) extern "C" type __stdcall
#{text}
}
                system "g++ #{cpp} -shared -static -s -m32 -o #{outdll} -Wl,-add-stdcall-alias"
                open(outdll, "rb") do |f| f.read end
            end
            Gap::DLL.new(dll)
        end

        DEFAULT_GEN = CFunc.new
        def self.gen(name, args, text)
            DEFAULT_GEN.gen name, args, text
        end

        def self.genlib(name, text)
            DEFAULT_GEN.genlib name, text
        end

        private
        def _file(name, ext = "")
            "temp/cfunc_" << name << ext
        end
    end
end