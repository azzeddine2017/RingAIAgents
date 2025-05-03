/*
الكلاس: State
الوصف: يدير حالة التدفق ويوفر واجهة للتخزين واسترجاع البيانات
*/
class State {
    
    func init {
        aData = []
        oThreads = new ThreadManager(1)
        nMutexId = oThreads.createRecursiveMutex()
    }

    # دوال التعامل مع النصوص
    func setText cKey, xValue {
        return setValue(cKey, string(xValue))
    }

    func getText cKey {
        return string(getValue(cKey))
    }

    # دوال التعامل مع الأرقام
    func setNumber cKey, xValue {
        return setValue(cKey, number(xValue))
    }

    func getNumber cKey {
        return number(getValue(cKey))
    }

    # دوال التعامل مع القوائم
    func setList cKey, aValue {
        if type(aValue) != "LIST" {
            raise("يجب تمرير قائمة")
        }
        return setValue(cKey, aValue)
    }

    func getList cKey {
        xValue = getValue(cKey)
        if type(xValue) != "LIST" {
            return []
        }
        return xValue
    }

    # دوال عامة
    func setValue cKey, xValue {
        oThreads.lockMutex(nMutexId)
        aData[cKey] = xValue
        oThreads.unlockMutex(nMutexId)
        return self
    }

    func getValue cKey {
        oThreads.lockMutex(nMutexId)
        if exists(aData, cKey) {
            xValue = aData[cKey]
        else
            xValue = null
        }
        oThreads.unlockMutex(nMutexId)
        return xValue
    }

    func exists aList, xKey {
        for item in aList {
            if item[1] = xKey {
                return true
            }
        }
        return false
    }

    func clear {
        oThreads.lockMutex(nMutexId)
        aData = []
        oThreads.unlockMutex(nMutexId)
        return self
    }

    func getAll {
        oThreads.lockMutex(nMutexId)
        aCopy = aData
        oThreads.unlockMutex(nMutexId)
        return aCopy
    }

    func cleanup {
        if oThreads != null {
            oThreads.destroy()
            oThreads = null
        }
    }

    func destructor {
        cleanup()
    }
    # المتغيرات الخاصة
    private
        aData = []      # مصفوفة لتخزين البيانات
        nMutexId = 0    # معرف mutex للمزامنة
        oThreads = null # كائن إدارة الثريدات

}