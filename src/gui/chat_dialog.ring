

/*
الكلاس: ChatMessage
الوصف: تمثيل رسالة في المحادثة
*/
class ChatMessage
    cId
    cText
    oSender
    oReceiver
    dTimestamp
    cType  # text, image, file, system
    cStatus  # sent, delivered, read

    func init cMessageText, oMessageSender, oMessageReceiver {
        cId = "msg_" + random(100000)
        cText = cMessageText
        oSender = oMessageSender
        oReceiver = oMessageReceiver
        dTimestamp = date()
        cType = "text"
        cStatus = "sent"
    }

    func getId return cId
    func getText return cText
    func getSender return oSender
    func getReceiver return oReceiver
    func getTimestamp return dTimestamp
    func getType return cType
    func getStatus return cStatus

    func setStatus cNewStatus {
        cStatus = cNewStatus
    }

/*
الكلاس: ChatDialog
الوصف: نافذة الدردشة مع العملاء
*/
class ChatDialog from QDialog

    # GUI Components
    oChatList
    oAgentList
    oMessageEdit
    oConversationView

    # Data
    oCurrentAgent
    aMessages
    oParent  # مرجع للنافذة الأم

    func init oParent {
        super.init(oParent)
        setWindowTitle("Chat with Agents")
        setModal(true)
        resize(900, 700)
        aMessages = []
        initUI()
        loadAgents()
    }

     # دالة للحصول على النافذة الأم
    func getParent {
        return this.oParent
    }
    
    func initUI {
        # Main layout
        oMainLayout = new QHBoxLayout()
        oMainLayout.setSpacing(10)

        # Left panel - Agent list
        oLeftPanel = new QWidget()
        oLeftPanel.setStyleSheet("background-color: #f8f9fa; border-radius: 8px; border: 1px solid #dfe6e9;")
        oLeftLayout = new QVBoxLayout()
        oLeftLayout.setSpacing(10)

        # Header for left panel
        oLeftHeaderLabel = new QLabel(oLeftPanel) {
            setText("Available Agents")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 18px; font-weight: bold; color: #2c3e50; margin: 10px 0; border-bottom: 1px solid #dfe6e9; padding-bottom: 10px;")
        }
        oLeftLayout.addWidget(oLeftHeaderLabel)

        # Search agents with icon
        oSearchLayout = new QHBoxLayout()
        oSearchIcon = new QLabel(oLeftPanel) {
            setText("🔍")
            setStyleSheet("font-size: 16px; padding-right: 5px;")
        }
        oSearchLayout.addWidget(oSearchIcon)

        oSearchEdit = new QLineEdit(oLeftPanel) {
            setPlaceholderText("Search agents...")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px;")
        }
        oSearchLayout.addWidget(oSearchEdit)
        oLeftLayout.addLayout(oSearchLayout)

        # Online/Offline filter
        oFilterFrame = new QFrame(oLeftPanel) {
            setFrameShape(QFrame_StyledPanel)
            setStyleSheet("background-color: #ecf0f1; border-radius: 4px; padding: 10px; margin: 5px 0;")
        }
        oFilterLayout = new QVBoxLayout()

        oFilterLabel = new QLabel(oFilterFrame) {
            setText("Status Filter:")
            setStyleSheet("font-size: 14px; font-weight: bold; color: #34495e;")
        }
        oFilterLayout.addWidget(oFilterLabel)

        oCheckboxLayout = new QHBoxLayout()

        oOnlineCheck = new QCheckBox(oFilterFrame) {
            setText("Online")
            setChecked(true)
            setStyleSheet("font-size: 14px;")
        }
        oCheckboxLayout.addWidget(oOnlineCheck)

        oOfflineCheck = new QCheckBox(oFilterFrame) {
            setText("Offline")
            setChecked(true)
            setStyleSheet("font-size: 14px;")
        }
        oCheckboxLayout.addWidget(oOfflineCheck)
        oCheckboxLayout.addStretch(1)

        oFilterLayout.addLayout(oCheckboxLayout)
        oFilterFrame.setLayout(oFilterLayout)
        oLeftLayout.addWidget(oFilterFrame)

        # Agent list
        oAgentListLabel = new QLabel(oLeftPanel) {
            setText("Agents:")
            setStyleSheet("font-size: 14px; font-weight: bold; color: #34495e;")
        }
        oLeftLayout.addWidget(oAgentListLabel)

        oAgentList = new QListWidget(oLeftPanel) {
            setStyleSheet("
                QListWidget {
                    padding: 5px;
                    font-size: 14px;
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
                QListWidget::item {
                    padding: 8px;
                    border-bottom: 1px solid #ecf0f1;
                }
                QListWidget::item:selected {
                    background-color: #3498db;
                    color: white;
                }
            ")
        }
        oLeftLayout.addWidget(oAgentList)

        oLeftPanel.setLayout(oLeftLayout)
        oMainLayout.addWidget(oLeftPanel, 30)

        # Right panel - Chat
        oRightPanel = new QWidget()
        oRightPanel.setStyleSheet("background-color: #f8f9fa; border-radius: 8px; border: 1px solid #dfe6e9;")
        oRightLayout = new QVBoxLayout()
        oRightLayout.setSpacing(10)

        # Agent info header
        oAgentInfo = new QFrame(oRightPanel) {
            setFrameShape(QFrame_StyledPanel)
            setStyleSheet("background-color: #ecf0f1; border-radius: 4px; padding: 10px; margin-bottom: 10px;")
        }
        oAgentInfoLayout = new QHBoxLayout()

        oAgentAvatar = new QLabel(oAgentInfo) {
            setText("👤")
            setStyleSheet("font-size: 24px; padding-right: 10px;")
            setFixedSize(40, 40)
            setAlignment(Qt_AlignCenter)
        }
        oAgentInfoLayout.addWidget(oAgentAvatar)

        oAgentNameLabel = new QLabel(oAgentInfo) {
            setText("Select an agent to start chat")
            setStyleSheet("font-size: 16px; font-weight: bold; color: #2c3e50;")
        }
        oAgentInfoLayout.addWidget(oAgentNameLabel)
        oAgentInfoLayout.addStretch(1)

        oAgentStatusLabel = new QLabel(oAgentInfo) {
            setStyleSheet("font-size: 14px; padding: 3px 8px; border-radius: 10px;")
        }
        oAgentInfoLayout.addWidget(oAgentStatusLabel)

        oAgentInfo.setLayout(oAgentInfoLayout)
        oRightLayout.addWidget(oAgentInfo)

        # Chat area
        oConversationView = new QTextEdit(oRightPanel) {
            setReadOnly(true)
            setStyleSheet("
                QTextEdit {
                    padding: 10px;
                    font-size: 14px;
                    border: 1px solid #bdc3c7;
                    border-radius: 4px;
                    background-color: white;
                }
            ")
        }
        oRightLayout.addWidget(oConversationView)

        # Message input area
        oInputFrame = new QFrame(oRightPanel) {
            setFrameShape(QFrame_StyledPanel)
            setStyleSheet("background-color: #ecf0f1; border-radius: 4px; padding: 10px;")
        }
        oInputLayout = new QHBoxLayout()

        # Attach file button
        oAttachButton = new QPushButton(oInputFrame) {
            setText("📎")
            setStyleSheet("font-size: 18px; background-color: #3498db; color: white; padding: 8px; border: 1px solid #2980b9; border-radius: 4px; min-width: 40px;")
        }
        oInputLayout.addWidget(oAttachButton)

        # Message edit
        oMessageEdit = new QTextEdit(oInputFrame) {
            setFixedHeight(60)
            setPlaceholderText("Type your message...")
            setStyleSheet("padding: 8px; font-size: 14px; border: 1px solid #bdc3c7; border-radius: 4px; background-color: white;")
        }
        oInputLayout.addWidget(oMessageEdit)

        # Send button
        oSendButton = new QPushButton(oInputFrame) {
            setText("Send")
            setStyleSheet("background-color: #2ecc71; color: white; padding: 8px; font-size: 14px; border: 1px solid #27ae60; border-radius: 4px; min-width: 80px;")
        }
        oInputLayout.addWidget(oSendButton)

        oInputFrame.setLayout(oInputLayout)
        oRightLayout.addWidget(oInputFrame)

        oRightPanel.setLayout(oRightLayout)
        oMainLayout.addWidget(oRightPanel, 70)

        setLayout(oMainLayout)

        # Connect signals
        oSearchEdit.textChangedEvent("filterAgents()")
        oOnlineCheck.stateChangedEvent("filterAgents()")
        oOfflineCheck.stateChangedEvent("filterAgents()")
        oAgentList.itemClickedEvent("agentSelected()")
        oAttachButton.setclickevent("showAttachMenu()")
        oSendButton.setclickevent("sendMessage()")
        oMessageEdit.returnPressedEvent("sendMessage()")
    }

    func loadAgents {
        oAgentList.clear()

        for oAgent in getParent().aAgents {
            oItem = new QListWidgetItem(oAgentList)
            oItem.setText(oAgent.getName())
            oItem.setData(Qt_UserRole, oAgent)

            if oAgent.isOnline() {
                oItem.setIcon(new QIcon(new QPixmap("icons/online.png")))
            else
                oItem.setIcon(new QIcon(new QPixmap("icons/offline.png")))
            }
        }
    }

    func filterAgents {
        cSearch = lower(oSearchEdit.text())
        bShowOnline = oOnlineCheck.isChecked()
        bShowOffline = oOfflineCheck.isChecked()

        for i = 0 to oAgentList.count()-1 {
            oItem = oAgentList.item(i)
            oAgent = oItem.data(Qt_UserRole)

            bShow = true

            # Apply search filter
            if cSearch != "" {
                if not substr(lower(oAgent.getName()), cSearch) {
                    bShow = false
                }
            }

            # Apply status filter
            if oAgent.isOnline() and not bShowOnline {
                bShow = false
            }
            if not oAgent.isOnline() and not bShowOffline {
                bShow = false
            }

            oItem.setHidden(not bShow)
        }
    }

    func agentSelected oItem {
        oCurrentAgent = oItem.data(Qt_UserRole)

        # Update agent info
        oAgentNameLabel.setText(oCurrentAgent.getName())
        if oCurrentAgent.isOnline() {
            oAgentStatusLabel.setText("Online")
            oAgentStatusLabel.setStyleSheet("color: white; background-color: #2ecc71; font-size: 14px; padding: 3px 8px; border-radius: 10px;")
            oAgentAvatar.setStyleSheet("font-size: 24px; padding-right: 10px; color: #2ecc71;")
        else
            oAgentStatusLabel.setText("Offline")
            oAgentStatusLabel.setStyleSheet("color: white; background-color: #95a5a6; font-size: 14px; padding: 3px 8px; border-radius: 10px;")
            oAgentAvatar.setStyleSheet("font-size: 24px; padding-right: 10px; color: #95a5a6;")
        }

        # Load conversation history
        loadMessages()
    }

    func loadMessages {
        oConversationView.clear()

        if oCurrentAgent = null { return }

        # Load messages from storage
        aMessages = getParent().getMessages(oCurrentAgent)

        # Display messages
        oCursor = oConversationView.textCursor()
        oFormat = new QTextCharFormat()

        # Add a welcome message if no messages
        if len(aMessages) = 0 {
            oFormat.setForeground(new QColor(128,128,128))
            oCursor.insertText("Start a conversation with " + oCurrentAgent.getName() + "\n", oFormat)
            return
        }

        # Create HTML for better styling
        cHtml = "<html><body style='font-family: Arial, sans-serif;'>"

        for oMessage in aMessages {
            cSenderName = oMessage.getSender().getName()
            cIsCurrentUser = (oMessage.getSender() = getParent().getCurrentUser())

            # Message container with alignment
            if cIsCurrentUser {
                cHtml += "<div style='margin: 10px 0; text-align: right;'>"
                cBgColor = "#dcf8c6" # Light green for user messages
            else
                cHtml += "<div style='margin: 10px 0; text-align: left;'>"
                cBgColor = "#f1f0f0" # Light gray for agent messages
            }

            # Message bubble
            cHtml += "<div style='display: inline-block; max-width: 80%; background-color: " +
                     cBgColor + "; padding: 10px; border-radius: 10px;'>"

            # Sender name
            cHtml += "<div style='font-weight: bold; color: #2c3e50;'>" + cSenderName + "</div>"

            # Message text
            cHtml += "<div style='margin-top: 5px;'>" + oMessage.getText() + "</div>"

            # Timestamp
            cHtml += "<div style='font-size: 12px; color: #7f8c8d; text-align: right; margin-top: 5px;'>" +
                     oMessage.getTimestamp() + "</div>"

            cHtml += "</div></div>"
        }

        cHtml += "</body></html>"
        oConversationView.setHtml(cHtml)

        # Scroll to bottom
        oConversationView.verticalScrollBar().setValue(
            oConversationView.verticalScrollBar().maximum()
        )
    }

    func sendMessage {
        if oCurrentAgent = null { return }

        cText = oMessageEdit.toPlainText()
        if trim(cText) = "" { return }

        # Create message
        oMessage = new ChatMessage(
            cText,
            getParent().getCurrentUser(),
            oCurrentAgent
        )

        # Add to conversation
        add(aMessages, oMessage)

        # Save to storage
        getParent().saveMessage(oMessage)

        # Update display
        loadMessages()

        # Clear input
        oMessageEdit.clear()

        # Send to agent
        sendToAgent(oMessage)
    }

    func showAttachMenu {
        oMenu = new QMenu(this)

        oImageAction = new QAction("Image", oMenu)
        oImageAction.setIcon(new QIcon(new QPixmap("icons/image.png")))
        oImageAction.setclickevent("attachImage()")
        oMenu.addAction(oImageAction)

        oFileAction = new QAction("File", oMenu)
        oFileAction.setIcon(new QIcon(new QPixmap("icons/file.png")))
        oFileAction.setclickevent("attachFile()")
        oMenu.addAction(oFileAction)

        oMenu.popup(QCursor.pos())
    }

    func attachImage {
        cPath = QFileDialog.getOpenFileName(
            this,
            "Select Image",
            "",
            "Images (*.png *.jpg *.jpeg *.gif)"
        )

        if cPath != "" {
            # TODO: Handle image attachment
            QMessageBox.information(
                this,
                "Not Implemented",
                "Image attachment will be implemented in a future version"
            )
        }
    }

    func attachFile {
        cPath = QFileDialog.getOpenFileName(
            this,
            "Select File",
            "",
            "All Files (*.*)"
        )

        if cPath != "" {
            # TODO: Handle file attachment
            QMessageBox.information(
                this,
                "Not Implemented",
                "File attachment will be implemented in a future version"
            )
        }
    }

    private

    func sendToAgent oMessage {
        # TODO: Implement actual message sending to agent
        # For now, just simulate a response
        simulateAgentResponse()
    }

    func simulateAgentResponse {
        if oCurrentAgent = null { return }

        # Create response after 1 second delay
        oTimer = new QTimer(this)
        oTimer.setInterval(1000)
        oTimer.timeoutEvent("createAgentResponse()")
        oTimer.start()
    }

    func createAgentResponse {
        # Generate a simple response
        oResponse = new ChatMessage(
            "I received your message. This is an automated response.",
            oCurrentAgent,
            getParent().getCurrentUser()
        )

        # Add to conversation
        add(aMessages, oResponse)

        # Save to storage
        getParent().saveMessage(oResponse)

        # Update display
        loadMessages()
    }

