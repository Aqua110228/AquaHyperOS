package com.aqua.hyperos.hooks

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.aqua.hyperos.utils.Logger
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage
import java.io.File

class LogViewerHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "LogViewer"
        private const val PKG = "com.android.settings"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            Logger.d(TAG, "Init log viewer")
            hookSettings(lpparam)
        }.onFailure {
            Logger.e(TAG, "Failed to hook", it)
        }
    }
    
    private fun hookSettings(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.settings.SettingsActivity",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "onCreate",
                android.os.Bundle::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val activity = param.thisObject as Activity
                            Logger.init(activity)
                        }
                    }
                }
            )
            
            Logger.d(TAG, "Settings hooked")
        }.onFailure {
            Logger.e(TAG, "Hook failed", it)
        }
    }
}
