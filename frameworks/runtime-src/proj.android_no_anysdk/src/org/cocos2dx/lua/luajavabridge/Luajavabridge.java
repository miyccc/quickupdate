package org.cocos2dx.lua.luajavabridge;


import org.cocos2dx.lib.Cocos2dxActivity;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;


public class Luajavabridge {
	public static int sAppVersionCode = -1;
	private static Cocos2dxActivity sActivity;

	public static void init(Cocos2dxActivity cocos2dActivity) {
		
		sActivity = cocos2dActivity;
	}
	
	public static int getAppVersionCode() {
		if (Luajavabridge.sAppVersionCode == -1) {			
			try {
				PackageInfo info = sActivity.getPackageManager().getPackageInfo(getPackageName(), 0);
				Luajavabridge.sAppVersionCode = info.versionCode;
			} catch (NameNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return Luajavabridge.sAppVersionCode;
	}

	private static String getPackageName() {
		// TODO Auto-generated method stub
		return null;
	}
}
