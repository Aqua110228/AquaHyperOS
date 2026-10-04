package com.aqua.hyperos.hooks

import android.content.Context
import android.content.Intent
import com.aqua.hyperos.utils.Logger
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class SettingsInjectionHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "设置注入"
        private const val PKG = "com.android.settings"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        Logger.hookStart(TAG, PKG)
        
        runCatching {
            injectSettingsEntry(lpparam)
            Logger.i(TAG, "设置注入模块加载完成")
        }.onFailure {
            Logger.e(TAG, "设置注入模块加载失败", it)
        }
    }
    
    private fun injectSettingsEntry(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            // 方法1：Hook DashboardFragment（MIUI设置主页）
            val dashboardClass = "com.android.settings.dashboard.DashboardFragment"
            val clazz = XposedHelpers.findClassIfExists(dashboardClass, lpparam.classLoader)
            
            if (clazz == null) {
                Logger.classNotFound(TAG, dashboardClass)
                // 尝试小米专用类
                tryMiuiSettings(lpparam)
                return
            }
            
            Logger.classFound(TAG, dashboardClass)
            
            // Hook onCreate
            XposedHelpers.findAndHookMethod(
                clazz,
                "onCreatePreferences",
                android.os.Bundle::class.java,
                String::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val fragment = param.thisObject
                            val context = XposedHelpers.callMethod(fragment, "getContext") as? Context ?: return
                            
                            // 添加我们的设置入口
                            injectPreference(fragment, context)
                            Logger.i(TAG, "设置入口已注入")
                        }.onFailure {
                            Logger.e(TAG, "注入设置入口失败", it)
                        }
                    }
                }
            )
            
            Logger.methodHooked(TAG, "onCreatePreferences")
            Logger.hookSuccess(TAG, "设置主页")
        }.onFailure {
            Logger.hookFailed(TAG, "设置主页", it.message ?: "未知错误")
        }
    }
    
    private fun tryMiuiSettings(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            // 尝试小米设置专用类
            val miuiClass = "com.android.settings.MiuiSettings"
            val clazz = XposedHelpers.findClassIfExists(miuiClass, lpparam.classLoader) ?: return
            
            Logger.classFound(TAG, miuiClass, isFallback = true)
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "onCreate",
                android.os.Bundle::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val activity = param.thisObject as android.app.Activity
                            // 这里可以注入设置入口
                            Logger.i(TAG, "MiuiSettings 已Hook")
                        }
                    }
                }
            )
            
            Logger.hookSuccess(TAG, "小米设置")
        }.onFailure {
            Logger.w(TAG, "小米设置Hook失败: ${it.message}")
        }
    }
    
    private fun injectPreference(fragment: Any, context: Context) {
        try {
            // 获取 PreferenceScreen
            val preferenceScreen = XposedHelpers.callMethod(fragment, "getPreferenceScreen")
            
            if (preferenceScreen == null) {
                Logger.w(TAG, "PreferenceScreen 为空")
                return
            }
            
            // 创建我们的Preference
            val preferenceClass = XposedHelpers.findClass(
                "androidx.preference.Preference",
                context.classLoader
            )
            
            val preference = XposedHelpers.newInstance(
                preferenceClass,
                context
            )
            
            // 设置属性
            XposedHelpers.callMethod(preference, "setKey", "aquahyperos_settings")
            XposedHelpers.callMethod(preference, "setTitle", "AquaHyperOS")
            XposedHelpers.callMethod(preference, "setSummary", "HyperOS 深度定制模块")
            XposedHelpers.callMethod(preference, "setOrder", 0) // 放在最前面
            
            // 设置图标（如果有）
            try {
                val iconRes = context.resources.getIdentifier(
                    "ic_settings_system_update",
                    "drawable",
                    context.packageName
                )
                if (iconRes != 0) {
                    val drawable = context.getDrawable(iconRes)
                    XposedHelpers.callMethod(preference, "setIcon", drawable)
                }
            } catch (e: Exception) {
                // 图标设置失败，忽略
            }
            
            // 设置点击事件
            XposedHelpers.callMethod(
                preference,
                "setOnPreferenceClickListener",
                object : androidx.preference.Preference.OnPreferenceClickListener {
                    override fun onPreferenceClick(pref: androidx.preference.Preference): Boolean {
                        // 打开我们的设置Activity
                        val intent = Intent().apply {
                            setClassName(
                                "com.aqua.hyperos",
                                "com.aqua.hyperos.ui.SettingsActivity"
                            )
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        
                        runCatching {
                            context.startActivity(intent)
                        }.onFailure {
                            Logger.e(TAG, "打开设置失败", it)
                            android.widget.Toast.makeText(
                                context,
                                "无法打开设置，请从桌面图标进入",
                                android.widget.Toast.LENGTH_SHORT
                            ).show()
                        }
                        
                        return true
                    }
                }
            )
            
            // 添加到PreferenceScreen
            XposedHelpers.callMethod(preferenceScreen, "addPreference", preference)
            
            Logger.configApplied(TAG, "设置入口已添加到第一位")
        } catch (e: Exception) {
            Logger.e(TAG, "创建Preference失败", e)
        }
    }
}
