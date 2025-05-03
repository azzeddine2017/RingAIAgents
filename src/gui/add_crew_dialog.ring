/*
الكلاس: AddCrewDialog
الوصف: نافذة حوار لإضافة فريق جديد
*/
class AddCrewDialog from QDialog

    # GUI Components
    oNameEdit
    oDescriptionEdit
    oMembersList
    oAvailableAgentsList

    # Data
    aSelectedMembers = []
    oParent  # مرجع للنافذة الأم

    func init oParent {
        super.init(oParent)
        this.oParent = oParent  # تخزين مرجع للنافذة الأم
        setWindowTitle("Add New Crew")
        setModal(true)
        setFixedSize(600, 600)  # عرض أكبر وطول أقل
        initUI()
    }

    # دالة للحصول على النافذة الأم
    func getParent {
        return this.oParent
    }
    
    func initUI {
        # Create main layout
        oMainLayout = new QVBoxLayout()
        oMainLayout.setSpacing(8)
        oMainLayout.setContentsMargins(15, 10, 15, 10)  # تقليل الهوامش

        # Header
        oHeaderLabel = new QLabel(this) {
            setText("Create New Crew")
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
            setText("📅")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oNameLayout.addWidget(oNameIcon)

        oNameLabel = new QLabel(oFormWidget) {
            setText("Crew Name:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oNameLayout.addWidget(oNameLabel)

        oNameEdit = new QLineEdit(oFormWidget) {
            setPlaceholderText("Enter crew name")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oNameLayout.addWidget(oNameEdit)
        oFormLayout.addLayout(oNameLayout)

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
            setPlainText("Enter crew description")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oDescriptionLayout.addWidget(oDescriptionEdit)
        oFormLayout.addLayout(oDescriptionLayout)

        # Members selection section with icon
        oMembersHeaderLayout = new QHBoxLayout()

        oMembersIcon = new QLabel(oFormWidget) {
            setText("👥")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oMembersHeaderLayout.addWidget(oMembersIcon)

        oMembersLabel = new QLabel(oFormWidget) {
            setText("Team Members:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oMembersHeaderLayout.addWidget(oMembersLabel)
        oMembersHeaderLayout.addStretch(1)

        oFormLayout.addLayout(oMembersHeaderLayout)

        # Members selection layout
        oMembersLayout = new QHBoxLayout()

        # Available agents
        oAvailableLayout = new QVBoxLayout()
        oAvailableLabel = new QLabel(oFormWidget) {
            setText("Available Agents:")
            setStyleSheet("font-size: 13px; color: #34495e;")
        }
        oAvailableLayout.addWidget(oAvailableLabel)

        oAvailableAgentsList = new QListWidget(oFormWidget) {
            setStyleSheet("padding: 5px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; min-height: 200px;")
        }
        oAvailableLayout.addWidget(oAvailableAgentsList)
        oMembersLayout.addLayout(oAvailableLayout)

        # Add/Remove buttons
        oButtonsLayout = new QVBoxLayout()
        oButtonsLayout.addStretch(1)

        oAddButton = new QPushButton(oFormWidget) {
            setText(">")
            setStyleSheet("background-color: #3498db; color: white; font-size: 14px; font-weight: bold; padding: 8px; border: 1px solid #2980b9; border-radius: 4px; min-width: 40px;")
        }
        oButtonsLayout.addWidget(oAddButton)

        oRemoveButton = new QPushButton(oFormWidget) {
            setText("<")
            setStyleSheet("background-color: #e74c3c; color: white; font-size: 14px; font-weight: bold; padding: 8px; border: 1px solid #c0392b; border-radius: 4px; min-width: 40px;")
        }
        oButtonsLayout.addWidget(oRemoveButton)
        oButtonsLayout.addStretch(1)

        oMembersLayout.addLayout(oButtonsLayout)

        # Selected members
        oSelectedLayout = new QVBoxLayout()
        oSelectedLabel = new QLabel(oFormWidget) {
            setText("Selected Members:")
            setStyleSheet("font-size: 13px; color: #34495e;")
        }
        oSelectedLayout.addWidget(oSelectedLabel)

        oMembersList = new QListWidget(oFormWidget) {
            setStyleSheet("padding: 5px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; min-height: 200px;")
        }
        oSelectedLayout.addWidget(oMembersList)
        oMembersLayout.addLayout(oSelectedLayout)

        oFormLayout.addLayout(oMembersLayout)
        oFormWidget.setLayout(oFormLayout)
        oMainLayout.addWidget(oFormWidget)

        # Dialog buttons
        oDialogButtonsLayout = new QHBoxLayout()
        oDialogButtonsLayout.addStretch(1)

        oCancelButton = new QPushButton(this) {
            setText("Cancel")
            setStyleSheet("background-color: #e74c3c; color: white; min-width: 100px; padding: 10px; font-size: 14px; border: 1px solid #c0392b; border-radius: 4px;")
        }
        oDialogButtonsLayout.addWidget(oCancelButton)

        oCreateButton = new QPushButton(this) {
            setText("Create")
            setStyleSheet("background-color: #2ecc71; color: white; min-width: 100px; padding: 10px; font-size: 14px; border: 1px solid #27ae60; border-radius: 4px;")
        }
        oDialogButtonsLayout.addWidget(oCreateButton)
        oDialogButtonsLayout.addStretch(1)

        oMainLayout.addLayout(oDialogButtonsLayout)
        oMainLayout.addSpacing(10)

        setLayout(oMainLayout)

        # Connect signals
        oAddButton.setclickevent("addSelectedAgent()")
        oRemoveButton.setclickevent("removeSelectedMember()")
        oCancelButton.setclickevent("reject()")
        oCreateButton.setclickevent("createCrew()")

        # Set focus
        oNameEdit.setFocus(true)

        # Load available agents
        loadAvailableAgents()
    }

    func loadAvailableAgents {
        # Get agents from parent window
        aAgents = getParent().aAgents
        for agent in aAgents {
            if !isAgentInCrew(agent) {
                oAvailableAgentsList.addItem(agent.getName())
            }
        }
    }

    func addSelectedAgent {
        nIndex = oAvailableAgentsList.currentRow()
        if nIndex >= 0 {
            cAgent = oAvailableAgentsList.item(nIndex).text()
            oAgent = findAgent(cAgent)
            if oAgent {
                add(aSelectedMembers, oAgent)
                oMembersList.addItem(cAgent)
                oAvailableAgentsList.takeItem(nIndex)
            }
        }
    }

    func removeSelectedMember {
        nIndex = oMembersList.currentRow()
        if nIndex >= 0 {
            cAgent = oMembersList.item(nIndex).text()
            oAgent = findAgent(cAgent)
            if oAgent {
                del(aSelectedMembers, find(aSelectedMembers, oAgent))
                oAvailableAgentsList.addItem(cAgent)
                oMembersList.takeItem(nIndex)
            }
        }
    }

    func createCrew {
        if validateInput() {
            accept()
        }
    }

    func getCrewData {
        return [
            :name = oNameEdit.text(),
            :description = oDescriptionEdit.toPlainText(),
            :members = aSelectedMembers
        ]
    }

    private

    func validateInput {
        if oNameEdit.text() = "" {
             new qmessagebox(this) {
                setwindowtitle("Validation Error")
                settext("messagebox text")
                setInformativeText("Please enter crew name")
                setstandardbuttons(qmessagebox_ok)
                exec()
            }
            return false
        }

        if oDescriptionEdit.toPlainText() = "" {
           
             new qmessagebox(this) {
                setwindowtitle("Validation Error")
                settext("messagebox text")
                setInformativeText("Please enter task description")
                setstandardbuttons(qmessagebox_ok)
                exec()
            }
            return false
        }

        if len(aSelectedMembers) = 0 {
            new qmessagebox(this) {
                setwindowtitle("Validation Error")
                settext("messagebox text")
                setInformativeText("Please select at least one member")
                setstandardbuttons(qmessagebox_ok)
                exec()
            }
            return false
        }

        return true
    }

    func findAgent cName {
        for agent in getParent().aAgents {
            if agent.getName() = cName {
                return agent
            }
        }
        return null
    }

    func isAgentInCrew oAgent {
        for crew in getParent().aCrews {
            if find(crew.getMembers(), oAgent) {
                return true
            }
        }
        return false
    }
