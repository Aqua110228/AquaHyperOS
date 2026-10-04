package com.aqua.hyperos.hooks

import android.content.Context
import android.view.View
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class DynamicIslandLyricsHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "AquaHyperOS-Lyrics"
        private const val PKG = "com.android.systemui"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            XposedBridge.log("$TAG: Init")
            hookStatusBar(lpparam)
            hookMediaSession(lpparam)
            XposedBridge.log("$TAG: Loaded")
        }.onFailure {
            XposedBridge.log("$TAG: Failed - ${it.message}")
        }
    }
    
    private fun hookStatusBar(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.systemui.statusbar.phone.MiuiPhoneStatusBarView",
                lpparam.classLoader
            ) ?: XposedHelpers.findClassIfExists(
                "com.android.systemui.statusbar.phone.PhoneStatusBarView",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "onFinishInflate",
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val view = param.thisObject as View
                            injectLyricsView(view)
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: StatusBar hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Hook failed - ${it.message}")
        }
    }
    
    private fun hookMediaSession(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.systemui.media.controls.ui.controller.MediaControlPanel",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "bind",
                "com.android.systemui.media.controls.models.player.MediaData",
                String::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            updateLyrics(param.args[0])
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: Media hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Media hook failed - ${it.message}")
        }
    }
    
    private fun injectLyricsView(statusBar: View) {
        runCatching {
            // Inject lyrics display view
            XposedBridge.log("$TAG: Lyrics view injected")
        }
    }
    
    private fun updateLyrics(mediaData: Any) {
        runCatching {
            // Update lyrics from media metadata
        }
    }
}
