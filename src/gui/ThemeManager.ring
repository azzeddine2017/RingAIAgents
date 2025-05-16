
/*
Class: ThemeManager
Description: Manages application themes and appearance
*/
class ThemeManager {

    aThemes = [
        :light = [
            # Base colors
            :background = "#FFFFFF",
            :text = "#000000",
            :primary = "#007BFF",
            :secondary = "#6C757D",
            :success = "#28A745",
            :danger = "#DC3545",
            :warning = "#FFC107",
            :info = "#17A2B8",

            # UI Elements
            :card_bg = "#FFFFFF",
            :card_border = "#E1E8ED",
            :input_bg = "#F8F9FA",
            :input_border = "#BDC3C7",
            :header_bg = "#3498DB",
            :header_text = "#FFFFFF",
            :sidebar_bg = "#F8F9FA",
            :sidebar_text = "#2C3E50",
            :sidebar_active = "#3498DB",
            :button_primary_bg = "#3498DB",
            :button_primary_text = "#FFFFFF",
            :button_secondary_bg = "#ECF0F1",
            :button_secondary_text = "#7F8C8D",
            :button_success_bg = "#2ECC71",
            :button_success_text = "#FFFFFF",
            :button_danger_bg = "#E74C3C",
            :button_danger_text = "#FFFFFF",

            # Gradients
            :gradient_primary = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #3498DB, stop:1 #2980B9)",
            :gradient_success = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #2ECC71, stop:1 #27AE60)",
            :gradient_danger = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #E74C3C, stop:1 #C0392B)",
            :gradient_warning = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #F1C40F, stop:1 #F39C12)",

            # Shadows
            :shadow_light = "1px 1px 3px rgba(0, 0, 0, 0.1)",
            :shadow_medium = "0 4px 6px rgba(0, 0, 0, 0.1)",
            :shadow_dark = "0 10px 20px rgba(0, 0, 0, 0.15)",

            # Fonts
            :font_family = "Arial, sans-serif",
            :font_size_small = "12px",
            :font_size_normal = "14px",
            :font_size_large = "16px",
            :font_size_xlarge = "20px",
            :font_size_xxlarge = "24px",

            # Spacing
            :spacing_xs = "5px",
            :spacing_sm = "10px",
            :spacing_md = "15px",
            :spacing_lg = "20px",
            :spacing_xl = "30px",

            # Border radius
            :border_radius_sm = "4px",
            :border_radius_md = "8px",
            :border_radius_lg = "12px",
            :border_radius_xl = "20px"
        ],
        :dark = [
            # Base colors
            :background = "#1A1A1A",
            :text = "#FFFFFF",
            :primary = "#0D6EFD",
            :secondary = "#6C757D",
            :success = "#198754",
            :danger = "#DC3545",
            :warning = "#FFC107",
            :info = "#0DCAF0",

            # UI Elements
            :card_bg = "#2C3E50",
            :card_border = "#34495E",
            :input_bg = "#34495E",
            :input_border = "#2C3E50",
            :header_bg = "#1F3A5F",
            :header_text = "#FFFFFF",
            :sidebar_bg = "#2C3E50",
            :sidebar_text = "#ECF0F1",
            :sidebar_active = "#3498DB",
            :button_primary_bg = "#3498DB",
            :button_primary_text = "#FFFFFF",
            :button_secondary_bg = "#34495E",
            :button_secondary_text = "#ECF0F1",
            :button_success_bg = "#27AE60",
            :button_success_text = "#FFFFFF",
            :button_danger_bg = "#C0392B",
            :button_danger_text = "#FFFFFF",

            # Gradients
            :gradient_primary = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #3498DB, stop:1 #2980B9)",
            :gradient_success = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #27AE60, stop:1 #2ECC71)",
            :gradient_danger = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #C0392B, stop:1 #E74C3C)",
            :gradient_warning = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #F39C12, stop:1 #F1C40F)",

            # Shadows
            :shadow_light = "1px 1px 3px rgba(0, 0, 0, 0.3)",
            :shadow_medium = "0 4px 6px rgba(0, 0, 0, 0.3)",
            :shadow_dark = "0 10px 20px rgba(0, 0, 0, 0.4)",

            # Fonts
            :font_family = "Arial, sans-serif",
            :font_size_small = "12px",
            :font_size_normal = "14px",
            :font_size_large = "16px",
            :font_size_xlarge = "20px",
            :font_size_xxlarge = "24px",

            # Spacing
            :spacing_xs = "5px",
            :spacing_sm = "10px",
            :spacing_md = "15px",
            :spacing_lg = "20px",
            :spacing_xl = "30px",

            # Border radius
            :border_radius_sm = "4px",
            :border_radius_md = "8px",
            :border_radius_lg = "12px",
            :border_radius_xl = "20px"
        ],
        :blue = [
            # Base colors
            :background = "#EBF5FB",
            :text = "#2C3E50",
            :primary = "#3498DB",
            :secondary = "#2980B9",
            :success = "#2ECC71",
            :danger = "#E74C3C",
            :warning = "#F39C12",
            :info = "#1ABC9C",

            # UI Elements
            :card_bg = "#FFFFFF",
            :card_border = "#AED6F1",
            :input_bg = "#FFFFFF",
            :input_border = "#3498DB",
            :header_bg = "#3498DB",
            :header_text = "#FFFFFF",
            :sidebar_bg = "#2980B9",
            :sidebar_text = "#FFFFFF",
            :sidebar_active = "#1ABC9C",
            :button_primary_bg = "#3498DB",
            :button_primary_text = "#FFFFFF",
            :button_secondary_bg = "#2980B9",
            :button_secondary_text = "#FFFFFF",
            :button_success_bg = "#2ECC71",
            :button_success_text = "#FFFFFF",
            :button_danger_bg = "#E74C3C",
            :button_danger_text = "#FFFFFF",

            # Gradients
            :gradient_primary = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #3498DB, stop:1 #2980B9)",
            :gradient_success = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #2ECC71, stop:1 #27AE60)",
            :gradient_danger = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #E74C3C, stop:1 #C0392B)",
            :gradient_warning = "qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #F1C40F, stop:1 #F39C12)",

            # Shadows
            :shadow_light = "1px 1px 3px rgba(52, 152, 219, 0.1)",
            :shadow_medium = "0 4px 6px rgba(52, 152, 219, 0.1)",
            :shadow_dark = "0 10px 20px rgba(52, 152, 219, 0.15)",

            # Fonts
            :font_family = "Arial, sans-serif",
            :font_size_small = "12px",
            :font_size_normal = "14px",
            :font_size_large = "16px",
            :font_size_xlarge = "20px",
            :font_size_xxlarge = "24px",

            # Spacing
            :spacing_xs = "5px",
            :spacing_sm = "10px",
            :spacing_md = "15px",
            :spacing_lg = "20px",
            :spacing_xl = "30px",

            # Border radius
            :border_radius_sm = "4px",
            :border_radius_md = "8px",
            :border_radius_lg = "12px",
            :border_radius_xl = "20px"
        ]
    ]
    cCurrentTheme = :light

    func init {
        loadUserPreference()
    }

    func setTheme cTheme {
        if find(aThemes, cTheme) {
            cCurrentTheme = cTheme
            saveUserPreference()
            applyTheme()
            return true
        }
        return false
    }

    func getCurrentTheme {
        return aThemes[cCurrentTheme]
    }

    func toggleTheme {
        if cCurrentTheme = :light {
            setTheme(:dark)
        else
            setTheme(:light)
        }
    }

    func getThemeNames {
        aNames = []
        for cKey in aThemes {
            add(aNames, cKey)
        }
        return aNames
    }

    func getThemeDisplayNames {
        aDisplayNames = [
            :light = "Light Theme",
            :dark = "Dark Theme",
            :blue = "Blue Theme"
        ]

        aResult = []
        for cKey in aThemes {
            if aDisplayNames[cKey] != NULL {
                add(aResult, [cKey, aDisplayNames[cKey]])
            else
                add(aResult, [cKey, cKey])
            }
        }
        return aResult
    }

    func getCurrentThemeName {
        return cCurrentTheme
    }

    func getStyleSheet cElement {
        oTheme = getCurrentTheme()

        switch cElement {
            case "button_primary"
                return "background-color: " + oTheme[:button_primary_bg] + "; " +
                       "color: " + oTheme[:button_primary_text] + "; " +
                       "border: 1px solid " + oTheme[:primary] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + "; " +
                       "padding: " + oTheme[:spacing_sm] + ";"

            case "button_secondary"
                return "background-color: " + oTheme[:button_secondary_bg] + "; " +
                       "color: " + oTheme[:button_secondary_text] + "; " +
                       "border: 1px solid " + oTheme[:secondary] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + "; " +
                       "padding: " + oTheme[:spacing_sm] + ";"

            case "button_success"
                return "background-color: " + oTheme[:button_success_bg] + "; " +
                       "color: " + oTheme[:button_success_text] + "; " +
                       "border: 1px solid " + oTheme[:success] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + "; " +
                       "padding: " + oTheme[:spacing_sm] + ";"

            case "button_danger"
                return "background-color: " + oTheme[:button_danger_bg] + "; " +
                       "color: " + oTheme[:button_danger_text] + "; " +
                       "border: 1px solid " + oTheme[:danger] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + "; " +
                       "padding: " + oTheme[:spacing_sm] + ";"

            case "input"
                return "background-color: " + oTheme[:input_bg] + "; " +
                       "color: " + oTheme[:text] + "; " +
                       "border: 1px solid " + oTheme[:input_border] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + "; " +
                       "padding: " + oTheme[:spacing_sm] + ";"

            case "card"
                return "background-color: " + oTheme[:card_bg] + "; " +
                       "color: " + oTheme[:text] + "; " +
                       "border: 1px solid " + oTheme[:card_border] + "; " +
                       "border-radius: " + oTheme[:border_radius_md] + "; " +
                       "padding: " + oTheme[:spacing_md] + ";"

            case "header"
                return "background: " + oTheme[:gradient_primary] + "; " +
                       "color: " + oTheme[:header_text] + "; " +
                       "border-radius: " + oTheme[:border_radius_md] + "; " +
                       "padding: " + oTheme[:spacing_md] + ";"

            case "sidebar"
                return "background-color: " + oTheme[:sidebar_bg] + "; " +
                       "color: " + oTheme[:sidebar_text] + "; " +
                       "border-right: 1px solid " + oTheme[:card_border] + "; " +
                       "padding: " + oTheme[:spacing_md] + ";"

            case "main_window"
                return "background-color: " + oTheme[:background] + "; " +
                       "color: " + oTheme[:text] + "; " +
                       "font-family: " + oTheme[:font_family] + "; " +
                       "font-size: " + oTheme[:font_size_normal] + ";"

            case "title"
                return "color: " + oTheme[:text] + "; " +
                       "font-size: " + oTheme[:font_size_xxlarge] + "; " +
                       "font-weight: bold;"

            case "subtitle"
                return "color: " + oTheme[:secondary] + "; " +
                       "font-size: " + oTheme[:font_size_large] + "; " +
                       "font-weight: bold;"

            case "list"
                return "background-color: " + oTheme[:card_bg] + "; " +
                       "color: " + oTheme[:text] + "; " +
                       "border: 1px solid " + oTheme[:card_border] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + "; " +
                       "padding: " + oTheme[:spacing_xs] + ";"

            case "tab"
                return "background-color: " + oTheme[:card_bg] + "; " +
                       "color: " + oTheme[:text] + "; " +
                       "border: 1px solid " + oTheme[:card_border] + "; " +
                       "border-radius: " + oTheme[:border_radius_sm] + " " +
                       oTheme[:border_radius_sm] + " 0 0;"

            default
                return "color: " + oTheme[:text] + "; " +
                       "font-family: " + oTheme[:font_family] + "; " +
                       "font-size: " + oTheme[:font_size_normal] + ";"
        }
    }

    func applyTheme {
        oTheme = getCurrentTheme()
        # Apply to all windows and widgets
        # updateAllWindows(oTheme) - This function is not defined yet

        # Notify about theme change
        ? "Theme changed to: " + cCurrentTheme
    }

    private

    func loadUserPreference {
        # Load from settings file
        if fexists(currentdir() + "/settings/theme.ini") {
            cContent = read(currentdir() + "/settings/theme.ini")
            cCurrentTheme = trim(cContent)
        }
    }

    func saveUserPreference {
        write(currentdir() + "/settings/theme.ini", cCurrentTheme)
    }

}
