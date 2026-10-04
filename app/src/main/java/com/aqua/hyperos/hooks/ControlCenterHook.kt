package com.aqua.hyperos.hooks

import android.content.Context
import android.view.View
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class ControlCenterHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "AquaHyperOS-CC"
        private const val PKG = "com.android.systemui"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            XposedBridge.log("$TAG: Init")
            hookQSTile(lpparam)
            XposedBridge.log("$TAG: Loaded")
        }.onFailure {
            XposedBridge.log("$TAG: Failed - ${it.message}")
        }
    }
    
    private fun hookQSTile(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.systemui.qs.tileimpl.MiuiQSTileView",
                lpparam.classLoader
            ) ?: XposedHelpers.findClassIfExists(
                "com.android.systemui.qs.tileimpl.QSTileViewImpl",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "onLayout",
                Boolean::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val view = param.thisObject as View
                            applyTileStyle(view)
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: QSTile hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Hook failed - ${it.message}")
        }
    }
    
    private fun applyTileStyle(view: View) {
        runCatching {
            val prefs = view.context.getSharedPreferences(
                "aquahyperos_settings",
                Context.MODE_WORLD_READABLE
            )
            
            if (prefs.getBoolean("cc_large_tile", false)) {
                view.layoutParams?.apply {
                    width = (width * 1.2).toInt()
                    height = (height * 1.2).toInt()
                }
            }
            
            if (prefs.getBoolean("cc_square_tile", false)) {
                view.layoutParams?.apply {
                    val size = maxOf(width, height)
                    width = size
                    height = size
                }
            }
        }
    }
}
