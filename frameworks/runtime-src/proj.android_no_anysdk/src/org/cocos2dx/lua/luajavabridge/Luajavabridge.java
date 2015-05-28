package org.cocos2dx.lua.luajavabridge;


import java.io.File;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;
import android.view.ViewGroup;


public class Luajavabridge {
	public static int sAppVersionCode = -1;

	public static void init(Cocos2dxActivity cocos2dActivity) {
		
		sActivity = cocos2dActivity;
	}
	
	public static int getAppVersionCode() {
		if (Luajavabridge.sAppVersionCode == -1) {			
			try {
				PackageInfo info = sActivity.getPackageManager().getPackageInfo(
				        getPackageName(), 0);
				Luajavabridge.sAppVersionCode = info.versionCode;
			} catch (NameNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return Luajavabridge.sAppVersionCode;
	}
}
