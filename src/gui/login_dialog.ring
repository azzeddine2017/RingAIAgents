

/*
الكلاس: LoginDialog
الوصف: نافذة تسجيل الدخول
*/
class LoginDialog from QDialog

    # GUI Components
    oUsernameEdit
    oPasswordEdit
    oRememberCheck

    # Data
    oUser = null

    func init oParent {
        super.init(oParent)
        setWindowTitle("Login")
        setModal(true)
        setFixedSize(600, 800)  # تثبيت حجم الديالوج - عرض أكبر وطول أقل
        initUI()
        loadSavedCredentials()
    }

    func initUI {
        # Create main layout
        oMainLayout = new QVBoxLayout()
        oMainLayout.setSpacing(5)
        oMainLayout.setContentsMargins(15, 10, 15, 10)  # تقليل الهوامش

        # Set window background
        setStyleSheet("background-color: #f5f7fa;")

        # Logo container with shadow effect
        oLogoContainer = new QWidget()
        oLogoContainer.setStyleSheet("
            background-color: #ffffff;
            border-radius: 10px;
            border: 1px solid #e1e8ed;
            margin: 10px;
        ")
        oLogoLayout = new QVBoxLayout()

        # Logo
        oLogoLabel = new QLabel(oLogoContainer) {
            # setPixmap(new QPixmap("icons/logo.png")) - غير مدعومة
            settext("RingAI Agents")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 24px; font-weight: bold; color: #3498db; margin: 10px 0;")
        }
        oLogoLayout.addWidget(oLogoLabel)

        # Subtitle
        oSubtitleLabel = new QLabel(oLogoContainer) {
            settext("Intelligent Agent Management")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 12px; color: #7f8c8d; margin-bottom: 5px;")
        }
        oLogoLayout.addWidget(oSubtitleLabel)

        oLogoContainer.setLayout(oLogoLayout)
        oMainLayout.addWidget(oLogoContainer)

        # Form container with shadow effect
        oFormContainer = new QWidget()
        oFormContainer.setStyleSheet("
            background-color: #ffffff;
            border-radius: 10px;
            border: 1px solid #e1e8ed;
            margin: 10px;
            padding: 20px;
        ")
        oFormLayout = new QVBoxLayout()
        oFormLayout.setSpacing(5)

        # Form title
        oFormTitle = new QLabel(oFormContainer) {
            settext("Sign In")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 16px; font-weight: bold; color: #2c3e50; margin-bottom: 8px;")
        }
        oFormLayout.addWidget(oFormTitle)

        # Username field with icon
        oUserLayout = new QHBoxLayout()
        oUserIcon = new QLabel(oFormContainer) {
            settext("👤")
            setStyleSheet("font-size: 16px; padding-right: 5px; color: #3498db;")
        }
        oUserLayout.addWidget(oUserIcon)

        oUsernameEdit = new QLineEdit(oFormContainer){
            setPlaceholderText("Username")
            setStyleSheet("
                padding: 8px;
                font-size: 13px;
                border: 1px solid #bdc3c7;
                border-radius: 5px;
                background-color: #f8f9fa;
            ")
        }
        oUserLayout.addWidget(oUsernameEdit)
        oFormLayout.addLayout(oUserLayout)

        # Password field with icon
        oPassLayout = new QHBoxLayout()
        oPassIcon = new QLabel(oFormContainer) {
            settext("🔒")
            setStyleSheet("font-size: 16px; padding-right: 5px; color: #3498db;")
        }
        oPassLayout.addWidget(oPassIcon)

        oPasswordEdit = new QLineEdit(oFormContainer) {
            # setEchoMode(QLineEdit_Password) - غير مدعومة
            setPlaceholderText("Password")
            setStyleSheet("
                padding: 8px;
                font-size: 13px;
                border: 1px solid #bdc3c7;
                border-radius: 5px;
                background-color: #f8f9fa;
            ")
        }
        oPassLayout.addWidget(oPasswordEdit)
        oFormLayout.addLayout(oPassLayout)

        # Remember me
        oRememberCheck = new QCheckBox(oFormContainer){
            setText("Remember me")
            setStyleSheet("font-size: 13px; margin-top: 2px; color: #7f8c8d;")
        }
        oFormLayout.addWidget(oRememberCheck)

        # Buttons
        oButtonsLayout = new QVBoxLayout()
        oButtonsLayout.setSpacing(5)

        oLoginButton = new QPushButton(oFormContainer){
            setText("Login")
            setStyleSheet("
                background-color: #3498db;
                color: white;
                font-weight: bold;
                min-width: 100%;
                padding: 8px;
                font-size: 13px;
                border: none;
                border-radius: 5px;
            ")
        }
        oButtonsLayout.addWidget(oLoginButton)

        oCancelButton = new QPushButton(oFormContainer){
            setText("Cancel")
            setStyleSheet("
                background-color: #ecf0f1;
                color: #7f8c8d;
                min-width: 100%;
                padding: 8px;
                font-size: 13px;
                border: 1px solid #bdc3c7;
                border-radius: 5px;
            ")
        }
        oButtonsLayout.addWidget(oCancelButton)

        oFormLayout.addLayout(oButtonsLayout)

        # Forgot password link
        oForgotLayout = new QHBoxLayout()
        oForgotLayout.addStretch(1)

        oForgotLabel = new QPushButton(oFormContainer) {
            setText("Forgot password?")
            setStyleSheet("
                font-size: 13px;
                color: #3498db;
                text-decoration: underline;
                background: transparent;
                border: none;
            ")
        }
        oForgotLayout.addWidget(oForgotLabel)
        oForgotLayout.addStretch(1)
        oFormLayout.addLayout(oForgotLayout)

        oFormContainer.setLayout(oFormLayout)
        oMainLayout.addWidget(oFormContainer)

        # Footer
        oFooterLabel = new QLabel(this) {
            settext("© 2025 RingAI Agents. All rights reserved.")
            setAlignment(Qt_AlignHCenter)
            setStyleSheet("font-size: 12px; color: #95a5a6; margin: 10px 0;")
        }
        oMainLayout.addWidget(oFooterLabel)

        setLayout(oMainLayout)

        # Connect signals
        oCancelButton.setclickevent("reject()")
        oLoginButton.setclickevent('login()')
        oForgotLabel.setclickevent("this.showForgotPassword()")

        # Set focus
        oUsernameEdit.setFocus(true)
    }

    func loadSavedCredentials {
        # Load saved credentials if "Remember me" was checked
        if fexists("credentials.dat") {
            try {
                cContent = read("credentials.dat")
                aCredentials = json2list(decrypt(cContent))
                if len(aCredentials) = 2 {
                    oUsernameEdit.setText(aCredentials[1])
                    oPasswordEdit.setText(aCredentials[2])
                    oRememberCheck.setChecked(true)

                    # طباعة رسالة للتأكد
                    ? "Credentials loaded from saved data."
                }
            catch
                # تجاهل الأخطاء
                ? "Error loading saved credentials."
            }
        else
            # إذا لم يكن هناك بيانات محفوظة، نضع المستخدم الافتراضي
            oUsernameEdit.setText("admin")
            oPasswordEdit.setText("admin")

            # طباعة رسالة للتأكد
            ? "Using default credentials: admin/admin"
        }
    }

    func login {
        cUsername = oUsernameEdit.text()
        cPassword = oPasswordEdit.text()

        # طباعة بيانات الدخول للتأكد
        ? "Attempting login with: " + cUsername + " / " + cPassword

        # التحقق من المستخدم الافتراضي مباشرة
        if cUsername = "admin" and cPassword = "admin" {
            ? "Using default admin credentials"
            oUser = [
                :name = "Administrator",
                :username = "admin",
                :role = "admin",
                :loginTime = date()
            ]

            # عرض رسالة ترحيب
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Login Successful")
                setText("Welcome Administrator!\nRole: admin")
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()

            # تسجيل عملية تسجيل الدخول في ملف السجل
            logLoginActivity("admin")

            accept()
            return
        }

        # التحقق من باقي المستخدمين
        if validateCredentials(cUsername, cPassword) {
            # Save credentials if "Remember me" is checked
            if oRememberCheck.isChecked() {
                saveCredentials(cUsername, cPassword)
            }

            # عرض رسالة ترحيب
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Login Successful")
                setText("Welcome " + oUser[:name] + "!\nRole: " + oUser[:role])
                setIcon(QMessageBox_Information)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()

            # تسجيل عملية تسجيل الدخول في ملف السجل
            logLoginActivity(oUser[:username])

            accept()
        else
            oMsgBox = new QMessageBox(this) {
                setWindowTitle("Login Error")
                setText("Invalid username or password")
                setIcon(QMessageBox_Warning)
                setStandardButtons(QMessageBox_Ok)
            }
            oMsgBox.exec()
        }
    }

    func accept {
        super.accept()
    }

    func logLoginActivity cUsername {
        # تسجيل نشاط تسجيل الدخول في ملف السجل
        cLogEntry = date() + " " + time() + " - User '" + cUsername + "' logged in."

        try {
            if fexists("login_log.txt") {
                cContent = read("login_log.txt")
                write("login_log.txt", cContent + nl + cLogEntry)
            else
                write("login_log.txt", cLogEntry)
            }
        catch
            # تجاهل الأخطاء
        }
    }

    func getUserData {
        return oUser
    }

    func showForgotPassword {
        # عرض رسالة بسيطة
        oMsgBox = new QMessageBox(this) {
            setWindowTitle("Forgot Password")
            setText("To recover your password, please contact the system administrator.\n\nNote: The default password is 'admin'")
            setIcon(QMessageBox_Information)
            setStandardButtons(QMessageBox_Ok)
        }
        oMsgBox.exec()
    }

    private

    func validateCredentials cUsername, cPassword {
        if cUsername = "" or cPassword = "" {
            return false
        }

        # التحقق من صحة بيانات الدخول من ملف المستخدمين
        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                for aUser in aUsers {
                    if aUser[:username] = cUsername and aUser[:password] = cPassword {
                        # تحديث بيانات المستخدم الحالي
                        oUser = [
                            :name = aUser[:name],
                            :username = aUser[:username],
                            :role = aUser[:role],
                            :loginTime = date()
                        ]
                        return true
                    }
                }

                return false
            catch
                # في حالة حدوث خطأ، نستخدم المستخدم الافتراضي
                if cUsername = "admin" and cPassword = "admin" {
                    oUser = [
                        :name = "Administrator",
                        :username = "admin",
                        :role = "admin",
                        :loginTime = date()
                    ]
                    return true
                }
                return false
            }
        else
            # إذا لم يكن هناك ملف مستخدمين، نستخدم المستخدم الافتراضي
            if cUsername = "admin" and cPassword = "admin" {
                oUser = [
                    :name = "Administrator",
                    :username = "admin",
                    :role = "admin",
                    :loginTime = date()
                ]
                # إنشاء ملف المستخدمين بالمستخدم الافتراضي
                createUsersFile()
                return true
            }
            return false
        }
    }

    func saveCredentials cUsername, cPassword {
        try {
            cContent = encrypt(list2json([cUsername, cPassword]))
            write("credentials.dat", cContent)
        catch
            # Ignore errors
        }
    }

    func encrypt cText {
        # تشفير بسيط للنص (في التطبيق الحقيقي يجب استخدام خوارزمية تشفير قوية)
        cResult = ""
        for i = 1 to len(cText) {
            cResult += char(ascii(substr(cText, i, 1)) + 1)
        }
        return cResult
    }

    func decrypt cText {
        # فك تشفير النص
        cResult = ""
        for i = 1 to len(cText) {
            cResult += char(ascii(substr(cText, i, 1)) - 1)
        }
        return cResult
    }

    func createUsersFile {
        # إنشاء ملف المستخدمين بالمستخدم الافتراضي
        aUsers = [
            [
                :name = "Administrator",
                :username = "admin",
                :password = "admin",
                :role = "admin",
                :created = date()
            ],
            [
                :name = "Guest User",
                :username = "guest",
                :password = "guest",
                :role = "guest",
                :created = date()
            ],
            [
                :name = "Test User",
                :username = "test",
                :password = "test123",
                :role = "user",
                :created = date()
            ]
        ]

        try {
            cContent = encrypt(list2json(aUsers))
            write("users.dat", cContent)
        catch
            # تجاهل الأخطاء
        }
    }

    func addUser cName, cUsername, cPassword, cRole {
        # إضافة مستخدم جديد إلى ملف المستخدمين
        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                # التحقق من عدم وجود المستخدم بالفعل
                for aUser in aUsers {
                    if aUser[:username] = cUsername {
                        return false  # المستخدم موجود بالفعل
                    }
                }

                # إضافة المستخدم الجديد
                add(aUsers, [
                    :name = cName,
                    :username = cUsername,
                    :password = cPassword,
                    :role = cRole,
                    :created = date()
                ])

                # حفظ الملف
                cContent = encrypt(list2json(aUsers))
                write("users.dat", cContent)
                return true
            catch
                return false
            }
        else
            # إنشاء ملف المستخدمين أولاً
            createUsersFile()
            return addUser(cName, cUsername, cPassword, cRole)
        }
    }

    func removeUser cUsername {
        # حذف مستخدم من ملف المستخدمين
        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                # البحث عن المستخدم وحذفه
                for i = 1 to len(aUsers) {
                    if aUsers[i][:username] = cUsername {
                        # لا يمكن حذف المستخدم admin
                        if cUsername = "admin" {
                            return false
                        }

                        # حذف المستخدم
                        del(aUsers, i)

                        # حفظ الملف
                        cContent = encrypt(list2json(aUsers))
                        write("users.dat", cContent)
                        return true
                    }
                }

                return false  # المستخدم غير موجود
            catch
                return false
            }
        else
            return false  # ملف المستخدمين غير موجود
        }
    }

    func changePassword cUsername, cOldPassword, cNewPassword {
        # تغيير كلمة مرور مستخدم
        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                # البحث عن المستخدم وتغيير كلمة المرور
                for i = 1 to len(aUsers) {
                    if aUsers[i][:username] = cUsername {
                        # التحقق من كلمة المرور القديمة
                        if aUsers[i][:password] != cOldPassword {
                            return false  # كلمة المرور القديمة غير صحيحة
                        }

                        # تغيير كلمة المرور
                        aUsers[i][:password] = cNewPassword
                        aUsers[i][:updated] = date()

                        # حفظ الملف
                        cContent = encrypt(list2json(aUsers))
                        write("users.dat", cContent)

                        # تسجيل عملية تغيير كلمة المرور
                        logPasswordChange(cUsername)

                        return true
                    }
                }

                return false  # المستخدم غير موجود
            catch
                return false
            }
        else
            return false  # ملف المستخدمين غير موجود
        }
    }

    func logPasswordChange cUsername {
        # تسجيل عملية تغيير كلمة المرور في ملف السجل
        cLogEntry = date() + " " + time() + " - User '" + cUsername + "' changed password."

        try {
            if fexists("security_log.txt") {
                cContent = read("security_log.txt")
                write("security_log.txt", cContent + nl + cLogEntry)
            else
                write("security_log.txt", cLogEntry)
            }
        catch
            # تجاهل الأخطاء
        }
    }

    func listUsers {
        # الحصول على قائمة المستخدمين
        aUsersList = []

        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                # إنشاء قائمة مبسطة للمستخدمين (بدون كلمات المرور)
                for aUser in aUsers {
                    add(aUsersList, [
                        :name = aUser[:name],
                        :username = aUser[:username],
                        :role = aUser[:role],
                        :created = aUser[:created]
                    ])
                }
            catch
                # تجاهل الأخطاء
            }
        }

        return aUsersList
    }

    func getUserInfo cUsername {
        # الحصول على معلومات مستخدم محدد
        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                # البحث عن المستخدم
                for aUser in aUsers {
                    if aUser[:username] = cUsername {
                        # إرجاع معلومات المستخدم بدون كلمة المرور
                        return [
                            :name = aUser[:name],
                            :username = aUser[:username],
                            :role = aUser[:role],
                            :created = aUser[:created]
                        ]
                    }
                }

                return null  # المستخدم غير موجود
            catch
                return null
            }
        else
            return null  # ملف المستخدمين غير موجود
        }
    }

    /*func showForgotPassword {
        # عرض نافذة لاستعادة كلمة المرور
        cUsername = QInputDialog.getText(
            this,
            "Forgot Password",
            "Enter your username to reset password:",
            QLineEdit.Normal,
            ""
        )

        if cUsername != "" {
            # التحقق من وجود المستخدم
            oUserInfo = getUserInfo(cUsername)

            if oUserInfo != null {
                # في التطبيق الحقيقي يجب إرسال رابط إعادة تعيين كلمة المرور بالبريد الإلكتروني
                # لكن هنا سنقوم بإعادة تعيين كلمة المرور مباشرة للعرض التوضيحي

                # إنشاء كلمة مرور جديدة عشوائية
                cNewPassword = "reset" + random(10000)

                # تغيير كلمة المرور في ملف المستخدمين
                if resetPassword(cUsername, cNewPassword) {
                    QMessageBox.information(
                        this,
                        "Password Reset",
                        "Your password has been reset to: " + cNewPassword + "\n\nPlease change it after logging in."
                    )
                else
                    QMessageBox.warning(
                        this,
                        "Reset Failed",
                        "Failed to reset password. Please try again later."
                    )
                }
            else
                QMessageBox.warning(
                    this,
                    "User Not Found",
                    "No user found with username: " + cUsername
                )
            }
        }
    }*/

    func resetPassword cUsername, cNewPassword {
        # إعادة تعيين كلمة مرور المستخدم
        if fexists("users.dat") {
            try {
                cContent = read("users.dat")
                aUsers = json2list(decrypt(cContent))

                # البحث عن المستخدم وتغيير كلمة المرور
                for i = 1 to len(aUsers) {
                    if aUsers[i][:username] = cUsername {
                        # تغيير كلمة المرور
                        aUsers[i][:password] = cNewPassword
                        aUsers[i][:updated] = date()

                        # حفظ الملف
                        cContent = encrypt(list2json(aUsers))
                        write("users.dat", cContent)

                        # تسجيل عملية إعادة تعيين كلمة المرور
                        logPasswordReset(cUsername)

                        return true
                    }
                }

                return false  # المستخدم غير موجود
            catch
                return false
            }
        else
            return false  # ملف المستخدمين غير موجود
        }
    }

    func logPasswordReset cUsername {
        # تسجيل عملية إعادة تعيين كلمة المرور في ملف السجل
        cLogEntry = date() + " " + time() + " - User '" + cUsername + "' password was reset."

        try {
            if fexists("security_log.txt") {
                cContent = read("security_log.txt")
                write("security_log.txt", cContent + nl + cLogEntry)
            else
                write("security_log.txt", cLogEntry)
            }
        catch
            # تجاهل الأخطاء
        }
    }
/*
المستخدم: admin، كلمة المرور: admin، الدور: admin
المستخدم: guest، كلمة المرور: guest، الدور: guest
المستخدم: test، كلمة المرور: test123، الدور: user
*/