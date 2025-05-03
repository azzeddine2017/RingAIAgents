/*
الكلاس: TaskManagerDialog
الوصف: نافذة إدارة المهام وعرض تفاصيلها
*/
class TaskManagerDialog from QDialog
    
    # GUI Components
    oTaskTable
    oFilterCombo
    oSearchEdit
    oStatusFilter
    oAssigneeFilter
    oKPIChart
    oDetailsPanel
    
    # Data
    aTasks
    aFilteredTasks
    oParent  # مرجع للنافذة الأم
    
    func init oParent {
        super.init(oParent)
        this.oParent = oParent  # تخزين مرجع للنافذة الأم
        setWindowTitle("Task Manager")
        resize(900, 700)
        aTasks = []
        aFilteredTasks = []
        initUI()
        loadTasks()
        updateKPIs()
    }
    
         # دالة للحصول على النافذة الأم
    func getParent {
        return this.oParent
    }
    
    func initUI {
        # Create main layout
        oMainLayout = new QHBoxLayout()
        
        # Left panel - Task list and filters
        oLeftPanel = new QWidget()
        oLeftLayout = new QVBoxLayout()
        
        # Search and filters
        oFilterLayout = new QHBoxLayout()
        
        oSearchEdit = new QLineEdit() {
            setPlaceholderText("Search tasks...")
        }
        oFilterLayout.addWidget(oSearchEdit)
        
        oFilterCombo = new QComboBox() {
            addItem("All Tasks")
            addItem("My Tasks")
            addItem("Unassigned")
            addItem("High Priority")
            addItem("Due Soon")
        }
        oFilterLayout.addWidget(oFilterCombo)
        
        oLeftLayout.addLayout(oFilterLayout)
        
        # Status filter
        oStatusGroup = new QGroupBox("Status")
        oStatusLayout = new QHBoxLayout()
        
        oStatusFilter = []
        for cStatus in ["New", "In Progress", "Completed", "Failed"] {
            oCheckBox = new QCheckBox(cStatus)
            oCheckBox.setChecked(true)
            add(oStatusFilter, oCheckBox)
            oStatusLayout.addWidget(oCheckBox)
        }
        
        oStatusGroup.setLayout(oStatusLayout)
        oLeftLayout.addWidget(oStatusGroup)
        
        # Task table
        oTaskTable = new QTableWidget() {
            setColumnCount(6)
            setHorizontalHeaderLabels([
                "ID",
                "Name",
                "Status",
                "Priority",
                "Assignee",
                "Due Date"
            ])
            setSelectionBehavior(QAbstractItemView_SelectRows)
            setSelectionMode(QAbstractItemView_SingleSelection)
            setEditTriggers(QAbstractItemView_NoEditTriggers)
            horizontalHeader().setSectionResizeMode(1, QHeaderView_Stretch)
        }
        oLeftLayout.addWidget(oTaskTable)
        
        # Action buttons
        oActionLayout = new QHBoxLayout()
        
        oAddButton = new QPushButton("Add Task")
        oActionLayout.addWidget(oAddButton)
        
        oEditButton = new QPushButton("Edit")
        oActionLayout.addWidget(oEditButton)
        
        oDeleteButton = new QPushButton("Delete")
        oActionLayout.addWidget(oDeleteButton)
        
        oExportButton = new QPushButton("Export")
        oActionLayout.addWidget(oExportButton)
        
        oLeftLayout.addLayout(oActionLayout)
        oLeftPanel.setLayout(oLeftLayout)
        oMainLayout.addWidget(oLeftPanel, 60)
        
        # Right panel - Details and KPIs
        oRightPanel = new QWidget()
        oRightLayout = new QVBoxLayout()
        
        # KPI Chart
        oKPIChart = new QChartView()
        oRightLayout.addWidget(oKPIChart)
        
        # Task details
        oDetailsPanel = new QGroupBox("Task Details")
        oDetailsLayout = new QVBoxLayout()
        
        # Details will be populated when a task is selected
        oDetailsPanel.setLayout(oDetailsLayout)
        oRightLayout.addWidget(oDetailsPanel)
        
        oRightPanel.setLayout(oRightLayout)
        oMainLayout.addWidget(oRightPanel, 40)
        
        setLayout(oMainLayout)
        
        # Connect signals
        oSearchEdit.textChangedEvent("filterTasks()")
        oFilterCombo.currentIndexChangedEvent("filterTasks()")
        for oCheck in oStatusFilter {
            oCheck.stateChangedEvent("filterTasks()")
        }
        oTaskTable.cellClickedEvent("showTaskDetails(" +row() + "," +  column() + ")")
        oAddButton.setClickEvent("showAddTaskDialog()")
        oEditButton.setClickEvent("editSelectedTask()")
        oDeleteButton.setClickEvent("deleteSelectedTask()")
        oExportButton.setClickEvent("exportTasks()")
    }
    
    func loadTasks {
        # TODO: Load tasks from storage
        clearTasks()
        aTasks = getParent().getTasks()
        filterTasks()
    }
    
    func filterTasks {
        aFilteredTasks = []
        
        # Get active status filters
        aActiveStatus = []
        for oCheck in oStatusFilter {
            if oCheck.isChecked() {
                add(aActiveStatus, lower(oCheck.text()))
            }
        }
        
        # Apply filters
        for oTask in aTasks {
            if shouldShowTask(oTask, aActiveStatus) {
                add(aFilteredTasks, oTask)
            }
        }
        
        updateTaskTable()
    }
    
    func shouldShowTask oTask, aActiveStatus {
        # Check status filter
        if not find(aActiveStatus, oTask.getStatus()) {
            return false
        }
        
        # Check search text
        cSearch = lower(oSearchEdit.text())
        if cSearch != "" {
            if not (substr(lower(oTask.getName()), cSearch) or
                   substr(lower(oTask.getDescription()), cSearch)) {
                return false
            }
        }
        
        # Check combo filter
        switch oFilterCombo.currentIndex() {
            on 1  # My Tasks
                if not isMyTask(oTask) { return false }
            
            on 2  # Unassigned
                if oTask.getAssignedTo() != null { return false }
            
            on 3  # High Priority
                if oTask.getPriority() != "high" and 
                   oTask.getPriority() != "critical" { return false }
            
            on 4  # Due Soon
                if not isDueSoon(oTask) { return false }
        }
        
        return true
    }
    
    func updateTaskTable {
        oTaskTable.setRowCount(len(aFilteredTasks))
        
        for i = 1 to len(aFilteredTasks) {
            oTask = aFilteredTasks[i]
            
            # ID
            item = new QTableWidgetItem(oTask.getId())
            oTaskTable.setItem(i-1, 0, item)
            
            # Name
            item = new QTableWidgetItem(oTask.getName())
            oTaskTable.setItem(i-1, 1, item)
            
            # Status
            item = new QTableWidgetItem(upper(oTask.getStatus()))
            item.setBackground(getStatusColor(oTask.getStatus()))
            oTaskTable.setItem(i-1, 2, item)
            
            # Priority
            item = new QTableWidgetItem(upper(oTask.getPriority()))
            item.setForeground(getPriorityColor(oTask.getPriority()))
            oTaskTable.setItem(i-1, 3, item)
            
            # Assignee
            cAssignee = ""
            if oTask.getAssignedTo() != null {
                cAssignee = oTask.getAssignedTo().getName()
            }
            item = new QTableWidgetItem(cAssignee)
            oTaskTable.setItem(i-1, 4, item)
            
            # Due Date
            item = new QTableWidgetItem(oTask.getDueDate())
            if isDueSoon(oTask) {
                item.setForeground(new QColor(255,0,0))
            }
            oTaskTable.setItem(i-1, 5, item)
        }
        
        oTaskTable.resizeColumnsToContents()
        updateKPIs()
    }
    
    func showTaskDetails nRow, nCol {
        if nRow >= 0 and nRow < len(aFilteredTasks) {
            oTask = aFilteredTasks[nRow + 1]
            
            # Clear previous details
            oDetailsLayout = oDetailsPanel.layout()
            clearLayout(oDetailsLayout)
            
            # Add new details
            oDetailsLayout.addWidget(new QLabel("Name: " + oTask.getName()))
            oDetailsLayout.addWidget(new QLabel("Status: " + upper(oTask.getStatus())))
            oDetailsLayout.addWidget(new QLabel("Priority: " + upper(oTask.getPriority())))
            
            cAssignee = "Unassigned"
            if oTask.getAssignedTo() != null {
                cAssignee = oTask.getAssignedTo().getName()
            }
            oDetailsLayout.addWidget(new QLabel("Assigned To: " + cAssignee))
            
            oDetailsLayout.addWidget(new QLabel("Due Date: " + oTask.getDueDate()))
            
            # Progress bar
            oProgress = new QProgressBar() {
                setRange(0, 100)
                setValue(oTask.getProgress())
            }
            oDetailsLayout.addWidget(oProgress)
            
            # Description
            oDescLabel = new QLabel("Description:")
            oDetailsLayout.addWidget(oDescLabel)
            
            oDescEdit = new QTextEdit() {
                setPlainText(oTask.getDescription())
                setReadOnly(true)
            }
            oDetailsLayout.addWidget(oDescEdit)
            
            # Subtasks
            if len(oTask.getSubTasks()) > 0 {
                oSubtasksLabel = new QLabel("Subtasks:")
                oDetailsLayout.addWidget(oSubtasksLabel)
                
                oSubtasksList = new QListWidget()
                for oSubtask in oTask.getSubTasks() {
                    oSubtasksList.addItem(oSubtask.getName())
                }
                oDetailsLayout.addWidget(oSubtasksList)
            }
            
            # Comments
            if len(oTask.getComments()) > 0 {
                oCommentsLabel = new QLabel("Comments:")
                oDetailsLayout.addWidget(oCommentsLabel)
                
                for oComment in oTask.getComments() {
                    oCommentWidget = new QLabel(
                        oComment[:user].getName() + " (" + 
                        oComment[:timestamp] + "): " + 
                        oComment[:text]
                    )
                    oCommentWidget.setWordWrap(true)
                    oDetailsLayout.addWidget(oCommentWidget)
                }
            }
            
            # Add comment button
            oAddCommentButton = new QPushButton("Add Comment")
            oAddCommentButton.setClickEvent("showAddCommentDialog()")
            oDetailsLayout.addWidget(oAddCommentButton)
            
            oDetailsLayout.addStretch()
        }
    }
    
    func showAddTaskDialog {
        oDialog = new AddTaskDialog(this)
        if oDialog.exec() = QDialog_Accepted {
            oTask = oDialog.getTaskData()
            add(aTasks, oTask)
            filterTasks()
        }
    }
    
    func editSelectedTask {
        nRow = oTaskTable.currentRow()
        if nRow >= 0 {
            oTask = aFilteredTasks[nRow + 1]
            oDialog = new AddTaskDialog(this)
            oDialog.loadTaskData(oTask)
            if oDialog.exec() = QDialog_Accepted {
                filterTasks()
            }
        }
    }
    
    func deleteSelectedTask {
        nRow = oTaskTable.currentRow()
        if nRow >= 0 {
            oTask = aFilteredTasks[nRow + 1]
            
            if QMessageBox.question(
                this,
                "Confirm Delete",
                "Are you sure you want to delete task '" + oTask.getName() + "'?",
                QMessageBox_Yes | QMessageBox_No
            ) = QMessageBox_Yes {
                del(aTasks, find(aTasks, oTask))
                filterTasks()
            }
        }
    }
    
    func exportTasks {
        cPath = QFileDialog.getSaveFileName(
            this,
            "Export Tasks",
            "",
            "CSV Files (*.csv);;Excel Files (*.xlsx);;PDF Files (*.pdf)"
        )
        
        if cPath != "" {
            cExt = right(cPath, 4)
            switch cExt {
                on ".csv"
                    exportToCSV(cPath)
                on "xlsx"
                    exportToExcel(cPath)
                on ".pdf"
                    exportToPDF(cPath)
                other
                    QMessageBox.warning(
                        this,
                        "Export Error",
                        "Unsupported file format"
                    )
            }
        }
    }
    
    func updateKPIs {
        # Create chart
        oChart = new QChart()
        oChart.setTitle("Task Status Distribution")
        
        # Calculate status counts
        aStatusCounts = [0,0,0,0]  # [new, in_progress, completed, failed]
        for oTask in aTasks {
            switch oTask.getStatus() {
                on "new"
                    aStatusCounts[1]++
                on "in_progress"
                    aStatusCounts[2]++
                on "completed"
                    aStatusCounts[3]++
                on "failed"
                    aStatusCounts[4]++
            }
        }
        
        # Create pie series
        oPieSeries = new QPieSeries()
        oPieSeries.append("New", aStatusCounts[1])
        oPieSeries.append("In Progress", aStatusCounts[2])
        oPieSeries.append("Completed", aStatusCounts[3])
        oPieSeries.append("Failed", aStatusCounts[4])
        
        oChart.addSeries(oPieSeries)
        oChart.legend().setVisible(true)
        oChart.legend().setAlignment(Qt_AlignRight)
        
        oKPIChart.setChart(oChart)
    }
    
    private
    
    func clearTasks {
        aTasks = []
        aFilteredTasks = []
        oTaskTable.setRowCount(0)
    }
    
    func clearLayout oLayout {
        while oLayout.count() > 0 {
            item = oLayout.takeAt(0)
            if item.widget() != null {
                item.widget().delete()
            }
        }
    }
    
    func getStatusColor cStatus {
        switch cStatus {
            on "new"
                return new QColor(200,200,200)  # Gray
            on "in_progress"
                return new QColor(255,255,200)  # Light yellow
            on "completed"
                return new QColor(200,255,200)  # Light green
            on "failed"
                return new QColor(255,200,200)  # Light red
        }
        return new QColor(255,255,255)  # White
    }
    
    func getPriorityColor cPriority {
        switch cPriority {
            on "low"
                return new QColor(0,128,0)  # Green
            on "medium"
                return new QColor(128,128,0)  # Yellow
            on "high"
                return new QColor(255,128,0)  # Orange
            on "critical"
                return new QColor(255,0,0)  # Red
        }
        return new QColor(0,0,0)  # Black
    }
    
    func isMyTask oTask {
        if oTask.getAssignedTo() = null { return false }
        return oTask.getAssignedTo().getId() = getParent().getCurrentUser().getId()
    }
    
    func isDueSoon oTask {
        if oTask.getDueDate() = "" { return false }
        
        # Check if due within 3 days
        dDue = date(oTask.getDueDate())
        dNow = date()
        return diffDays(dDue, dNow) <= 3
    }
    
    func exportToCSV cPath {
        try {
            fh = fopen(cPath, "w")
            
            # Write header
            fputs(fh, "ID,Name,Status,Priority,Assignee,Due Date,Progress\n")
            
            # Write tasks
            for oTask in aFilteredTasks {
                cAssignee = ""
                if oTask.getAssignedTo() != null {
                    cAssignee = oTask.getAssignedTo().getName()
                }
                
                fputs(fh, 
                    oTask.getId() + "," +
                    oTask.getName() + "," +
                    oTask.getStatus() + "," +
                    oTask.getPriority() + "," +
                    cAssignee + "," +
                    oTask.getDueDate() + "," +
                    oTask.getProgress() + "\n"
                )
            }
            
            fclose(fh)
            
            QMessageBox.information(
                this,
                "Export Complete",
                "Tasks exported successfully to CSV"
            )
            
        catch
            QMessageBox.warning(
                this,
                "Export Error",
                "Failed to export tasks: " + cCatchError
            )
        }
    }
    
    func exportToExcel cPath {
        # TODO: Implement Excel export using external library
         new qmessagebox(this) {
                setwindowtitle("information")
                settext("Not Implemented")
                setInformativeText("Excel export will be implemented in a future version")
                setstandardbuttons(qmessagebox_ok)
                exec()
            }
    }
    
    func exportToPDF cPath {
        # TODO: Implement PDF export using external library
         new qmessagebox(this) {
                setwindowtitle("information")
                settext("Not Implemented")
                setInformativeText("PDF export will be implemented in a future version")
                setstandardbuttons(qmessagebox_ok)
                exec()
            }
    }
    
    func showAddCommentDialog {
        nRow = oTaskTable.currentRow()
        if nRow >= 0 {
            oTask = aFilteredTasks[nRow + 1]
            
            cComment = QInputDialog.getText(
                this,
                "Add Comment",
                "Enter your comment:",
                QLineEdit.Normal,
                ""
            )
            
            if cComment != "" {
                oTask.addComment(
                    cComment,
                    getParent().getCurrentUser()
                )
                showTaskDetails(nRow, 0)
            }
        }
    }
