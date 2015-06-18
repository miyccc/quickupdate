require("launcher.init")

GameHttpMsgTypeEnum = {
    SceneOne = 1,
    SceneTwo = 2,
}

--去除扩展名
local function stripExtension(fileName)  
    local idx = fileName:match(".+()%.%w+$")  
    if(idx) then  
        return fileName:sub(1, idx-1)
    else  
        return fileName
    end  
end

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self._isDownloading = false
end

function MainScene:onEnter()
    --self:_requestFromServer(DownloadServerUrl,1,30)
    self:_initUI()
end

function MainScene:onExit()
end

function MainScene:_initUI()
    cc.ui.UILabel.new({UILabelType = 2, text = "Hello, World", size = 64})
        :align(display.CENTER, display.cx, display.top - 100)
        :addTo(self)

    self._firButton = cc.ui.UIPushButton.new({normal = 'image/rw.png', pressed = 'image/rwa.png'}) 
        :onButtonClicked(function(event)
            self:_firClick(event)
        end)
        :align(display.CENTER, display.cx + 70, display.cy)
        :addTo(self)

    self._secButton = cc.ui.UIPushButton.new({normal = 'image/fl.png', pressed = 'image/fla.png'})
        :onButtonClicked(function(event)
            self:_sceClick(event)
        end)
        :align(display.CENTER, display.cx - 70, display.cy)
        :addTo(self)
end

function MainScene:_firClick(event)
    local key = cc.UserDefault:getInstance():getIntegerForKey('SceneOne')
    if key and key ~= 0 then
        self:_preloadZip(Launcher.writablePath .. 'upd/lib/sceneone.zip')
        app:enterScene('SceneOne')
    else
        self._firButton:setButtonEnabled(false)
        self:_requestFromServer(SCENE_ONE_URL,GameHttpMsgTypeEnum.SceneOne,30)
    end
end

function MainScene:_sceClick(event)
    local key = cc.UserDefault:getInstance():getIntegerForKey('SceneTwo')
    if key and key ~= 0 then
        self:_preloadZip(Launcher.writablePath .. 'upd/lib/scenetwo.zip')
        app:enterScene('SceneTwo')
    else
        self._secButton:setButtonEnabled(false)
        self:_requestFromServer(SCENE_TWO_URL,GameHttpMsgTypeEnum.SceneTwo,30)
    end
end

function MainScene:_requestFromServer(url, requestType, waittime)
    print('create request:',url)
    local request = cc.HTTPRequest:createWithUrl(function(event) 
        self:_onResponse(event, requestType)
    end, url, cc.kCCHTTPRequestMethodGET)

    if request then
        request:setTimeout(waittime or 30)
        request:start()
    else
        --初始化网络错误
        print('ERROR:network init error')
    end
end

function MainScene:_onResponse(event,requestType)
    local request = event.request
    if event.name == "completed" then
        if request:getResponseStatusCode() == 200 then
            local dataRecv = request:getResponseData()
            local fileName = nil
            if requestType == GameHttpMsgTypeEnum.SceneOne then
                fileName = Launcher.writablePath .. 'upd/sceneone.zip'
            elseif requestType == GameHttpMsgTypeEnum.SceneTwo then
                fileName = Launcher.writablePath .. 'upd/scenetwo.zip'
            end
            self:_upzipAndLoadFile(fileName,dataRecv,requestType)
        else
            print('ERROR:network response status code error:%d',request:getResponseStatusCode())
        end
    elseif event.name == "progress" then
    else
        print('ERROR:network other error')
    end
end

function MainScene:_upzipAndLoadFile(fileName,dataRecv,requestType)
    Launcher.writefile(fileName,dataRecv)
    self:_unzipFile(fileName,function()
        Launcher.removePath(fileName)
        if requestType == GameHttpMsgTypeEnum.SceneOne then
            self._firButton:setButtonEnabled(true)
            cc.UserDefault:getInstance():setIntegerForKey('SceneOne',1)
        elseif requestType == GameHttpMsgTypeEnum.SceneTwo then
            self._secButton:setButtonEnabled(true)
            cc.UserDefault:getInstance():setIntegerForKey('SceneTwo',1)
        end
        cc.UserDefault:getInstance():flush()
    end)
end

function MainScene:_unzipFile(fileName,callBack)
    MyUnZip:getInstance():registerUnZipFinishHandler(function()
        if callBack then
            callBack()
        end
    end)
    MyUnZip:getInstance():UnZipFile(fileName, Launcher.writablePath .. 'upd/')
end 

function MainScene:_preloadZip(fullName)
    if Launcher.fileExists(fullName) then
        cc.LuaLoadChunksFromZIP('lib/'.. string.match(fullName,'.*/(.*)'))
    end
end

return MainScene
