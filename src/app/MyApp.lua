
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    MyUnZip:getInstance():registerUnZipFinishHandler(function()
        print('unzip finish')
    end)
    MyUnZip:getInstance():UnZipFile("/Users/binW/Downloads/game.zip", "/Users/binW/Downloads/")
    self:enterScene("MainScene")
end

return MyApp
