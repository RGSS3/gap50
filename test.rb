require 'gap50'
require 'gap-launcher'

x = Gap::Ext::Launcher.provide
Gap::Maker.new do
    FROM "test.sam"
    COPY x.genfile("RGSS103J.dll"), "RGSS103J.dll"
    COPY x.genfile("xp_game.exe"), "Game.exe"
    WRITE "Game.ini", %{[Game]
Library=RGSS103J.dll
Scripts=Scripts.rxdata
Title=Test
RTP1=
RTP2=
RTP3=
}
    WRITE "Scripts.rxdata", Gap::Ext::Launcher.make_script(["print 'Hello world'"])
    RUN "Game.exe"
    tear
end
