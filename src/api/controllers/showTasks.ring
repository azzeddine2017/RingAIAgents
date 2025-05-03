/*
    RingAI Agents API - Tasks Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showTasks
الوصف: عرض قائمة المهام
*/
import System.Web

func showTasks
    oPage = New BootStrapWebPage {
        Title = "RingAI Tasks List"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/tables.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/tasks.js'></script>")

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
                        h1 { text("Tasks Management") }
                        p { text("View and manage all tasks in the system") }
                    }
                }

                div {
                    classname = "row mb-3"
                    div {
                        classname = "col-md-12 text-right"
                        button {
                            classname = "btn btn-success"
                            onclick = "showAddTaskForm()"
                            html("<i class='fas fa-plus'></i> Add New Task")
                        }
                    }
                }

                div {
                    classname = "row"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "table-responsive"
                            table {
                                classname = "table table-striped table-bordered"
                                thead {
                                    classname = "thead-dark"
                                    tr {
                                        th { text("ID") }
                                        th { text("Title") }
                                        th { text("Description") }
                                        th { text("Assigned To") }
                                        th { text("Priority") }
                                        th { text("Progress") }
                                        th { text("Status") }
                                        th { text("Actions") }
                                    }
                                }
                                tbody {
                                    for oTask in aTasks {
                                        tr {
                                            td { text(oTask.getId()) }
                                            td { text(oTask.getTitle()) }
                                            td { text(oTask.getDescription()) }
                                            td { text(oTask.getAssignedTo().getName()) }
                                           /* td {
                                                span {
                                                    classname = "badge badge-" +
                                                        iif(oTask.getPriority() = 1, "danger",
                                                            iif(oTask.getPriority() = 2, "warning", "info"))
                                                    text(iif(oTask.getPriority() = 1, "High",
                                                            iif(oTask.getPriority() = 2, "Medium", "Low")))
                                                }
                                            }
                                            td {
                                                div {
                                                    classname = "progress"
                                                    div {
                                                        classname = "progress-bar bg-" +
                                                            iif(oTask.getProgress() < 30, "danger",
                                                                iif(oTask.getProgress() < 70, "warning", "success"))
                                                        style = "width: " + oTask.getProgress() + "%"
                                                        role = "progressbar"
                                                        ariaValuenow = oTask.getProgress()
                                                        ariaValuemin = "0"
                                                        ariaValuemax = "100"
                                                        text(oTask.getProgress() + "%")
                                                    }
                                                }
                                            }
                                            td {
                                                span {
                                                    classname = "badge badge-" +
                                                        iif(oTask.getStatus() = "Completed", "success",
                                                            iif(oTask.getStatus() = "In Progress", "primary", "secondary"))
                                                    text(oTask.getStatus())
                                                }
                                            }*/
                                            td {
                                                div {
                                                    classname = "btn-group btn-group-sm"
                                                    button {
                                                        classname = "btn btn-info"
                                                        onclick = "editTask(" + oTask.getId() + ")"
                                                        html("<i class='fas fa-edit'></i> Edit")
                                                    }
                                                    button {
                                                        classname = "btn btn-danger"
                                                        onclick = "deleteTask(" + oTask.getId() + ")"
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

               /* div {
                    classname = "row mt-4"
                    div {
                        classname = "col-md-12 text-center"
                        Link { Link = "/" classname = "btn btn-secondary" html("<i class='fas fa-home'></i> Back to Dashboard") }
                    }
                }*/

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
        }

        # إضافة الفوتر
        getFooter(oPage)

        noOutput()
    }

    oServer.setHTMLPage(oPage)
