package com.aqua.hyperos.hooks

import android.content.Context
import android.graphics.Color
import android.view.View
import com.aqua.hyperos.utils.Logger
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class StatusBarHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "状态栏"
        private const val PKG = "com.android.systemui"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        Logger.hookStart(TAG, PKG)
        
        runCatching {
            hookStatusBar(lpparam)
            hookStatusBarHeight(lpparam)
            Logger.i(TAG, "状态栏模块加载完成")
        }.onFailure {
            Logger.e(TAG, "状态栏模块加载失败", it)
        }
    }
    
    private fun hookStatusBar(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val primaryClass = "com.android.systemui.statusbar.phone.MiuiPhoneStatusBarView"
            val fallbackClass = "com.android.systemui.statusbar.phone.PhoneStatusBarView"
            
            val clazz = XposedHelpers.findClassIfExists(primaryClass, lpparam.classLoader)?.also {
                Logger.classFound(TAG, primaryClass)
            } ?: XposedHelpers.findClassIfExists(fallbackClass, lpparam.classLoader)?.also {
                Logger.classFound(TAG, fallbackClass, isFallback = true)
            } ?: run {
                Logger.classNotFound(TAG, "$primaryClass / $fallbackClass")
                return
            }
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "onFinishInflate",
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val view = param.thisObject as View
                            applyCustomization(view)
                        }.onFailure {
                            Logger.e(TAG, "应用状态栏自定义失败", it)
                        }
                    }
                }
            )
            
            Logger.methodHooked(TAG, "onFinishInflate")
            Logger.hookSuccess(TAG, "状态栏视图")
        }.onFailure {
            Logger.hookFailed(TAG, "状态栏视图", it.message ?: "未知错误")
        }
    }
    
    private fun applyCustomization(view: View) {
        val prefs = view.context.getSharedPreferences("aquahyperos_settings", Context.MODE_WORLD_READABLE)
        
        // Custom background
        if (prefs.getBoolean("statusbar_custom_bg", false)) {
            val color = prefs.getString("statusbar_bg_color", "#00000000")!!
            Logger.configLoaded(TAG, "statusbar_bg_color", color)
            
            runCatching {
                view.setBackgroundColor(Color.parseColor(color))
                Logger.configApplied(TAG, "背景颜色 = $color")
            }.onFailure {
                Logger.w(TAG, "背景颜色解析失败: $color")
            }
        }
        
        // Custom alpha
        if (prefs.getBoolean("statusbar_custom_alpha", false)) {
            val alpha = prefs.getInt("statusbar_alpha", 255)
            Logger.configLoaded(TAG, "statusbar_alpha", alpha)
            
            val newAlpha = alpha / 255f
            view.alpha = newAlpha
            Logger.configApplied(TAG, "透明度 = $alpha/255")
        }
        
        // Custom height
        if (prefs.getBoolean("statusbar_custom_height", false)) {
            val height = prefs.getInt("statusbar_height", 0)
            Logger.configLoaded(TAG, "statusbar_height", height)
            
            if (height > 0) {
                val oldHeight = view.layoutParams?.height
                view.layoutParams?.height = dpToPx(view.context, height)
                Logger.valueChanged(TAG, "高度", "${oldHeight}px", "${dpToPx(view.context, height)}px")
                Logger.configApplied(TAG, "高度 = ${height}dp")
            }
        }
    }
    
    private fun hookStatusBarHeight(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val className = "com.android.internal.policy.StatusBarUtils"
            val clazz = XposedHelpers.findClassIfExists(className, lpparam.classLoader) ?: return
            
            Logger.classFound(TAG, className)
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "getStatusBarHeight",
                Context::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val ctx = param.args[0] as Context
                            val prefs = ctx.getSharedPreferences("aquahyperos_settings", Context.MODE_WORLD_READABLE)
                            
                            if (prefs.getBoolean("statusbar_custom_height", false)) {
                                val height = prefs.getInt("statusbar_height", 0)
                                if (height > 0) {
                                    val oldHeight = param.result
                                    param.result = dpToPx(ctx, height)
                                    Logger.valueChanged(TAG, "系统状态栏高度", oldHeight, param.result)
                                }
                            }
                        }
                    }
                }
            )
            
            Logger.methodHooked(TAG, "getStatusBarHeight")
            Logger.hookSuccess(TAG, "状态栏高度")
        }.onFailure {
            Logger.w(TAG, "状态栏高度Hook失败 (非关键): ${it.message}")
        }
    }
    
    private fun dpToPx(ctx: Context, dp: Int): Int {
        val density = ctx.resources.displayMetrics.density
        return (dp * density + 0.5f).toInt()
    }
}
