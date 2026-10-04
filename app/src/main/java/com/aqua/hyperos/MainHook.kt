package com.aqua.hyperos

import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.callbacks.XC_LoadPackage
import com.aqua.hyperos.hooks.*
import com.aqua.hyperos.utils.Logger

class MainHook : IXposedHookLoadPackage {
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        try {
            when (lpparam.packageName) {
                "android" -> {
                    Logger.i("MainHook", "Hook android framework")
                    CorePatchHook().handleLoadPackage(lpparam)
                }
                
                "com.android.systemui" -> {
                    Logger.i("MainHook", "Hook SystemUI")
                    StatusBarHook().handleLoadPackage(lpparam)
                    ControlCenterHook().handleLoadPackage(lpparam)
                    LockscreenHook().handleLoadPackage(lpparam)
                    ThemeBlurHook().handleLoadPackage(lpparam)
                    DynamicIslandLyricsHook().handleLoadPackage(lpparam)
                }
                
                "com.android.settings" -> {
                    Logger.i("MainHook", "Hook Settings")
                    SettingsInjectionHook().handleLoadPackage(lpparam)
                    SettingsUIHook().handleLoadPackage(lpparam)
                    SettingsAppHook().handleLoadPackage(lpparam)
                }
                
                "com.miui.home" -> {
                    Logger.i("MainHook", "Hook Launcher")
                    LauncherHook().handleLoadPackage(lpparam)
                }
            }
        } catch (e: Throwable) {
            Logger.e("MainHook", "Error in handleLoadPackage for ${lpparam.packageName}", e)
        }
    }
}
