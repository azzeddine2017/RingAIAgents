Load "G:\RingAIAgents\src\libAgentAi.ring"



# مثال للاستخدام
func main {
    # تدفق معالجة النصوص
    oTextFlow = new TextGenerationFlow()

    # تدفق المهام
    oTaskFlow = new TaskFlow()

    # تدفق متوازي
    oParallelFlow = new ParallelFlow()

    ? "=== بدء تنفيذ التدفقات ==="

    ? "--- تدفق النصوص ---"
    oTextFlow.execute()
    ? "النتيجة: " + oTextFlow.oState.getText("result")

    ? "--- تدفق المهام ---"
    oTaskFlow.execute()
    ? "حالة المهمة: "
    see oTaskFlow.oState.getList("task")

    ? "--- تدفق متوازي ---"
    oParallelFlow.execute()
    ? "المجموع النهائي: " + oParallelFlow.oState.getNumber("total")

    ? "--- تدفق معالجة البيانات ---"
    oDataFlow = new DataProcessingFlow()
    oDataFlow.execute()
    ? "نتيجة المعالجة: " + oDataFlow.oState.getNumber("result")
    if len(oDataFlow.oState.getList("errors")) > 0 {
        ? "سجل الأخطاء:"
        ? oDataFlow.oState.getText("error_log")
    }

    ? "--- تدفق سير العمل ---"
    aWorkflowFlow = new WorkflowFlow()
    aWorkflowFlow.execute()
    ? "حالة سير العمل النهائية:"
    see aWorkflowFlow.oState.getList("workflow")
}



/*
الكلاس: TextGenerationFlow
الوصف: مثال لتدفق يقوم بتوليد وتحليل النصوص
*/
class TextGenerationFlow from Flow {

    func init {
        super.init()
        # تسجيل الدوال
        registerMethod("generatetext")
        //registerMethod("analyzetext")
        //registerMethod("formatresults")

        # بدء التدفق
        start("generatetext")
    }

    func generatetext {
        oState.setText("text", "مرحباً بكم في نظام تدفقات الرينج!")
        ctext = oState.getText("text")
        emit("text_generated", ctext)

        # إنشاء ثريد للتحليل
        oThreads.createThread(1, super +".analyzetext(ctext)")
        oThreads.setThreadName(1, "TextAnalysis")
    }

    func analyzetext xText {
        nWords = len(split(xText))
        oState.setNumber("word_count", nWords)
        emit("analysis_complete", nWords)

        # إنشاء ثريد للتنسيق
        oThreads.createThread(2, super +".formatresults(" + nWords + ")")
        oThreads.setThreadName(2, "ResultFormat")
    }

    func formatresults nCount {
        cResult = "تم تحليل النص: عدد الكلمات = " + nCount
        oState.setText("result", cResult)
        emit("formatting_complete", cResult)
    }
}

/*
الكلاس: TaskFlow
الوصف: مثال لتدفق يدير المهام مع شروط متعددة
*/
class TaskFlow from Flow {

    func init {
        super.init()
        registerMethod("createTask")
        start("createTask")
    }

    func createTask {
        oTask = [
            :title = "مهمة جديدة",
            :priority = "عالي",
            :status = "جديد"
        ]
        oState.setList("task", oTask)
        emit("task_created", oTask)

        # تنفيذ متوازي للمهام
        oThreads.createThread(1, super +".assignTask(oTask)")
        oThreads.createThread(2, super +".validateTask(oTask)")
        oThreads.setThreadName(1, "TaskAssignment")
        oThreads.setThreadName(2, "TaskValidation")
    }

    func assignTask oTask {
        oTask[:assignee] = "أحمد"
        oState.setList("task", oTask)
        emit("task_assigned", oTask)
    }

    func validateTask oTask {
        bValid = true
        if oTask[:title] = "" { bValid = false }
        if oTask[:priority] = "" { bValid = false }
        emit("validation_complete", bValid)
    }
}

/*
الكلاس: ParallelFlow
الوصف: مثال لتدفق يعمل بشكل متوازي
*/
class ParallelFlow from Flow {

    func init {
        super.init()
        registerMethod("startParallel")
        start("startParallel")
    }

    func startParallel {
        # تنفيذ العمليات بشكل متوازي
        oThreads.createThread(1, super +".process1()")
        oThreads.createThread(2, super +".process2()")
        oThreads.setThreadName(1, "Process1")
        oThreads.setThreadName(2, "Process2")

        # انتظار اكتمال العمليات
        oThreads.joinAllThreads()

        # دمج النتائج
        combineResults()
    }

    func process1 {
        # محاكاة معالجة
        oState.setNumber("result1", 10)
        emit("process1_complete", 10)
    }

    func process2 {
        # محاكاة معالجة
        oState.setNumber("result2", 20)
        emit("process2_complete", 20)
    }

    func combineResults {
        nTotal = oState.getNumber("result1") + oState.getNumber("result2")
        oState.setNumber("total", nTotal)
        emit("all_complete", nTotal)
    }
}

/*
الكلاس: DataProcessingFlow
الوصف: مثال لتدفق يقوم بمعالجة البيانات مع التعامل مع الأخطاء
*/
class DataProcessingFlow from Flow {

    func init {
        super.init()
        registerMethod("loadData")
        start("loadData")
    }

    func loadData {
        try {
            aData = [1, 2, "three", 4, 5]
            oState.setList("raw_data", aData)

            # إنشاء ثريد للتحقق من البيانات
            oThreads.createThread(1, super +".validateData(aData)")
            oThreads.setThreadName(1, "DataValidation")
        catch
            emit("data_error", "خطأ في تحميل البيانات: " + cCatchError)
        }
    }

    func validateData aData {
        aValidData = []
        aErrors = []

        # قفل الوصول للبيانات المشتركة
        oThreads.lockMutex(nMutexId)

        for item in aData {
            if type(item) = "NUMBER" {
                add(aValidData, item)
            else
                add(aErrors, "قيمة غير صالحة: " + item)
            }
        }

        oState.setList("valid_data", aValidData)
        oState.setList("errors", aErrors)

        # تحرير القفل
        oThreads.unlockMutex(nMutexId)

        if len(aErrors) > 0 {
            # معالجة الأخطاء في ثريد منفصل
            oThreads.createThread(2, super +".handleErrors(aErrors)")
            oThreads.setThreadName(2, "ErrorHandler")
        else
            # معالجة البيانات الصحيحة في ثريد منفصل
            oThreads.createThread(3, super +".processData(aValidData)")
            oThreads.setThreadName(3, "DataProcessor")
        }
    }

    func processData aData {
        nSum = 0
        for num in aData {
            nSum += num
        }
        oState.setNumber("result", nSum)
        emit("processing_complete", nSum)
    }

    func handleErrors aErrors {
        cErrorLog = "تم اكتشاف " + len(aErrors) + " أخطاء:"
        for error in aErrors {
            cErrorLog += nl + "- " + error
        }
        oState.setText("error_log", cErrorLog)
        emit("error_handling_complete", cErrorLog)
    }
}

/*
الكلاس: WorkflowFlow
الوصف: مثال لتدفق يدير سير العمل مع حالات مختلفة
*/
class WorkflowFlow from Flow {

    func init {
        super.init()
        registerMethod("initializeWorkflow")
        start("initializeWorkflow")
    }

    func initializeWorkflow {
        aWorkflow = [
            :status = "new",
            :steps = ["review", "approve", "implement"],
            :currentStep = 1,
            :assignee = "مدير المشروع"
        ]
        oState.setList("workflow", aWorkflow)
        emit("workflow_initialized", aWorkflow)
    }

    func review aWorkflow {
        listen("workflow_initialized", "review")
        if aWorkflow[:currentStep] = 1 {
            aWorkflow[:status] = "in_review"
            aWorkflow[:reviewDate] = date()
            oState.setList("workflow", aWorkflow)
            emit("review_complete", aWorkflow)
        }
    }

    func approve aWorkflow {
        listen(or_(["review_complete", "review_rejected"]), "approve")

        # محاكاة قرار الموافقة
        if random(2) = 1 {
            aWorkflow[:status] = "approved"
            aWorkflow[:currentStep] = 2
            emit("approval_complete", aWorkflow)
        else
            aWorkflow[:status] = "rejected"
            emit("review_rejected", aWorkflow)
        }

        oState.setList("workflow", aWorkflow)
    }

    func implement aWorkflow {
        listen("approval_complete", "implement")
        aWorkflow[:status] = "implementing"
        aWorkflow[:currentStep] = 3
        aWorkflow[:implementationDate] = date()
        oState.setList("workflow", aWorkflow)
        emit("implementation_complete", aWorkflow)
    }

    func finalizeWorkflow aWorkflow {
        listen("implementation_complete", "finalizeWorkflow")
        aWorkflow[:status] = "completed"
        aWorkflow[:completionDate] = date()
        oState.setList("workflow", aWorkflow)
        emit("workflow_complete", aWorkflow)
    }
}
