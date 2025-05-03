# أدوات الوكلاء الذكية

هذا الملف يوثق الأدوات المتاحة في مكتبة RingAIAgents وكيفية استخدامها.

## أدوات الويب

### 1. البحث في الويب (web_search)
البحث في الإنترنت باستخدام محرك DuckDuckGo
```ring
executeTool("web_search", [
    :query = "Ring Programming Language"
])
```

### 2. تحميل ملف (download_file)
تحميل ملف من الإنترنت
```ring
executeTool("download_file", [
    :url = "https://example.com/file.pdf",
    :destination = "downloads/file.pdf"
])
```

### 3. قراءة صفحة ويب (read_webpage)
قراءة محتوى صفحة ويب
```ring
executeTool("read_webpage", [
    :url = "https://example.com"
])
```

## أدوات نظام الملفات

### 1. قراءة ملف (read_file)
قراءة محتوى ملف
```ring
executeTool("read_file", {
    :path = "data/example.txt"
})
```

### 2. كتابة ملف (write_file)
كتابة محتوى إلى ملف
```ring
executeTool("write_file", {
    :path = "data/output.txt",
    :content = "Hello, World!"
})
```

### 3. قائمة المجلد (list_directory)
عرض محتويات مجلد
```ring
executeTool("list_directory", {
    :path = "data/"
})
```

### 4. ضغط الملفات (zip_files)
ضغط مجموعة من الملفات
```ring
executeTool("zip_files", {
    :zipfile = "archive.zip",
    :files = ["file1.txt", "file2.txt"]
})
```

## أدوات معالجة البيانات

### 1. تحليل JSON (parse_json)
تحويل نص JSON إلى قائمة
```ring
executeTool("parse_json", {
    :json = '{"name": "Ring", "type": "Language"}'
})
```

### 2. تحويل CSV إلى JSON (csv_to_json)
تحويل ملف CSV إلى تنسيق JSON
```ring
executeTool("csv_to_json", {
    :csv_file = "data/input.csv"
})
```

## أدوات معالجة الصور

### 1. تغيير حجم الصورة (resize_image)
تغيير أبعاد الصورة
```ring
executeTool("resize_image", {
    :image = "images/photo.jpg",
    :width = 800,
    :height = 600
})
```

### 2. استخراج النص (extract_text)
استخراج النص من الصور
```ring
executeTool("extract_text", {
    :image = "images/document.png"
})
```

## أدوات النظام

### 1. معلومات النظام (get_system_info)
الحصول على معلومات النظام
```ring
executeTool("get_system_info", {})
```

### 2. تنفيذ أمر (execute_command)
تنفيذ أمر نظام
```ring
executeTool("execute_command", {
    :command = "dir"
})
```

## أدوات الأمان

### 1. تشفير النص (encrypt_text)
تشفير نص باستخدام مفتاح
```ring
executeTool("encrypt_text", {
    :text = "سري للغاية",
    :key = "مفتاح_التشفير"
})
```

### 2. توليد التجزئة (hash_text)
توليد تجزئة للنص
```ring
executeTool("hash_text", {
    :text = "نص للتجزئة",
    :algorithm = "sha256"
})
```

## أدوات الشبكة

### 1. فحص المضيف (ping_host)
اختبار الاتصال بمضيف
```ring
executeTool("ping_host", {
    :host = "example.com"
})
```

### 2. فحص DNS (dns_lookup)
البحث عن معلومات DNS
```ring
executeTool("dns_lookup", {
    :domain = "example.com"
})
```

## أدوات الذكاء الاصطناعي ومعالجة اللغات

### 1. تحليل المشاعر (sentiment_analysis)
تحليل مشاعر النص
```ring
executeTool("sentiment_analysis", {
    :text = "هذا منتج رائع وأنا سعيد جداً به"
})
```

### 2. تصنيف النص (text_classification)
تصنيف النص إلى فئات
```ring
executeTool("text_classification", {
    :text = "آخر أخبار كرة القدم",
    :categories = ["رياضة", "سياسة", "تكنولوجيا"]
})
```

### 3. استخراج الكيانات (named_entity_recognition)
استخراج الأسماء والمنظمات والمواقع من النص
```ring
executeTool("extract_entities", {
    :text = "زار محمد شركة جوجل في مدينة نيويورك"
})
```

## أدوات معالجة الصوت

### 1. تحويل الكلام إلى نص (speech_to_text)
تحويل ملف صوتي إلى نص
```ring
executeTool("speech_to_text", {
    :audio_file = "audio/recording.wav"
})
```

### 2. تحويل النص إلى كلام (text_to_speech)
تحويل النص إلى ملف صوتي
```ring
executeTool("text_to_speech", {
    :text = "مرحباً بكم في مكتبة Ring",
    :output_file = "audio/output.mp3"
})
```

## أدوات معالجة الفيديو

### 1. تحويل صيغ الفيديو (video_transcoding)
تحويل الفيديو إلى صيغة أخرى
```ring
executeTool("video_transcoding", {
    :input_file = "video/input.mp4",
    :output_file = "video/output.avi",
    :format = "h264"
})
```

### 2. توليد صورة مصغرة (video_thumbnail)
إنشاء صورة مصغرة من الفيديو
```ring
executeTool("generate_thumbnail", {
    :video_file = "video/movie.mp4",
    :output_file = "images/thumbnail.jpg",
    :time = 10
})
```

## أدوات قواعد البيانات

### 1. تنفيذ استعلام SQL (sql_query)
تنفيذ استعلام SQL على قاعدة البيانات
```ring
executeTool("sql_query", {
    :database = "data/mydb.sqlite",
    :query = "SELECT * FROM users"
})
```

### 2. نسخ احتياطي (database_backup)
إنشاء نسخة احتياطية من قاعدة البيانات
```ring
executeTool("database_backup", {
    :database = "data/mydb.sqlite",
    :backup_file = "backup/mydb_backup.sqlite"
})
```

## أدوات تحليل البيانات

### 1. تحليل إحصائي (statistical_analysis)
إجراء تحليل إحصائي للبيانات
```ring
executeTool("analyze_statistics", {
    :data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
})
```

### 2. تحليل السلاسل الزمنية (time_series_analysis)
تحليل البيانات عبر الزمن
```ring
executeTool("analyze_time_series", {
    :data = [
        {:date = "2025-01-01", :value = 100},
        {:date = "2025-01-02", :value = 105}
    ]
})
```

## أدوات استخراج البيانات من الويب

### 1. زاحف الويب (web_crawler)
جمع البيانات من المواقع
```ring
executeTool("crawl_website", {
    :url = "https://example.com",
    :depth = 2
})
```

### 2. محلل HTML (html_parser)
تحليل محتوى HTML
```ring
executeTool("parse_html", {
    :content = "<html><body>مرحباً</body></html>"
})
```

## أدوات البريد الإلكتروني

### 1. إرسال بريد (send_email)
إرسال رسالة بريد إلكتروني
```ring
executeTool("send_email", {
    :to = "example@example.com",
    :subject = "مرحباً",
    :body = "محتوى الرسالة"
})
```

### 2. تحليل البريد (email_analysis)
تحليل محتوى البريد الإلكتروني
```ring
executeTool("analyze_email", {
    :email = "content of email"
})
```

## أدوات جغرافية

### 1. تحويل العنوان إلى إحداثيات (geocoding)
تحويل العنوان النصي إلى إحداثيات
```ring
executeTool("geocode_address", {
    :address = "القاهرة، مصر",
    :api_key = "your_api_key"
})
```

### 2. حساب المسافات (distance_calculation)
حساب المسافة بين نقطتين
```ring
executeTool("calculate_distance", {
    :point1 = {:lat = 30.0444, :lng = 31.2357},
    :point2 = {:lat = 25.2048, :lng = 55.2708}
})
```

## أدوات مالية

### 1. تحويل العملات (currency_conversion)
تحويل بين العملات المختلفة
```ring
executeTool("convert_currency", {
    :from = "USD",
    :to = "EUR",
    :amount = 100
})
```

### 2. تحليل الأسهم (stock_analysis)
تحليل بيانات الأسهم
```ring
executeTool("analyze_stock", {
    :symbol = "AAPL",
    :period = "1y"
})
```

## ملاحظات مهمة

1. تأكد من توفر الصلاحيات المناسبة قبل استخدام الأدوات
2. بعض الأدوات تتطلب برامج إضافية مثل ImageMagick لمعالجة الصور
3. يمكن إضافة أدوات جديدة باستخدام دالة registerTool
4. جميع الأدوات تعيد null في حالة الفشل

## ملاحظات إضافية

1. بعض الأدوات تتطلب مفاتيح API خارجية
2. تأكد من تثبيت المكتبات الإضافية المطلوبة
3. بعض الأدوات قد تكون بطيئة مع البيانات الكبيرة
4. راجع التوثيق الخاص بكل أداة للحصول على المزيد من المعلومات

## أمثلة إضافية

### سلسلة معالجة ملف
```ring
# تحميل ملف من الإنترنت
executeTool("download_file", {
    :url = "https://example.com/data.csv",
    :destination = "data/input.csv"
})

# تحويله إلى JSON
executeTool("csv_to_json", {
    :csv_file = "data/input.csv"
})

# حفظ النتيجة
executeTool("write_file", {
    :path = "data/output.json",
    :content = oResult
})
```

### معالجة صورة وتحليل محتواها
```ring
# تحميل صورة
executeTool("download_file", {
    :url = "https://example.com/document.jpg",
    :destination = "images/doc.jpg"
})

# تغيير حجمها
executeTool("resize_image", {
    :image = "images/doc.jpg",
    :width = 1200,
    :height = 1600
})

# استخراج النص
cText = executeTool("extract_text", {
    :image = "images/doc.jpg"
})

# حفظ النص
executeTool("write_file", {
    :path = "output/text.txt",
    :content = cText
})
```

### تحليل محتوى متكامل
```ring
# تحليل نص من صورة
cText = executeTool("extract_text", {
    :image = "document.jpg"
})

# تحليل المشاعر
oSentiment = executeTool("sentiment_analysis", {
    :text = cText
})

# استخراج الكيانات
oEntities = executeTool("extract_entities", {
    :text = cText
})

# حفظ النتائج
executeTool("write_file", {
    :path = "analysis_results.json",
    :content = List2JSON({
        :text = cText,
        :sentiment = oSentiment,
        :entities = oEntities
    })
})
```

### معالجة فيديو متقدمة
```ring
# تحويل صيغة الفيديو
executeTool("video_transcoding", {
    :input_file = "input.mp4",
    :output_file = "output.mp4",
    :format = "h264"
})

# إنشاء صور مصغرة
executeTool("generate_thumbnail", {
    :video_file = "output.mp4",
    :output_file = "thumbnail.jpg",
    :time = 5
})

# استخراج النص من الصورة المصغرة
cText = executeTool("extract_text", {
    :image = "thumbnail.jpg"
})

# تحليل النص
oAnalysis = executeTool("text_classification", {
    :text = cText,
    :categories = ["فيلم", "موسيقى", "رياضة"]
})
```
