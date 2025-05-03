/* load "openssllib.ring"
load "internetlib.ring" */

/*
Class: MFAManager
Description: مدير المصادقة متعددة العوامل
*/
class MFAManager {
    
    

    func init {
        oConfig = new SecurityConfig
        oEmailService = new EmailService
        oSMSService = new SMSService
    }

    # إنشاء وإرسال رمز المصادقة
    func generateAndSendCode cUser, cMethod {
        cCode = generateCode()
        cExpiry = calculateExpiry()
        
        switch cMethod {
            case "email"
                sendEmailCode(cUser, cCode)
            case "sms"
                sendSMSCode(cUser, cCode)
            case "authenticator"
                return generateAuthenticatorCode(cUser)
        }
        
        aActiveCodes + [cUser, cCode, cExpiry]
        return true
    }

    # التحقق من صحة الرمز
    func verifyCode cUser, cCode {
        for aCode in aActiveCodes {
            if aCode[1] = cUser and aCode[2] = cCode {
                if not isCodeExpired(aCode[3]) {
                    removeCode(cUser)
                    return true
                }
            }
        }
        return false
    }

    private

    oConfig
    oEmailService
    oSMSService
    aActiveCodes = []

    # توليد رمز عشوائي
    func generateCode {
        cCode = ""
        for i = 1 to oConfig.nMFACodeLength {
            cCode += random(0, 9)
        }
        return cCode
    }

    # حساب وقت انتهاء صلاحية الرمز
    func calculateExpiry {
        return date() + " " + time() + oConfig.nMFACodeExpiry
    }

    # إرسال الرمز عبر البريد الإلكتروني
    func sendEmailCode cUser, cCode {
        cSubject = "رمز المصادقة"
        cBody = "رمز المصادقة الخاص بك هو: " + cCode
        oEmailService.send(cUser, cSubject, cBody)
    }

    # إرسال الرمز عبر الرسائل القصيرة
    func sendSMSCode cUser, cCode {
        cMessage = "رمز المصادقة: " + cCode
        oSMSService.send(cUser, cMessage)
    }

    # توليد رمز لتطبيق المصادقة
    func generateAuthenticatorCode cUser {
        cSecret = generateTOTPSecret()
        return generateQRCode(cUser, cSecret)
    }

    # التحقق من انتهاء صلاحية الرمز
    func isCodeExpired cExpiry {
        return timeDiff(cExpiry, date() + " " + time()) <= 0
    }

    # إزالة الرمز المستخدم
    func removeCode cUser {
        for i = 1 to len(aActiveCodes) {
            if aActiveCodes[i][1] = cUser {
                del(aActiveCodes, i)
                exit
            }
        }
    }
}

/*
Class: EmailService
Description: خدمة إرسال البريد الإلكتروني
SendEmail(cSMTPServer,cEmail,cPassword,
            cSender,cReceiver,cCC,cTitle,cContent)
*/
class EmailService {
    func send cTo, cSubject, cBody {
        # تنفيذ إرسال البريد
        SendEmail(oConfig.cSMTPServer, oConfig.cEmail, oConfig.cPassword,
            oConfig.cEmail, cTo, "", cSubject, cBody)
        return true
    }
}

/*
Class: SMSService
Description: خدمة إرسال الرسائل القصيرة
*/
class SMSService {
    func send cTo, cMessage {
        # تنفيذ إرسال الرسالة
        return true
    }
}
