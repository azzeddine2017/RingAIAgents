

/*
الكلاس: Settings
الوصف: إدارة إعدادات النظام
*/
class Settings
    cSettingsFile = currentdir() + "/settings/settings.json"

    # Default settings
    oDefaults = [
        :theme = "light",
        :language = "en",
        :updateInterval = 5000,
        :maxAgents = 100,
        :maxCrews = 20,
        :maxTasksPerAgent = 10,
        :backupInterval = 3600,
        :logLevel = "info",
        :notifications = true
    ]

    # Current settings
    oSettings = []

    func init {
        oSettings = oDefaults
    }

    func loadSetting {
        if fexists(cSettingsFile) {
            try {
                cContent = read(cSettingsFile)
                oSettings = json2list(cContent)
            catch
                ? "Error loading settings: " + cCatchError
                oSettings = oDefaults
            }
        else
            # If settings file doesn't exist, create it with default settings
            save()
        }
    }

    func save {
        try {
            # Ensure settings directory exists
            if not fexists(currentdir() + "/settings") {
                system("mkdir " + currentdir() + "/settings")
            }
            write(cSettingsFile, list2json(oSettings))
            return true
        catch
            ? "Error saving settings: " + cCatchError
            return false
        }
    }

    func getKey cKey {
        if oSettings[cKey] != NULL {
            return oSettings[cKey]
        }
        return oDefaults[cKey]
    }

    func setKey cKey, xValue {
        oSettings[cKey] = xValue
        save()
    }


/*
الكلاس: SettingsDialog
الوصف: نافذة حوار لتعديل إعدادات النظام
*/
class SettingsDialog from QDialog

    # GUI Components
    oThemeCombo
    oLanguageCombo
    oUpdateIntervalSpin
    oMaxAgentsSpin
    oMaxCrewsSpin
    oMaxTasksSpin
    oBackupIntervalSpin
    oLogLevelCombo
    oNotificationsCheck

    # Data
    oSettings

    func init oParent {
        super.init(oParent)
        setWindowTitle("Settings")
        setModal(true)
        resize(600, 800)
        oSettings = new Settings()
        initUI()
        loadSettings()
    }

    func initUI {
        # Create main layout
        oMainLayout = new QVBoxLayout()
        oMainLayout.setSpacing(15)

        # Header
        oHeaderLabel = new QLabel(this) {
            setText("Application Settings")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 24px; font-weight: bold; color: #2c3e50; margin: 15px 0;")
        }
        oMainLayout.addWidget(oHeaderLabel)

        # Create tabs with styling
        oTabs = new QTabWidget()
        oTabs.setStyleSheet("
            QTabWidget::pane {
                border: 1px solid #bdc3c7;
                border-radius: 4px;
                background-color: #f8f9fa;
                padding: 10px;
            }
            QTabBar::tab {
                background-color: #ecf0f1;
                border: 1px solid #bdc3c7;
                border-bottom: none;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                padding: 8px 12px;
                margin-right: 2px;
                font-size: 14px;
            }
            QTabBar::tab:selected {
                background-color: #f8f9fa;
                border-bottom: 1px solid #f8f9fa;
                font-weight: bold;
            }
        ")

        # General settings tab
        oGeneralTab = new QWidget()
        oGeneralLayout = new QVBoxLayout()

        # Theme with icon
        oThemeLayout = new QHBoxLayout()
        oThemeIcon = new QLabel(oGeneralTab) {
            setText("🌙")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oThemeLayout.addWidget(oThemeIcon)

        oThemeLabel = new QLabel(oGeneralTab) {
            setText("Theme:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oThemeLayout.addWidget(oThemeLabel)

        oThemeCombo = new QComboBox(oGeneralTab) {
            addItem("Light")
            addItem("Dark")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oThemeLayout.addWidget(oThemeCombo)
        oThemeLayout.addStretch(1)
        oGeneralLayout.addLayout(oThemeLayout)

        # Language with icon
        oLangLayout = new QHBoxLayout()
        oLangIcon = new QLabel(oGeneralTab) {
            setText("🌐")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oLangLayout.addWidget(oLangIcon)

        oLangLabel = new QLabel(oGeneralTab) {
            setText("Language:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oLangLayout.addWidget(oLangLabel)

        oLanguageCombo = new QComboBox(oGeneralTab) {
            addItem("English")
            addItem("Arabic")
            addItem("French")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oLangLayout.addWidget(oLanguageCombo)
        oLangLayout.addStretch(1)
        oGeneralLayout.addLayout(oLangLayout)

        # Update interval with icon
        oUpdateLayout = new QHBoxLayout()
        oUpdateIcon = new QLabel(oGeneralTab) {
            setText("⏱")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oUpdateLayout.addWidget(oUpdateIcon)

        oUpdateLabel = new QLabel(oGeneralTab) {
            setText("Update Interval:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oUpdateLayout.addWidget(oUpdateLabel)

        oUpdateIntervalSpin = new QSpinBox(oGeneralTab) {
            setMinimum(1000)
            setMaximum(60000)
            setSingleStep(1000)
            setSuffix(" ms")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oUpdateLayout.addWidget(oUpdateIntervalSpin)
        oUpdateLayout.addStretch(1)
        oGeneralLayout.addLayout(oUpdateLayout)

        oGeneralTab.setLayout(oGeneralLayout)
        oTabs.addTab(oGeneralTab, "General")

        # System settings tab
        oSystemTab = new QWidget()
        oSystemLayout = new QVBoxLayout()

        # Max agents with icon
        oAgentsLayout = new QHBoxLayout()
        oAgentsIcon = new QLabel(oSystemTab) {
            setText("👤")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oAgentsLayout.addWidget(oAgentsIcon)

        oAgentsLabel = new QLabel(oSystemTab) {
            setText("Max Agents:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oAgentsLayout.addWidget(oAgentsLabel)

        oMaxAgentsSpin = new QSpinBox(oSystemTab) {
            setMinimum(1)
            setMaximum(1000)
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oAgentsLayout.addWidget(oMaxAgentsSpin)
        oAgentsLayout.addStretch(1)
        oSystemLayout.addLayout(oAgentsLayout)

        # Max crews with icon
        oCrewsLayout = new QHBoxLayout()
        oCrewsIcon = new QLabel(oSystemTab) {
            setText("👥")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oCrewsLayout.addWidget(oCrewsIcon)

        oCrewsLabel = new QLabel(oSystemTab) {
            setText("Max Crews:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oCrewsLayout.addWidget(oCrewsLabel)

        oMaxCrewsSpin = new QSpinBox(oSystemTab) {
            setMinimum(1)
            setMaximum(100)
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oCrewsLayout.addWidget(oMaxCrewsSpin)
        oCrewsLayout.addStretch(1)
        oSystemLayout.addLayout(oCrewsLayout)

        # Max tasks per agent with icon
        oTasksLayout = new QHBoxLayout()
        oTasksIcon = new QLabel(oSystemTab) {
            setText("📝")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oTasksLayout.addWidget(oTasksIcon)

        oTasksLabel = new QLabel(oSystemTab) {
            setText("Max Tasks per Agent:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oTasksLayout.addWidget(oTasksLabel)

        oMaxTasksSpin = new QSpinBox(oSystemTab) {
            setMinimum(1)
            setMaximum(50)
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oTasksLayout.addWidget(oMaxTasksSpin)
        oTasksLayout.addStretch(1)
        oSystemLayout.addLayout(oTasksLayout)

        # Backup interval with icon
        oBackupLayout = new QHBoxLayout()
        oBackupIcon = new QLabel(oSystemTab) {
            setText("💾")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oBackupLayout.addWidget(oBackupIcon)

        oBackupLabel = new QLabel(oSystemTab) {
            setText("Backup Interval:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oBackupLayout.addWidget(oBackupLabel)

        oBackupIntervalSpin = new QSpinBox(oSystemTab) {
            setMinimum(300)
            setMaximum(86400)
            setSingleStep(300)
            setSuffix(" seconds")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oBackupLayout.addWidget(oBackupIntervalSpin)
        oBackupLayout.addStretch(1)
        oSystemLayout.addLayout(oBackupLayout)

        oSystemTab.setLayout(oSystemLayout)
        oTabs.addTab(oSystemTab, "System")

        # Advanced settings tab
        oAdvancedTab = new QWidget()
        oAdvancedLayout = new QVBoxLayout()

        # Log level with icon
        oLogLayout = new QHBoxLayout()
        oLogIcon = new QLabel(oAdvancedTab) {
            setText("📓")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oLogLayout.addWidget(oLogIcon)

        oLogLabel = new QLabel(oAdvancedTab) {
            setText("Log Level:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oLogLayout.addWidget(oLogLabel)

        oLogLevelCombo = new QComboBox(oAdvancedTab) {
            addItem("Debug")
            addItem("Info")
            addItem("Warning")
            addItem("Error")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oLogLayout.addWidget(oLogLevelCombo)
        oLogLayout.addStretch(1)
        oAdvancedLayout.addLayout(oLogLayout)

        # Notifications with icon
        oNotifyLayout = new QHBoxLayout()
        oNotifyIcon = new QLabel(oAdvancedTab) {
            setText("🔔")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oNotifyLayout.addWidget(oNotifyIcon)

        oNotifyLabel = new QLabel(oAdvancedTab) {
            setText("Enable Notifications:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oNotifyLayout.addWidget(oNotifyLabel)

        oNotificationsCheck = new QCheckBox(oAdvancedTab) {
            setStyleSheet("font-size: 14px;")
        }
        oNotifyLayout.addWidget(oNotificationsCheck)
        oNotifyLayout.addStretch(1)
        oAdvancedLayout.addLayout(oNotifyLayout)

        oAdvancedTab.setLayout(oAdvancedLayout)
        oTabs.addTab(oAdvancedTab, "Advanced")

        oMainLayout.addWidget(oTabs)

        # Buttons
        oButtonsLayout = new QHBoxLayout()
        oButtonsLayout.addStretch(1)

        oCancelButton = new QPushButton(this) {
            setText("Cancel")
            setStyleSheet("background-color: #e74c3c; color: white; min-width: 100px; padding: 10px; font-size: 14px; border: 1px solid #c0392b; border-radius: 4px;")
        }
        oButtonsLayout.addWidget(oCancelButton)

        oSaveButton = new QPushButton(this) {
            setText("Save")
            setStyleSheet("background-color: #2ecc71; color: white; min-width: 100px; padding: 10px; font-size: 14px; border: 1px solid #27ae60; border-radius: 4px;")
        }
        oButtonsLayout.addWidget(oSaveButton)
        oButtonsLayout.addStretch(1)

        oMainLayout.addLayout(oButtonsLayout)
        oMainLayout.addSpacing(10)

        setLayout(oMainLayout)

        # Connect signals
        oCancelButton.setclickevent("reject()")
        oSaveButton.setclickevent("saveSettings()")
    }

    func loadSettings {
        oSettings.loadSetting()

        # Load values
        oThemeCombo.setCurrentText(proper(oSettings.getKey("theme")))
        oLanguageCombo.setCurrentText(proper(oSettings.getKey("language")))
        oUpdateIntervalSpin.setValue(oSettings.getKey("updateInterval"))
        oMaxAgentsSpin.setValue(oSettings.getKey("maxAgents"))
        oMaxCrewsSpin.setValue(oSettings.getKey("maxCrews"))
        oMaxTasksSpin.setValue(oSettings.getKey("maxTasksPerAgent"))
        oBackupIntervalSpin.setValue(oSettings.getKey("backupInterval"))
        oLogLevelCombo.setCurrentText(proper(oSettings.getKey("logLevel")))
        oNotificationsCheck.setChecked(oSettings.getKey("notifications"))
    }

    func saveSettings {
        # Save values
        oSettings.setKey("theme", lower(oThemeCombo.currentText()))
        oSettings.setKey("language", lower(oLanguageCombo.currentText()))
        oSettings.setKey("updateInterval", oUpdateIntervalSpin.value())
        oSettings.setKey("maxAgents", oMaxAgentsSpin.value())
        oSettings.setKey("maxCrews", oMaxCrewsSpin.value())
        oSettings.setKey("maxTasksPerAgent", oMaxTasksSpin.value())
        oSettings.setKey("backupInterval", oBackupIntervalSpin.value())
        oSettings.setKey("logLevel", lower(oLogLevelCombo.currentText()))
        oSettings.setKey("notifications", oNotificationsCheck.isChecked())

        if oSettings.save() {
            accept()
        }
    }
