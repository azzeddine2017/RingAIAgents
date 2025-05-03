/*
    RingAI Agents - GUI Application
    Author: Azzeddine Remmal
    Date: 2025
*/

oWindow = null
oApp = null

Load "libAgantAi_gui.ring" # استدعاء ملف النواة المحلي
load "add_agent_dialog.ring"
load "add_crew_dialog.ring"
load "add_task_dialog.ring"
load "settings_dialog.ring"
load "login_dialog.ring"
load "chat_dialog.ring"
load "dashboardManager.ring"
load "languageManager.ring"
load "themeManager.ring"
load "performance_monitor.ring"


/*
Class: MainWindow
Description: The main window for managing customers and monitoring their performance
*/
class MainWindow from qMainWindow {

    ###############################################
    # GUI Components - Main Window Elements
    ###############################################
    oWidget             # Main widget
    oMainLayout         # Main layout
    oSpacerWidget       # Spacer for menu bar
    oMenuBar            # Main menu bar
    oToolbar            # Main toolbar
    oTabs               # Tab widget
    oStatusBar          # Status bar
    oTimer              # Update timer

    ###############################################
    # Menu Bar Components
    ###############################################
    oFileMenu           # File menu
    oEditMenu           # Edit menu
    oViewMenu           # View menu
    oThemeMenu          # Theme menu
    oToolsMenu          # Tools menu
    oHelpMenu           # Help menu
    oBlueThemeAction

    # File Menu Actions
    oNewAction
    oOpenAction
    oSaveAction
    oImportAction
    oExportAction
    oExitAction

    # Edit Menu Actions
    oSettingsAction

    # View Menu Actions
    oRefreshAction

    # Theme Menu Actions
    oLightThemeAction
    oDarkThemeAction

    # Tools Menu Actions
    oBackupAction
    oRestoreAction
    oLogsAction

    # Help Menu Actions
    oDocumentationAction
    oAboutAction

    # Language Menu Actions
    oArabicAction
    oFrenchAction
    oEnglishAction
    olanguagemenu


    ###############################################
    # Toolbar Components
    ###############################################
    # Labels
    oAgentsLabelTB
    oCrewsLabelTB
    oTasksLabelTB

    # Agent Buttons
    oAddAgentBtn
    oEditAgentBtn
    oDeleteAgentBtn

    # Crew Buttons
    oAddCrewBtn
    oEditCrewBtn
    oDeleteCrewBtn

    # Task Buttons
    oAddTaskBtn

    # Monitor Buttons
    oStartMonitorBtn
    oStopMonitorBtn

    # Other Buttons
    oChatBtn
    oExitBtn

    ###############################################
    # Dashboard Tab Components
    ###############################################
    # Cards
    oAgentsCard
    oCrewsCard
    oTasksCard
    oSystemCard

    # Card Labels
    oAgentsTitle
    oAgentsCount
    oCrewsTitle
    oCrewsCount
    oTasksTitle
    oTasksCount
    oSystemTitle
    oSystemLoad

    # Activities
    oActivitiesFrame
    oActivitiesTitle
    oActivitiesList

    ###############################################
    # Teams Tab Components
    ###############################################
    # Agents Panel
    oAgentsPanel
    oAgentsTitle
    oAgentsList

    # Crews Panel
    oCrewsPanel
    oCrewsTitle
    oCrewsList

    ###############################################
    # Tasks Tab Components
    ###############################################
    oTasksList
    oAddTaskButton
    oRemoveTaskButton

    ###############################################
    # Monitor Tab Components
    ###############################################
    oPerformanceChart
    oMonitorView
    oLogFrame
    oLogTitle
    oLogView

    ###############################################
    # Analytics Tab Components
    ###############################################
    oTasksChart
    oTrendsChart
    oKPIsTable

    ###############################################
    # Status Bar Components
    ###############################################
    oAgentsLabel
    oCrewsLabel
    oTasksLabel
    oSystemLoadLabel
    oUserLabel

    ###############################################
    # Data
    ###############################################
    aAgents = []
    aCrews = []
    aTasks = []
    oMonitor = new GUIPerformanceMonitor()
    oSettings = null
    oCurrentUser = null

    # مدراء النظام
    oThemeManager = new ThemeManager()
    oLanguageManager = new LanguageManager()
    oDashboardManager = new DashboardManager()

    ###############################################
    # Initialization Methods
    ###############################################

    func init {
        super.init()
        setWindowTitle("RingAI Agents Manager")
        resize(1200, 800)
        loadSettings()
        initUI()

        # Show login dialog
        showLoginDialog()
        show()
    }

    func initUI {
        # Create main layout
        oMainLayout = new QVBoxLayout() {
            setSpacing(10)
            setContentsMargins(10,10,10,10)
        }

        # Add spacer to ensure menu bar is visible
        oSpacerWidget = new QWidget()
        oSpacerWidget.setFixedHeight(25)  # Add space below menu bar

       # Create menu bar using direct style
        oMenuBar = new QMenuBar(oSpacerWidget){
            setFixedHeight(25)  # Set fixed height for menu bar
            setStyleSheet("
                    QMenuBar {
                        background-color:#596068;
                        color: white;
                        spacing: 10px;
                    }
                    QMenuBar::item {
                        padding: 5px 20px;
                        margin-right: 10px;
                        background: transparent;
                    }
                    QMenuBar::item:selected {
                        background-color: #596068;
                        border-radius: 4px;
                    }
                    QMenu {
                        background-color: #596068;
                        color: white;
                        border: 1px solid #596068;
                        padding: 5px;
                        margin: 2px;
                    }
                    QMenu::item {
                        padding: 5px 25px 5px 20px;
                        margin: 2px;
                    }
                    QMenu::item:selected {
                        background-color: #3498db;
                    }
                ")
            oFileMenu  = addMenu("File")
            oEditMenu  = addMenu("Edit")
            oViewMenu  = addMenu("View")
            oThemeMenu = addMenu("Theme")
            oToolsMenu = addMenu("Tools")
            oHelpMenu  = addMenu("Help")
            # File menu
            oFileMenu  {
                this.oNewAction = new QAction(this.oSpacerWidget) { settext("New") setclickevent("oWindow.showAddAgentDialog()") }
                addAction(this.oNewAction)
                this.oOpenAction = new QAction(this.oSpacerWidget) { settext("Open") setclickevent("oWindow.showAddCrewDialog()") }
                addAction(this.oOpenAction)
                this.oSaveAction = new QAction(this.oSpacerWidget) { settext("Save") setclickevent("oWindow.showAddTaskDialog()") }
                addAction(this.oSaveAction)
                addSeparator()
                this.oImportAction = new QAction(this.oSpacerWidget) { settext("Import") setclickevent("") }
                addAction(this.oImportAction)
                this.oExportAction = new QAction(this.oSpacerWidget) { settext("Export") setclickevent("") }
                addAction(this.oExportAction)
                addSeparator()
                this.oExitAction = new QAction(this.oSpacerWidget) { settext("Exit") setclickevent("oWindow.exitApplication()") }
                addAction(this.oExitAction)
            }

            # Edit menu
            oEditMenu  {
                this.oSettingsAction = new QAction(this.oSpacerWidget) { settext("Settings") setclickevent("oWindow.showSettingsDialog()") }
                addAction(this.oSettingsAction)
            }
            # View menu
            oViewMenu {
                this.oRefreshAction = new QAction(this.oSpacerWidget) { settext("Refresh") setclickevent("oWindow.refreshDashboard()") }
                addAction(this.oRefreshAction)
                addSeparator()
            }

            oThemeMenu {
                this.oLightThemeAction = new QAction(this.oSpacerWidget) { settext("Light") setclickevent("oWindow.setTheme('light')") }
                addAction(this.oLightThemeAction)
                this.oDarkThemeAction = new QAction(this.oSpacerWidget) { settext("Dark") setclickevent("oWindow.setTheme('dark')") }
                addAction(this.oDarkThemeAction)
                addSeparator()
                this.oBlueThemeAction = new QAction(this.oSpacerWidget) { settext("Blue") setclickevent("oWindow.setTheme('blue')") }
                addAction(this.oBlueThemeAction)
            }

            # Tools menu
            oToolsMenu {
                this.oBackupAction = new QAction(this.oSpacerWidget) { settext("Backup") setclickevent("oWindow.backupData()") }
                addAction(this.oBackupAction)
                this.oRestoreAction = new QAction(this.oSpacerWidget) { settext("Restore") setclickevent("oWindow.restoreData()") }
                addAction(this.oRestoreAction)
                addSeparator()
                this.oLogsAction = new QAction(this.oSpacerWidget) { settext("View Logs") setclickevent("oWindow.viewLogs()") }
                addAction(this.oLogsAction)
                addSeparator()
                # Language submenu
                this.oLanguageMenu = addMenu("Language")
                this.oLanguageMenu {
                    setStyleSheet("background-color: #596068; color: white;")
                    this.oEnglishAction = new QAction(this.oSpacerWidget) { settext("English") setclickevent("oWindow.setLanguage('en')") }
                    addAction(this.oEnglishAction)
                    this.oArabicAction = new QAction(this.oSpacerWidget) { settext("Arabic") setclickevent("oWindow.setLanguage('ar')") }
                    addAction(this.oArabicAction)
                    this.oFrenchAction = new QAction(this.oSpacerWidget) { settext("French") setclickevent("oWindow.setLanguage('fr')") }
                    addAction(this.oFrenchAction)
                }
            }
            # Help menu
            oHelpMenu {
                this.oDocumentationAction = new QAction(this.oSpacerWidget) { settext("Documentation") setclickevent("") }
                addAction(this.oDocumentationAction)
                this.oAboutAction = new QAction(this.oSpacerWidget) { settext("About") setclickevent("") }
                addAction(this.oAboutAction)
            }
        }


        oMainLayout.addWidget(oSpacerWidget) # Add menu bar


        # Create toolbar
        oToolbar = new QToolBar(this)

        # Agents section
        oAgentsLabelTB = new QLabel(this) { settext("Agents: ") }
        oToolbar.addWidget(oAgentsLabelTB)

        # Create actions as buttons
        oAddAgentBtn = new QPushButton(this) {
            settext("➕ Add Agent")
            setStyleSheet("background-color: #3498db;")
        }
        oToolbar.addWidget(oAddAgentBtn)

        oEditAgentBtn = new QPushButton(this) { settext("Edit Agent") }
        oToolbar.addWidget(oEditAgentBtn)

        oDeleteAgentBtn = new QPushButton(this) { settext("Delete Agent") }
        oToolbar.addWidget(oDeleteAgentBtn)

        oToolbar.addseparator()

        # Crews section
        oCrewsLabelTB = new QLabel(this) { settext("Crews: ") }
        oToolbar.addWidget(oCrewsLabelTB)

        oAddCrewBtn = new QPushButton(this) {
            settext("➕ Add Crew")
            setStyleSheet("background-color: #2ecc71;")
        }
        oToolbar.addWidget(oAddCrewBtn)

        oEditCrewBtn = new QPushButton(this) { settext("Edit Crew") }
        oToolbar.addWidget(oEditCrewBtn)

        oDeleteCrewBtn = new QPushButton(this) { settext("Delete Crew") }
        oToolbar.addWidget(oDeleteCrewBtn)

        oToolbar.addseparator()

        # Tasks section
        oTasksLabelTB = new QLabel(this) { settext("Tasks: ") }
        oToolbar.addWidget(oTasksLabelTB)

        oAddTaskBtn = new QPushButton(this) {
            settext("➕ Add Task")
            setStyleSheet("background-color: #9b59b6;")
        }
        oToolbar.addWidget(oAddTaskBtn)

        oToolbar.addseparator()

        # Monitor section
        oStartMonitorBtn = new QPushButton(this) {
            settext("▶ Start Monitoring")
            setStyleSheet("background-color: #27ae60;")
        }
        oToolbar.addWidget(oStartMonitorBtn)

        oStopMonitorBtn = new QPushButton(this) {
            settext("⏹ Stop Monitoring")
            setStyleSheet("background-color: #c0392b;")
        }
        oToolbar.addWidget(oStopMonitorBtn)

        oToolbar.addseparator()

        # Chat action
        oChatBtn = new QPushButton(this) {
            settext("💬 Chat")
            setStyleSheet("background-color: #3498db;")
        }
        oToolbar.addWidget(oChatBtn)

        oToolbar.addseparator()

        # Exit button
        oExitBtn = new QPushButton(this) {
            settext("🚪 Exit")
            setStyleSheet("background-color: #e74c3c;")
        }
        oToolbar.addWidget(oExitBtn)

        # Set toolbar properties
        oToolbar.setmovable(true)
        oToolbar.setFloatable(true)
        oToolbar.setStyleSheet("
            QPushButton {
                min-width: 80px;
                padding: 5px;
                margin: 2px;
                border: 2px solid rgba(0, 0, 0, 0.2);
                border-radius: 4px;
                font-weight: bold;
                color: white;
            }
            QPushButton:hover {
                border: 2px solid rgba(0, 0, 0, 0.5);
                background-color: #2980b9;
            }
            QPushButton:pressed {
                background-color: #1a5276;
            }
            QLabel {
                font-weight: bold;
                color: #34495e;
                margin-left: 5px;
            }
        ")


        oMainLayout.addWidget(oToolbar )

        # Create tab widget
        oTabs = new QTabWidget(this) {
            setDocumentMode(true)  # Cleaner look for tabs
            setStyleSheet("
                QTabWidget::pane {
                    border-top: 2px solid #3498db;
                    background-color: #f8f9fa;
                }
                QTabBar::tab {
                    background-color: #ecf0f1;
                    border: 1px solid #bdc3c7;
                    border-bottom: none;
                    border-top-left-radius: 4px;
                    border-top-right-radius: 4px;
                    padding: 10px 20px;
                    margin-right: 5px;
                    font-size: 14px;
                    min-width: 120px;
                }
                QTabBar::tab:selected {
                    background-color: #f8f9fa;
                    border-bottom: 2px solid #3498db;
                    font-weight: bold;
                }
                QTabBar::tab:hover {
                    background-color: #d6eaf8;
                }
            ")
        }

        # Create tabs
        oDashboardTab = createDashboardTab()
        oTeamsTab = createTeamsTab()
        oTasksTab = createTasksTab()
        oMonitorTab = createMonitorTab()
        oAnalyticsTab = createAnalyticsTab()

        # Add tabs to widget
        oTabs.addTab(oDashboardTab, "Dashboard")
        oTabs.addTab(oTeamsTab, "Teams")
        oTabs.addTab(oTasksTab, "Tasks")
        oTabs.addTab(oMonitorTab, "Monitor")
        oTabs.addTab(oAnalyticsTab, "Analytics")
        oMainLayout.addWidget(oTabs)

        # Create status bar
        oStatusBar = new QStatusBar(this) {
            # Add status labels
            oAgentsLabel = new QLabel(this){settext("Agents: 0")}
            addWidget(oAgentsLabel, 1)

            oCrewsLabel = new QLabel(this){settext("Crews: 0")}
            addWidget(oCrewsLabel, 1)

            oTasksLabel = new QLabel(this){settext("Tasks: 0")}
            addWidget(oTasksLabel, 1)

            oSystemLoadLabel = new QLabel(this){settext("System Load: 0%")}
            addWidget(oSystemLoadLabel, 1)

            # Add current user label
            this.oUserLabel = new QLabel(this){settext("User: Not logged in")}
            addPermanentWidget(this.oUserLabel, 1)
        }

        # Set main layout
        oWidget = new QWidget() {
            setLayout(this.oMainLayout)
        }
        setCentralWidget(oWidget)

        # Connect signals
        connectSignals()
        updateMonitor()
    }

  /*  func createMenuBar {

    }

    func createToolbar {

    }

    func createStatusBar {

    }*/

    func createDashboardTab {
        oWidget = new QWidget()
        oLayout = new QVBoxLayout()

        # Summary cards - with fixed height and spacing
        oCardsLayout = new QHBoxLayout()
        oCardsLayout.setSpacing(10)  # Reduce spacing between cards
        oCardsLayout.setContentsMargins(5, 5, 5, 5)  # Reduce margins

        # Agents card
        oAgentsCard = new QFrame(oWidget, 0)
        oAgentsCard.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oAgentsCard.setStyleSheet("
            background-color: #3498db;
            border-radius: 8px;
            padding: 10px;
            color: white;
            border: 1px solid #2980b9;
        ")
        oAgentsCard.setFixedHeight(90)  # Reduce card height
        oAgentsCard.setMinimumWidth(150)  # Set minimum width
        oAgentsCardLayout = new QVBoxLayout()
        oAgentsTitle = new QLabel(oAgentsCard) {
            settext("Agents")
            setStyleSheet("font-weight: bold; font-size: 14px; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oAgentsCount = new QLabel(oAgentsCard) {
            settext("0")
            setStyleSheet("font-size: 22px; font-weight: bold; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oAgentsCardLayout.addWidget(oAgentsTitle)
        oAgentsCardLayout.addWidget(oAgentsCount)
        oAgentsCard.setLayout(oAgentsCardLayout)
        oCardsLayout.addWidget(oAgentsCard)

        # Crews card
        oCrewsCard = new QFrame(oWidget, 0)
        oCrewsCard.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oCrewsCard.setStyleSheet("
            background-color: #2ecc71;
            border-radius: 8px;
            padding: 10px;
            color: white;
            border: 1px solid #27ae60;
        ")
        oCrewsCard.setFixedHeight(90)  # Reduce card height
        oCrewsCard.setMinimumWidth(150)  # Set minimum width
        oCrewsCardLayout = new QVBoxLayout()
        oCrewsTitle = new QLabel(oCrewsCard) {
            settext("Crews")
            setStyleSheet("font-weight: bold; font-size: 14px; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oCrewsCount = new QLabel(oCrewsCard) {
            settext("0")
            setStyleSheet("font-size: 22px; font-weight: bold; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oCrewsCardLayout.addWidget(oCrewsTitle)
        oCrewsCardLayout.addWidget(oCrewsCount)
        oCrewsCard.setLayout(oCrewsCardLayout)
        oCardsLayout.addWidget(oCrewsCard)

        # Tasks card
        oTasksCard = new QFrame(oWidget, 0)
        oTasksCard.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oTasksCard.setStyleSheet("
            background-color: #9b59b6;
            border-radius: 8px;
            padding: 10px;
            color: white;
            border: 1px solid #8e44ad;
        ")
        oTasksCard.setFixedHeight(90)  # Reduce card height
        oTasksCard.setMinimumWidth(150)  # Set minimum width
        oTasksCardLayout = new QVBoxLayout()
        oTasksTitle = new QLabel(oTasksCard) {
            settext("Tasks")
            setStyleSheet("font-weight: bold; font-size: 14px; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oTasksCount = new QLabel(oTasksCard) {
            settext("0")
            setStyleSheet("font-size: 22px; font-weight: bold; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oTasksCardLayout.addWidget(oTasksTitle)
        oTasksCardLayout.addWidget(oTasksCount)
        oTasksCard.setLayout(oTasksCardLayout)
        oCardsLayout.addWidget(oTasksCard)

        # System card
        oSystemCard = new QFrame(oWidget, 0)
        oSystemCard.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oSystemCard.setStyleSheet("
            background-color: #e74c3c;
            border-radius: 8px;
            padding: 10px;
            color: white;
            border: 1px solid #c0392b;
        ")
        oSystemCard.setFixedHeight(90)  # Reduce card height
        oSystemCard.setMinimumWidth(150)  # Set minimum width
        oSystemCardLayout = new QVBoxLayout()
        oSystemTitle = new QLabel(oSystemCard) {
            settext("System Load")
            setStyleSheet("font-weight: bold; font-size: 14px; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oSystemLoad = new QLabel(oSystemCard) {
            settext("0%")
            setStyleSheet("font-size: 22px; font-weight: bold; color: white;")
            setAlignment(Qt_AlignHCenter)
        }
        oSystemCardLayout.addWidget(oSystemTitle)
        oSystemCardLayout.addWidget(oSystemLoad)
        oSystemCard.setLayout(oSystemCardLayout)
        oCardsLayout.addWidget(oSystemCard)

        oLayout.addLayout(oCardsLayout)

        # Recent activities
        oActivitiesFrame = new QFrame(oWidget, 0)
        oActivitiesFrame.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oActivitiesFrame.setStyleSheet("
            background-color: white;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
            padding: 8px;
        ")
        oActivitiesLayout = new QVBoxLayout()
        oActivitiesLayout.setSpacing(5)  # تقليل المسافة بين العناصر

        # عنوان مع زر تحديث
        oActivitiesHeaderLayout = new QHBoxLayout()

        oActivitiesTitle = new QLabel(oActivitiesFrame) {
            settext("Recent Activities")
            setStyleSheet("font-weight: bold; font-size: 14px; color: #2c3e50;")
        }
        oActivitiesHeaderLayout.addWidget(oActivitiesTitle)

        oActivitiesHeaderLayout.addStretch(1)  # إضافة مسافة مرنة

        oRefreshActivitiesBtn = new QPushButton(oActivitiesFrame) {
            setText("↻")
            setToolTip("Refresh Activities")
            setStyleSheet("
                QPushButton {
                    background-color: #3498db;
                    color: white;
                    border-radius: 4px;
                    padding: 3px;
                    max-width: 24px;
                    max-height: 24px;
                    font-weight: bold;
                }
                QPushButton:hover {
                    background-color: #2980b9;
                }
            ")
            setclickevent(method(:refreshActivities))
        }
        oActivitiesHeaderLayout.addWidget(oRefreshActivitiesBtn)

        oActivitiesLayout.addLayout(oActivitiesHeaderLayout)

        # قائمة الأنشطة
        oActivitiesList = new QListWidget(oActivitiesFrame) {
            setStyleSheet("
                QListWidget {
                    border: 1px solid #e0e0e0;
                    border-radius: 4px;
                    background-color: #f8f9fa;
                }
                QListWidget::item {
                    border-bottom: 1px solid #e0e0e0;
                    padding: 4px;
                }
                QListWidget::item:selected {
                    background-color: #d6eaf8;
                    color: #2c3e50;
                }
                QListWidget::item:hover {
                    background-color: #eaf2f8;
                }
            ")
            setAlternatingRowColors(true)  # تلوين الصفوف بالتناوب
            setMaximumHeight(150)  # تحديد الارتفاع الأقصى
        }

        # Add some sample activities
        oActivitiesList.addItem("System started - " + date() + " " + time())
        oActivitiesList.addItem("User logged in - admin")
        oActivitiesList.addItem("Dashboard loaded successfully")

        oActivitiesLayout.addWidget(oActivitiesTitle)
        oActivitiesLayout.addWidget(oActivitiesList)
        oActivitiesFrame.setLayout(oActivitiesLayout)
        oLayout.addWidget(oActivitiesFrame)

        oWidget.setLayout(oLayout)
        return oWidget
    }

    func createTeamsTab {
        oWidget = new QWidget()
        oLayout = new QHBoxLayout()

        # Agents panel
        oAgentsPanel = new QFrame(oWidget, 0)
        oAgentsPanel.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oAgentsPanel.setStyleSheet("background-color: #f0f0f0; border-radius: 5px; padding: 5px;")
        oAgentsPanelLayout = new QVBoxLayout()
        oAgentsTitle = new QLabel(oAgentsPanel) { settext("Agents") setStyleSheet("font-weight: bold;") }
        oAgentsList = new QTreeWidget( oAgentsPanel ) {
            setHeaderLabels(new QStringList(){
                append("Name")
                append("Role")
                append("Status")
                append("Tasks")
                append("Energy")
                append("Confidence")
            })
            setColumnWidth(0, 150)  # عرض عمود الاسم
            setColumnWidth(1, 100)  # عرض عمود الدور
            setColumnWidth(2, 100)  # عرض عمود الحالة
            setColumnWidth(3, 80)   # عرض عمود المهام
            setColumnWidth(4, 80)   # عرض عمود الطاقة
            setColumnWidth(5, 100)  # عرض عمود الثقة
            setStyleSheet("
                QTreeWidget {
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
                QHeaderView::section {
                    background-color: #ecf0f1;
                    padding: 6px;
                    border: 1px solid #bdc3c7;
                    font-weight: bold;
                }
                QTreeWidget::item {
                    border-bottom: 1px solid #ecf0f1;
                    padding: 5px;
                }
                QTreeWidget::item:selected {
                    background-color: #d6eaf8;
                    color: #2c3e50;
                }
            ")
        }
        oAgentsPanelLayout.addWidget(oAgentsTitle)
        oAgentsPanelLayout.addWidget(oAgentsList)
        oAgentsPanel.setLayout(oAgentsPanelLayout)
        oLayout.addWidget(oAgentsPanel)

        # Crews panel
        oCrewsPanel = new QFrame(oWidget, 0)
        oCrewsPanel.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oCrewsPanel.setStyleSheet("background-color: #f0f0f0; border-radius: 5px; padding: 5px;")
        oCrewsPanelLayout = new QVBoxLayout()
        oCrewsTitle = new QLabel(oCrewsPanel) { settext("Crews") setStyleSheet("font-weight: bold;") }
        oCrewsList = new QTreeWidget( oCrewsPanel ) {
            setHeaderLabels(new QStringList(){
                append("Name")
                append("Members")
                append("Active Tasks")
                append("Status")
            })
            setColumnWidth(0, 150)  # عرض عمود الاسم
            setColumnWidth(1, 100)  # عرض عمود الأعضاء
            setColumnWidth(2, 120)  # عرض عمود المهام النشطة
            setColumnWidth(3, 100)  # عرض عمود الحالة
            setStyleSheet("
                QTreeWidget {
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
                QHeaderView::section {
                    background-color: #ecf0f1;
                    padding: 6px;
                    border: 1px solid #bdc3c7;
                    font-weight: bold;
                }
                QTreeWidget::item {
                    border-bottom: 1px solid #ecf0f1;
                    padding: 5px;
                }
                QTreeWidget::item:selected {
                    background-color: #d6eaf8;
                    color: #2c3e50;
                }
            ")
        }
        oCrewsPanelLayout.addWidget(oCrewsTitle)
        oCrewsPanelLayout.addWidget(oCrewsList)
        oCrewsPanel.setLayout(oCrewsPanelLayout)
        oLayout.addWidget(oCrewsPanel)

        oWidget.setLayout(oLayout)
        return oWidget
    }

    func createTasksTab {
        oWidget = new QWidget()
        oLayout = new QVBoxLayout()

        # Tasks list
        oTasksList = new QTreeWidget( oWidget ) {
            setHeaderLabels(new QStringList(){
                append("ID")
                append("Name")
                append("Assigned To")
                append("Status")
                append("Priority")
                append("Progress")
                append("Due Date")
            })
            setColumnWidth(0, 60)   # عرض عمود المعرف
            setColumnWidth(1, 150)  # عرض عمود الاسم
            setColumnWidth(2, 120)  # عرض عمود المسند إلى
            setColumnWidth(3, 100)  # عرض عمود الحالة
            setColumnWidth(4, 80)   # عرض عمود الأولوية
            setColumnWidth(5, 80)   # عرض عمود التقدم
            setColumnWidth(6, 100)  # عرض عمود تاريخ الاستحقاق
            setStyleSheet("
                QTreeWidget {
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
                QHeaderView::section {
                    background-color: #ecf0f1;
                    padding: 6px;
                    border: 1px solid #bdc3c7;
                    font-weight: bold;
                }
                QTreeWidget::item {
                    border-bottom: 1px solid #ecf0f1;
                    padding: 5px;
                }
                QTreeWidget::item:selected {
                    background-color: #d6eaf8;
                    color: #2c3e50;
                }
            ")
            setAlternatingRowColors(true)  # تلوين الصفوف بالتناوب
        }
        oLayout.addWidget(oTasksList)

        # Add buttons
        oButtonsLayout = new QHBoxLayout()

        oAddTaskButton = new QPushButton( oWidget ) {
            # setIcon(new QIcon(new QPixmap("icons/add.png")))
            # setIconSize(new QSize(16, 16))
            setText("Add Task")
            setclickevent("showAddTaskDialog()")
        }

        oRemoveTaskButton = new QPushButton( oWidget ) {
            # setIcon(new QIcon(new QPixmap("icons/remove.png")))
            # setIconSize(new QSize(16, 16))
            setText("Remove Task")
            setclickevent("removeSelectedTask()")
        }

        oButtonsLayout.addWidget(oAddTaskButton)
        oButtonsLayout.addWidget(oRemoveTaskButton)

        # Add to layout
        oLayout.addLayout(oButtonsLayout)

        oWidget.setLayout(oLayout)
        return oWidget
    }

    func createMonitorTab {
        oWidget = new QWidget()
        oLayout = new QVBoxLayout()

        # Performance chart (using QLabel instead of QChartView)
        oPerformanceChart = new QLabel( oWidget ) {
            setText("System Performance Chart")
            setAlignment( Qt_AlignHCenter)
            setStyleSheet("background-color: #f0f0f0; border: 1px solid #ccc; padding: 10px;")
            setMinimumHeight(200)
        }
        oLayout.addWidget(oPerformanceChart)

        # Monitor view
        oMonitorView = new QTableWidget( oWidget ) {
            setColumnCount(4)
            setHorizontalHeaderLabels(new QStringList(){
                append("Metric")
                append("Value")
                append("Status")
                append("Trend")
            })
            setColumnWidth(0, 150)  # عرض عمود المقياس
            setColumnWidth(1, 100)  # عرض عمود القيمة
            setColumnWidth(2, 100)  # عرض عمود الحالة
            setColumnWidth(3, 100)  # عرض عمود الاتجاه
            setStyleSheet("
                QTableWidget {
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
                QHeaderView::section {
                    background-color: #ecf0f1;
                    padding: 6px;
                    border: 1px solid #bdc3c7;
                    font-weight: bold;
                }
                QTableWidget::item {
                    border-bottom: 1px solid #ecf0f1;
                    padding: 5px;
                }
                QTableWidget::item:selected {
                    background-color: #d6eaf8;
                    color: #2c3e50;
                }
            ")
            setAlternatingRowColors(true)  # تلوين الصفوف بالتناوب
            setMinimumHeight(150)  # تحديد الارتفاع الأدنى
        }
        oLayout.addWidget(oMonitorView)

        # Log view
        oLogFrame = new QFrame(oWidget, 0)
        oLogFrame.setframestyle(0x0040 | 0x0003)  # QFrame_Raised | QFrame_Panel
        oLogFrame.setStyleSheet("background-color: #f0f0f0; border-radius: 5px; padding: 5px;")
        oLogLayout = new QVBoxLayout()
        oLogTitle = new QLabel(oLogFrame) { settext("System Logs") setStyleSheet("font-weight: bold;") }
        oLogView = new QTextEdit( oLogFrame ) {
            setReadOnly(true)
        }
        oLogLayout.addWidget(oLogTitle)
        oLogLayout.addWidget(oLogView)
        oLogFrame.setLayout(oLogLayout)
        oLayout.addWidget(oLogFrame)

        oWidget.setLayout(oLayout)
        return oWidget
    }


    func createAnalyticsTab {
        oWidget = new QWidget()
        oLayout = new QVBoxLayout()

        # Charts container
        oChartsLayout = new QHBoxLayout()

        # Tasks distribution chart (using QLabel instead of QChartView)
        oTasksChart = new QLabel( oWidget ) {
            setText("Tasks Distribution Chart")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("background-color: #f0f0f0; border: 1px solid #ccc; padding: 10px;")
            setMinimumHeight(200)
        }
        oChartsLayout.addWidget(oTasksChart)

        # Performance trends chart (using QLabel instead of QChartView)
        oTrendsChart = new QLabel( oWidget ) {
            setText("Performance Trends Chart")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("background-color: #f0f0f0; border: 1px solid #ccc; padding: 10px;")
            setMinimumHeight(200)
        }
        oChartsLayout.addWidget(oTrendsChart)

        oLayout.addLayout(oChartsLayout)

        # KPIs table
        oKPIsTable = new QTableWidget( oWidget ) {
            setColumnCount(4)
            setHorizontalHeaderLabels(new QStringList(){
                append("KPI")
                append("Current")
                append("Target")
                append("Status")
            })
            setColumnWidth(0, 200)  # عرض عمود مؤشر الأداء
            setColumnWidth(1, 100)  # عرض عمود القيمة الحالية
            setColumnWidth(2, 100)  # عرض عمود الهدف
            setColumnWidth(3, 150)  # عرض عمود الحالة
            setStyleSheet("
                QTableWidget {
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
                QHeaderView::section {
                    background-color: #ecf0f1;
                    padding: 6px;
                    border: 1px solid #bdc3c7;
                    font-weight: bold;
                }
                QTableWidget::item {
                    border-bottom: 1px solid #ecf0f1;
                    padding: 5px;
                }
                QTableWidget::item:selected {
                    background-color: #d6eaf8;
                    color: #2c3e50;
                }
            ")
            setAlternatingRowColors(true)  # تلوين الصفوف بالتناوب
            setMinimumHeight(150)  # تحديد الارتفاع الأدنى

            # إضافة بيانات افتراضية
            setRowCount(4)
            setItem(0, 0, new QTableWidgetItem("Task Completion Rate"))
            setItem(0, 1, new QTableWidgetItem("75%"))
            setItem(0, 2, new QTableWidgetItem("90%"))
            setItem(0, 3, new QTableWidgetItem("Needs Improvement"))

            setItem(1, 0, new QTableWidgetItem("Agent Utilization"))
            setItem(1, 1, new QTableWidgetItem("85%"))
            setItem(1, 2, new QTableWidgetItem("80%"))
            setItem(1, 3, new QTableWidgetItem("Good"))

            setItem(2, 0, new QTableWidgetItem("Response Time"))
            setItem(2, 1, new QTableWidgetItem("2.5s"))
            setItem(2, 2, new QTableWidgetItem("2.0s"))
            setItem(2, 3, new QTableWidgetItem("Acceptable"))

            setItem(3, 0, new QTableWidgetItem("System Efficiency"))
            setItem(3, 1, new QTableWidgetItem("68%"))
            setItem(3, 2, new QTableWidgetItem("75%"))
            setItem(3, 3, new QTableWidgetItem("Needs Improvement"))
        }
        oLayout.addWidget(oKPIsTable)

        oWidget.setLayout(oLayout)
        return oWidget
    }

    ###############################################
    # Timer Methods
    ###############################################

    func startTimer {
        # Create and start the timer
        oTimer = new QTimer(this)
        oTimer.setInterval(5000)  # 5 seconds
        oTimer.setTimeoutEvent("oWindow.timerEvent()")
        oTimer.start()
    }

    func timerEvent {
        # Update monitor
        updateMonitor()

        # Restart timer if application is still running
        if oApp.applicationState() {
            oTimer.start()
        }
    }

    func loadSettings {
        # Load settings from file
        oSettings = new Settings()
        oSettings.loadSetting()

        # تحميل الإعدادات الأخرى
        oThemeManager.init()
        oLanguageManager.init()
        oDashboardManager.init()
    }

    func connectSignals {
        # Connect toolbar buttons
        oAddAgentBtn.setclickevent("oWindow.showAddAgentDialog()")
        oAddCrewBtn.setclickevent("oWindow.showAddCrewDialog()")
        oAddTaskBtn.setclickevent("oWindow.showAddTaskDialog()")
        oStartMonitorBtn.setclickevent("oWindow.startMonitoring()")
        oStopMonitorBtn.setclickevent("oWindow.stopMonitoring()")
        oChatBtn.setclickevent("oWindow.showChatDialog()")
        oExitBtn.setclickevent("oWindow.exitApplication()")

        # Connect menu actions
        this.oNewAction.setclickevent("oWindow.showAddAgentDialog()")
        this.oOpenAction.setclickevent("oWindow.showAddCrewDialog()")
        this.oSaveAction.setclickevent("oWindow.showAddTaskDialog()")
        this.oExitAction.setclickevent("oWindow.exitApplication()")

        # Connect other buttons
        oAddTaskButton.setclickevent("oWindow.showAddTaskDialog()")
        oRemoveTaskButton.setclickevent("oWindow.removeSelectedTask()")
    }

    ###############################################
    # Application Control Methods
    ###############################################

    func exitApplication {
        # Stop timer before closing
        if oTimer != NULL {
            oTimer.stop()
        }

        # Close the application
        close()
    }

    ###############################################
    # Dialog Methods
    ###############################################

    func showLoginDialog {
        oDialog = new LoginDialog(this)
        oDialog.exec()
        if oDialog.result() {
            oCurrentUser = oDialog.getUserData()
            this.oUserLabel.setText("User: " + oCurrentUser[:name])

            # Start the timer after login
            startTimer()
        }
    }

    func showAddAgentDialog {
        # Create and show the Add Agent dialog
        oDialog = new AddAgentDialog(this)
        oDialog.exec()

        # Check if dialog was accepted (user clicked Create)
        if oDialog.result() {
            # Get agent data and add to the system
            oAgentData = oDialog.getAgentData()
            addAgent(oAgentData)

            # Show success message
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Success")
                setText("Agent '" + oAgentData[:name] + "' added successfully.")
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
        }
    }

    func showAddCrewDialog {
        # Create and show the Add Crew dialog
        oDialog = new AddCrewDialog(this)
        oDialog.exec()

        # Check if dialog was accepted (user clicked Create)
        if oDialog.result() {
            # Get crew data and add to the system
            oCrewData = oDialog.getCrewData()
            addCrew(oCrewData)

            # Show success message
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Success")
                setText("Crew '" + oCrewData[:name] + "' added successfully.")
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
        }
    }

    func showAddTaskDialog {
        # Create and show the Add Task dialog
        oDialog = new AddTaskDialog(this)
        oDialog.exec()

        # Check if dialog was accepted (user clicked Create)
        if oDialog.result() {
            # Get task data and add to the system
            oTaskData = oDialog.getTaskData()
            addTask(oTaskData)

            # Show success message
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Success")
                setText("Task '" + oTaskData[:name] + "' added successfully.")
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
        }
    }

    ###############################################
    # Data Management Methods
    ###############################################

    func addAgent oAgentData {
        oAgent = new Agent(oAgentData[:name], oAgentData[:description])
        oAgent.setRole(oAgentData[:role])
        add(aAgents, oAgent)
        updateAgentsList()
        log("Added new agent: " + oAgentData[:name])
    }

    func addCrew oCrewData {
        oCrew = new Crew(oCrewData[:name])
        for agent in oCrewData[:members] {
            oCrew.addMember(agent)
        }
        add(aCrews, oCrew)
        updateCrewsList()
        log("Added new crew: " + oCrewData[:name])
    }

    func addTask oTaskData {
        oTask = new GUITask(oTaskData[:name], oTaskData[:description])
        oTask.setPriority(oTaskData[:priority])
        oTask.setDueDate(oTaskData[:dueDate])
        add(aTasks, oTask)
        updateTasksList()
        log("Added new task: " + oTaskData[:name])
    }

    ###############################################
    # UI Update Methods
    ###############################################

    func updateAgentsList {
        oAgentsList.clear()
        for agent in aAgents {
            oItem = new QTreeWidgetItem(oAgentsList)
            oItem.setText(0, agent.getName())
            oItem.setText(1, agent.getRole())
            oItem.setText(2, agent.getState())
            oItem.setText(3, "" + len(agent.getTaskHistory()))
            oItem.setText(4, "" + agent.getEnergyLevel())
            oItem.setText(5, "" + agent.getConfidenceLevel())
        }
    }

    func updateCrewsList {
        oCrewsList.clear()
        for crew in aCrews {
            oItem = new QTreeWidgetItem(oCrewsList)
            oItem.setText(0, crew.getName())
            oItem.setText(1, "" + len(crew.getMembers()))
            oItem.setText(2, "" + len(crew.getActiveTasks()))
            oItem.setText(3, crew.getState())
        }
    }

    func updateTasksList {
        oTasksList.clear()
        for task in aTasks {
            oItem = new QTreeWidgetItem(oTasksList)
            oItem.setText(0, task.getId())
            oItem.setText(1, task.getName())
            if task.getAssignedTo() != NULL {
                oItem.setText(2, task.getAssignedTo().getName())
            else
                oItem.setText(2, "Unassigned")
            }
            oItem.setText(3, task.getStatus())
            oItem.setText(4, task.getPriority())
            oItem.setText(5, "" + task.getProgress() + "%")
            oItem.setText(6, task.getDueDate())
        }
    }



    ###############################################
    # Monitor Update Methods
    ###############################################

    func updateMonitor {
        # Update performance metrics
        updatePerformanceChart()
        updateMonitorView()
        updateLogView()
    }

    func updatePerformanceChart {
        # Update performance chart text with agent stats
        cText = "System Performance Chart" + nl + nl
        cText += "Active Agents: " + len(aAgents) + nl
        cText += "Active Crews: " + len(aCrews) + nl
        cText += "Total Tasks: " + getTotalTasks() + nl
        cText += "System Load: " + getSystemLoad() + nl

        # Update the label
        oPerformanceChart.setText(cText)
    }

    func updateMonitorView {
        oMonitorView.setRowCount(0)

        # Add system metrics
        addMonitorRow("Active Agents", "" + len(aAgents))
        addMonitorRow("Active Crews", "" + len(aCrews))
        addMonitorRow("Total Tasks", "" + getTotalTasks())
        addMonitorRow("System Load", getSystemLoad())
    }

    func updateLogView {
        # Get latest logs from monitor
        aLogs = oMonitor.getLatestLogs(10)

        # Clear the log view first
        oLogView.clear()

        # Add each log entry
        for log in aLogs {
            oLogView.append(log)
        }
    }

    func log cMessage {
        oMonitor.log(cMessage)
        updateLogView()

        # إضافة الرسالة إلى قائمة الأنشطة الحديثة
        if oActivitiesList != NULL {
            oActivitiesList.insertItem(0, cMessage + " - " + time())

            # التأكد من عدم تجاوز الحد الأقصى للأنشطة
            if oActivitiesList.count() > 20 {
                oActivitiesList.takeItem(oActivitiesList.count() - 1)
            }
        }
    }

    func refreshActivities {
        # مسح القائمة الحالية
        oActivitiesList.clear()

        # إضافة أنشطة جديدة
        oActivitiesList.addItem("System refreshed - " + date() + " " + time())

        # إضافة معلومات عن النظام
        oActivitiesList.addItem("Active Agents: " + len(aAgents))
        oActivitiesList.addItem("Active Crews: " + len(aCrews))
        oActivitiesList.addItem("Total Tasks: " + getTotalTasks())
        oActivitiesList.addItem("System Load: " + getSystemLoad())

        # إضافة معلومات عن المستخدم
        if oCurrentUser != NULL {
            oActivitiesList.addItem("Current User: " + oCurrentUser[:name] + " (" + oCurrentUser[:role] + ")")
        }

        # تحديث البطاقات
        updateDashboardCards()

        # إضافة رسالة إلى السجل
        log("Dashboard refreshed")
    }

    func startMonitoring {
        # Start the performance monitor
        oMonitor.start()

        # Show a simple message box
        oMsgBox = new QMessageBox(this) {
            setWindowTitle("Start Monitoring")
            setText("Monitoring started.")
            setIcon(QMessageBox_Information)
            setStandardButtons(QMessageBox_Ok)
        }
        oMsgBox.exec()

        # Log the event
        log("Performance monitoring started")
    }

    func stopMonitoring {
        # Stop the performance monitor
        oMonitor.stop()

        # Show a simple message box
        oMsgBox = new QMessageBox(this) {
            setWindowTitle("Stop Monitoring")
            setText("Monitoring stopped.")
            setIcon(QMessageBox_Information)
            setStandardButtons(QMessageBox_Ok)
        }
        oMsgBox.exec()

        # Log the event
        log("Performance monitoring stopped")
    }

    func updateDashboardTab {
        # Update dashboard cards
        updateDashboardCards()

        # تحديث قائمة الأنشطة الحديثة
        if oActivitiesList != NULL {
            oActivitiesList.insertItem(0, "Dashboard updated - " + time())

            # التأكد من عدم تجاوز الحد الأقصى للأنشطة
            if oActivitiesList.count() > 20 {
                oActivitiesList.takeItem(oActivitiesList.count() - 1)
            }
        }
    }

    func updateDashboardCards {
        # تحديث بطاقات لوحة المعلومات
        oAgentsCount.setText("" + len(aAgents))
        oCrewsCount.setText("" + len(aCrews))
        oTasksCount.setText("" + getTotalTasks())
        oSystemLoad.setText(getSystemLoad())

        # تحديث شريط الحالة
        oAgentsLabel.setText("Agents: " + len(aAgents))
        oCrewsLabel.setText("Crews: " + len(aCrews))
        oTasksLabel.setText("Tasks: " + getTotalTasks())
        oSystemLoadLabel.setText("System Load: " + getSystemLoad())
    }

    ###############################################
    # Private Helper Methods
    ###############################################
    private

    func getTotalTasks {
        nTotal = 0
        for agent in aAgents {
            nTotal += len(agent.getTaskHistory())
        }
        return nTotal
    }

    func getSystemLoad {
        # Calculate system load based on active tasks and agents
        if len(aAgents) = 0 { return "0%" }
        nLoad = (getTotalTasks() * 100) / (len(aAgents) * 10)
        if nLoad > 100 { nLoad = 100 }
        return "" + nLoad + "%"
    }

    func addMonitorRow cMetric, cValue {
        nRow = oMonitorView.rowCount()
        oMonitorView.insertRow(nRow)
        oMonitorView.setItem(nRow, 0, new QTableWidgetItem(cMetric))
        oMonitorView.setItem(nRow, 1, new QTableWidgetItem(cValue))
    }



    ###############################################
    # Data Access Methods
    ###############################################

    # Functions to support chat feature
    func getMessages oAgent {
        # This is a placeholder implementation
        # In a real application, messages would be stored in a database
        return []
    }

    func saveMessage oMessage {
        # This is a placeholder implementation
        # In a real application, messages would be stored in a database
        return true
    }

    func getCurrentUser {
        # Return the current logged-in user
        return oCurrentUser
    }

    ###############################################
    # Settings and Theme Management Methods
    ###############################################

    func showSettingsDialog {
        oDialog = new SettingsDialog(this)
        oDialog.exec()

        # إذا تم قبول الحوار (النقر على حفظ)
        if oDialog.result() {
            # تطبيق الإعدادات الجديدة
            applySettings()

            # عرض رسالة نجاح
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Success")
                setText("Settings saved successfully.")
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()

            # تسجيل الحدث
            log("Settings updated")
        }
    }

    func applySettings {
        # تطبيق الإعدادات من ملف الإعدادات
        oSettings.loadSetting()

        # تطبيق السمة
        cTheme = oSettings.getKey("theme")
        setTheme(cTheme)

        # تطبيق اللغة
        cLang = oSettings.getKey("language")
        setLanguage(cLang)

        # تطبيق فاصل التحديث
        nInterval = oSettings.getKey("updateInterval")
        if oTimer != NULL {
            oTimer.setInterval(nInterval)
        }
    }

    func setTheme cTheme {
        # تعيين السمة باستخدام مدير السمات
        if oThemeManager.setTheme(cTheme) {
            # تحديث الإعدادات
            oSettings.setKey("theme", cTheme)

            # تطبيق السمة على واجهة المستخدم
            applyThemeToUI()

            # تسجيل الحدث
            log("Theme changed to: " + cTheme)
        }
    }

    func applyThemeToUI {
        # الحصول على السمة الحالية
        oTheme = oThemeManager.getCurrentTheme()

        # تطبيق السمة على البطاقات
        oAgentsCard.setStyleSheet("background-color: " + oTheme[:card_bg] + "; border: 1px solid " + oTheme[:card_border] + "; border-radius: 8px; padding: 10px; color: " + oTheme[:text] + ";")
        oCrewsCard.setStyleSheet("background-color: " + oTheme[:card_bg] + "; border: 1px solid " + oTheme[:card_border] + "; border-radius: 8px; padding: 10px; color: " + oTheme[:text] + ";")
        oTasksCard.setStyleSheet("background-color: " + oTheme[:card_bg] + "; border: 1px solid " + oTheme[:card_border] + "; border-radius: 8px; padding: 10px; color: " + oTheme[:text] + ";")
        oSystemCard.setStyleSheet("background-color: " + oTheme[:card_bg] + "; border: 1px solid " + oTheme[:card_border] + "; border-radius: 8px; padding: 10px; color: " + oTheme[:text] + ";")

        # تحديث الواجهة
        updateDashboardTab()
    }

    func setLanguage cLang {
        # تعيين اللغة باستخدام مدير اللغات
        oLanguageManager.setLanguage(cLang)

        # تحديث الإعدادات
        oSettings.setKey("language", cLang)

        # تطبيق اللغة على واجهة المستخدم
        applyLanguageToUI()

        # تسجيل الحدث
        log("Language changed to: " + cLang)
    }

    func applyLanguageToUI {
        # تحديث نصوص القوائم
        oFileMenu.setTitle(oLanguageManager.getText(:file))
        oEditMenu.setTitle(oLanguageManager.getText(:edit))
        oViewMenu.setTitle(oLanguageManager.getText(:view))
        oThemeMenu.setTitle(oLanguageManager.getText(:theme))
        oToolsMenu.setTitle(oLanguageManager.getText(:tools))
        oHelpMenu.setTitle(oLanguageManager.getText(:help))

        # تحديث نصوص التابات
        oTabs.setTabText(0, oLanguageManager.getText(:dashboard))
        oTabs.setTabText(1, oLanguageManager.getText(:teams))
        oTabs.setTabText(2, oLanguageManager.getText(:tasks))
        oTabs.setTabText(3, oLanguageManager.getText(:monitor))
        oTabs.setTabText(4, oLanguageManager.getText(:analytics))

        # تحديث الواجهة
        updateDashboardTab()
    }

    func refreshDashboard {
        # استخدام مدير لوحة المعلومات لتحديث لوحة المعلومات
        oDashboardManager.updateDashboard()

        # تحديث البطاقات والقوائم
        updateDashboardTab()
        updateAgentsList()
        updateCrewsList()
        updateTasksList()

        # تحديث الأنشطة
        refreshActivities()

        # تسجيل الحدث
        log("Dashboard refreshed")
    }

    func backupData {
        # إنشاء مجلد النسخ الاحتياطي إذا لم يكن موجودًا
        if not dirExists("backups") {
            system("mkdir backups")
        }

        # إنشاء اسم ملف النسخ الاحتياطي باستخدام التاريخ والوقت
        cBackupFile = "backups/backup_" + replace(date(), "/", "-") + "_" + replace(time(), ":", "-") + ".zip"

        # إنشاء ملف النسخ الاحتياطي
        system("zip -r " + cBackupFile + " settings/ data/")

        # عرض رسالة نجاح
        oMsgBox = new QMessageBox(this) {
            setWindowTitle("Backup Complete")
            setText("Data backed up successfully to: " + cBackupFile)
            setIcon(QMessageBox_Information)
            setStandardButtons(QMessageBox_Ok)
        }
        oMsgBox.exec()

        # تسجيل الحدث
        log("Data backed up to: " + cBackupFile)
    }

    func restoreData {
        # التحقق من وجود مجلد النسخ الاحتياطي
        if not dirExists("backups") {
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Error")
                setText("No backups found.")
                setIcon(QMessageBox_Warning)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
            return
        }

        # الحصول على قائمة ملفات النسخ الاحتياطي
        aFiles = listdir("backups", "*.zip")

        if len(aFiles) = 0 {
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Error")
                setText("No backup files found.")
                setIcon(QMessageBox_Warning)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
            return
        }

        # عرض مربع حوار لاختيار ملف النسخ الاحتياطي
        cBackupFile = QInputDialog.getItem(
            this,
            "Restore Backup",
            "Select backup file to restore:",
            aFiles,
            0,
            false
        )

        if cBackupFile = "" { return }

        # عرض رسالة تأكيد
        oMsgBox = new QMessageBox(this) {
            setWindowTitle("Confirm Restore")
            setText("Are you sure you want to restore from backup: " + cBackupFile + "?\nThis will overwrite current data.")
            setIcon(QMessageBox_Question)
            setStandardButtons(QMessageBox_Yes | QMessageBox_No)
            setDefaultButton(QMessageBox_No)
        }

        if oMsgBox.exec() = QMessageBox_Yes {
            # استعادة النسخة الاحتياطية
            system("unzip -o backups/" + cBackupFile + " -d ./")

            # إعادة تحميل الإعدادات
            loadSettings()

            # عرض رسالة نجاح
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Restore Complete")
                setText("Data restored successfully from: " + cBackupFile)
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()

            # تحديث الواجهة
            refreshDashboard()

            # تسجيل الحدث
            log("Data restored from: " + cBackupFile)
        }
    }

    func viewLogs {
        # عرض مربع حوار لعرض السجلات
        oDialog = new QDialog(this) {
            setWindowTitle("System Logs")
            setModal(true)
            resize(800, 600)
        }

        oLayout = new QVBoxLayout()

        # عنوان
        oHeaderLabel = new QLabel(oDialog) {
            setText("System Logs")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 18px; font-weight: bold; color: #2c3e50; margin: 10px 0;")
        }
        oLayout.addWidget(oHeaderLabel)

        # مربع نص لعرض السجلات
        oLogView = new QTextEdit(oDialog) {
            setReadOnly(true)
            setStyleSheet("font-family: monospace; font-size: 12px;")
        }

        # قراءة ملف السجل
        if fexists("logs/system.log") {
            cLogContent = read("logs/system.log")
            oLogView.setText(cLogContent)
        else
            oLogView.setText("No log file found.")
        }

        oLayout.addWidget(oLogView)

        # زر إغلاق
        oButtonsLayout = new QHBoxLayout()
        oButtonsLayout.addStretch(1)

        oCloseButton = new QPushButton(oDialog) {
            setText("Close")
            setStyleSheet("min-width: 100px; padding: 8px;")
            setclickevent("pClose()")
        }
        oButtonsLayout.addWidget(oCloseButton)
        oButtonsLayout.addStretch(1)

        oLayout.addLayout(oButtonsLayout)
        oDialog.setLayout(oLayout)

        # تعريف دالة الإغلاق
        oDialog.pClose = func { oDialog.close() }

        # عرض مربع الحوار
        oDialog.exec()
    }

    ###############################################
    # Task Management Methods
    ###############################################

    func removeSelectedTask {
        nRow = oTasksList.currentIndex().row()
        if nRow >= 0 {
            cTaskName = oTasksList.topLevelItem(nRow).text(1) # Get task name from column 1
            oMsgBox = new QMessageBox() {
                setWindowTitle("Confirm Deletion")
                setText("Are you sure you want to delete task: " + cTaskName + "?")
                setIcon(QMessageBox_Question)
                setStandardButtons(QMessageBox_Yes | QMessageBox_No)
                setDefaultButton(QMessageBox_No)
            }

            if oMsgBox.exec() = QMessageBox_Yes {
                # Remove from list
                oTasksList.takeTopLevelItem(nRow)

                # Remove from tasks array
                if nRow <= len(aTasks) {
                    del(aTasks, nRow)
                }

                log("Task removed: " + cTaskName)
            }
        else
            oMsgBox = new QMessageBox() {
                setWindowTitle("Error")
                setText("Please select a task to remove.")
                setIcon(QMessageBox_Warning)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
        }
    }

}