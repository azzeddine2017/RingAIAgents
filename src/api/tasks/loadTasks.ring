/*
    RingAI Agents API - Task Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: loadTasks
الوصف: تحميل المهام المتاحة
*/
func loadTasks
    try {
        # مسح قائمة المهام الحالية
        aTasks = []

        # تحديد مسار قاعدة البيانات
        cDBPath = "G:\RingAIAgents\db\tasks.db"

        # التحقق من وجود قاعدة بيانات للمهام
        if fexists(cDBPath) {
            ? logger("loadTasks function", "Loading tasks from database: " + cDBPath, :info)
            # فتح قاعدة البيانات
            oDatabase = sqlite_init()
            sqlite_open(oDatabase, cDBPath)

            # استرجاع المهام
            cSQL = "SELECT * FROM tasks"
            aResults = sqlite_execute(oDatabase, cSQL)

            # تسجيل نتائج الاستعلام
            ? logger("loadTasks function", "SQL query executed: " + cSQL, :info)
            ? logger("loadTasks function", "Number of tasks found: " + iif(type(aResults) = "LIST" , len(aResults) , 0), :info)

            # معالجة النتائج
            if type(aResults) = "LIST" and len(aResults) > 0 {
                # تسجيل تفاصيل كل مهمة
                for nTaskIndex = 1 to len(aResults) {
                    aResult = aResults[nTaskIndex]
                    ? logger("loadTasks function", "Processing task " + nTaskIndex + " of " + len(aResults) + ": " + aResult[:title], :info)

                    # إنشاء مهمة جديدة
                    oTask = new Task(aResult[:description])

                    # تعيين المعرف والعنوان
                    oTask.setId(aResult[:id])
                    oTask.setTitle(aResult[:title])

                    # تعيين الحالة والأولوية
                    oTask.setStatus(aResult[:status])
                    oTask.setPriority(number(aResult[:priority]))

                    # تعيين الأوقات
                    oTask.setStartTime(aResult[:start_time])
                    oTask.setDueTime(aResult[:due_time])

                    # تعيين السياق والتقدم
                    oTask.setContext(aResult[:context])
                    oTask.updateProgress(number(aResult[:progress]))

                    # تعيين العميل المسند إليه المهمة
                    cAssignedTo = aResult[:assigned_to]
                    if cAssignedTo != "" {
                        for i = 1 to len(aAgents) {
                            if isObject(aAgents[i]) and methodExists(aAgents[i], "getId") {
                                if aAgents[i].getId() = cAssignedTo {
                                    oTask.assignTo(aAgents[i])
                                    exit
                                }
                            }
                        }
                    }

                    # إضافة المهام الفرعية
                    try {
                        aSubtasks = JSON2List(aResult[:subtasks])
                        if isList(aSubtasks) {
                            for aSubtask in aSubtasks {
                                oSubtask = new Task(aSubtask[:description])
                                oSubtask.setId(aSubtask[:id])
                                oSubtask.setStatus(aSubtask[:status])
                                oTask.addSubtask(oSubtask)
                            }
                        }
                    catch
                        ? logger("loadTasks function", "Error parsing subtasks: " + cCatchError, :error)
                    }

                    # إضافة المهمة إلى القائمة
                    add(aTasks, oTask)
                }
            }

            # إغلاق قاعدة البيانات
            sqlite_close(oDatabase)
        }

        # إذا لم يتم تحميل أي مهام، إنشاء مهام افتراضية
        if len(aTasks) = 0 and len(aAgents) > 0 {
            ? logger("loadTasks function", "No tasks loaded, creating default tasks", :info)

            # إنشاء مهمة افتراضية
            oDefaultTask = new Task("Implement basic functionality")
            oDefaultTask.setTitle("Basic Implementation")
            oDefaultTask.setPriority(5)
            oDefaultTask.setContext("Initial system setup")

            # إضافة مهمة فرعية
            oSubtask = new Task("Create database schema")
            oDefaultTask.addSubtask(oSubtask)

            # تعيين المهمة للعميل الأول
            oDefaultTask.assignTo(aAgents[1])

            # إضافة المهمة إلى القائمة
            add(aTasks, oDefaultTask)

            # حفظ المهام الافتراضية
            saveTasks()
        }

        ? logger("loadTasks function", "Tasks loaded successfully: " + len(aTasks), :info)
        return true
    catch
        ? logger("loadTasks function", "Error loading tasks: " + cCatchError, :error)
        return false
    }
