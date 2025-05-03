Load "G:\RingAIAgents\src\libAgantAi.ring"

/*
المثال: تدفق العمل مع الوكلاء والفرق
الوصف: مثال يوضح كيفية استخدام التدفقات مع الوكلاء والفرق في نظام RingAI Agents
*/

serverdebug = true
aDebag = [:error, :info]


# مثال استخدام
func main {
    ? "=== بدء مثال تدفق العمل مع الوكلاء والفرق ==="
     
    # إنشاء نظام العملاء
    oSystem = new AgentAI()

    # إنشاء الوكلاء
    oFrontendDev = oSystem.createAgent("مطور واجهة المستخدم", "متخصص في تطوير واجهات المستخدم")
    oFrontendDev.setRole("مطور واجهة المستخدم")
    oFrontendDev.addSkill("JavaScript", 90)
    oFrontendDev.addSkill("React", 85)
    oFrontendDev.addSkill("CSS", 80)

    oBackendDev = oSystem.createAgent("مطور الخلفية", "متخصص في تطوير الخوادم")
    oBackendDev.setRole("مطور الخلفية")
    oBackendDev.addSkill("Python", 90)
    oBackendDev.addSkill("Node.js", 85)
    oBackendDev.addSkill("Databases", 80)

    oDesigner = oSystem.createAgent("مصمم", "متخصص في تصميم واجهات المستخدم")
    oDesigner.setRole("مصمم")
    oDesigner.addSkill("UI/UX", 95)
    oDesigner.addSkill("Photoshop", 85)
    oDesigner.addSkill("Figma", 90)

    oProjectManager = oSystem.createAgent("مدير المشروع", "مسؤول عن إدارة المشروع وتنسيق العمل")
    oProjectManager.setRole("مدير المشروع")
    oProjectManager.addSkill("Project Management", 95)
    oProjectManager.addSkill("Communication", 90)
    oProjectManager.addSkill("Leadership", 85)

    # إنشاء فريق التطوير
    oDevTeam = oSystem.createTeam("oDevTeam", "فريق التطوير", oProjectManager)
    oDevTeam.addMember(oFrontendDev)
    oDevTeam.addMember(oBackendDev)
    oDevTeam.addMember(oDesigner)

    # إنشاء المهام
    oLoginTask = oSystem.createTask("تنفيذ وظيفة تسجيل الدخول")
    oLoginTask.setPriority(8)

    oDashboardTask = oSystem.createTask("إنشاء واجهة لوحة التحكم")
    oDashboardTask.setPriority(7)

    oDesignTask = oSystem.createTask("تصميم واجهة المستخدم")
    oDesignTask.setPriority(9)

    # إنشاء تدفق العمل للمشروع
    oProjectFlow = new ProjectWorkflow(oDevTeam)

    # تنفيذ تدفق العمل
    ? "--- بدء تدفق العمل للمشروع ---"
    oProjectFlow.execute()
    ? "حالة المشروع: " + oProjectFlow.oState.getText("project_status")

    # إنشاء تدفق للمهام
    oTaskFlow = new TaskAssignmentFlow(oDevTeam, [oLoginTask, oDashboardTask, oDesignTask])

    # تنفيذ تدفق المهام
    ? "--- بدء تدفق المهام ---"
    oTaskFlow.execute()
    ? "حالة المهام: "
    see oTaskFlow.oState.getList("assignments")

    # إنشاء تدفق للتعاون
    oCollaborationFlow = new CollaborationFlow(oDevTeam)

    # تنفيذ تدفق التعاون
    ? "--- بدء تدفق التعاون ---"
    oCollaborationFlow.execute()
    ? "نتائج التعاون: " + oCollaborationFlow.oState.getText("collaboration_result")

    # إنشاء تدفق للتقييم
    oEvaluationFlow = new EvaluationFlow(oDevTeam)

    # تنفيذ تدفق التقييم
    ? "--- بدء تدفق التقييم ---"
    oEvaluationFlow.execute()
    ? "نتائج التقييم: "
    see oEvaluationFlow.oState.getList("evaluation_results")

    ? "=== انتهاء المثال ==="
}

/*
الكلاس: ProjectWorkflow
الوصف: تدفق عمل للمشروع
*/
class ProjectWorkflow from Flow {

    oTeam = null
   

    func init oTeam {
        super.init()
        self.oTeam = oTeam
        
        
        registerMethod("startproject")
        start("startproject")
    }

    func startproject {
        oState.setText("project_status", "بدء المشروع")
        emit("project_started", null)

        # تحديد أهداف المشروع
        defineProjectGoals()
    }

    func defineProjectGoals {
        oState.setText("project_goals", "إنشاء نظام تسجيل دخول وواجهة لوحة تحكم")
        oState.setText("project_status", "تم تحديد الأهداف")
        emit("goals_defined", null)

        # تخطيط المشروع
        planProject()
    }

    func planProject {
        # إنشاء خطة المشروع
        aProjectPlan = [
            :phases = ["تصميم", "تطوير", "اختبار", "نشر"],
            :timeline = "4 أسابيع",
            :resources = ["مطورين", "مصممين", "مختبرين"]
        ]

        oState.setList("project_plan", aProjectPlan)
        oState.setText("project_status", "تم التخطيط")
        emit("project_planned", aProjectPlan)

        # إعلام الفريق بالخطة
        oTeam.broadcast("تم الانتهاء من خطة المشروع. يرجى مراجعة المهام المسندة إليكم.")

        # بدء تنفيذ المشروع
        startExecution()
    }

    func startExecution {
        oState.setText("project_status", "قيد التنفيذ")
        emit("execution_started", null)

        # محاكاة تقدم المشروع
        oState.setNumber("progress", 25)
        emit("progress_updated", 25)

        # تحديث حالة المشروع
        updateProjectStatus()
    }

    func updateProjectStatus {
        oState.setText("project_status", "مستمر - 25% مكتمل")
        emit("status_updated", oState.getText("project_status"))
    }
}

/*
الكلاس: TaskAssignmentFlow
الوصف: تدفق لتوزيع المهام على أعضاء الفريق
*/
class TaskAssignmentFlow from Flow {

    oTeam = null
    aTasks = []
   

    func init oTeam, aTasks {
        super.init()
        self.oTeam = oTeam
        self.aTasks = aTasks
       
        registerMethod("starttaskassignment")
        start("starttaskassignment")
    }

    func starttaskassignment {
        oState.setText("assignment_status", "بدء توزيع المهام")
        emit("assignment_started", null)

        # توزيع المهام بناءً على المهارات
        assignTasksBySkill()
    }

    func assignTasksBySkill {
        aAssignments = []
        aMembers = oTeam.getMembers()

        # محاكاة توزيع المهام بناءً على المهارات
        for i = 1 to len(aTasks) {
            oTask = aTasks[i]
            oAgent = findBestAgentForTask(oTask, aMembers)

            if oAgent != null {
                add(aAssignments, [
                    :task = oTask.getDescription(),
                    :agent = oAgent.getName(),
                    :priority = oTask.getPriority()
                ])

                # إسناد المهمة للوكيل
                oTeam.assignTask(oTask, oAgent)
            }
        }

        oState.setList("assignments", aAssignments)
        oState.setText("assignment_status", "تم توزيع المهام")
        emit("tasks_assigned", aAssignments)

        # إعلام الفريق بالمهام
        notifyTeamMembers()
    }

    func notifyTeamMembers {
        oTeam.broadcast("تم توزيع المهام على أعضاء الفريق. يرجى مراجعة المهام المسندة إليكم.")
        emit("team_notified", null)
    }

    # دالة مساعدة لإيجاد أفضل وكيل للمهمة
    func findBestAgentForTask oTask, aAgents {
        nHighestScore = 0
        oBestAgent = null

        for oAgent in aAgents {
            nScore = calculateAgentTaskScore(oAgent, oTask)
            if nScore > nHighestScore {
                nHighestScore = nScore
                oBestAgent = oAgent
            }
        }

        return oBestAgent
    }

    # دالة مساعدة لحساب درجة ملاءمة الوكيل للمهمة
    func calculateAgentTaskScore oAgent, oTask {
        nScore = 0
        cTaskDesc = lower(oTask.getDescription())

        # فحص مهارات الوكيل
        for aSkill in oAgent.getSkills() {
            cSkillName = lower(aSkill[:name])
            if substr(cTaskDesc, cSkillName) {
                nScore += aSkill[:proficiency]
            }
        }

        # مراعاة دور الوكيل
        if oAgent.getRole() = "مدير المشروع" and substr(cTaskDesc, "إدارة") {
            nScore += 50
        }

        if oAgent.getRole() = "مطور واجهة المستخدم" and (substr(cTaskDesc, "واجهة") or substr(cTaskDesc, "تصميم")) {
            nScore += 30
        }

        if oAgent.getRole() = "مطور الخلفية" and substr(cTaskDesc, "تسجيل") {
            nScore += 40
        }

        if oAgent.getRole() = "مصمم" and substr(cTaskDesc, "تصميم") {
            nScore += 50
        }

        return nScore
    }
}

/*
الكلاس: CollaborationFlow
الوصف: تدفق للتعاون بين أعضاء الفريق
*/
class CollaborationFlow from Flow {

    oTeam = null
   

    func init oTeam {
        super.init()
        self.oTeam = oTeam
        
        registerMethod("startcollaboration")
        start("startcollaboration")
    }

    func startcollaboration {
        oState.setText("collaboration_status", "بدء التعاون")
        emit("collaboration_started", "تم بدء جلسة تعاون بين أعضاء فريق التطوير." + oTeam.getName() )

        # إنشاء جلسة تعاون
        createCollaborationSession()
    }

    func createCollaborationSession {
        # محاكاة جلسة تعاون
        aSession = [
            :topic = "تكامل واجهة المستخدم مع الخلفية",
            :participants = [],
            :date = TimeList()[5],
            :duration = "60 دقيقة"
        ]

        # إضافة المشاركين
        aMembers = oTeam.getMembers()
        for oMember in aMembers {
            add(aSession[:participants], oMember.getName())
        }

        oState.setList("collaboration_session", aSession)
        emit("session_created", aSession)

        # محاكاة نتائج التعاون
        simulateCollaboration()
    }

    func simulateCollaboration {
        # محاكاة تبادل المعلومات بين أعضاء الفريق
        aMembers = oTeam.getMembers()

        # التأكد من وجود أعضاء كافيين في الفريق
        if len(aMembers) >= 4 {
            oFrontendDev = null
            oBackendDev = null

            # البحث عن الأعضاء حسب الدور
            for oMember in aMembers {
                if oMember.getRole() = "مطور واجهة المستخدم" {
                    oFrontendDev = oMember
                }
                if oMember.getRole() = "مطور الخلفية" {
                    oBackendDev = oMember
                }
            }

            # تبادل المعلومات إذا وجدنا الأعضاء
            if oFrontendDev != null and oBackendDev != null {
                # تبادل المعلومات
                oFrontendDev.learn("API Integration", "Learned how to integrate with backend APIs")
                oBackendDev.learn("UI Requirements", "Understood the UI requirements for the login system")

                # تسجيل الملاحظات
                oFrontendDev.observe("Backend team is using JWT for authentication")
                oBackendDev.observe("Frontend team needs detailed API documentation")
            }
        }

        # تحديث حالة التعاون
        oState.setText("collaboration_result", "تم تبادل المعلومات بنجاح بين فريق الواجهة وفريق الخلفية")
        oState.setText("collaboration_status", "مكتمل")
        emit("collaboration_completed", oState.getText("collaboration_result"))
    }
}

/*
الكلاس: EvaluationFlow
الوصف: تدفق لتقييم أداء الفريق
*/
class EvaluationFlow from Flow {

    oTeam = null

    func init oTeam {
        super.init()
        self.oTeam = oTeam
       
        registerMethod("startevaluation")
        start("startevaluation")
    }

    func startevaluation {
        oState.setText("evaluation_status", "بدء التقييم")
        emit("evaluation_started", null)

        # جمع بيانات الأداء
        collectPerformanceData()
    }

    func collectPerformanceData {
        aMembers = oTeam.getMembers()
        aPerformanceData = []

        # محاكاة جمع بيانات الأداء
        for oMember in aMembers {
            aPerformance = [
                :name = oMember.getName(),
                :role = oMember.getRole(),
                :skills = oMember.getSkills(),
                :performance_score = oMember.getPerformanceScore(),
                :energy_level = oMember.getEnergyLevel(),
                :confidence_level = oMember.getConfidenceLevel()
            ]

            add(aPerformanceData, aPerformance)
        }

        oState.setList("performance_data", aPerformanceData)
        emit("data_collected", aPerformanceData)

        # تحليل البيانات
        analyzePerformanceData()
    }

    func analyzePerformanceData {
        aPerformanceData = oState.getList("performance_data")
        aEvaluationResults = []

        # محاكاة تحليل البيانات
        for aData in aPerformanceData {
            # حساب درجة التقييم الإجمالية
            nOverallScore = (aData[:performance_score] * 0.5) +
                           (aData[:energy_level] / 20) +
                           (aData[:confidence_level] / 2)

            # تحديد مستوى الأداء
            cPerformanceLevel = ""
            if nOverallScore >= 8
                cPerformanceLevel = "ممتاز"
            elseif nOverallScore >= 6
                cPerformanceLevel = "جيد جداً"
            elseif nOverallScore >= 4
                cPerformanceLevel = "جيد"
            else
                cPerformanceLevel = "بحاجة إلى تحسين"
            ok

            # إنشاء نتيجة التقييم
            aEvaluation = [
                :name = aData[:name],
                :role = aData[:role],
                :overall_score = nOverallScore,
                :performance_level = cPerformanceLevel,
                :strengths = [],
                :areas_for_improvement = []
            ]

            # تحديد نقاط القوة ومجالات التحسين
            for aSkill in aData[:skills] {
                if aSkill[:proficiency] >= 85 {
                    add(aEvaluation[:strengths], aSkill[:name])
                elseif aSkill[:proficiency] < 70
                    add(aEvaluation[:areas_for_improvement], aSkill[:name])
                }
            }

            add(aEvaluationResults, aEvaluation)
        }

        oState.setList("evaluation_results", aEvaluationResults)
        oState.setText("evaluation_status", "مكتمل")
        emit("evaluation_completed", aEvaluationResults)

        # تقديم التوصيات
        provideRecommendations()
    }

    func provideRecommendations {
        aEvaluationResults = oState.getList("evaluation_results")
        aRecommendations = []

        # محاكاة تقديم التوصيات
        for aResult in aEvaluationResults {
            aRecommendation = [
                :name = aResult[:name],
                :recommendations = []
            ]

            # إضافة توصيات بناءً على مجالات التحسين
            for cArea in aResult[:areas_for_improvement] {
                add(aRecommendation[:recommendations], "تحسين مهارات " + cArea)
            }

            # إضافة توصيات عامة
            if aResult[:overall_score] < 6 {
                add(aRecommendation[:recommendations], "حضور دورات تدريبية في مجال التخصص")
            }

            if aResult[:energy_level] < 70 {
                add(aRecommendation[:recommendations], "تحسين مستوى الطاقة من خلال توزيع المهام بشكل أفضل")
            }

            add(aRecommendations, aRecommendation)
        }

        oState.setList("recommendations", aRecommendations)
        emit("recommendations_provided", aRecommendations)
    }
}
