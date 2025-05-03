/*
Class: LanguageManager
Description: Manages application localization
*/

class LanguageManager {

    aLanguages = [:en, :ar]
    cCurrentLang = :en
    aTranslations = []

    func init {
        loadLanguages()
        loadUserPreference()
    }

    func setLanguage cLang {
        if find(aLanguages, cLang) {
            cCurrentLang = cLang
            saveUserPreference()
            applyLanguage()
        }
    }

    func getText cKey {
        if aTranslations[cCurrentLang][cKey] != NULL {
            return aTranslations[cCurrentLang][cKey]
        }
        return cKey
    }

    //private

    func loadLanguages {
        # Load English translations
        aTranslations[:en] = [
            # Main menu
            :dashboard = "Dashboard",
            :agents = "Agents",
            :tasks = "Tasks",
            :settings = "Settings",
            :profile = "Profile",
            :logout = "Logout",

            # Common buttons
            :save = "Save",
            :cancel = "Cancel",
            :delete = "Delete",
            :edit = "Edit",
            :add = "Add",
            :refresh = "Refresh",
            :search = "Search",

            # Dashboard
            :recent_activity = "Recent Activity",
            :performance = "Performance",
            :completed = "Completed",
            :crews = "Crews",

            # Agents
            :agent_name = "Agent Name",
            :agent_role = "Role",
            :agent_status = "Status",
            :agent_skills = "Skills",
            :agent_personality = "Personality",

            # Tasks
            :task_name = "Task Name",
            :task_description = "Description",
            :task_priority = "Priority",
            :task_due_date = "Due Date",
            :task_assignee = "Assigned To",
            :task_status = "Status",
            :task_progress = "Progress",

            # Status values
            :status_online = "Online",
            :status_offline = "Offline",
            :status_busy = "Busy",
            :status_idle = "Idle",
            :status_completed = "Completed",
            :status_in_progress = "In Progress",
            :status_pending = "Pending",
            :status_failed = "Failed",

            # Priority levels
            :priority_low = "Low",
            :priority_medium = "Medium",
            :priority_high = "High",
            :priority_critical = "Critical",

            # Login
            :login = "Login",
            :username = "Username",
            :password = "Password",
            :remember_me = "Remember me",
            :forgot_password = "Forgot password?",

            # Messages
            :confirm_delete = "Are you sure you want to delete this item?",
            :login_success = "Login successful",
            :login_failed = "Invalid username or password",
            :save_success = "Changes saved successfully",
            :operation_failed = "Operation failed"
        ]

        # Load Arabic translations
        aTranslations[:ar] = [
            # Main menu
            :dashboard = "لوحة التحكم",
            :agents = "العملاء",
            :tasks = "المهام",
            :settings = "الإعدادات",
            :profile = "الملف الشخصي",
            :logout = "تسجيل الخروج",

            # Common buttons
            :save = "حفظ",
            :cancel = "إلغاء",
            :delete = "حذف",
            :edit = "تعديل",
            :add = "إضافة",
            :refresh = "تحديث",
            :search = "بحث",

            # Dashboard
            :recent_activity = "النشاط الأخير",
            :performance = "الأداء",
            :completed = "مكتمل",
            :crews = "الفرق",

            # Agents
            :agent_name = "اسم العميل",
            :agent_role = "الدور",
            :agent_status = "الحالة",
            :agent_skills = "المهارات",
            :agent_personality = "الشخصية",

            # Tasks
            :task_name = "اسم المهمة",
            :task_description = "الوصف",
            :task_priority = "الأولوية",
            :task_due_date = "تاريخ الاستحقاق",
            :task_assignee = "مسند إلى",
            :task_status = "الحالة",
            :task_progress = "التقدم",

            # Status values
            :status_online = "متصل",
            :status_offline = "غير متصل",
            :status_busy = "مشغول",
            :status_idle = "خامل",
            :status_completed = "مكتمل",
            :status_in_progress = "قيد التنفيذ",
            :status_pending = "قيد الانتظار",
            :status_failed = "فشل",

            # Priority levels
            :priority_low = "منخفض",
            :priority_medium = "متوسط",
            :priority_high = "مرتفع",
            :priority_critical = "حرج",

            # Login
            :login = "تسجيل الدخول",
            :username = "اسم المستخدم",
            :password = "كلمة المرور",
            :remember_me = "تذكرني",
            :forgot_password = "نسيت كلمة المرور؟",

            # Messages
            :confirm_delete = "هل أنت متأكد من رغبتك في حذف هذا العنصر؟",
            :login_success = "تم تسجيل الدخول بنجاح",
            :login_failed = "اسم المستخدم أو كلمة المرور غير صحيحة",
            :save_success = "تم حفظ التغييرات بنجاح",
            :operation_failed = "فشلت العملية"
        ]

        # Add French translations
        aTranslations[:fr] = [
            # Main menu
            :dashboard = "Tableau de bord",
            :agents = "Agents",
            :tasks = "Tâches",
            :settings = "Paramètres",
            :profile = "Profil",
            :logout = "Déconnexion",

            # Common buttons
            :save = "Enregistrer",
            :cancel = "Annuler",
            :delete = "Supprimer",
            :edit = "Modifier",
            :add = "Ajouter",
            :refresh = "Actualiser",
            :search = "Rechercher",

            # Dashboard
            :recent_activity = "Activité récente",
            :performance = "Performance",
            :completed = "Terminé",
            :crews = "Équipes",

            # Login
            :login = "Connexion",
            :username = "Nom d'utilisateur",
            :password = "Mot de passe",
            :remember_me = "Se souvenir de moi",
            :forgot_password = "Mot de passe oublié?"
            # Add more translations as needed
        ]

        # Update available languages list
        aLanguages = [:en, :ar, :fr]
    }

    func loadUserPreference {
        if fexists("settings/language.ini") {
            cContent = read("settings/language.ini")
            cCurrentLang = trim(cContent)
        }
    }

    func saveUserPreference {
        write("settings/language.ini", cCurrentLang)
    }

    func applyLanguage {
        # Update all UI elements
        updateAllTexts()

        # Set text direction based on language
        if cCurrentLang = :ar {
            setTextDirection("RTL")
        else
            setTextDirection("LTR")
        }

        # Notify all components about language change
        notifyLanguageChange()
    }

    func setTextDirection cDirection {
        # Set application text direction (RTL for Arabic, LTR for others)
        # This would be implemented in the actual application
        ? "Setting text direction to: " + cDirection
    }

    func notifyLanguageChange {
        # Notify all components about language change
        # This would be implemented in the actual application
        ? "Language changed to: " + cCurrentLang
    }

    func getAvailableLanguages {
        # Return list of available languages with their native names
        aLangNames = [
            :en = "English",
            :ar = "العربية",
            :fr = "Français"
        ]

        aResult = []
        for cLang in aLanguages {
            add(aResult, [cLang, aLangNames[cLang]])
        }

        return aResult
    }

    func getCurrentLanguageCode {
        return cCurrentLang
    }

    func getCurrentLanguageName {
        aLangNames = [
            :en = "English",
            :ar = "العربية",
            :fr = "Français"
        ]

        return aLangNames[cCurrentLang]
    }

}
