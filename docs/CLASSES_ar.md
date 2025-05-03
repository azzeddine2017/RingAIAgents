# توثيق الكلاسات - RingAI Agents

## Agent كلاس العميل

### الخصائص
- `cId`: معرف فريد للعميل
- `cName`: اسم العميل
- `cRole`: دور العميل
- `cGoal`: هدف العميل
- `cState`: حالة العميل (IDLE, WORKING, LEARNING, COLLABORATING, ERROR)
- `cLanguageModel`: نموذج اللغة المستخدم (gemini-1.5-flash)

### الكائنات
- `oMemory`: ذاكرة العميل
- `oToolRegistry`: سجل الأدوات
- `oLLM`: نموذج اللغة
- `oCrew`: الفريق


### الحالات
- `nEmotionalState`: الحالة العاطفية (1-10)
- `nEnergyLevel`: مستوى الطاقة (0-100)
- `nConfidenceLevel`: مستوى الثقة (1-10)

### المصفوفات
- `aSkills`: المهارات
- `aPersonalityTraits`: السمات الشخصية
- `aCurrentTask`: المهمة الحالية
- `aTaskHistory`: سجل المهام
- `aCollaborators`: المتعاونون
- `aLearningHistory`: سجل التعلم
- `aObservations`: الملاحظات
- `aMetadata`: البيانات الوصفية

### الدوال الرئيسية
- `init(cAgentName, cAgentDescription)`: تهيئة العميل
- `initializeMorgen()`: تهيئة قدرات مرجان
- `processTask(oTask)`: معالجة المهام مع مرجان
- `makeDecision(xData)`: اتخاذ القرارات
- `learn(cTopic, cContent)`: التعلم
- `executeTask()`: تنفيذ المهام

## Crew كلاس الفريق

### الخصائص
- `cId`: معرف فريد للفريق
- `cName`: اسم الفريق
- `cObjective`: هدف الفريق
- `cState`: حالة الفريق (IDLE, WORKING, PLANNING, REVIEWING, ERROR)
- `POOL_SIZE`: حجم مجموعة العمل (4 threads)

### المصفوفات
- `aMembers`: أعضاء الفريق
- `aTaskQueue`: قائمة انتظار المهام
- `aCompletedTasks`: المهام المكتملة
- `aWorkingPlan`: خطة العمل
- `aConflicts`: التعارضات
- `aMessages`: الرسائل
- `aPerformance`: الأداء
- `aMetadata`: البيانات الوصفية

### الكائنات
- `oLeader`: قائد الفريق
- `oThreads`: مدير العمليات المتزامنة
- `queueMutex`: قفل قائمة الانتظار
- `resultMutex`: قفل النتائج
- `taskAvailable`: شرط توفر المهام

### الدوال الرئيسية
- `init(cCrewName, oLeaderAgent)`: تهيئة الفريق
- `addMember(oAgent)`: إضافة عضو
- `assignTask(oTask, oAgent)`: تعيين مهمة
- `recordPerformance(oAgent, cMetric, nValue)`: تسجيل الأداء
- `isMember(oAgent)`: التحقق من العضوية

## Task كلاس المهمة

### الحالات
- `PENDING`: قيد الانتظار
- `RUNNING`: قيد التنفيذ
- `COMPLETED`: مكتملة
- `FAILED`: فشلت
- `CANCELLED`: ملغاة

### الخصائص
- `cId`: معرف فريد للمهمة
- `cDescription`: وصف المهمة
- `dStartTime`: وقت البدء
- `cState`: حالة المهمة
- `nPriority`: الأولوية (1-10)
- `cContext`: السياق
- `nProgress`: نسبة التقدم (0-100)
- `nMaxRetries`: أقصى عدد للمحاولات
- `nRetryCount`: عدد المحاولات الحالية
- `cError`: رسالة الخطأ
- `dEndTime`: وقت الانتهاء

### المصفوفات
- `aSubtasks`: المهام الفرعية
- `aArtifacts`: المخرجات
- `aMetadata`: البيانات الوصفية

### الدوال الرئيسية
- `init(cTaskDescription)`: تهيئة المهمة
- `setState(cNewState)`: تغيير حالة المهمة
- `setPriority(nValue)`: تحديد الأولوية
- `setContext(cValue)`: تحديد السياق
- `addSubtask(oSubtask)`: إضافة مهمة فرعية
- `updateProgress(nValue)`: تحديث نسبة التقدم
- `updateParentProgress()`: تحديث تقدم المهمة الأصلية

## LLM كلاس نماذج اللغة

### النماذج المدعومة
- `GEMINI`: نموذج Gemini 1.5 Flash
- `GPT4`: نموذج GPT-4
- `CLAUDE`: نموذج Claude
- `LLAMA`: نموذج Llama

### الخصائص
- `cModel`: النموذج المستخدم
- `nTemperature`: درجة العشوائية (0-1)
- `nMaxTokens`: أقصى عدد للرموز
- `nTopP`: احتمالية أعلى P رموز
- `nPresencePenalty`: عقوبة التكرار
- `nFrequencyPenalty`: عقوبة التردد
- `cSystemPrompt`: توجيه النظام
- `cApiKey`: مفتاح API

### الدوال الرئيسية
- `init(cModelName)`: تهيئة النموذج
- `setModel(cValue)`: تحديد النموذج
- `getResponse(cPrompt, aParams)`: الحصول على استجابة
- `addToHistory(cRole, cContent)`: إضافة للمحادثة
- `clearHistory()`: مسح المحادثة

## Memory كلاس الذاكرة

### أنواع الذاكرة
- `SHORT_TERM`: قصيرة المدى
- `LONG_TERM`: طويلة المدى
- `EPISODIC`: حدثية
- `SEMANTIC`: دلالية

### الدوال الرئيسية
- `init()`: تهيئة نظام الذاكرة
- `store(cContent, cType, nPriority, aTags, aMetadata)`: تخزين ذكرى
- `retrieve(cQuery, cType, nLimit)`: استرجاع ذكريات
- `searchByTags(aTags, nLimit)`: البحث بالوسوم
- `updatePriority(nId, nNewPriority)`: تحديث الأولوية
- `clear()`: مسح الذاكرة

## PerformanceMonitor كلاس المراقبة

### الخصائص
- `bIsRunning`: حالة التشغيل
- `nStartTime`: وقت البدء

### الدوال الرئيسية
- `init()`: تهيئة نظام المراقبة
- `registerAgent/LLM/RL/Crew/Tools/Tasks`: تسجيل المكونات
- `startMonitoring()`: بدء المراقبة
- `stopMonitoring()`: إيقاف المراقبة
- `recordMetric(cComponent, cMetricName, nValue, aMetadata)`: تسجيل مقياس
- `recordEvent(cComponent, cEventType, cDescription, aMetadata)`: تسجيل حدث

## ReinforcementLearning كلاس التعلم المعزز

### استراتيجيات التعلم
- `EPSILON_GREEDY`: إبسيلون جريدي
- `UCB`: حد الثقة العلوي
- `THOMPSON`: أخذ عينات طومسون

### الخصائص
- `cStrategy`: الاستراتيجية المستخدمة
- `nEpsilon`: معامل الاستكشاف
- `nAlpha`: معدل التعلم
- `nGamma`: معامل الخصم

### الدوال الرئيسية
- `init(cLearningStrategy)`: تهيئة نظام التعلم
- `addState(cState)`: إضافة حالة
- `addAction(cAction)`: إضافة إجراء
- `chooseAction(cState)`: اختيار إجراء
- `learn(cState, cAction, nReward, cNextState)`: التعلم من التجربة

## Tool كلاس الأداة

### الخصائص
- `cName`: اسم الأداة
- `cDescription`: وصف الأداة
- `cVersion`: الإصدار
- `bEnabled`: حالة التفعيل

### الدوال الرئيسية
- `init(cToolName, cToolDescription)`: تهيئة الأداة
- `addParameter(cName, cType, bRequired, cDefaultValue)`: إضافة معامل
- `validateParameters(aInputParams)`: التحقق من المعاملات
- `addPermission(cPermission)`: إضافة صلاحية
- `execute(aParams)`: تنفيذ الأداة

## ToolRegistry كلاس سجل الأدوات

### الدوال الرئيسية
- `registerTool(oTool)`: تسجيل أداة
- `unregisterTool(cToolName)`: إلغاء تسجيل أداة
- `getTool(cToolName)`: الحصول على أداة
- `getToolsByCategory(cCategory)`: الحصول على أدوات فئة
- `addCategory(cName, cDescription)`: إضافة فئة

## التحديثات الرئيسية

1. إضافة دعم مرجان في كلاس `Agent`:
   - تهيئة قدرات مرجان
   - تحليل السياق والمشاعر
   - معالجة اللغة الطبيعية
   - إدارة المعرفة
   - تحسين النتائج

2. تحسين إدارة المهام في كلاس `Crew`:
   - إضافة نظام العمليات المتزامنة
   - تحسين إدارة قائمة الانتظار
   - إضافة آليات التزامن
   - تحسين تتبع الأداء

3. تحسين تتبع المهام في كلاس `Task`:
   - إضافة حالات جديدة للمهام
   - تحسين تتبع التقدم
   - دعم المهام الفرعية
   - تحسين معالجة الأخطاء

4. إضافة كلاسات جديدة:
   - `LLM`: دعم نماذج لغة متعددة
   - `Memory`: نظام ذاكرة متقدم
   - `PerformanceMonitor`: مراقبة الأداء
   - `ReinforcementLearning`: التعلم المعزز
   - `Tool` و `ToolRegistry`: إدارة الأدوات