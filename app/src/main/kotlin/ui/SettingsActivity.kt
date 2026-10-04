package com.aqua.hyperos.ui

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.*
import com.aqua.hyperos.utils.Logger

class SettingsActivity : Activity() {
    
    private lateinit var scrollView: ScrollView
    private lateinit var mainLayout: LinearLayout
    private var isLSPosedActive = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 初始化日志
        try {
            Logger.init(this)
        } catch (e: Exception) {
            // 日志初始化失败不影响界面
        }
        
        // 检测 LSPosed 状态
        isLSPosedActive = checkLSPosedActive()
        
        createUI()
    }
    
    private fun createUI() {
        scrollView = ScrollView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        
        mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            setPadding(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(16))
        }
        
        // Header
        addHeader("AquaHyperOS 设置")
        
        // 重要：状态卡片
        addStatusCard()
        
        // 如果没有激活LSPosed，显示提示
        if (!isLSPosedActive) {
            addWarningCard()
        }
        
        // Settings Sections
        addSection("核心功能", listOf(
            Setting.Switch("签名验证绕过", "core_signature_bypass", true),
            Setting.Switch("权限检查绕过", "core_permission_bypass", false)
        ))
        
        addSection("状态栏", listOf(
            Setting.Switch("自定义背景", "statusbar_custom_bg", false),
            Setting.Color("背景颜色", "statusbar_bg_color", "#00000000"),
            Setting.Switch("自定义透明度", "statusbar_custom_alpha", false),
            Setting.SeekBar("透明度", "statusbar_alpha", 255, 0, 255),
            Setting.Switch("自定义高度", "statusbar_custom_height", false),
            Setting.SeekBar("高度(dp)", "statusbar_height", 32, 24, 48)
        ))
        
        addSection("控制中心", listOf(
            Setting.Switch("大磁贴", "cc_large_tile", false),
            Setting.Switch("方形磁贴", "cc_square_tile", false),
            Setting.Switch("自定义图标颜色", "cc_custom_icon_color", false)
        ))
        
        addSection("锁屏", listOf(
            Setting.Switch("隐藏指纹图标", "lockscreen_hide_fingerprint_icon", false),
            Setting.Switch("隐藏指纹动画", "lockscreen_hide_fingerprint_animation", false),
            Setting.Switch("显示导航栏", "lockscreen_show_navigation_bar", false)
        ))
        
        addSection("主题", listOf(
            Setting.Switch("强制柔光玻璃", "theme_force_blur", false)
        ))
        
        // Buttons
        addButton("查看日志") { viewLogs() }
        addButton("关于模块") { showAbout() }
        
        scrollView.addView(mainLayout)
        setContentView(scrollView)
    }
    
    private fun addHeader(title: String) {
        TextView(this).apply {
            text = title
            textSize = 24f
            setTextColor(0xFF000000.toInt())
            setPadding(0, 0, 0, dpToPx(16))
            mainLayout.addView(this)
        }
    }
    
    private fun addStatusCard() {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(if (isLSPosedActive) 0xFFE8F5E9.toInt() else 0xFFFFF3E0.toInt())
            setPadding(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(16))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dpToPx(16))
            }
        }
        
        // Module Status
        addStatusRow(card, "模块状态", if (isLSPosedActive) "✓ 已激活" else "✗ 未激活", isLSPosedActive)
        
        // Log Status
        try {
            val logPath = Logger.getLogPath()
            val logSize = Logger.getLogSize()
            if (logPath != null) {
                addStatusRow(card, "日志文件", "${logSize / 1024} KB", logSize > 0)
            }
        } catch (e: Exception) {
            // 忽略
        }
        
        mainLayout.addView(card)
    }
    
    private fun addWarningCard() {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0xFFFFEBEE.toInt())
            setPadding(dpToPx(16), dpToPx(16), dpToPx(16), dpToPx(16))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dpToPx(16))
            }
        }
        
        TextView(this).apply {
            text = "⚠️ 模块未激活"
            textSize = 16f
            setTextColor(0xFFD32F2F.toInt())
            setPadding(0, 0, 0, dpToPx(8))
            card.addView(this)
        }
        
        TextView(this).apply {
            text = "您可以在此配置所有设置，但需要在 LSPosed 中激活本模块后才能生效。\n\n" +
                    "激活步骤：\n" +
                    "1. 安装 LSPosed 框架\n" +
                    "2. 在 LSPosed 中勾选 AquaHyperOS\n" +
                    "3. 选择作用域（系统界面、设置等）\n" +
                    "4. 重启设备"
            textSize = 14f
            setTextColor(0xFF000000.toInt())
            card.addView(this)
        }
        
        mainLayout.addView(card)
    }
    
    private fun addStatusRow(parent: LinearLayout, label: String, value: String, isGood: Boolean) {
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, dpToPx(4))
            }
        }
        
        TextView(this).apply {
            text = label
            textSize = 14f
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            row.addView(this)
        }
        
        TextView(this).apply {
            text = value
            textSize = 14f
            setTextColor(if (isGood) 0xFF4CAF50.toInt() else 0xFFF57C00.toInt())
            gravity = Gravity.END
            row.addView(this)
        }
        
        parent.addView(row)
    }
    
    private fun addSection(title: String, settings: List<Setting>) {
        TextView(this).apply {
            text = title
            textSize = 18f
            setTextColor(0xFF000000.toInt())
            setPadding(0, dpToPx(16), 0, dpToPx(8))
            mainLayout.addView(this)
        }
        
        settings.forEach { setting ->
            when (setting) {
                is Setting.Switch -> addSwitch(setting)
                is Setting.SeekBar -> addSeekBar(setting)
                is Setting.Color -> addColorPicker(setting)
            }
        }
    }
    
    private fun addSwitch(setting: Setting.Switch) {
        val prefs = getSharedPreferences("aquahyperos_settings", Context.MODE_WORLD_READABLE)
        
        Switch(this).apply {
            text = setting.label
            isChecked = prefs.getBoolean(setting.key, setting.defaultValue)
            setPadding(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8))
            
            // 如果没有激活LSPosed，禁用但允许切换（保存配置）
            isEnabled = true
            
            setOnCheckedChangeListener { _, isChecked ->
                prefs.edit().putBoolean(setting.key, isChecked).apply()
                
                try {
                    Logger.i("设置", "配置变更: ${setting.key} = $isChecked")
                } catch (e: Exception) {
                    // 忽略
                }
                
                if (isLSPosedActive) {
                    Toast.makeText(context, "已保存，重启生效", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(context, "已保存，激活模块后生效", Toast.LENGTH_SHORT).show()
                }
            }
            
            mainLayout.addView(this)
        }
    }
    
    private fun addSeekBar(setting: Setting.SeekBar) {
        val prefs = getSharedPreferences("aquahyperos_settings", Context.MODE_WORLD_READABLE)
        
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8))
        }
        
        val labelView = TextView(this).apply {
            text = "${setting.label}: ${prefs.getInt(setting.key, setting.defaultValue)}"
            textSize = 14f
        }
        container.addView(labelView)
        
        SeekBar(this).apply {
            max = setting.max - setting.min
            progress = prefs.getInt(setting.key, setting.defaultValue) - setting.min
            
            setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                    val value = progress + setting.min
                    labelView.text = "${setting.label}: $value"
                }
                
                override fun onStartTrackingTouch(seekBar: SeekBar?) {}
                
                override fun onStopTrackingTouch(seekBar: SeekBar?) {
                    val value = (seekBar?.progress ?: 0) + setting.min
                    prefs.edit().putInt(setting.key, value).apply()
                    
                    try {
                        Logger.i("设置", "配置变更: ${setting.key} = $value")
                    } catch (e: Exception) {
                        // 忽略
                    }
                    
                    Toast.makeText(context, "已保存", Toast.LENGTH_SHORT).show()
                }
            })
        }
        container.addView(seekBar)
        
        mainLayout.addView(container)
    }
    
    private fun addColorPicker(setting: Setting.Color) {
        val prefs = getSharedPreferences("aquahyperos_settings", Context.MODE_WORLD_READABLE)
        
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8))
        }
        
        TextView(this).apply {
            text = setting.label
            textSize = 14f
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            row.addView(this)
        }
        
        EditText(this).apply {
            setText(prefs.getString(setting.key, setting.defaultValue))
            hint = "#AARRGGBB"
            textSize = 12f
            layoutParams = LinearLayout.LayoutParams(dpToPx(120), ViewGroup.LayoutParams.WRAP_CONTENT)
            
            setOnFocusChangeListener { _, hasFocus ->
                if (!hasFocus) {
                    val color = text.toString()
                    prefs.edit().putString(setting.key, color).apply()
                    
                    try {
                        Logger.i("设置", "配置变更: ${setting.key} = $color")
                    } catch (e: Exception) {
                        // 忽略
                    }
                }
            }
            
            row.addView(this)
        }
        
        mainLayout.addView(row)
    }
    
    private fun addButton(text: String, onClick: () -> Unit) {
        Button(this).apply {
            this.text = text
            setPadding(dpToPx(16), dpToPx(12), dpToPx(16), dpToPx(12))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, dpToPx(8), 0, 0)
            }
            setOnClickListener { onClick() }
            mainLayout.addView(this)
        }
    }
    
    private fun viewLogs() {
        try {
            val logs = Logger.getLogs(200)
            
            AlertDialog.Builder(this)
                .setTitle("最近日志 (200行)")
                .setMessage(logs)
                .setPositiveButton("关闭", null)
                .setNeutralButton("清空日志") { _, _ ->
                    Logger.clearLogs()
                    Toast.makeText(this, "日志已清空", Toast.LENGTH_SHORT).show()
                }
                .show()
        } catch (e: Exception) {
            Toast.makeText(this, "无法读取日志: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun showAbout() {
        AlertDialog.Builder(this)
            .setTitle("关于 AquaHyperOS")
            .setMessage("""
                版本: 1.0.0
                
                HyperOS 深度定制模块
                
                功能：
                • 核心破解
                • 状态栏自定义
                • 控制中心自定义
                • 锁屏自定义
                • 主题美化
                
                需要 LSPosed 框架支持
                
                日志位置: /sdcard/AquaHyperOS/logs/
            """.trimIndent())
            .setPositiveButton("确定", null)
            .show()
    }
    
    private fun checkLSPosedActive(): Boolean {
        return try {
            Class.forName("de.robv.android.xposed.XposedBridge")
            true
        } catch (e: ClassNotFoundException) {
            false
        }
    }
    
    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }
    
    sealed class Setting {
        data class Switch(val label: String, val key: String, val defaultValue: Boolean) : Setting()
        data class SeekBar(val label: String, val key: String, val defaultValue: Int, val min: Int, val max: Int) : Setting()
        data class Color(val label: String, val key: String, val defaultValue: String) : Setting()
    }
}
