
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
end

function MainScene:onEnter()
    self:_requestFromServer(DownloadServerUrl,1,30)
end

function MainScene:onExit()
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
    print(event.name,request:getResponseStatusCode())
    if event.name == "completed" then
        if request:getResponseStatusCode() == 200 then
        else
            print('ERROR:network response status code error:%d',request:getResponseStatusCode())
        end
    elseif event.name == "progress" then
    	 if requestType == Launcher.RequestType.RES then
    	 end
    else
        print('ERROR:network other error')
    end
end

return MainScene
