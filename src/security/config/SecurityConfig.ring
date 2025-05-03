# تكوين نظام الأمان

class SecurityConfig {
    # إعدادات التشفير
    cEncryptionAlgorithm = "aes-256-cbc"
    nKeyLength = 32
    nIVLength = 16
    
    # إعدادات المصادقة
    nMinPasswordLength = 12
    bRequireSpecialChars = true
    bRequireNumbers = true
    bRequireUpperCase = true
    nMFACodeLength = 6
    nMFACodeExpiry = 300  # 5 دقائق
    
    # إعدادات الجلسات
    nSessionExpiry = 3600  # 1 ساعة
    bSecureCookies = true
    bHttpOnlyCookies = true
    cCookieDomain = ""
    cCookiePath = "/"
    
    # إعدادات التوكنات
    cJWTSigningKey = ""  # سيتم توليده تلقائياً إذا كان فارغاً
    nJWTExpiry = 86400  # 24 ساعة
    
    # إعدادات CSRF
    nCSRFTokenExpiry = 3600  # 1 ساعة
    
    # إعدادات سجل المراجعة
    cAuditLogPath = "logs/audit/"
    nLogRetentionDays = 90
    bEncryptLogs = true
    
    # إعدادات منع الاختراق
    nMaxLoginAttempts = 5
    nLoginBlockDuration = 1800  # 30 دقيقة
    nRateLimitRequests = 100
    nRateLimitWindow = 60  # 1 دقيقة
    aBlockedIPs = []
    
    # أنماط الطلبات المشبوهة
    aSuspiciousPatterns = [
        "SELECT.*FROM",
        "DROP.*TABLE",
        "<script>",
        "eval\(",
        "document\.cookie",
        "javascript:",
        "onload=",
        "onclick=",
        "onerror=",
        "onmouseover=",
        "alert\(",
        "prompt\(",
        "confirm\(",
        "window\.location",
        "document\.location",
        "document\.write"
    ]
    
    # مستويات الصلاحيات
    aRoles = [
        "admin" = [
            "permissions" = ["read", "write", "delete", "manage_users", "manage_system"],
            "level" = 3
        ],
        "manager" = [
            "permissions" = ["read", "write", "manage_team", "view_reports"],
            "level" = 2
        ],
        "user" = [
            "permissions" = ["read", "write_own", "view_own_reports"],
            "level" = 1
        ],
        "guest" = [
            "permissions" = ["read"],
            "level" = 0
        ]
    ]
    
    # إعدادات الاتصال بقاعدة البيانات
    cDBHost = "localhost"
    cDBName = "ringai_agents"
    cDBUser = "ringai_user"
    cDBPassword = ""  # يجب تعيينه في بيئة الإنتاج
    nDBPort = 3306
    
    # إعدادات البريد الإلكتروني
    cEmail = "ringai@ring-framework.com"
    cPassword = "ringai@ring-framework.com"  # يجب تعيينه في بيئة الإنتاج
    cSMTPServer = "smtp.gmail.com"
    

}

/* supported shifer Algorithms 

aes-128-cbc
aes-128-cbc-hmac-sha1
aes-128-cbc-hmac-sha256
aes-128-ccm
aes-128-cfb
aes-128-cfb1
aes-128-cfb8
aes-128-ctr
aes-128-ecb
aes-128-gcm
aes-128-ocb
aes-128-ofb
aes-128-xts
aes-192-cbc
aes-192-ccm
aes-192-cfb
aes-192-cfb1
aes-192-cfb8
aes-192-ctr
aes-192-ecb
aes-192-gcm
aes-192-ocb
aes-192-ofb
aes-256-cbc
aes-256-cbc-hmac-sha1
aes-256-cbc-hmac-sha256
aes-256-ccm
aes-256-cfb
aes-256-cfb1
aes-256-cfb8
aes-256-ctr
aes-256-ecb
aes-256-gcm
aes-256-ocb
aes-256-ofb
aes-256-xts
aes128
aes128-wrap
aes192
aes192-wrap
aes256
aes256-wrap
aria-128-cbc
aria-128-ccm
aria-128-cfb
aria-128-cfb1
aria-128-cfb8
aria-128-ctr
aria-128-ecb
aria-128-gcm
aria-128-ofb
aria-192-cbc
aria-192-ccm
aria-192-cfb
aria-192-cfb1
aria-192-cfb8
aria-192-ctr
aria-192-ecb
aria-192-gcm
aria-192-ofb
aria-256-cbc
aria-256-ccm
aria-256-cfb
aria-256-cfb1
aria-256-cfb8
aria-256-ctr
aria-256-ecb
aria-256-gcm
aria-256-ofb
aria128
aria192
aria256
bf
bf-cbc
bf-cfb
bf-ecb
bf-ofb
blowfish
camellia-128-cbc
camellia-128-cfb
camellia-128-cfb1
camellia-128-cfb8
camellia-128-ctr
camellia-128-ecb
camellia-128-ofb
camellia-192-cbc
camellia-192-cfb
camellia-192-cfb1
camellia-192-cfb8
camellia-192-ctr
camellia-192-ecb
camellia-192-ofb
camellia-256-cbc
camellia-256-cfb
camellia-256-cfb1
camellia-256-cfb8
camellia-256-ctr
camellia-256-ecb
camellia-256-ofb
camellia128
camellia192
camellia256
cast
cast-cbc
cast5-cbc
cast5-cfb
cast5-ecb
cast5-ofb
chacha20
chacha20-poly1305
des
des-cbc
des-cfb
des-cfb1
des-cfb8
des-ecb
des-ede
des-ede-cbc
des-ede-cfb
des-ede-ecb
des-ede-ofb
des-ede3
des-ede3-cbc
des-ede3-cfb
des-ede3-cfb1
des-ede3-cfb8
des-ede3-ecb
des-ede3-ofb
des-ofb
des3
des3-wrap
desx
desx-cbc
id-aes128-CCM
id-aes128-GCM
id-aes128-wrap
id-aes128-wrap-pad
id-aes192-CCM
id-aes192-GCM
id-aes192-wrap
id-aes192-wrap-pad
id-aes256-CCM
id-aes256-GCM
id-aes256-wrap
id-aes256-wrap-pad
id-smime-alg-CMS3DESwrap
idea
idea-cbc
idea-cfb
idea-ecb
idea-ofb
rc2
rc2-128
rc2-40
rc2-40-cbc
rc2-64
rc2-64-cbc
rc2-cbc
rc2-cfb
rc2-ecb
rc2-ofb
rc4
rc4-40
rc4-hmac-md5
seed
seed-cbc
seed-cfb
seed-ecb
seed-ofb
sm4
sm4-cbc
sm4-cfb
sm4-ctr
sm4-ecb
sm4-ofb
*/
