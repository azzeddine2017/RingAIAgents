# RingAI Agents

نظام متكامل لإدارة العملاء الذكيين (AI Agents) مع دعم مرجان للذكاء الاصطناعي.

## المميزات الرئيسية

### 1. العملاء الذكيون
- إنشاء وإدارة عملاء ذكيين
- نماذج شخصية متقدمة (OCEAN)
- تتبع المهارات والخبرات
- حالات عاطفية وطاقة
- تعلم وتحسين مستمر

### 2. الفرق والتعاون
- إدارة فرق العمل
- تحديد القادة والأعضاء
- توزيع المهام
- تتبع الأداء
- التواصل والتنسيق

### 3. المهام والمشاريع
- إدارة المهام والمشاريع
- تحديد الأولويات
- تتبع التقدم
- المهام الفرعية
- التقارير والإحصائيات

### 4. الذكاء الاصطناعي
- دمج مع مرجان
- نماذج لغة متقدمة
- تعلم معزز
- ذاكرة ذكية
- تحليل المشاعر

### 5. المراقبة والتحليل
- مراقبة الأداء
- تحليل البيانات
- تقارير تفصيلية
- تنبيهات وإشعارات
- تحسين مستمر

## المكونات الرئيسية

### 1. نواة النظام (Core)
- `Agent`: إدارة العملاء
- `Crew`: إدارة الفرق
- `Task`: إدارة المهام
- `Memory`: نظام الذاكرة
- `LLM`: نماذج اللغة
- `ReinforcementLearning`: التعلم المعزز
- `PerformanceMonitor`: مراقبة الأداء
- `Tool`: إدارة الأدوات

### 2. واجهة المستخدم (GUI)
- نافذة رئيسية
- إدارة العملاء
- إدارة الفرق
- إدارة المهام
- الدردشة والتواصل
- الإعدادات

### 3. الأدوات والمكتبات
- RingQt
- SQLite
- مرجان
- RingThreadPro
- HTTP

## المتطلبات

### النظام
- نظام التشغيل: Windows
- لغة Ring
- RingQt
- SQLite

### المكتبات
- RingThreadPro
- MorGen
- RingAIAgents Core

## التثبيت

1. تثبيت Ring
```
ring.exe
```

2. تثبيت المكتبات
```
ringpm install ringqt
ringpm install sqlitelib
ringpm install threadpro
```

3. تثبيت مرجان
```
git clone https://github.com/YourUsername/MorGen.git
```

4. تثبيت RingAI Agents
```
git clone https://github.com/YourUsername/RingAIAgents.git
cd RingAIAgents
ring install.ring
```

## الاستخدام

### تشغيل النظام
```ring
ring main.ring
```

### إنشاء عميل
```ring
oAgent = new Agent("Agent1", "Frontend Developer")
oAgent {
    setRole("Developer")
    addSkill("React", 90)
}
```

### إنشاء فريق
```ring
oCrew = new Crew("DevTeam")
oCrew {
    setLeader(oSeniorDev)
    addMember(oJuniorDev)
}
```

### إدارة المهام
```ring
oTask = new Task("Implement Feature")
oTask {
    setPriority(8)
    setDueDate("2025-03-01")
}
```

## التوثيق

- [دليل المطور](DEVELOPER_GUIDE.md)
- [توثيق الكلاسات](CLASSES.md)
- [دليل المستخدم](USER_GUIDE.md)
- [المساهمة](CONTRIBUTING.md)

## المساهمة

نرحب بمساهماتكم! يرجى:
1. نسخ المستودع
2. إنشاء فرع جديد
3. إجراء التعديلات
4. إنشاء طلب دمج

## الترخيص

MIT License - راجع ملف [LICENSE](LICENSE)