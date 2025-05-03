/*
    RingAI Agents API - Agents Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showAgents
الوصف: عرض قائمة العملاء
*/
import System.Web

func showAgents
    oPage = New BootStrapWebPage {
        Title = "RingAI Agents List"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/tables.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/agents.js'></script>")

        # إضافة الهيدر
        getHeader(oPage)

        div {
            classname = "main-content"
            div {
                classname = "container"

                div {
                    classname = "row mb-4"
                    div {
                        classname = "col-md-12"
                        h1 { text("Agents Management") }
                        p { text("View and manage all AI agents in the system") }
                    }
                }

                div {
                    classname = "row mb-3"
                    div {
                        classname = "col-md-12 text-right"
                        button {
                            classname = "btn btn-primary"
                            onclick = "showAddAgentForm()"
                            html("<i class='fas fa-plus'></i> Add New Agent")
                        }
                    }
                }

                div {
                    classname = "row"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "table-responsive-xl w-100"
                            style = "overflow-x: auto; min-width: 100%;"
                            table {
                                classname = "table table-striped table-bordered table-hover table-horizontal-scroll table-sticky-header w-100"
                                style = "min-width: 1200px;"
                                thead {
                                    classname = "thead-dark"
                                    tr {
                                        th { style = "width: 5%;" text("ID") }
                                        th { style = "width: 10%;" text("Name") }
                                        th { style = "width: 8%;" text("Role") }
                                        th { style = "width: 15%;" text("Goal") }
                                        th { style = "width: 10%;" text("Skills") }
                                        th { style = "width: 8%;" text("Language Model") }
                                        th { style = "width: 8%;" text("Energy") }
                                        th { style = "width: 8%;" text("Confidence") }
                                        th { style = "width: 12%;" text("Personality") }
                                        th { style = "width: 6%;" text("Status") }
                                        th { style = "width: 10%;" text("Actions") }
                                    }
                                }
                                tbody {
                                    for oAgent in aAgents {
                                        tr {
                                            td { style = "vertical-align: middle; text-align: center;" text(oAgent.getID()) }
                                            td { style = "vertical-align: middle; font-weight: bold;" text(oAgent.getName()) }
                                            td { style = "vertical-align: middle;" text(oAgent.getRole()) }
                                            td { style = "vertical-align: middle; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title = oAgent.getGoal() text(oAgent.getGoal()) }

                                            # Concatenate skills into a comma-separated string
                                            Skills = ""
                                            try {
                                                aSkills = oAgent.getSkills()

                                                # التحقق من أن aSkills هي قائمة وليست فارغة
                                                if islist(aSkills) and len(aSkills) > 0 {
                                                    # تحضير المهارات للعرض

                                                    # إضافة كل مهارة إلى النص
                                                    for i = 1 to len(aSkills) {
                                                        if i <= len(aSkills) {  # التحقق من أن المؤشر ضمن النطاق
                                                            aSkill = aSkills[i]
                                                            if isList(aSkill) and aSkill[:name] != NULL {
                                                                Skills += aSkill[:name]

                                                                # إضافة مستوى المهارة إذا كان متاحاً
                                                                if aSkill[:proficiency] != NULL {
                                                                    Skills += " (" + aSkill[:proficiency] + ")"
                                                                }

                                                                if i < len(aSkills) {
                                                                    Skills += ", "
                                                                }
                                                            }
                                                        }
                                                    }
                                                else
                                                    # لا توجد مهارات أو قائمة المهارات فارغة
                                                }

                                                # إذا لم يتم إضافة أي مهارات، عرض "No skills"
                                                if Skills = "" {
                                                    Skills = "No skills"
                                                }
                                            catch
                                                # تجاهل أخطاء عرض المهارات
                                                Skills = "No skills"
                                            }
                                            td {
                                                style = "vertical-align: middle; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                                                title = Skills
                                                text(Skills)
                                            }

                                            # Language Model
                                            cLanguageModel = ""
                                            try {
                                                cLanguageModel = oAgent.getLanguageModel()
                                            catch
                                                cLanguageModel = "Unknown"
                                            }
                                            td {
                                                style = "vertical-align: middle; text-align: center;"
                                                span {
                                                    classname = "badge badge-info"
                                                    text(cLanguageModel)
                                                }
                                            }

                                            # Energy Level
                                            nEnergy = 0
                                            try {
                                                nEnergy = oAgent.getEnergyLevel()
                                            catch
                                                nEnergy = 0
                                            }
                                            td {
                                                style = "vertical-align: middle;"
                                                div {
                                                    classname = "progress"
                                                    style = "height: 20px;"
                                                    div {
                                                        classname = "progress-bar bg-" +
                                                            iif(nEnergy > 70, "success",
                                                                iif(nEnergy > 30, "warning", "danger"))
                                                        style = "width: " + nEnergy + "%; font-weight: bold;"
                                                        text("" + nEnergy + "%")
                                                    }
                                                }
                                            }

                                            # Confidence Level
                                            nConfidence = 0
                                            try {
                                                nConfidence = oAgent.getConfidenceLevel()
                                            catch
                                                nConfidence = 0
                                            }
                                            td {
                                                style = "vertical-align: middle; text-align: center;"
                                                div {
                                                    classname = "d-flex justify-content-center"
                                                    for i = 1 to 5 {
                                                        span {
                                                            classname = "fa fa-star" + iif(i <= (nConfidence/2), "", "-o")
                                                            style = "color: " + iif(i <= (nConfidence/2), "gold", "#ccc") + "; margin: 0 1px; font-size: 16px;"
                                                        }
                                                    }
                                                }
                                                div {
                                                    style = "margin-top: 5px; font-size: 12px;"
                                                    span {
                                                        classname = "badge badge-" +
                                                            iif(nConfidence > 7, "primary",
                                                                iif(nConfidence > 4, "info", "secondary"))
                                                        text("" + nConfidence + "/10")
                                                    }
                                                }
                                            }

                                            # Personality Traits
                                            cPersonality = ""
                                            try {
                                                aPersonality = oAgent.getPersonalityTraits()
                                                if isList(aPersonality) {
                                                    if aPersonality[:openness] != NULL {
                                                        cPersonality += "O:" + aPersonality[:openness] + " "
                                                    }
                                                    if aPersonality[:conscientiousness] != NULL {
                                                        cPersonality += "C:" + aPersonality[:conscientiousness] + " "
                                                    }
                                                    if aPersonality[:extraversion] != NULL {
                                                        cPersonality += "E:" + aPersonality[:extraversion] + " "
                                                    }
                                                    if aPersonality[:agreeableness] != NULL {
                                                        cPersonality += "A:" + aPersonality[:agreeableness] + " "
                                                    }
                                                    if aPersonality[:neuroticism] != NULL {
                                                        cPersonality += "N:" + aPersonality[:neuroticism]
                                                    }
                                                }
                                            catch
                                                cPersonality = "Not defined"
                                            }
                                            td {
                                                style = "vertical-align: middle;"
                                                if cPersonality != "Not defined" {
                                                    div {
                                                        classname = "d-flex flex-wrap justify-content-around"

                                                        # Openness
                                                        if aPersonality[:openness] != NULL {
                                                            div {
                                                                style = "margin: 2px; text-align: center;"
                                                                span {
                                                                    classname = "badge badge-success"
                                                                    style = "display: block; margin-bottom: 2px;"
                                                                    text("O")
                                                                }
                                                                span {
                                                                    text(aPersonality[:openness])
                                                                }
                                                            }
                                                        }

                                                        # Conscientiousness
                                                        if aPersonality[:conscientiousness] != NULL {
                                                            div {
                                                                style = "margin: 2px; text-align: center;"
                                                                span {
                                                                    classname = "badge badge-primary"
                                                                    style = "display: block; margin-bottom: 2px;"
                                                                    text("C")
                                                                }
                                                                span {
                                                                    text(aPersonality[:conscientiousness])
                                                                }
                                                            }
                                                        }

                                                        # Extraversion
                                                        if aPersonality[:extraversion] != NULL {
                                                            div {
                                                                style = "margin: 2px; text-align: center;"
                                                                span {
                                                                    classname = "badge badge-warning"
                                                                    style = "display: block; margin-bottom: 2px;"
                                                                    text("E")
                                                                }
                                                                span {
                                                                    text(aPersonality[:extraversion])
                                                                }
                                                            }
                                                        }

                                                        # Agreeableness
                                                        if aPersonality[:agreeableness] != NULL {
                                                            div {
                                                                style = "margin: 2px; text-align: center;"
                                                                span {
                                                                    classname = "badge badge-info"
                                                                    style = "display: block; margin-bottom: 2px;"
                                                                    text("A")
                                                                }
                                                                span {
                                                                    text(aPersonality[:agreeableness])
                                                                }
                                                            }
                                                        }

                                                        # Neuroticism
                                                        if aPersonality[:neuroticism] != NULL {
                                                            div {
                                                                style = "margin: 2px; text-align: center;"
                                                                span {
                                                                    classname = "badge badge-danger"
                                                                    style = "display: block; margin-bottom: 2px;"
                                                                    text("N")
                                                                }
                                                                span {
                                                                    text(aPersonality[:neuroticism])
                                                                }
                                                            }
                                                        }
                                                    }
                                                else
                                                    text(cPersonality)
                                                }
                                            }

                                            # Status
                                            td {
                                                style = "vertical-align: middle; text-align: center;"
                                                span {
                                                    classname = "badge badge-pill badge-" + iif(oAgent.getStatus() = "active", "success",
                                                        iif(oAgent.getStatus() = "working", "primary",
                                                            iif(oAgent.getStatus() = "learning", "info", "secondary")))
                                                    style = "font-size: 14px; padding: 8px 12px;"
                                                    text(oAgent.getStatus())
                                                }
                                            }
                                            td {
                                                style = "vertical-align: middle; text-align: center;"
                                                div {
                                                    classname = "btn-group btn-group-sm"
                                                    button {
                                                        classname = "btn btn-info"
                                                        style = "margin-right: 5px;"
                                                        onclick = "editAgent('" + oAgent.getID() + "')"
                                                        html("<i class='fas fa-edit'></i> Edit")
                                                    }
                                                    button {
                                                        classname = "btn btn-danger"
                                                        onclick = "deleteAgent('" + oAgent.getID() + "')"
                                                        html("<i class='fas fa-trash'></i> Delete")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            div {
                classname = "row mt-4"
                div {
                    classname = "col-md-12 text-center"
                    Link { Link = "/" classname = "btn btn-secondary" html("<i class='fas fa-home'></i> Back to Dashboard") }
                }
            }

            # Modal for forms
            div {
                id = "mainModal"
                classname = "modal fade"
                tabindex = "-1"
                role = "dialog"
                arialabelledby = "modalTitle"
                ariahidden = "true"

                div {
                    classname = "modal-dialog modal-lg"
                    role = "document"

                    div {
                        classname = "modal-content"

                        div {
                            classname = "modal-header"
                            h5 {
                                classname = "modal-title"
                                id = "modalTitle"
                                text("Modal Title")
                            }
                            button {
                                type = "button"
                                classname = "close"
                                datadismiss = "modal"
                                arialabel = "Close"
                                span {
                                    ariahidden = "true"
                                    html("&times;")
                                }
                            }
                        }

                        div {
                            classname = "modal-body"
                            id = "modalBody"
                            text("Modal content will be loaded here...")
                        }

                        div {
                            classname = "modal-footer"
                            button {
                                type = "button"
                                classname = "btn btn-secondary"
                                datadismiss = "modal"
                                text("Close")
                            }
                        }
                    }
                }
            }
        }

        # إضافة سكريبت لتفعيل النوافذ المنبثقة
        html("<script>
            $(document).ready(function() {
                // تفعيل النوافذ المنبثقة
                $('#mainModal').modal({
                    show: false
                });
            });
        </script>")

        # إضافة الفوتر
        getFooter(oPage)

        noOutput()
    }

    oServer.setHTMLPage(oPage)
