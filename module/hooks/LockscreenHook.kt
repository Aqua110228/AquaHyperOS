package com.aqua.hyperos.hooks

import android.content.Context
import android.view.View
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class LockscreenHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "AquaHyperOS-Lock"
        private const val PKG = "com.android.systemui"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            XposedBridge.log("$TAG: Init")
            hookFingerprint(lpparam)
            hookNavBar(lpparam)
            XposedBridge.log("$TAG: Loaded")
        }.onFailure {
            XposedBridge.log("$TAG: Failed - ${it.message}")
        }
    }
    
    private fun hookFingerprint(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.systemui.biometrics.UdfpsControllerOverlay",
                lpparam.classLoader
            ) ?: XposedHelpers.findClassIfExists(
                "com.android.systemui.biometrics.UdfpsKeyguardView",
                lpparam.classLoader
            ) ?: XposedHelpers.findClassIfExists(
                "com.android.systemui.biometrics.UdfpsView",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "setVisibility",
                Int::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun beforeHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val view = param.thisObject as View
                            val prefs = view.context.getSharedPreferences(
                                "aquahyperos_settings",
                                Context.MODE_WORLD_READABLE
                            )
                            
                            if (prefs.getBoolean("lockscreen_hide_fingerprint_icon", false)) {
                                param.args[0] = View.GONE
                            }
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: Fingerprint hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Fingerprint hook failed - ${it.message}")
        }
    }
    
    private fun hookNavBar(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.systemui.navigationbar.views.NavigationBarView",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "setVisibility",
                Int::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun beforeHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val view = param.thisObject as View
                            val prefs = view.context.getSharedPreferences(
                                "aquahyperos_settings",
                                Context.MODE_WORLD_READABLE
                            )
                            
                            if (prefs.getBoolean("lockscreen_show_navigation_bar", false)) {
                                param.args[0] = View.VISIBLE
                            }
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: NavBar hooked")
        }.onFailure {
            XposedBridge.log("$TAG: NavBar hook failed - ${it.message}")
        }
    }
}
