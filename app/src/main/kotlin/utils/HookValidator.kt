package com.aqua.hyperos.utils

import android.content.Context
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers

/**
 * Hook 验证工具
 * 用于在运行时检测类和方法是否存在
 */
object HookValidator {
    
    private const val TAG = "AquaHyperOS-Validator"
    
    /**
     * 验证类是否存在
     */
    fun validateClass(className: String, classLoader: ClassLoader): Boolean {
        return try {
            XposedHelpers.findClass(className, classLoader)
            XposedBridge.log("$TAG: ✅ 类存在 - $className")
            true
        } catch (e: Exception) {
            XposedBridge.log("$TAG: ❌ 类不存在 - $className")
            false
        }
    }
    
    /**
     * 验证方法是否存在
     */
    fun validateMethod(
        className: String,
        methodName: String,
        classLoader: ClassLoader,
        vararg parameterTypes: Class<*>
    ): Boolean {
        return try {
            val clazz = XposedHelpers.findClass(className, classLoader)
            XposedHelpers.findMethodExact(clazz, methodName, *parameterTypes)
            XposedBridge.log("$TAG: ✅ 方法存在 - $className.$methodName")
            true
        } catch (e: Exception) {
            XposedBridge.log("$TAG: ❌ 方法不存在 - $className.$methodName: ${e.message}")
            false
        }
    }
    
    /**
     * 尝试多个可能的类名
     */
    fun findFirstExistingClass(classLoader: ClassLoader, vararg classNames: String): Class<*>? {
        for (className in classNames) {
            try {
                val clazz = XposedHelpers.findClass(className, classLoader)
                XposedBridge.log("$TAG: ✅ 找到类 - $className")
                return clazz
            } catch (e: Exception) {
                continue
            }
        }
        XposedBridge.log("$TAG: ❌ 所有类都不存在 - ${classNames.joinToString()}")
        return null
    }
    
    /**
     * 列出类的所有方法（用于调试）
     */
    fun listClassMethods(className: String, classLoader: ClassLoader) {
        try {
            val clazz = XposedHelpers.findClass(className, classLoader)
            XposedBridge.log("$TAG: 📋 类 $className 的方法列表:")
            clazz.declaredMethods.forEach { method ->
                XposedBridge.log("$TAG:   - ${method.name}(${method.parameterTypes.joinToString { it.simpleName }})")
            }
        } catch (e: Exception) {
            XposedBridge.log("$TAG: ❌ 无法列出方法 - ${e.message}")
        }
    }
}
