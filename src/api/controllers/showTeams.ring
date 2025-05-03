/*
    RingAI Agents API - Teams Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showTeams
الوصف: عرض قائمة الفرق
*/
import System.Web

func showTeams
    oPage = New BootStrapWebPage {
        Title = "RingAI Teams List"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/tables.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/teams.js'></script>")

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
                        h1 { text("Teams Management") }
                        p { text("View and manage all teams in the system") }
                    }
                }

                div {
                    classname = "row mb-3"
                    div {
                        classname = "col-md-12 text-right"
                        button {
                            classname = "btn btn-success"
                            onclick = "showAddTeamForm()"
                            html("<i class='fas fa-plus'></i> Add New Team")
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
                                classname = "table table-striped table-bordered table-horizontal-scroll table-sticky-header"
                                thead {
                                    classname = "thead-dark"
                                    tr {
                                        th { text("ID") }
                                        th { text("Name") }
                                        th { text("Objective") }
                                        th { text("Leader") }
                                        th { text("Members") }
                                        th { text("Performance") }
                                        th { text("Actions") }
                                    }
                                }
                                tbody {
                                    for oCrew in aTeams {
                                        tr {
                                            td { text(oCrew.getID()) }
                                            td { text(oCrew.getName()) }
                                            td { text(oCrew.getObjective()) }
                                            td { text(oCrew.getLeader().getName()) }
                                            td { text(len(oCrew.getMembers())) }
                                            td {
                                                div {
                                                    classname = "progress"
                                                    div {
                                                        classname = "progress-bar bg-success"
                                                        style = "width: " + oCrew.getPerformanceScore() + "%"
                                                        role = "progressbar"
                                                        ariaValuenow = oCrew.getPerformanceScore()
                                                        ariaValuemin = "0"
                                                        ariaValuemax = "100"
                                                        text("" +oCrew.getPerformanceScore() + "%")
                                                    }
                                                }
                                            }
                                            td {
                                                div {
                                                    classname = "btn-group btn-group-sm"
                                                    button {
                                                        classname = "btn btn-info"
                                                        onclick = "editTeam('" + oCrew.getID() + "')"
                                                        html("<i class='fas fa-edit'></i> Edit")
                                                    }
                                                    button {
                                                        classname = "btn btn-danger"
                                                        onclick = "deleteTeam('" + oCrew.getID() + "')"
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
