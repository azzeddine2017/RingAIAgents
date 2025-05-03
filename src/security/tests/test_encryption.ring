load "G:\RingAIAgents\src\security\EncryptionManager.ring"


/*
    اختبار وظائف التشفير والتوقيع
*/
func main {
    ? "=== اختبار وظائف التشفير والتوقيع ==="
    
    # اختبار التشفير وفك التشفير باستخدام AES
    testAESEncryption()
    
    # اختبار توليد مفاتيح RSA
    testRSAKeyGeneration()
    
    # اختبار التشفير وفك التشفير باستخدام RSA
    testRSAEncryption()
    
    # اختبار توقيع البيانات والتحقق من التوقيع باستخدام RSA
    testRSASignature()
    
    # اختبار تشفير الملفات وفك تشفيرها
    testFileEncryption()
    
    # اختبار توقيع الملفات والتحقق من التوقيع
    testFileSignature()
    
    ? "=== تم اكتمال الاختبارات بنجاح ==="
}

# اختبار التشفير وفك التشفير باستخدام AES
func testAESEncryption {
    ? "اختبار التشفير وفك التشفير باستخدام AES..."
    
    oEncryption = new EncryptionManager()
    
    # توليد مفتاح وvector تهيئة
    cKey = oEncryption.generateKey(32)
    cIV = oEncryption.generateIV(16)
    
    assert(len(cKey) = 32, "اختبار توليد مفتاح AES")
    assert(len(cIV) = 16, "اختبار توليد vector تهيئة")
    
    # اختبار التشفير وفك التشفير
    cData = "بيانات سرية للاختبار"
    cEncrypted = oEncryption.encrypte(cData, cKey, cIV)
    cDecrypted = oEncryption.decrypte(cEncrypted, cKey, cIV)
    
    assert(cDecrypted = cData, "اختبار التشفير وفك التشفير باستخدام AES")
    
    ? "  تم اختبار التشفير وفك التشفير باستخدام AES بنجاح"
}

# اختبار توليد مفاتيح RSA
func testRSAKeyGeneration {
    ? "اختبار توليد مفاتيح RSA..."
    
    oEncryption = new EncryptionManager
    
    # توليد زوج مفاتيح RSA
    aKeyPair = oEncryption.generateRSAKeyPair(2048)
    
    assert(len(aKeyPair[:private_key]) > 0, "اختبار توليد المفتاح الخاص")
    assert(len(aKeyPair[:public_key]) > 0, "اختبار توليد المفتاح العام")
    
    # حفظ المفاتيح في ملفات مؤقتة للاختبارات اللاحقة
    write("temp_private_key.pem", aKeyPair[:private_key])
    write("temp_public_key.pem", aKeyPair[:public_key])
    
    ? "  تم اختبار توليد مفاتيح RSA بنجاح"
}

# اختبار التشفير وفك التشفير باستخدام RSA
func testRSAEncryption {
    ? "اختبار التشفير وفك التشفير باستخدام RSA..."
    
    oEncryption = new EncryptionManager
    
    # قراءة المفاتيح من الملفات المؤقتة
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # اختبار التشفير وفك التشفير
    cData = "بيانات سرية للاختبار باستخدام RSA"
    cEncrypted = oEncryption.encryptRSA(cData, cPublicKeyPEM)
    cDecrypted = oEncryption.decryptRSA(cEncrypted, cPrivateKeyPEM)
    
    assert(cDecrypted = cData, "اختبار التشفير وفك التشفير باستخدام RSA")
    
    ? "  تم اختبار التشفير وفك التشفير باستخدام RSA بنجاح"
}

# اختبار توقيع البيانات والتحقق من التوقيع باستخدام RSA
func testRSASignature {
    ? "اختبار توقيع البيانات والتحقق من التوقيع باستخدام RSA..."
    
    oEncryption = new EncryptionManager
    
    # قراءة المفاتيح من الملفات المؤقتة
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # اختبار التوقيع والتحقق من التوقيع
    cData = "بيانات للتوقيع باستخدام RSA"
    cSignature = oEncryption.signRSA(cData, cPrivateKeyPEM)
    bVerified = oEncryption.verifyRSA(cData, cSignature, cPublicKeyPEM)
    
    assert(bVerified, "اختبار التوقيع والتحقق من التوقيع باستخدام RSA")
    
    # اختبار التحقق من توقيع بيانات مختلفة
    cModifiedData = cData + " (تم تعديلها)"
    bVerified = oEncryption.verifyRSA(cModifiedData, cSignature, cPublicKeyPEM)
    
    assert(not bVerified, "اختبار التحقق من توقيع بيانات مختلفة")
    
    ? "  تم اختبار توقيع البيانات والتحقق من التوقيع باستخدام RSA بنجاح"
}

# اختبار تشفير الملفات وفك تشفيرها
func testFileEncryption {
    ? "اختبار تشفير الملفات وفك تشفيرها..."
    
    oEncryption = new EncryptionManager
    
    # قراءة المفاتيح من الملفات المؤقتة
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # إنشاء ملف اختبار
    cTestData = "هذا ملف اختبار لتشفير الملفات وفك تشفيرها باستخدام AES و RSA."
    write("test_file.txt", cTestData)
    
    # تشفير الملف
    oEncryption.encryptFile("test_file.txt", "test_file.enc", cPublicKeyPEM)
    
    # فك تشفير الملف
    oEncryption.decryptFile("test_file.enc", "test_file_decrypted.txt", cPrivateKeyPEM)
    
    # التحقق من صحة فك التشفير
    cDecryptedData = read("test_file_decrypted.txt")
    assert(cDecryptedData = cTestData, "اختبار تشفير الملفات وفك تشفيرها")
    
    ? "  تم اختبار تشفير الملفات وفك تشفيرها بنجاح"
}

# اختبار توقيع الملفات والتحقق من التوقيع
func testFileSignature {
    ? "اختبار توقيع الملفات والتحقق من التوقيع..."
    
    oEncryption = new EncryptionManager
    
    # قراءة المفاتيح من الملفات المؤقتة
    cPrivateKeyPEM = read("temp_private_key.pem")
    cPublicKeyPEM = read("temp_public_key.pem")
    
    # توقيع ملف الاختبار
    oEncryption.signFile("test_file.txt", "test_file.sig", cPrivateKeyPEM)
    
    # التحقق من توقيع الملف
    bVerified = oEncryption.verifyFileSignature("test_file.txt", "test_file.sig", cPublicKeyPEM)
    assert(bVerified, "اختبار توقيع الملفات والتحقق من التوقيع")
    
    # تعديل الملف
    cModifiedData = read("test_file.txt") + " (تم تعديله)"
    write("test_file_modified.txt", cModifiedData)
    
    # التحقق من توقيع الملف المعدل
    bVerified = oEncryption.verifyFileSignature("test_file_modified.txt", "test_file.sig", cPublicKeyPEM)
    assert(not bVerified, "اختبار التحقق من توقيع ملف معدل")
    
    ? "  تم اختبار توقيع الملفات والتحقق من التوقيع بنجاح"
    
    # تنظيف الملفات المؤقتة
    remove("temp_private_key.pem")
    remove("temp_public_key.pem")
    remove("test_file.txt")
    remove("test_file.enc")
    remove("test_file_decrypted.txt")
    remove("test_file.sig")
    remove("test_file_modified.txt")
}

# دالة مساعدة للتأكيد
func assert condition, message {
    if condition {
        ? "  ✓ " + message
    else
        ? "  ✗ " + message
        raise("فشل الاختبار: " + message)
    }
}

