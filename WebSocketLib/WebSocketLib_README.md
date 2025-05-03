# مكتبة WebSocketLib

## نظرة عامة
مكتبة WebSocketLib هي تنفيذ احترافي لبروتوكول WebSocket في لغة Ring. تم تصميمها لتوفير اتصال ثنائي الاتجاه في الوقت الحقيقي بين الخادم والعملاء.

## الميزات
- تنفيذ كامل لخادم WebSocket
- دعم للاتصالات المتزامنة المتعددة
- استخدام مجمع الثريدات (Thread Pool) للأداء الأمثل
- واجهة برمجة بسيطة وسهلة الاستخدام
- دعم الإشعارات في الوقت الحقيقي
- إمكانية البث لجميع العملاء المتصلين

## المتطلبات
- لغة Ring
- مكتبة sockets.ring
- مكتبة threads.ring
- مكتبة stdlibcore.ring

## الاستخدام الأساسي

### إنشاء خادم WebSocket
```ring
load "WebSocketLib.ring"

# تعريف دوال رد الاتصال
func handleMessage message, clientSocket {
    ? "تم استلام رسالة: " + message
    ? "من العميل: " + clientSocket
    
    # إرسال رد للعميل
    oWebSocket.send(clientSocket, "صدى: " + message)
}

func handleConnect clientSocket {
    ? "تم اتصال العميل: " + clientSocket
}

func handleDisconnect clientSocket {
    ? "تم قطع اتصال العميل: " + clientSocket
}

func handleError errorMessage {
    ? "خطأ: " + errorMessage
}

# إنشاء خادم WebSocket
oWebSocket = new WebSocket {
    port = 8082
    debug = true
    
    # تعريف دوال رد الاتصال
    onMessage = "handleMessage"
    onConnect = "handleConnect"
    onDisconnect = "handleDisconnect"
    onError = "handleError"
}

# تشغيل الخادم
oWebSocket.start()

? "تم تشغيل خادم WebSocket على المنفذ 8082"
? "اضغط Ctrl+C للخروج"

# إبقاء التطبيق قيد التشغيل
while true {
    sleep(1)
}
```

### إنشاء عميل WebSocket
```ring
load "sockets.ring"

# إنشاء سوكيت
sock = socket(AF_INET, SOCK_STREAM, 0)
if sock <= 0 {
    ? "خطأ: فشل إنشاء السوكيت"
    exit
}

# الاتصال بالخادم
if connect(sock, "127.0.0.1", 8082) < 0 {
    ? "خطأ: فشل الاتصال بالخادم"
    exit
}

? "تم الاتصال بخادم WebSocket"

# إرسال رسالة
message = "مرحباً من عميل WebSocket!"
? "إرسال: " + message
send(sock, message)

# استقبال الرد
response = recv(sock, 1024)
? "تم استلام: " + response

# إغلاق السوكيت
close(sock)
? "تم إغلاق الاتصال"
```

## الفئات الرئيسية

### WebSocket
الفئة الرئيسية التي تمثل خادم WebSocket.

#### الخصائص
- `socket`: مقبض السوكيت
- `port`: المنفذ الذي يستمع عليه الخادم
- `host`: المضيف الذي يستمع عليه الخادم
- `backlog`: عدد الاتصالات المعلقة المسموح بها
- `buffer`: حجم المخزن المؤقت للرسائل
- `onMessage`: دالة رد الاتصال عند استلام رسالة
- `onConnect`: دالة رد الاتصال عند اتصال عميل جديد
- `onDisconnect`: دالة رد الاتصال عند قطع اتصال عميل
- `onError`: دالة رد الاتصال عند حدوث خطأ
- `isRunning`: حالة تشغيل الخادم
- `clients`: قائمة العملاء المتصلين
- `debug`: وضع التصحيح

#### الدوال
- `init()`: تهيئة الخادم
- `start()`: بدء تشغيل الخادم
- `stop()`: إيقاف الخادم
- `send(clientSocket, message)`: إرسال رسالة إلى عميل محدد
- `broadcast(message)`: إرسال رسالة إلى جميع العملاء المتصلين

### WebSocketTask
فئة تمثل مهمة في مجمع الثريدات.

#### الخصائص
- `taskType`: نوع المهمة
- `clientSocket`: مقبض سوكيت العميل
- `webSocket`: مرجع إلى كائن WebSocket

#### الدوال
- `execute()`: تنفيذ المهمة

## الدوال العامة
- `WebSocketAcceptThread(oWebSocketID)`: دالة ثريد لقبول اتصالات جديدة
- `WebSocketWorkerThread(nThreadID, oWebSocketID)`: دالة ثريد للعمال في مجمع الثريدات

## المساهمة
نرحب بالمساهمات لتحسين هذه المكتبة. يرجى إرسال طلبات السحب أو فتح مشكلات للإبلاغ عن الأخطاء أو طلب ميزات جديدة.

## الترخيص
تم إصدار هذه المكتبة بموجب ترخيص MIT.
