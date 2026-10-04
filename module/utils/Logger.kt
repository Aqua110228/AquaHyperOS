package com.aqua.hyperos.utils

import android.content.Context
import android.os.Environment
import de.robv.android.xposed.XposedBridge
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

object Logger {
    
    private const val TAG = "AquaHyperOS"
    private const val LOG_DIR = "AquaHyperOS/logs"
    private const val MAX_LOG_SIZE = 10 * 1024 * 1024 // 10MB
    
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())
    private val dateOnlyFormat = SimpleDateFormat("yyyyMMdd", Locale.getDefault())
    private var logFile: File? = null
    private var isInitialized = false
    
    fun init(context: Context) {
        if (isInitialized) return
        
        try {
            val logDir = File(Environment.getExternalStorageDirectory(), LOG_DIR)
            if (!logDir.exists()) {
                val created = logDir.mkdirs()
                if (!created) {
                    XposedBridge.log("$TAG: 无法创建日志目录: ${logDir.absolutePath}")
                    return
                }
            }
            
            val fileName = "aqua_${dateOnlyFormat.format(Date())}.log"
            logFile = File(logDir, fileName)
            
            // Rotate log if too large
            if (logFile?.exists() == true && logFile!!.length() > MAX_LOG_SIZE) {
                val backupFile = File(logDir, "${fileName}.old")
                logFile?.renameTo(backupFile)
                logFile = File(logDir, fileName)
            }
            
            isInitialized = true
            writeHeader()
            i("日志系统", "初始化完成 → ${logFile?.absolutePath}")
        } catch (e: Exception) {
            XposedBridge.log("$TAG: Logger init failed - ${e.message}")
        }
    }
    
    private fun writeHeader() {
        try {
            val header = """
                
================================================================================
AquaHyperOS 模块日志
启动时间: ${SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())}
日志路径: ${logFile?.absolutePath}
================================================================================

""".trimIndent()
            logFile?.appendText(header)
        } catch (e: Exception) {
            // Ignore
        }
    }
    
    // Verbose - 详细调试信息
    fun v(module: String, msg: String) {
        log("详细", module, msg)
    }
    
    // Debug - 调试信息
    fun d(module: String, msg: String) {
        log("调试", module, msg)
    }
    
    // Info - 一般信息
    fun i(module: String, msg: String) {
        log("信息", module, msg)
    }
    
    // Warning - 警告
    fun w(module: String, msg: String) {
        log("警告", module, msg)
    }
    
    // Error - 错误
    fun e(module: String, msg: String, throwable: Throwable? = null) {
        log("错误", module, msg)
        throwable?.let {
            log("错误", module, "异常类型: ${it.javaClass.simpleName}")
            log("错误", module, "异常信息: ${it.message ?: "无"}")
            log("错误", module, "异常堆栈:")
            it.stackTrace.take(10).forEach { element ->
                log("错误", module, "  at ${element}")
            }
        }
    }
    
    // Hook start
    fun hookStart(module: String, pkg: String) {
        val msg = """
            
┌─────────────────────────────────────────
│ Hook 模块启动
│ 模块: $module
│ 目标包: $pkg
└─────────────────────────────────────────""".trimIndent()
        log("信息", module, msg)
    }
    
    // Hook success
    fun hookSuccess(module: String, target: String) {
        log("信息", module, "✓ Hook 成功 → $target")
    }
    
    // Hook failed
    fun hookFailed(module: String, target: String, reason: String) {
        log("错误", module, "✗ Hook 失败 → $target")
        log("错误", module, "  失败原因: $reason")
    }
    
    // Class found
    fun classFound(module: String, className: String, isFallback: Boolean = false) {
        if (isFallback) {
            log("警告", module, "→ 使用备用类: $className")
        } else {
            log("调试", module, "→ 找到类: $className")
        }
    }
    
    // Class not found
    fun classNotFound(module: String, className: String) {
        log("错误", module, "→ 未找到类: $className")
    }
    
    // Method hooked
    fun methodHooked(module: String, methodName: String) {
        log("调试", module, "→ Hook 方法: $methodName")
    }
    
    // Config loaded
    fun configLoaded(module: String, key: String, value: Any?) {
        log("详细", module, "配置读取: $key = $value")
    }
    
    // Config applied
    fun configApplied(module: String, description: String) {
        log("信息", module, "✓ 配置已应用: $description")
    }
    
    // Value changed
    fun valueChanged(module: String, description: String, from: Any?, to: Any?) {
        log("调试", module, "值变更: $description [$from → $to]")
    }
    
    private fun log(level: String, module: String, msg: String) {
        val timestamp = dateFormat.format(Date())
        val logMsg = "[$timestamp] [$level] [$module] $msg"
        
        // Log to Xposed
        XposedBridge.log("$TAG: $logMsg")
        
        // Log to file
        try {
            logFile?.appendText("$logMsg\n")
        } catch (e: Exception) {
            // Ignore file write errors
        }
    }
    
    fun getLogPath(): String? {
        return logFile?.absolutePath
    }
    
    fun clearLogs() {
        try {
            logFile?.writeText("")
            writeHeader()
            i("日志系统", "日志已清空")
        } catch (e: Exception) {
            e("日志系统", "清空日志失败", e)
        }
    }
    
    fun getLogs(lines: Int = 500): String {
        return try {
            val allLines = logFile?.readLines() ?: emptyList()
            allLines.takeLast(lines).joinToString("\n")
        } catch (e: Exception) {
            "读取日志失败: ${e.message}"
        }
    }
    
    fun getLogSize(): Long {
        return logFile?.length() ?: 0L
    }
}
