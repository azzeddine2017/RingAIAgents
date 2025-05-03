/*
    RingAI Agents API - Users Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showUsers
الوصف: عرض قائمة المستخدمين
*/
import System.Web

func showUsers
    oPage = New BootStrapWebPage {
        Title = "RingAI Users List"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/tables.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/users.js'></script>")

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
                        h1 { text("Users Management") }
                        p { text("View and manage all users in the system") }
                    }
                }

                div {
                    classname = "row mb-3"
                    div {
                        classname = "col-md-12 text-right"
                        button {
                            classname = "btn btn-warning"
                            onclick = "showAddUserForm()"
                            html("<i class='fas fa-plus'></i> Add New User")
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
                                        th { text("Username") }
                                        th { text("Email") }
                                        th { text("Role") }
                                        th { text("Last Login") }
                                        th { text("Status") }
                                        th { text("Actions") }
                                    }
                                }
                                tbody {
                                    for oUser in aUsers {
                                        tr {
                                            td { text(oUser.nID) }
                                            td { text(oUser.cUsername) }
                                            td { text(oUser.cEmail) }
                                            td {
                                                span {
                                                    classname = "badge badge-" +
                                                        iif(oUser.cRole = "admin", "danger",
                                                            iif(oUser.cRole = "manager", "warning", "info"))
                                                    text(oUser.cRole)
                                                }
                                            }
                                            td { text(oUser.dLastLogin) }
                                            td {
                                                span {
                                                    classname = "badge badge-" +
                                                        iif(oUser.cStatus = "active", "success", "secondary")
                                                    text(oUser.cStatus)
                                                }
                                            }
                                            td {
                                                div {
                                                    classname = "btn-group btn-group-sm"
                                                    button {
                                                        classname = "btn btn-info"
                                                        onclick = "editUser(" + oUser.nID + ")"
                                                        html("<i class='fas fa-edit'></i> Edit")
                                                    }
                                                    button {
                                                        classname = "btn btn-danger"
                                                        onclick = "deleteUser(" + oUser.nID + ")"
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
        }

        # إضافة الفوتر
        getFooter(oPage)

        noOutput()
    }

    oServer.setHTMLPage(oPage)
