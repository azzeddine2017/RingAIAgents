load "openssllib.ring"
load "G:/RingAIAgents/src/security/Base64.ring"
load "G:/RingAIAgents/src/security/config/SecurityConfig.ring"

/*
Class: EncryptionManager
Description: مدير التشفير
*/
class EncryptionManager {

    func init {
        oConfig = new SecurityConfig

        # تحميل إعدادات التشفير من التكوين
        this.cAlgorithm = oConfig.cEncryptionAlgorithm
        this.nKeyLength = oConfig.nKeyLength
        this.nIVLength = oConfig.nIVLength

        # التحقق من دعم الخوارزمية
        aSupportedCiphers = supportedCiphers()
        if not find(aSupportedCiphers, this.cAlgorithm) {
            raise("Unsupported encryption algorithm: " + this.cAlgorithm)
        }
    }

    # تشفير البيانات
    func encrypte cData, cKey, cIV {
        try {
            return encrypt(cData, cKey, cIV, this.cAlgorithm)
        catch
            raise("خطأ في التشفير: " + cCatchError)
        }
    }

    # تشفير البيانات باستخدام خوارزمية محددة
    func encryptWithAlgorithm cData, cKey, cIV, cCipherAlgorithm {
        try {
            # التحقق من دعم الخوارزمية
            aSupportedCiphers = supportedCiphers()
            if not find(aSupportedCiphers, cCipherAlgorithm) {
                raise("Unsupported encryption algorithm: " + cCipherAlgorithm)
            }
            # تشفير البيانات
            return encrypt(cData, cKey, cIV, cCipherAlgorithm)
        catch
            raise("خطأ في التشفير: " + cCatchError)
        }
    }

    # فك تشفير البيانات
    func decrypte cEncryptedData, cKey, cIV {
        try {
            # فك تشفير البيانات
            return decrypt(cEncryptedData, cKey, cIV, this.cAlgorithm)
        catch
            raise("خطأ في فك التشفير: " + cCatchError)
        }
    }

    # فك تشفير البيانات باستخدام خوارزمية محددة
    func decryptWithAlgorithm cEncryptedData, cKey, cIV, cCipherAlgorithm {
        try {
            # التحقق من دعم الخوارزمية
            aSupportedCiphers = supportedCiphers()
            if not find(aSupportedCiphers, cCipherAlgorithm) {
                raise("Unsupported encryption algorithm: " + cCipherAlgorithm)
            }
            # فك تشفير البيانات
            return decrypt(cEncryptedData, cKey, cIV, cCipherAlgorithm)
        catch
            raise("خطأ في فك التشفير: " + cCatchError)
        }
    }

    # توليد مفتاح عشوائي
    func generateKey nLength {
        if nLength <= 0 {
            nLength = this.nKeyLength
        }

        return randbytes(nLength)
    }

    # توليد vector تهيئة عشوائي
    func generateIV nLength {
        if nLength <= 0 {
            nLength = this.nIVLength
        }

        return randbytes(nLength)
    }

    # الحصول على قائمة الخوارزميات المدعومة
    func getSupportedAlgorithms {
        return supportedCiphers()
    }

    # حساب تجزئة MD5 للملف
    func calculateMD5File cFilePath {
        try {
            # قراءة محتوى الملف
            cFileContent = Read(cFilePath)

            # التحقق من قراءة الملف
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }

            #  حساب التجزئة
            return md5(cFileContent)
        catch
            return ""
        }
    }

    # حساب تجزئة SHA1 للملف
    func calculateSHA1File cFilePath {
        try {
            cFileContent = Read(cFilePath)
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }
            return sha1(cFileContent)
        catch
            return ""
        }
    }

    # حساب تجزئة SHA256 للملف
    func calculateSHA256File cFilePath {
        try {
            cFileContent = Read(cFilePath)
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }
            return sha256(cFileContent)
        catch
            return ""
        }
    }

    # حساب تجزئة SHA512 للملف
    func calculateSHA512File cFilePath {
        try {
            cFileContent = Read(cFilePath)
            if cFileContent = "" {
                raise("Failed to read file: " + cFilePath)
            }
            return sha512(cFileContent)
        catch
            return ""
        }
    }

    # توليد زوج مفاتيح RSA
    func generateRSAKeyPair nBits {
        try {
            # توليد زوج مفاتيح RSA
            rsaKey = rsa_generate(nBits)

            # استخراج معلمات المفتاح
            rsaKeyParams = rsa_export_params(rsaKey)

            # إنشاء المفتاح العام
            rsaPublicKeyParam = [:n = rsaKeyParams[:n], :e = rsaKeyParams[:e]]
            rsaPublicKey = rsa_import_params(rsaPublicKeyParam)

            # تصدير المفاتيح بتنسيق PEM
            cPrivateKeyPEM = rsa_export_pem(rsaKey)
            cPublicKeyPEM = rsa_export_pem(rsaPublicKey)

            return [
                :private_key = cPrivateKeyPEM,
                :public_key = cPublicKeyPEM
            ]
        catch
            raise("خطأ في توليد زوج مفاتيح RSA: " + cCatchError)
        }
    }

    # تشفير البيانات باستخدام RSA
    func encryptRSA cData, cPublicKeyPEM {
        try {
            # استيراد المفتاح العام
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # تشفير البيانات
            return rsa_encrypt_pkcs(rsaPublicKey, cData)
        catch
            raise("خطأ في تشفير البيانات باستخدام RSA: " + cCatchError)
        }
    }

    # فك تشفير البيانات باستخدام RSA
    func decryptRSA cEncryptedData, cPrivateKeyPEM {
        try {
            # استيراد المفتاح الخاص
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # التحقق من أن المفتاح هو مفتاح خاص
            if not rsa_is_privatekey(rsaKey) {
                raise("المفتاح المقدم ليس مفتاحًا خاصًا")
            }

            # فك تشفير البيانات
            return rsa_decrypt_pkcs(rsaKey, cEncryptedData)
        catch
            raise("خطأ في فك تشفير البيانات باستخدام RSA: " + cCatchError)
        }
    }

    # توقيع البيانات باستخدام RSA
    func signRSA cData, cPrivateKeyPEM {
        try {
            # استيراد المفتاح الخاص
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # التحقق من أن المفتاح هو مفتاح خاص
            if not rsa_is_privatekey(rsaKey) {
                raise("المفتاح المقدم ليس مفتاحًا خاصًا")
            }

            # حساب تجزئة البيانات
            cHash = SHA256(cData)

            # توقيع التجزئة
            return rsa_signhash_pkcs(rsaKey, cHash)
        catch
            raise("خطأ في توقيع البيانات باستخدام RSA: " + cCatchError)
        }
    }

    # التحقق من توقيع البيانات باستخدام RSA
    func verifyRSA cData, cSignature, cPublicKeyPEM {
        try {
            # استيراد المفتاح العام
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # حساب تجزئة البيانات
            cHash = SHA256(cData)

            # التحقق من التوقيع
            return rsa_verifyhash_pkcs(rsaPublicKey, cHash, cSignature)
        catch
            raise("خطأ في التحقق من توقيع البيانات باستخدام RSA: " + cCatchError)
        }
    }

    # تشفير ملف باستخدام AES ثم تشفير مفتاح AES باستخدام RSA
    func encryptFile cFilePath, cOutputPath, cPublicKeyPEM {
        try {
            # استيراد المفتاح العام
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # قراءة محتوى الملف
            cData = read(cFilePath)

            # توليد مفتاح AES-256 عشوائي
            cKey = randbytes(32)
            cIV = randbytes(16)

            # تشفير البيانات باستخدام AES-256
            cEncryptedData = encrypt(cData, cKey, cIV, "aes256")

            # تشفير مفتاح AES باستخدام RSA
            cEncryptedKey = rsa_encrypt_pkcs(rsaPublicKey, cKey)

            # حساب طول المفتاح المشفر
            nKeyLength = len(cEncryptedKey)

            # تخزين IV وطول المفتاح المشفر والمفتاح المشفر والبيانات المشفرة في ملف
            write(cOutputPath, cIV + char(nKeyLength) + cEncryptedKey + cEncryptedData)

            return true
        catch
            raise("خطأ في تشفير الملف: " + cCatchError)
        }
    }

    # فك تشفير ملف مشفر باستخدام AES و RSA
    func decryptFile cEncryptedFilePath, cOutputPath, cPrivateKeyPEM {
        try {
            # استيراد المفتاح الخاص
            rsaKey = rsa_import_pem(cPrivateKeyPEM)
            
            # التحقق من أن المفتاح هو مفتاح خاص
            if not rsa_is_privatekey(rsaKey) {
                raise("المفتاح المقدم ليس مفتاحًا خاصًا")
            }

            # قراءة محتوى الملف المشفر
            cEncryptedContent = read(cEncryptedFilePath)

            # استخراج IV (أول 16 بايت)
            cIV = substr(cEncryptedContent, 1, 16)

            # استخراج طول المفتاح المشفر (البايت التالي)
            rsaKeyParams = rsa_export_params(rsaKey)
            nKeyLength = rsaKeyParams[:bits]/ 8
            # استخراج المفتاح المشفر
            cEncryptedKey = substr(cEncryptedContent, 18, nKeyLength)

            # استخراج البيانات المشفرة
            cEncryptedData = substr(cEncryptedContent, 18 + nKeyLength)

            # فك تشفير مفتاح AES باستخدام RSA
            cKey = rsa_decrypt_pkcs(rsaKey, cEncryptedKey)

            # فك تشفير البيانات باستخدام AES
            cPlainData = decrypt(cEncryptedData, cKey, cIV, "aes256")

            # كتابة البيانات المفكوكة إلى ملف
            write(cOutputPath, cPlainData)

            return true
        catch
            raise("خطأ في فك تشفير الملف: " + cCatchError)
        }
    }

    # تشفير ملف كبير باستخدام AES ثم تشفير مفتاح AES باستخدام RSA
    func encryptLargeFile cFilePath, cOutputPath, cPublicKeyPEM {
        try {
            # استيراد المفتاح العام
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # توليد مفتاح AES-256 عشوائي
            cKey = randbytes(32)
            cIV = randbytes(16)

            # تشفير مفتاح AES باستخدام RSA
            cEncryptedKey = rsa_encrypt_pkcs(rsaPublicKey, cKey)

            # حساب طول المفتاح المشفر
            nKeyLength = len(cEncryptedKey)

            # فتح الملف المصدر للقراءة
            fpSource = fopen(cFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open source file: " + cFilePath)
            }

            # فتح الملف الهدف للكتابة
            fpDest = fopen(cOutputPath, "wb")
            if fpDest = 0 {
                fclose(fpSource)
                raise("Failed to open destination file: " + cOutputPath)
            }

            # كتابة IV وطول المفتاح المشفر والمفتاح المشفر إلى الملف الهدف
            fwrite(fpDest, cIV + char(nKeyLength) + cEncryptedKey)

            # قراءة الملف المصدر وتشفيره على دفعات
            nChunkSize = 8192  # 8 كيلوبايت
            while true {
                cChunk = fread(fpSource, nChunkSize)
                if len(cChunk) = 0 {
                    exit
                }

                # تشفير الدفعة
                cEncryptedChunk = encrypt(cChunk, cKey, cIV, "aes256")

                # كتابة طول الدفعة المشفرة والدفعة المشفرة إلى الملف الهدف
                nChunkLength = len(cEncryptedChunk)
                fwrite(fpDest, char(nChunkLength / 256) + char(nChunkLength % 256) + cEncryptedChunk)
            }

            # إغلاق الملفات
            fclose(fpSource)
            fclose(fpDest)

            return true
        catch
            # إغلاق الملفات في حالة حدوث خطأ
            if fpSource != NULL {
                fclose(fpSource)
            }
            if fpDest != NULL {
                fclose(fpDest)
            }

            raise("خطأ في تشفير الملف الكبير: " + cCatchError)
        }
    }

    # فك تشفير ملف كبير مشفر باستخدام AES و RSA
    func decryptLargeFile cEncryptedFilePath, cOutputPath, cPrivateKeyPEM {
        try {
            # استيراد المفتاح الخاص
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # التحقق من أن المفتاح هو مفتاح خاص
            if not rsa_is_privatekey(rsaKey) {
                raise("المفتاح المقدم ليس مفتاحًا خاصًا")
            }

            # فتح الملف المشفر للقراءة
            fpSource = fopen(cEncryptedFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open encrypted file: " + cEncryptedFilePath)
            }

            # قراءة IV (أول 16 بايت)
            cIV = fread(fpSource, 16)

            # قراءة طول المفتاح المشفر (البايت التالي)
            nKeyLength = ascii(fread(fpSource, 1))

            # قراءة المفتاح المشفر
            cEncryptedKey = fread(fpSource, nKeyLength)

            # فك تشفير مفتاح AES باستخدام RSA
            cKey = rsa_decrypt_pkcs(rsaKey, cEncryptedKey)

            # فتح الملف الهدف للكتابة
            fpDest = fopen(cOutputPath, "wb")
            if fpDest = 0 {
                fclose(fpSource)
                raise("Failed to open destination file: " + cOutputPath)
            }

            # قراءة وفك تشفير الدفعات
            while true {
                # قراءة طول الدفعة المشفرة (2 بايت)
                cChunkLengthBytes = fread(fpSource, 2)
                if len(cChunkLengthBytes) < 2 {
                    exit  # نهاية الملف
                }

                nChunkLength = ascii(cChunkLengthBytes[1]) * 256 + ascii(cChunkLengthBytes[2])

                # قراءة الدفعة المشفرة
                cEncryptedChunk = fread(fpSource, nChunkLength)
                if len(cEncryptedChunk) < nChunkLength {
                    raise("Unexpected end of file")
                }

                # فك تشفير الدفعة
                cPlainChunk = decrypt(cEncryptedChunk, cKey, cIV, "aes256")

                # كتابة الدفعة المفكوكة إلى الملف الهدف
                fwrite(fpDest, cPlainChunk)
            }

            # إغلاق الملفات
            fclose(fpSource)
            fclose(fpDest)

            return true
        catch
            # إغلاق الملفات في حالة حدوث خطأ
            if fpSource != NULL {
                fclose(fpSource)
            }
            if fpDest != NULL {
                fclose(fpDest)
            }

            raise("خطأ في فك تشفير الملف الكبير: " + cCatchError)
        }
    }

    # توقيع ملف باستخدام RSA
    func signFile cFilePath, cSignatureFilePath, cPrivateKeyPEM {
        try {
            # استيراد المفتاح الخاص
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # التحقق من أن المفتاح هو مفتاح خاص
            if not rsa_is_privatekey(rsaKey) {
                raise("المفتاح المقدم ليس مفتاحًا خاصًا")
            }

           # حساب تجزئة SHA256 للملف
            cDigest = calculateSHA256File(cFilePath)

            # توقيع التجزئة باستخدام RSA-PKCS
            cSignature = rsa_signhash_pkcs(rsaKey, cDigest)

            # كتابة التوقيع إلى ملف
            write(cSignatureFilePath, cSignature)

            return true
        catch
            raise("خطأ في توقيع الملف: " + cCatchError)
        }
    }

    # التحقق من توقيع ملف باستخدام RSA
    func verifyFileSignature cFilePath, cSignatureFilePath, cPublicKeyPEM {
        try {
            # استيراد المفتاح العام
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # حساب تجزئة SHA256 للملف
            cDigest = calculateSHA256File(cFilePath)

            # قراءة التوقيع من الملف
            cSignature = read(cSignatureFilePath)

            # التحقق من التوقيع باستخدام RSA-PKCS
            return rsa_verifyhash_pkcs(rsaPublicKey, cDigest, cSignature)
        catch
            raise("خطأ في التحقق من توقيع الملف: " + cCatchError)
        }
    }

    # توقيع ملف كبير باستخدام RSA
    func signLargeFile cFilePath, cSignatureFilePath, cPrivateKeyPEM {
        try {
            # استيراد المفتاح الخاص
            rsaKey = rsa_import_pem(cPrivateKeyPEM)

            # التحقق من أن المفتاح هو مفتاح خاص
            if not rsa_is_privatekey(rsaKey) {
                raise("المفتاح المقدم ليس مفتاحًا خاصًا")
            }

            # فتح الملف للقراءة
            fpSource = fopen(cFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open file: " + cFilePath)
            }

            # تهيئة سياق SHA256
            ctx = sha256init()

            # قراءة الملف على دفعات وتحديث سياق التجزئة
            nChunkSize = 8192  # 8 كيلوبايت
            while true {
                cChunk = fread(fpSource, nChunkSize)
                if len(cChunk) = 0 {
                    exit
                }

                sha256update(ctx, cChunk)
            }

            # إغلاق الملف
            fclose(fpSource)

            # إنهاء حساب التجزئة
            cDigest = sha256final(ctx)

            # توقيع التجزئة باستخدام RSA-PKCS
            cSignature = rsa_signhash_pkcs(rsaKey, cDigest)

            # كتابة التوقيع إلى ملف
            write(cSignatureFilePath, cSignature)

            return true
        catch
            # إغلاق الملف في حالة حدوث خطأ
            if fpSource != NULL {
                fclose(fpSource)
            }

            raise("خطأ في توقيع الملف الكبير: " + cCatchError)
        }
    }

    # التحقق من توقيع ملف كبير باستخدام RSA
    func verifyLargeFileSignature cFilePath, cSignatureFilePath, cPublicKeyPEM {
        try {
            # استيراد المفتاح العام
            rsaPublicKey = rsa_import_pem(cPublicKeyPEM)

            # فتح الملف للقراءة
            fpSource = fopen(cFilePath, "rb")
            if fpSource = 0 {
                raise("Failed to open file: " + cFilePath)
            }

            # تهيئة سياق SHA256
            ctx = sha256init()

            # قراءة الملف على دفعات وتحديث سياق التجزئة
            nChunkSize = 8192  # 8 كيلوبايت
            while true {
                cChunk = fread(fpSource, nChunkSize)
                if len(cChunk) = 0 {
                    exit
                }

                sha256update(ctx, cChunk)
            }

            # إغلاق الملف
            fclose(fpSource)

            # إنهاء حساب التجزئة
            cDigest = sha256final(ctx)

            # قراءة التوقيع من الملف
            cSignature = read(cSignatureFilePath)

            # التحقق من التوقيع باستخدام RSA-PKCS
            return rsa_verifyhash_pkcs(rsaPublicKey, cDigest, cSignature)
        catch
            # إغلاق الملف في حالة حدوث خطأ
            if fpSource != NULL {
                fclose(fpSource)
            }

            raise("خطأ في التحقق من توقيع الملف الكبير: " + cCatchError)
        }
    }

    # Helper function for generating random strings
    func random_string nLength
        cResult = ""
        for i = 1 to nLength {
            cResult += char(random(26) + 97)
        }
        return cResult
    
    private

    oConfig
    cAlgorithm
    nKeyLength
    nIVLength
}
