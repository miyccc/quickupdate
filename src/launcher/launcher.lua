package.loaded["launcher.init"] = nil
require("launcher.init")

local function enter_game()
    --TODO:这里加载游戏包
    if GAME_RELEASE then
        cc.LuaLoadChunksFromZIP("lib/game.zip")
    end
	require("app.MyApp").new():run()
end

local LauncherScene = lcher_class("LauncherScene", function()
	local scene = cc.Scene:create()
	scene.name = "LauncherScene"
    return scene
end)


function LauncherScene:ctor()
    self._path = Launcher.writablePath .. "upd/"
    if Launcher.needUpdate then
        Launcher.performWithDelayGlobal(function()
            self:_checkUpdate()
        end, 0.1)
    else
        enter_game()
    end
end

function LauncherScene:_checkUpdate()
	Launcher.mkDir(self._path)

	self._curListFile =  self._path .. Launcher.fListName
	if Launcher.fileExists(self._curListFile) then
        self._fileList = Launcher.doFile(self._curListFile)
    end

    if self._fileList ~= nil then
        local appVersionCode = Launcher.getAppVersionCode()
        if appVersionCode ~= self._fileList.appVersion then
            --新的app已经更新需要删除upd/目录下的所有文件
            Launcher.removePath(self._path)
            require("main")
            return
        end
    else
    	self._fileList = Launcher.doFile(Launcher.fListName)
    end

    self._textLabel = cc.Label:createWithTTF(STR_LCHER_HAS_UPDATE, LCHER_FONT, 20)
    self._textLabel:setColor({r = 255, g = 255, b = 255})
    self._textLabel:setPosition(Launcher.cx, Launcher.cy - 60)
    self:addChild(self._textLabel)

    if self._fileList == nil then
    	self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    	self:_endUpdate()
    end

    self:_requestFromServer(Launcher.libDir .. Launcher.lcherZipName, Launcher.RequestType.LAUNCHER, 30)
end

-- 对应不同错误作出不同的提示
function LauncherScene:_endUpdate()
	if self._updateRetType ~= Launcher.UpdateRetType.SUCCESSED then
		print(string.format("update errorCode = %d", self._updateRetType))
		Launcher.removePath(self._curListFile)
	end

	enter_game()
end

function LauncherScene:_requestFromServer(filename, requestType, waittime)
    local url = Launcher.server .. filename
    print('create request:',url)
    if Launcher.needUpdate then
        local request = cc.HTTPRequest:createWithUrl(function(event) 
        	self:_onResponse(event, requestType)
        end, url, cc.kCCHTTPRequestMethodGET)

        if request then
        	request:setTimeout(waittime or 30)
        	request:start()
    	else
    		--初始化网络错误
    		self._updateRetType = UpdateRetType.NETWORK_ERROR
        	self:_endUpdate()
    	end
    else
    	--不更新
    	enter_game()
    end
end

function LauncherScene:_onResponse(event, requestType)
    local request = event.request
    if event.name == "completed" then
        if request:getResponseStatusCode() ~= 200 then
            self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
        	self:_endUpdate()
        else
            local dataRecv = request:getResponseData()
            if requestType == Launcher.RequestType.LAUNCHER then
            	self:_onLauncherPacakgeFinished(dataRecv)
                print('_onLauncherPacakgeFinished')
            elseif requestType == Launcher.RequestType.FLIST then
            	self:_onFileListDownloaded(dataRecv)
                print('_onFileListDownloaded')
            else
            	self:_onResFileDownloaded(dataRecv)
                print('_onResFileDownloaded')
            end
        end
    elseif event.name == "progress" then
    	 if requestType == Launcher.RequestType.RES then
    	 	self:_onResProgress(event.dltotal)
    	 end
    else
        self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
        self:_endUpdate()
    end
end

function LauncherScene:_onLauncherPacakgeFinished(dataRecv)
	Launcher.mkDir(self._path .. Launcher.libDir)
	local localmd5 = nil
	local localPath = self._path .. Launcher.libDir .. Launcher.lcherZipName
	if not Launcher.fileExists(localPath) then
		localPath = Launcher.libDir .. Launcher.lcherZipName
	end
		
	localmd5 = Launcher.fileMd5(localPath)

	local downloadMd5 =  Launcher.fileDataMd5(dataRecv)

	if downloadMd5 ~= localmd5 then
		Launcher.writefile(self._path .. Launcher.libDir .. Launcher.lcherZipName, dataRecv)
        require("main")
    else
    	self:_requestFromServer(Launcher.fListName, Launcher.RequestType.FLIST)
    end
end

function LauncherScene:_onFileListDownloaded(dataRecv)
	self._newListFile = self._curListFile .. Launcher.updateFilePostfix
	Launcher.writefile(self._newListFile, dataRecv)
	self._fileListNew = Launcher.doFile(self._newListFile)
	if self._fileListNew == nil then
        self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
		self:_endUpdate()
		return
	end

	if self._fileListNew.version == self._fileList.version then
		Launcher.removePath(self._newListFile)
		self._updateRetType = Launcher.UpdateRetType.SUCCESSED
		self:_endUpdate()
		return
	end

	--创建资源目录
	local dirPaths = self._fileListNew.dirPaths
    for i=1,#(dirPaths) do
        Launcher.mkDir(self._path..(dirPaths[i].name))
    end

    self:_updateNeedDownloadFiles()

    self._numFileCheck = 0
    self:_reqNextResFile()

end

function LauncherScene:_onResFileDownloaded(dataRecv)
	local fn = self._curFileInfo.name .. Launcher.updateFilePostfix
	Launcher.writefile(self._path .. fn, dataRecv)
	if Launcher.checkFileWithMd5(self._path .. fn, self._curFileInfo.code) then
		table.insert(self._downList, fn)
		self._hasDownloadSize = self._hasDownloadSize + self._curFileInfo.size
		self._hasCurFileDownloadSize = 0
		self:_reqNextResFile()
	else
		--文件验证失败
        self._updateRetType = Launcher.UpdateRetType.MD5_ERROR
    	self:_endUpdate()
	end
end

function LauncherScene:_onResProgress(dltotal)
	self._hasCurFileDownloadSize = dltotal
    self:_updateProgressUI()
end

function LauncherScene:_updateNeedDownloadFiles()
	self._needDownloadFiles = {}
    self._needRemoveFiles = {}
    self._downList = {}
    self._needDownloadSize = 0
    self._hasDownloadSize = 0
    self._hasCurFileDownloadSize = 0

    local newFileInfoList = self._fileListNew.fileInfoList
    local oldFileInfoList = self._fileList.fileInfoList

    local hasChanged = false
    for i=1, #(newFileInfoList) do
        hasChanged = false
        for k=1, #(oldFileInfoList) do
            if newFileInfoList[i].name == oldFileInfoList[k].name then
                hasChanged = true
                if newFileInfoList[i].code ~= oldFileInfoList[k].code then
                    local fn = newFileInfoList[i].name .. Launcher.updateFilePostfix
                    if Launcher.checkFileWithMd5(self._path .. fn, newFileInfoList[i].code) then
                        table.insert(self._downList, fn)
                    else
                        self._needDownloadSize = self._needDownloadSize + newFileInfoList[i].size
                        table.insert(self._needDownloadFiles, newFileInfoList[i])
                    end
                end
                table.remove(oldFileInfoList, k)
                break
            end
        end
        if hasChanged == false then
            self._needDownloadSize = self._needDownloadSize + newFileInfoList[i].size
            table.insert(self._needDownloadFiles, newFileInfoList[i])
        end
    end
    self._needRemoveFiles = oldFileInfoList

    print("self._needDownloadFiles count = " .. (#self._needDownloadFiles))

    self._progressLabel = cc.Label:createWithTTF("0%", LCHER_FONT, 20)
    self._progressLabel:setColor({r = 255, g = 255, b = 255})
    self._progressLabel:setPosition(Launcher.cx, Launcher.cy - 20)
    self:addChild(self._progressLabel)

    local progressBarBg = cc.FilteredSpriteWithOne:create("launcher/logo.png")
    local grayFilter = cc.GrayFilter:create(0.2, 0.3, 0.5, 0.2)
    progressBarBg:setFilter(grayFilter)
    self:addChild(progressBarBg)
    local progressBarBgSize = progressBarBg:getContentSize()
    local progressBarPt = {x = Launcher.cx, y = Launcher.cy + progressBarBgSize.height * 0.5}
    progressBarBg:setPosition(progressBarPt)

    self._progressBar = cc.ProgressTimer:create(cc.Sprite:create("launcher/logo.png"))
    self._progressBar:setType(Launcher.PROGRESS_TIMER_BAR)
    self._progressBar:setMidpoint({x = 0, y = 0})
    self._progressBar:setBarChangeRate({x = 0, y = 1})
    self._progressBar:setPosition(progressBarPt)
    self:addChild(self._progressBar)

    self._textLabel:setString(STR_LCHER_UPDATING_TEXT)

end

function LauncherScene:_updateProgressUI()
	local downloadPro = ((self._hasDownloadSize + self._hasCurFileDownloadSize) * 100) / (self._needDownloadSize)
    self._progressBar:setPercentage(downloadPro)
    self._progressLabel:setString(string.format("%d%%", downloadPro))
end

function LauncherScene:_reqNextResFile()
    self:_updateProgressUI()
    self._numFileCheck = self._numFileCheck + 1
    self._curFileInfo = self._needDownloadFiles[self._numFileCheck]
    if self._curFileInfo and self._curFileInfo.name then
    	self:_requestFromServer(self._curFileInfo.name, Launcher.RequestType.RES)
    else
    	self:_endAllResFileDownloaded()
    end

end

function LauncherScene:_endAllResFileDownloaded()
	local data = Launcher.readFile(self._newListFile)
    Launcher.writefile(self._curListFile, data)
    self._fileList = Launcher.doFile(self._curListFile)
    if self._fileList == nil then
        self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    	self:_endUpdate()
        return
    end

    Launcher.removePath(self._newListFile)

    local offset = -1 - string.len(Launcher.updateFilePostfix)
    for i,v in ipairs(self._downList) do
        v = self._path .. v
        local data = Launcher.readFile(v)

        local fn = string.sub(v, 1, offset)
        Launcher.writefile(fn, data)
        Launcher.removePath(v)
    end

    for i,v in ipairs(self._needRemoveFiles) do
        Launcher.removePath(self._path .. (v.name))
    end

    self._updateRetType = Launcher.UpdateRetType.SUCCESSED
    self:_endUpdate()
end




local lchr = LauncherScene.new()
Launcher.runWithScene(lchr)
