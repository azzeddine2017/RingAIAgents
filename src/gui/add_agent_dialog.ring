/*
الكلاس: AddAgentDialog
الوصف: نافذة حوار لإضافة عميل جديد
*/

class AddAgentDialog from QDialog

    # GUI Components
    oNameEdit
    oRoleEdit
    oDescriptionEdit
    oSkillsList
    oPersonalityList


    # Data
    aSkills = []
    aPersonalityTraits = []
    oParent  # مرجع للنافذة الأم

   

    func init oParent {
        super.init(oParent)
        this.oParent = oParent  # تخزين مرجع للنافذة الأم
        setWindowTitle("Add New Agent")
        setModal(true)
        setFixedSize(600, 600)  # عرض أكبر وطول أقل
        initUI()
    }

     # دالة للحصول على النافذة الأم
    func getParent {
        return oParent
    }
    
    func initUI {
        # Create main layout
        oMainLayout = new QVBoxLayout()
        oMainLayout.setSpacing(8)
        oMainLayout.setContentsMargins(15, 10, 15, 10)  # تقليل الهوامش

        # Header
        oHeaderLabel = new QLabel(this) {
            setText("Create New Agent")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 24px; font-weight: bold; color: #2c3e50; margin: 15px 0;")
        }
        oMainLayout.addWidget(oHeaderLabel)

        # Form widget with border
        oFormWidget = new QWidget()
        oFormWidget.setStyleSheet("background-color: #f8f9fa; border-radius: 8px; padding: 10px;")
        oFormLayout = new QVBoxLayout()
        oFormLayout.setSpacing(12)

        # Name input with icon
        oNameLayout = new QHBoxLayout()
        oNameIcon = new QLabel(oFormWidget) {
            setText("👤")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oNameLayout.addWidget(oNameIcon)

        oNameLabel = new QLabel(oFormWidget) {
            setText("Name:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oNameLayout.addWidget(oNameLabel)

        oNameEdit = new QLineEdit(oFormWidget) {
            setPlaceholderText("Enter agent name")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oNameLayout.addWidget(oNameEdit)
        oFormLayout.addLayout(oNameLayout)

        # Role input with icon
        oRoleLayout = new QHBoxLayout()
        oRoleIcon = new QLabel(oFormWidget) {
            setText("🎭")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oRoleLayout.addWidget(oRoleIcon)

        oRoleLabel = new QLabel(oFormWidget) {
            setText("Role:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oRoleLayout.addWidget(oRoleLabel)

        oRoleEdit = new QLineEdit(oFormWidget) {
            setPlaceholderText("Enter agent role")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oRoleLayout.addWidget(oRoleEdit)
        oFormLayout.addLayout(oRoleLayout)

        # Description input with icon
        oDescriptionLayout = new QVBoxLayout()
        oDescHeaderLayout = new QHBoxLayout()

        oDescIcon = new QLabel(oFormWidget) {
            setText("📝")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oDescHeaderLayout.addWidget(oDescIcon)

        oDescLabel = new QLabel(oFormWidget) {
            setText("Description:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oDescHeaderLayout.addWidget(oDescLabel)
        oDescHeaderLayout.addStretch(1)

        oDescriptionLayout.addLayout(oDescHeaderLayout)

        oDescriptionEdit = new QTextEdit(oFormWidget) {
            setPlainText("Enter agent description")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oDescriptionLayout.addWidget(oDescriptionEdit)
        oFormLayout.addLayout(oDescriptionLayout)

        # Skills list with icon
        oSkillsLayout = new QVBoxLayout()
        oSkillsHeaderLayout = new QHBoxLayout()

        oSkillsIcon = new QLabel(oFormWidget) {
            setText("🔧")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oSkillsHeaderLayout.addWidget(oSkillsIcon)

        oSkillsLabel = new QLabel(oFormWidget) {
            setText("Skills:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oSkillsHeaderLayout.addWidget(oSkillsLabel)
        oSkillsHeaderLayout.addStretch(1)

        oSkillsLayout.addLayout(oSkillsHeaderLayout)

        oSkillsList = new QListWidget(oFormWidget) {
            setStyleSheet("padding: 5px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; min-height: 100px;")
        }
        oSkillsLayout.addWidget(oSkillsList)

        oAddSkillButton = new QPushButton(oFormWidget) {
            setText("Add Skill")
            setStyleSheet("background-color: #3498db; color: white; padding: 8px; font-size: 14px; border: 1px solid #2980b9; border-radius: 4px;")
        }
        oSkillsLayout.addWidget(oAddSkillButton)
        oFormLayout.addLayout(oSkillsLayout)

        # Personality traits with icon
        oPersonalityLayout = new QVBoxLayout()
        oPersonalityHeaderLayout = new QHBoxLayout()

        oPersonalityIcon = new QLabel(oFormWidget) {
            setText("😀")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oPersonalityHeaderLayout.addWidget(oPersonalityIcon)

        oPersonalityLabel = new QLabel(oFormWidget) {
            setText("Personality Traits:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oPersonalityHeaderLayout.addWidget(oPersonalityLabel)
        oPersonalityHeaderLayout.addStretch(1)

        oPersonalityLayout.addLayout(oPersonalityHeaderLayout)

        oPersonalityList = new QListWidget(oFormWidget) {
            setStyleSheet("padding: 5px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; min-height: 100px;")
        }
        oPersonalityLayout.addWidget(oPersonalityList)

        oAddTraitButton = new QPushButton(oFormWidget) {
            setText("Add Trait")
            setStyleSheet("background-color: #3498db; color: white; padding: 8px; font-size: 14px; border: 1px solid #2980b9; border-radius: 4px;")
        }
        oPersonalityLayout.addWidget(oAddTraitButton)
        oFormLayout.addLayout(oPersonalityLayout)

        oFormWidget.setLayout(oFormLayout)
        oMainLayout.addWidget(oFormWidget)

        # Buttons
        oButtonsLayout = new QHBoxLayout()
        oButtonsLayout.addStretch(1)

        oCancelButton = new QPushButton(this) {
            setText("Cancel")
            setStyleSheet("background-color: #e74c3c; color: white; min-width: 100px; padding: 10px; font-size: 14px; border: 1px solid #c0392b; border-radius: 4px;")
        }
        oButtonsLayout.addWidget(oCancelButton)

        oCreateButton = new QPushButton(this) {
            setText("Create")
            setStyleSheet("background-color: #2ecc71; color: white; min-width: 100px; padding: 10px; font-size: 14px; border: 1px solid #27ae60; border-radius: 4px;")
        }
        oButtonsLayout.addWidget(oCreateButton)
        oButtonsLayout.addStretch(1)

        oMainLayout.addLayout(oButtonsLayout)
        oMainLayout.addSpacing(10)

        setLayout(oMainLayout)

        # Connect signals
        oAddSkillButton.setclickevent("showAddSkillDialog()")
        oAddTraitButton.setclickevent("howAddTraitDialog()")
        oCancelButton.setclickevent("reject()")
        oCreateButton.setclickevent("createAgent()")

        # Set focus
        oNameEdit.setFocus(true)
    }

    func showAddSkillDialog {

        cSkill = New QInputDialog(this) {
                setwindowtitle("Add Skill")
                setgeometry(100,100,400,50)
                setlabeltext("Enter skill name:")
                settextvalue("")
                lcheck = exec()
                if lCheck {
                this.aSkills + cSkill.textvalue()
                this.oSkillsList.addItem(cSkill.textvalue())
                }
        }


    }

    func showAddTraitDialog {
        cTrait = New QInputDialog(this) {
                setwindowtitle("Add Personality Trait")
                setlabeltext("Enter trait:")
                settextvalue("")
                lcheck = exec()
                if lCheck {
                this.aPersonalityTraits + cTrait.textvalue()
                this.oPersonalityList.addItem(cTrait.textvalue())
                }
        }
    }

    func createAgent {
        if validateInput() {
            accept()
        }
    }

    func getAgentData {
        return [
            :name = oNameEdit.text(),
            :role = oRoleEdit.text(),
            :description = oDescriptionEdit.toPlainText(),
            :skills = aSkills,
            :personality = aPersonalityTraits
        ]
    }

    private

    func validateInput {
        if oNameEdit.text() = "" {
            MessageBoxWarning(
                this,
                "Validation Error",
                "Please enter agent name"
            )
            return false
        }

        if oRoleEdit.text() = "" {
            MessageBoxWarning(
                this,
                "Validation Error",
                "Please enter agent role"
            )
            return false
        }

        if oDescriptionEdit.toPlainText() = "" {
            MessageBoxWarning(
                this,
                "Validation Error",
                "Please enter agent description"
            )
            return false
        }

        return true
    }

    func MessageBoxWarning(oObject, cTitle, cMessage) {
        new QMessageBox(oObject) {
            setWindowTitle(cTitle)
            setText(cMessage)
            setStandardButtons(QMessageBox_Ok)
            exec()
        }
    }
               