# تم نقل الاستدعاءات إلى libAgentAi.ring

/*
الكلاس: Flow
الوصف: يمثل تدفق العمل في النظام ويدير تسلسل المهام والحالة
*/
class Flow {
    # المتغيرات العامة
    cId
    oState
    aListeners
    bPersist
    oThreads
    nMutexId
    aRegisteredMethods

    func init {
        cId = generateUniqueId("flow_")
        oState = new State()
        aListeners = []
        # إنشاء مدير الثريد مع 4 ثريدات
        oThreads = new ThreadManager(4)
        # إنشاء mutex للمزامنة
        this.nMutexId = oThreads.createRecursiveMutex()
       // oThreads.dumpThreadInfo()

        # تسجيل الدوال المتاحة
        aRegisteredMethods = []
    }

    /*
    الدالة: start
    الوصف: تحديد نقطة البداية للتدفق
    المدخلات: cMethodName - اسم الدالة التي ستبدأ التدفق
    */
    func start cMethodName {
        return addListener(:start, cMethodName)
    }

    /*
    الدالة: listen
    الوصف: إضافة مستمع لحدث معين
    المدخلات: cEvent - الحدث المراد الاستماع له
             cMethodName - اسم الدالة التي ستنفذ عند حدوث الحدث
    */
    func listen cEvent, cMethodName {
        return addListener(cEvent, cMethodName)
    }

    /*
    الدالة: or_
    الوصف: دمج مستمعين أو أكثر بحيث يتم تنفيذ الدالة عند حدوث أي منهم
    المدخلات: aEvents - قائمة بالأحداث
    */
    func or_ aEvents {
        if type(aEvents) != "LIST" {
            raise("يجب تمرير قائمة من الأحداث")
        }
        return "or:" + list2str(aEvents)
    }

    /*
    الدالة: and_
    الوصف: دمج مستمعين أو أكثر بحيث يتم تنفيذ الدالة عند حدوث جميعهم
    المدخلات: aEvents - قائمة بالأحداث
    */
    func and_ aEvents {
        if type(aEvents) != "LIST" {
            raise("يجب تمرير قائمة من الأحداث")
        }
        return "and:" + list2str(aEvents)
    }

    /*
    الدالة: parallel
    الوصف: تنفيذ مجموعة من المهام بشكل متوازي
    المدخلات: aTasks - قائمة بالمهام المراد تنفيذها
    */
    func parallel aTasks {
        if type(aTasks) != "LIST" {
            raise("يجب تمرير قائمة من المهام")
        }

        # تنفيذ المهام في ثريدات متوازية
        for i = 1 to len(aTasks) {
            oThreads.createThread(i, aTasks[i])
            oThreads.setThreadName(i, "Task_" + i)
        }
    }

    /*
    الدالة: waitAll
    الوصف: انتظار اكتمال جميع المهام المتوازية
    */
    func waitAll {
        oThreads.joinAllThreads()
    }

    /*
    الدالة: execute
    الوصف: تنفيذ التدفق
    */
    func execute {
        emit(:start, null)
        waitAll()
    }

    //private

    /*
    الدالة: addListener
    الوصف: إضافة مستمع داخلي
    المدخلات: cEvent - الحدث
             cMethod - الدالة المستمعة
    */
    func addListener cEvent, cMethod {
        oThreads.lockMutex(this.nMutexId)
        aListener = [
            :event = cEvent,
            :method = cMethod
        ]
        add(aListeners, aListener)
        oThreads.unlockMutex(this.nMutexId)

    }

    /*
    الدالة: emit
    الوصف: إطلاق حدث معين
    المدخلات: cEvent - الحدث المراد إطلاقه
             xData - البيانات المرتبطة بالحدث
    */
    func emit cEvent, xData {
        if this.nMutexId != 0 {
            oThreads.lockMutex(this.nMutexId)
            aCurrentListeners = aListeners
            oThreads.unlockMutex(this.nMutexId)
        else 
            aCurrentListeners = aListeners
        }

        nThreadId = 1
        for listener in aCurrentListeners {
            if isMatchingEvent(listener[:event], cEvent) {
                # إنشاء دالة مغلفة لتمرير البيانات
                listenerMethod = listener[:method]

                # محاولة استدعاء الدالة باستخدام callMethod
                if callMethod(listenerMethod, xData)
                    # تم استدعاء الدالة بنجاح
                else
                    # استخدام الطريقة التقليدية
                    wrapperFunc = listenerMethod + "(" + xData + ")"
                    oThreads.createThread(nThreadId, wrapperFunc)
                    oThreads.setThreadName(nThreadId, "Event_" + cEvent + "_" + nThreadId)
                    nThreadId++
                ok
            }
        }
    }

    /*
    الدالة: isMatchingEvent
    الوصف: التحقق من تطابق الحدث
    المدخلات: cPattern - نمط الحدث
             cEvent - الحدث الفعلي
    المخرجات: true إذا كان هناك تطابق
    */
    func isMatchingEvent cPattern, cEvent {
        if left(cPattern, 3) = "or:" {
            aEvents = str2list(substr(cPattern, 4))
            for event in aEvents {
                if event = cEvent return true ok
            }
            return false
        elseif left(cPattern, 4) = "and:"
            aEvents = str2list(substr(cPattern, 5))
            for event in aEvents {
                if event != cEvent return false ok
            }
            return true
        }
        return cPattern = cEvent
    }

    /*
    الدالة: cleanup
    الوصف: تنظيف الموارد المستخدمة
    */
    func cleanup {
        if oThreads != null {
            oThreads.destroy()
            oThreads = null
        }
    }

    /*
    الدالة: registerMethod
    الوصف: تسجيل دالة ليتم استدعاؤها من الكلاس الأب
    المدخلات: cMethodName - اسم الدالة المراد تسجيلها
    */
    func registerMethod cMethodName {
        add(aRegisteredMethods, cMethodName)
    }

    /*
    الدالة: callMethod
    الوصف: استدعاء دالة مسجلة
    المدخلات: cMethodName - اسم الدالة المراد استدعاؤها
               xData - البيانات المراد تمريرها للدالة
    */
    func callMethod cMethodName, xData {
        if find(aRegisteredMethods, cMethodName) > 0 {
            if xData = NULL
                call cMethodName()
            else
                call cMethodName(xData)
            ok
            return true
        }
        return false
    }

    /*
    الدالة: destructor
    الوصف: تنظيف الموارد عند حذف الكائن
    */
    func destructor {
        cleanup()
    }
}

