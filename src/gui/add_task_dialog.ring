

/*
الكلاس: GUITask
الوصف: تمثيل مهمة في النظام لواجهة المستخدم
*/
class GUITask
    # Constants
    cNEW = :new
    IN_PROGRESS = :in_progress
    COMPLETED = :completed
    FAILED = :failed

    # Properties
    cId
    cName
    cDescription
    cStatus
    cPriority
    cDueDate
    nProgress
    oAssignedTo
    oCreatedBy
    aSubTasks
    aComments
    aHistory
    oMetadata

    func init cTaskName, cTaskDescription {
        # Initialize properties
        cId = generateUniqueId("task")
        cName = cTaskName
        cDescription = cTaskDescription
        cStatus = cNEW
        cPriority = "medium"
        cDueDate = ""
        nProgress = 0
        oAssignedTo = null
        oCreatedBy = null
        aSubTasks = []
        aComments = []
        aHistory = []
        oMetadata = []

        # Add creation to history
        addHistoryEntry("Task created")
    }

    # Getters
    func getId return cId
    func getName return cName
    func getDescription return cDescription
    func getStatus return cStatus
    func getPriority return cPriority
    func getDueDate return cDueDate
    func getProgress return nProgress
    func getAssignedTo return oAssignedTo
    func getCreatedBy return oCreatedBy
    func getSubTasks return aSubTasks
    func getComments return aComments
    func getHistory return aHistory
    func getMetadata return oMetadata

    # Setters
    func setName cValue {
        cName = cValue
        addHistoryEntry("Name updated to: " + cValue)
    }

    func setDescription cValue {
        cDescription = cValue
        addHistoryEntry("Description updated")
    }

    func setStatus cValue {
        if isValidStatus(cValue) {
            cStatus = cValue
            addHistoryEntry("Status changed to: " + cValue)
        }
    }

    func setPriority cValue {
        cPriority = cValue
        addHistoryEntry("Priority set to: " + cValue)
    }

    func setDueDate cValue {
        cDueDate = cValue
        addHistoryEntry("Due date set to: " + cValue)
    }

    func setProgress nValue {
        if nValue >= 0 and nValue <= 100 {
            nProgress = nValue
            addHistoryEntry("Progress updated to: " + nValue + "%")

            # Update status based on progress
            if nProgress = 100 {
                setStatus(COMPLETED)

            elseif nProgress > 0
                setStatus(IN_PROGRESS)
            }
        }
    }

    func assign oTarget {
        oAssignedTo = oTarget
        addHistoryEntry("Assigned to: " + oTarget.getName())
    }

    # Task management
    func addSubTask oTask {
        add(aSubTasks, oTask)
        addHistoryEntry("Added subtask: " + oTask.getName())
    }

    func addComment cComment, oUser {
        add(aComments, [
            :text = cComment,
            :user = oUser,
            :timestamp = date()
        ])
        addHistoryEntry("Comment added by: " + oUser.getName())
    }

    private

    func isValidStatus cValue {
        return cValue = cNEW or
               cValue = IN_PROGRESS or
               cValue = COMPLETED or
               cValue = FAILED
    }

    func addHistoryEntry cEntry {
        add(aHistory, [
            :entry = cEntry,
            :timestamp = date()
        ])
    }

    func generateUniqueId cPrefix {
        return cPrefix + "_" + random(100000)
    }

/*
الكلاس: AddTaskDialog
الوصف: نافذة إضافة مهمة جديدة
*/
class AddTaskDialog from QDialog

    # GUI Components
    oNameEdit
    oDescriptionEdit
    oPriorityCombo
    oDueDateEdit
    oAssigneeCombo
    oSubTasksList
    oTemplateCombo
    oAgentRadio
    
    # Data
    oTask
    oParent  # مرجع للنافذة الأم

    
    func init oParent {
        super.init(oParent)
        this.oParent = oParent  # تخزين مرجع للنافذة الأم
        setWindowTitle("Add New Task")
        setModal(true)
        setFixedSize(600, 600)  # عرض أكبر وطول أقل
        initUI()
        loadTemplates()
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
            setText("Create New Task")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 24px; font-weight: bold; color: #2c3e50; margin: 15px 0;")
        }
        oMainLayout.addWidget(oHeaderLabel)

        # Create tabs with styling
        oTabs = new QTabWidget(this)
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

        # Basic info tab
        oBasicTab = new QWidget()
        oBasicLayout = new QVBoxLayout()

        # Name with icon
        oNameLayout = new QHBoxLayout()
        oNameIcon = new QLabel(oBasicTab) {
            setText("💾")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oNameLayout.addWidget(oNameIcon)

        oNameLabel = new QLabel(oBasicTab) {
            setText("Task Name:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oNameLayout.addWidget(oNameLabel)

        oNameEdit = new QLineEdit(oBasicTab) {
            setPlaceholderText("Enter task name")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oNameLayout.addWidget(oNameEdit)
        oBasicLayout.addLayout(oNameLayout)

        # Description with icon
        oDescLayout = new QVBoxLayout()
        oDescHeaderLayout = new QHBoxLayout()

        oDescIcon = new QLabel(oBasicTab) {
            setText("📝")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oDescHeaderLayout.addWidget(oDescIcon)

        oDescLabel = new QLabel(oBasicTab) {
            setText("Description:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oDescHeaderLayout.addWidget(oDescLabel)
        oDescHeaderLayout.addStretch(1)

        oDescLayout.addLayout(oDescHeaderLayout)

        oDescriptionEdit = new QTextEdit(oBasicTab) {
            setPlainText("Enter task description")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oDescLayout.addWidget(oDescriptionEdit)
        oBasicLayout.addLayout(oDescLayout)

        # Priority with icon
        oPriorityLayout = new QHBoxLayout()
        oPriorityIcon = new QLabel(oBasicTab) {
            setText("🚨")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oPriorityLayout.addWidget(oPriorityIcon)

        oPriorityLabel = new QLabel(oBasicTab) {
            setText("Priority:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oPriorityLayout.addWidget(oPriorityLabel)

        oPriorityCombo = new QComboBox(oBasicTab) {
            addItem("Low", 0)
            addItem("Medium",0)
            addItem("High",0)
            addItem("Critical",0)
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oPriorityLayout.addWidget(oPriorityCombo)
        oPriorityLayout.addStretch(1)
        oBasicLayout.addLayout(oPriorityLayout)

        # Due date with icon
        oDueDateLayout = new QHBoxLayout()
        oDueDateIcon = new QLabel(oBasicTab) {
            setText("📅")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oDueDateLayout.addWidget(oDueDateIcon)

        oDueDateLabel = new QLabel(oBasicTab) {
            setText("Due Date:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oDueDateLayout.addWidget(oDueDateLabel)

        oDueDateEdit = new QDateTimeEdit(oBasicTab) {
            setCalendarPopup(true)
            setDateTime(date())
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oDueDateLayout.addWidget(oDueDateEdit)
        oDueDateLayout.addStretch(1)
        oBasicLayout.addLayout(oDueDateLayout)

        # Template with icon
        oTemplateLayout = new QHBoxLayout()
        oTemplateIcon = new QLabel(oBasicTab) {
            setText("🖼")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oTemplateLayout.addWidget(oTemplateIcon)

        oTemplateLabel = new QLabel(oBasicTab) {
            setText("Template:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oTemplateLayout.addWidget(oTemplateLabel)

        oTemplateCombo = new QComboBox(oBasicTab) {
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oTemplateLayout.addWidget(oTemplateCombo)
        oTemplateLayout.addStretch(1)
        oBasicLayout.addLayout(oTemplateLayout)

        oBasicTab.setLayout(oBasicLayout)
        oTabs.addTab(oBasicTab, "Basic Info")

        # Assignment tab
        oAssignmentTab = new QWidget()
        oAssignmentLayout = new QVBoxLayout()

        # Assignee type with icon
        oAssignTypeLayout = new QHBoxLayout()
        oAssignIcon = new QLabel(oAssignmentTab) {
            setText("👤")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oAssignTypeLayout.addWidget(oAssignIcon)

        oAssignLabel = new QLabel(oAssignmentTab) {
            setText("Assign To:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oAssignTypeLayout.addWidget(oAssignLabel)
        oAssignTypeLayout.addStretch(1)
        oAssignmentLayout.addLayout(oAssignTypeLayout)

        # Radio buttons in a styled frame
        oTypeFrame = new QFrame(oAssignmentTab, 0) {
            setFrameShape(QFrame_StyledPanel)
            setStyleSheet("background-color: #ecf0f1; border-radius: 4px; padding: 10px; margin: 5px 0;")
        }
        oTypeLayout = new QHBoxLayout()

        oAgentRadio = new QRadioButton(oTypeFrame) {
            setText("Agent")
            setChecked(true)
            setStyleSheet("font-size: 14px;")
        }
        oTypeLayout.addWidget(oAgentRadio)

        oCrewRadio = new QRadioButton(oTypeFrame) {
            setText("Crew")
            setStyleSheet("font-size: 14px;")
        }
        oTypeLayout.addWidget(oCrewRadio)
        oTypeLayout.addStretch(1)

        oTypeFrame.setLayout(oTypeLayout)
        oAssignmentLayout.addWidget(oTypeFrame)

        # Assignee selection with icon
        oAssigneeLayout = new QHBoxLayout()
        oAssigneeIcon = new QLabel(oAssignmentTab) {
            setText("👥")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oAssigneeLayout.addWidget(oAssigneeIcon)

        oAssigneeLabel = new QLabel(oAssignmentTab) {
            setText("Select Assignee:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oAssigneeLayout.addWidget(oAssigneeLabel)
        oAssigneeLayout.addStretch(1)
        oAssignmentLayout.addLayout(oAssigneeLayout)

        oAssigneeCombo = new QComboBox(oAssignmentTab) {
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; margin: 5px 0;")
        }
        oAssignmentLayout.addWidget(oAssigneeCombo)

        oAssignmentTab.setLayout(oAssignmentLayout)
        oTabs.addTab(oAssignmentTab, "Assignment")

        # Subtasks tab
        oSubtasksTab = new QWidget()
        oSubtasksLayout = new QVBoxLayout()

        # Subtasks header with icon
        oSubtasksHeaderLayout = new QHBoxLayout()
        oSubtasksIcon = new QLabel(oSubtasksTab) {
            setText("📌")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oSubtasksHeaderLayout.addWidget(oSubtasksIcon)

        oSubtasksLabel = new QLabel(oSubtasksTab) {
            setText("Subtasks:")
            setStyleSheet("font-size: 14px; font-weight: bold;")
        }
        oSubtasksHeaderLayout.addWidget(oSubtasksLabel)
        oSubtasksHeaderLayout.addStretch(1)
        oSubtasksLayout.addLayout(oSubtasksHeaderLayout)

        oSubTasksList = new QListWidget(oSubtasksTab) {
            setStyleSheet("padding: 5px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; min-height: 200px;")
        }
        oSubtasksLayout.addWidget(oSubTasksList)

        oAddSubtaskButton = new QPushButton(oSubtasksTab) {
            setText("Add Subtask")
            setStyleSheet("background-color: #3498db; color: white; padding: 8px; font-size: 14px; border: 1px solid #2980b9; border-radius: 4px;")
        }
        oSubtasksLayout.addWidget(oAddSubtaskButton)

        oSubtasksTab.setLayout(oSubtasksLayout)
        oTabs.addTab(oSubtasksTab, "Subtasks")

        oMainLayout.addWidget(oTabs)

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
        oAgentRadio.setclickedevent("updateAssigneeList()")
        oCrewRadio.setclickedevent("updateAssigneeList()")
       // oTemplateCombo.getcurrentIndexChangedEvent("loadTemplate()")
        oAddSubtaskButton.setclickevent("showAddSubtaskDialog()")
        oCancelButton.setclickevent("reject()")
        oCreateButton.setclickevent("createTask()")

        # Set focus
        oNameEdit.setFocus(true)

        # Initial update
        updateAssigneeList()
    }

    func loadTemplates {
        # TODO: Load task templates from storage
        oTemplateCombo.addItem("None", 0)
        oTemplateCombo.addItem("Bug Fix", 0)
        oTemplateCombo.addItem("Feature Request", 0)
        oTemplateCombo.addItem("Documentation", 0)
    }

    func loadTemplate {
        nIndex = oTemplateCombo.currentIndex()
        if nIndex > 0 {
            switch nIndex {
                on 1  # Bug Fix
                    this.oNameEdit.setText("Fix: ")
                    this.oDescriptionEdit.setText("Bug Description:" + nl + nl +"Steps to Reproduce:" + nl + nl +"Expected Behavior:" + nl + nl +"Actual Behavior:")
                    this.oPriorityCombo.setCurrentText("High")

                on 2  # Feature Request
                    this.oNameEdit.setText("Feature: ")
                    this.oDescriptionEdit.setText("Feature Description:" + nl + nl +"Use Cases:" + nl + nl +"Acceptance Criteria:")
                    this.oPriorityCombo.setCurrentText("Medium")

                on 3  # Documentation
                    oNameEdit.setText("Doc: ")
                    oDescriptionEdit.setText("Documentation Type:" + nl + nl +"Target Audience:" + nl + nl +"Key Points:")
                    oPriorityCombo.setCurrentText("Low")
            }
        }
    }

    func updateAssigneeList {
        oAssigneeCombo.clear()

        if oAgentRadio.isChecked() {
            for agent in getParent().aAgents {
                oAssigneeCombo.addItem(agent.getName())
            }
        else
            for crew in getParent().aCrews {
                oAssigneeCombo.addItem(crew.getName())
            }
        }
    }

    func showAddSubtaskDialog {
        cSubtask = QInputDialog.getText(
            this,
            "Add Subtask",
            "Enter subtask description:",
            QLineEdit.Normal,
            ""
        )
        if cSubtask != "" {
            oSubTasksList.addItem(cSubtask)
        }
    }

    func createTask {
        if validateInput() {
            # Create task
            oTask = new GUITask(
                oNameEdit.text(),
                oDescriptionEdit.toPlainText()
            )

            # Set properties
            oTask.setPriority(lower(oPriorityCombo.currentText()))
            oTask.setDueDate(oDueDateEdit.dateTime())

            # Add subtasks
            for i = 1 to oSubTasksList.count() {
                oSubTask = new GUITask(
                    oSubTasksList.item(i-1).text(),
                    "Subtask of: " + oNameEdit.text()
                )
                oTask.addSubTask(oSubTask)
            }

            # Assign task
            if oAgentRadio.isChecked() {
                oTask.assign(findAgent(oAssigneeCombo.currentText()))
            else
                oTask.assign(findCrew(oAssigneeCombo.currentText()))
            }

            accept()
        }
    }

    func getTaskData {
        return oTask
    }

    func getTaskName {
        return oNameEdit.text()
    }

    func getAssignedTo {
        return oAssigneeCombo.currentText()
    }

    func getPriority {
        return oPriorityCombo.currentIndex() + 1
    }

    private

    func validateInput {
        if oNameEdit.text() = "" {
            new qmessagebox(this) {
                setwindowtitle("Validation Error")
                settext("messagebox text")
                setInformativeText("Please enter task name")
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

        if oAssigneeCombo.currentText() = "" {
            
             new qmessagebox(this) {
                setwindowtitle("Validation Error")
                settext("messagebox text")
                setInformativeText("Please select an assignee")
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

    func findCrew cName {
        for crew in getParent().aCrews {
            if crew.getName() = cName {
                return crew
            }
        }
        return null
    }
