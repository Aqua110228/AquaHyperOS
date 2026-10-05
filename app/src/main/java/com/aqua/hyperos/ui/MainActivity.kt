package com.aqua.hyperos.ui

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.io.DataOutputStream

/**
 * AquaHyperOS Main Activity
 * 
 * 启动逻辑：
 * 1. 检查 Root 权限（静默获取）
 * 2. 有 Root：直接进入设置界面
 * 3. 无 Root：显示提示页面
 */
class MainActivity : Activity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 静默获取 Root 权限
        when (checkAndRequestRoot()) {
            RootStatus.GRANTED -> {
                // 有 Root，直接进入设置
                startActivity(Intent(this, SettingsActivity::class.java))
                finish()
            }
            RootStatus.DENIED -> {
                // 没有 Root，显示提示页面
                showNoRootPage()
            }
            RootStatus.UNAVAILABLE -> {
                // 设备没有 Root
                showNoRootPage()
            }
        }
    }
    
    private fun checkAndRequestRoot(): RootStatus {
        return try {
            // 尝试执行 su 命令
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)
            
            // 执行简单命令测试
            os.writeBytes("id\n")
            os.writeBytes("exit\n")
            os.flush()
            
            val exitCode = process.waitFor()
            
            if (exitCode == 0) {
                RootStatus.GRANTED
            } else {
                RootStatus.DENIED
            }
        } catch (e: Exception) {
            RootStatus.UNAVAILABLE
        }
    }
    
    private fun showNoRootPage() {
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(32), dpToPx(64), dpToPx(32), dpToPx(32))
        }
        
        // 标题
        TextView(this).apply {
            text = "需要 Root 权限"
            textSize = 24f
            setTextColor(0xFF000000.toInt())
            setPadding(0, 0, 0, dpToPx(16))
            layout.addView(this)
        }
        
        // 说明
        TextView(this).apply {
            text = """
                AquaHyperOS 需要 Root 权限才能正常工作。
                
                请确保：
                1. 设备已获取 Root 权限
                2. 授予本应用 Root 权限
                3. 安装 LSPosed 框架
                
                获取 Root 权限后，请重新打开本应用。
            """.trimIndent()
            textSize = 16f
            setTextColor(0xFF666666.toInt())
            lineHeight = (textSize * 1.5f).toInt()
            setPadding(0, 0, 0, dpToPx(24))
            layout.addView(this)
        }
        
        // 重试按钮
        Button(this).apply {
            text = "重新检测"
            setOnClickListener {
                // 重新检测 Root
                recreate()
            }
            layout.addView(this)
        }
        
        // 退出按钮
        Button(this).apply {
            text = "退出"
            setOnClickListener {
                finish()
            }
            layout.addView(this)
        }
        
        setContentView(layout)
    }
    
    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }
    
    enum class RootStatus {
        GRANTED,    // Root 权限已授予
        DENIED,     // Root 权限被拒绝
        UNAVAILABLE // 设备没有 Root
    }
}
