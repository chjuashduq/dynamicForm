pragma Singleton
import QtQuick 6.5

/**
 * 应用全局样式配置
 * 使用单例模式，在整个应用中共享样式设置
 */
QtObject {
    id: appStyles
    
    // ===== 颜色配置 =====
    readonly property color primaryColor: "#667eea"        // 主色调（紫色）
    readonly property color primaryDark: "#5568d3"         // 主色调深色
    readonly property color primaryLight: "#7c8ef5"        // 主色调浅色
    
    readonly property color accentColor: "#48bb78"         // 强调色（绿色）
    readonly property color dangerColor: "#f56565"         // 危险色（红色）
    readonly property color warningColor: "#ed8936"        // 警告色（橙色）
    readonly property color infoColor: "#4299e1"           // 信息色（蓝色）
    
    readonly property color backgroundColor: "#f7fafc"     // 背景色
    readonly property color surfaceColor: "#ffffff"        // 表面色（卡片、输入框等）
    readonly property color borderColor: "#e2e8f0"         // 边框色
    readonly property color dividerColor: "#cbd5e0"        // 分割线色
    
    readonly property color textPrimary: "#2d3748"         // 主要文字
    readonly property color textSecondary: "#718096"       // 次要文字
    readonly property color textDisabled: "#a0aec0"        // 禁用文字
    readonly property color textPlaceholder: "#cbd5e0"     // 占位符文字
    
    readonly property color errorColor: "#fc8181"          // 错误色
    readonly property color successColor: "#68d391"        // 成功色
    
    // ===== 尺寸配置 =====
    readonly property int radiusSmall: 4                   // 小圆角
    readonly property int radiusMedium: 8                  // 中圆角
    readonly property int radiusLarge: 12                  // 大圆角
    
    readonly property int spacingTiny: 4                   // 极小间距
    readonly property int spacingSmall: 8                  // 小间距
    readonly property int spacingMedium: 12                // 中间距
    readonly property int spacingLarge: 16                 // 大间距
    readonly property int spacingXLarge: 24                // 超大间距
    
    readonly property int paddingSmall: 8                  // 小内边距
    readonly property int paddingMedium: 12                // 中内边距
    readonly property int paddingLarge: 16                 // 大内边距
    
    // ===== 字体配置 =====
    readonly property int fontSizeSmall: 12                // 小字体
    readonly property int fontSizeMedium: 14               // 中字体
    readonly property int fontSizeLarge: 16                // 大字体
    readonly property int fontSizeXLarge: 18               // 超大字体
    readonly property int fontSizeTitle: 20                // 标题字体
    
    readonly property string fontFamily: "Microsoft YaHei" // 字体族
    
    // ===== 控件高度 =====
    readonly property int controlHeightSmall: 32           // 小控件高度
    readonly property int controlHeightMedium: 40          // 中控件高度
    readonly property int controlHeightLarge: 48           // 大控件高度
    
    // ===== 阴影配置 =====
    readonly property int shadowRadius: 8                  // 阴影半径
    readonly property color shadowColor: "#00000020"       // 阴影颜色
    
    // ===== 动画配置 =====
    readonly property int animationDuration: 200           // 动画时长（毫秒）
    
    // ===== 输入框样式 =====
    readonly property color inputBackground: surfaceColor
    readonly property color inputBorder: "#cbd5e0"         // 更深的边框色，更清晰
    readonly property color inputBorderFocus: primaryColor
    readonly property color inputBorderError: errorColor
    readonly property int inputBorderWidth: 2               // 增加边框宽度
    readonly property int inputRadius: radiusMedium
    readonly property int inputHeight: controlHeightMedium
    readonly property int inputPadding: paddingMedium
    
    // ===== 按钮样式 =====
    readonly property color buttonPrimary: primaryColor
    readonly property color buttonPrimaryHover: primaryDark
    readonly property color buttonPrimaryPressed: "#4556c2"
    readonly property color buttonSecondary: "#e2e8f0"
    readonly property color buttonSecondaryHover: "#cbd5e0"
    readonly property color buttonDanger: dangerColor
    readonly property color buttonDangerHover: "#e53e3e"
    readonly property int buttonRadius: radiusMedium
    readonly property int buttonHeight: controlHeightMedium
    readonly property int buttonPadding: paddingLarge
    
    // ===== 标签样式 =====
    readonly property color labelColor: textPrimary
    readonly property int labelFontSize: fontSizeMedium
    readonly property bool labelBold: false
    
    // ===== 卡片样式 =====
    readonly property color cardBackground: surfaceColor
    readonly property color cardBorder: borderColor
    readonly property int cardRadius: radiusLarge
    readonly property int cardPadding: paddingLarge
    readonly property int cardBorderWidth: 1
}
