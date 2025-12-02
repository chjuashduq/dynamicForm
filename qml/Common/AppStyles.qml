pragma Singleton
import QtQuick 6.5

/**
 * 应用全局样式配置
 */
QtObject {
    id: appStyles

    // ===== 颜色配置 (加深关键颜色) =====
    readonly property color primaryColor: "#667eea"
    readonly property color primaryDark: "#5568d3"
    readonly property color primaryLight: "#7c8ef5"

    // [修改] 加深绿色，使新增按钮更明显 (原 #48bb78 -> #38a169)
    readonly property color accentColor: "#38a169"
    readonly property color successColor: "#38a169"

    readonly property color dangerColor: "#e53e3e"
    readonly property color warningColor: "#dd6b20"
    readonly property color infoColor: "#3182ce"

    readonly property color backgroundColor: "#f7fafc"
    readonly property color surfaceColor: "#ffffff"
    readonly property color borderColor: "#e2e8f0"
    readonly property color dividerColor: "#cbd5e0"

    readonly property color textPrimary: "#2d3748"
    readonly property color textSecondary: "#718096"
    readonly property color textDisabled: "#a0aec0"
    readonly property color textPlaceholder: "#a0aec0"

    readonly property color errorColor: "#e53e3e"

    // ===== 尺寸配置 =====
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 6
    readonly property int radiusLarge: 12

    readonly property int spacingTiny: 4
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int spacingXLarge: 32

    readonly property int paddingSmall: 8
    readonly property int paddingMedium: 12
    readonly property int paddingLarge: 20

    // ===== 字体配置 =====
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeXLarge: 18
    readonly property int fontSizeTitle: 24

    readonly property string fontFamily: "Microsoft YaHei"

    // ===== 控件高度 =====
    readonly property int controlHeightSmall: 32
    readonly property int controlHeightMedium: 40
    readonly property int controlHeightLarge: 48

    // ===== 阴影配置 =====
    readonly property int shadowRadius: 8
    readonly property color shadowColor: "#00000020"

    // ===== 动画配置 =====
    readonly property int animationDuration: 200

    // ===== 输入框样式 =====
    readonly property color inputBackground: surfaceColor
    // [修改] 加深边框颜色 (原 #cbd5e0 -> #a0aec0)
    readonly property color inputBorder: "#a0aec0"
    readonly property color inputBorderFocus: primaryColor
    readonly property color inputBorderError: errorColor
    readonly property int inputBorderWidth: 1
    readonly property int inputRadius: radiusSmall
    readonly property int inputHeight: controlHeightMedium
    readonly property int inputPadding: paddingMedium

    // ===== 按钮样式 =====
    readonly property color buttonPrimary: primaryColor
    readonly property color buttonPrimaryHover: primaryDark
    readonly property color buttonPrimaryPressed: "#4c51bf"
    readonly property color buttonSecondary: "#edf2f7"
    readonly property color buttonSecondaryHover: "#e2e8f0"
    readonly property color buttonDanger: dangerColor
    readonly property color buttonDangerHover: "#c53030"
    readonly property int buttonRadius: radiusSmall
    readonly property int buttonHeight: controlHeightMedium
    readonly property int buttonPadding: paddingLarge

    // ===== 标签样式 =====
    readonly property color labelColor: textPrimary
    readonly property int labelFontSize: fontSizeMedium
    readonly property bool labelBold: false

    // ===== 卡片样式 =====
    readonly property color cardBackground: surfaceColor
    readonly property color cardBorder: borderColor
    readonly property int cardRadius: radiusMedium
    readonly property int cardPadding: paddingLarge
    readonly property int cardBorderWidth: 1
}
