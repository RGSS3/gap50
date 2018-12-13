begin
    Win32API
rescue NameError
    require 'win32api'
end

begin
    Zlib
rescue NameError
    require 'zlib'
end

