module Gap
    module Ruby25
        URL = "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.5.3-1/rubyinstaller-2.5.3-1-x86.7z"
        def self.provide(path = "samdev/ruby25")
            @ruby = Samsara.new "ruby.sam"
            ruby_exe = "#{path}/rubyinstaller-2.5.3-1-x86/bin/ruby.exe"
            unless FileTest.exists?(ruby_exe)
                unless @ruby.has_file_in? "rubyinstaller-2.5.3-1-x86.7z" 
                    Gap::Maker.new do
                        FROM "ruby.sam"
                        aria = File.expand_path Gap::Aria2C.genfile "aria2c.exe"    
                        system "cd #{@temp} && #{aria} #{URL}"
                    end
                    @ruby = Samsara.new "ruby.sam"
                end

                file = @ruby.genfile("rubyinstaller-2.5.3-1-x86.7z")
                sza = Gap::SevenZA.genfile "7za.exe"
                system "#{sza} x -aou -o#{path} #{file}"
            end
            ruby_exe
        end
    end
end