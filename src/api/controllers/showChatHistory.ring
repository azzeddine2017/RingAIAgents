/*
    RingAI Agents API - Chat History Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showChatHistory
الوصف: عرض تاريخ المحادثات
*/
import System.Web

func showChatHistory
    oPage = new BootStrapWebPage {
        Title = "RingAI Chat History"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/chat.css'>")
        html("<script src='/static/js/chat-history.js'></script>")

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
                        h1 { text("RingAI Chat History") }
                        p { text("View and manage your conversation history") }
                    }
                }

                # قسم البحث والتصفية
                div {
                    classname = "row mb-4"
                    div {
                        classname = "col-md-6"
                        div {
                            classname = "input-group"
                            input {
                                type = "text"
                                id = "search-input"
                                classname = "form-control"
                                placeholder = "Search conversations..."
                            }
                            div {
                                classname = "input-group-append"
                                button {
                                    id = "search-button"
                                    classname = "btn btn-primary"
                                    onclick = "searchConversations()"
                                    html("<i class='fas fa-search'></i>")
                                }
                            }
                        }
                    }
                    div {
                        classname = "col-md-6"
                        div {
                            classname = "d-flex justify-content-end"
                            select {
                                id = "agent-filter"
                                classname = "form-control mr-2"
                                style = "width: auto;"
                                option { value = "0" text("All Agents") }

                                # التحقق من وجود عملاء
                                if isList(aAgents) and len(aAgents) > 0 {
                                    ? logger("showChatHistory function", "Number of agents: " + len(aAgents), :info)
                                    for i = 1 to len(aAgents) {
                                        if isObject(aAgents[i]) {
                                            ? logger("showChatHistory function", "Checking agent " + i, :info)
                                            # لغة الرينج ليست حساسة لحالة الأحرف، لذلك نتحقق من وجود الدوال بأحرف صغيرة
                                            if methodExists(aAgents[i], "getname") and methodExists(aAgents[i], "getid") {
                                                cName = aAgents[i].getname()
                                                cId = aAgents[i].getid()

                                                ? logger("showChatHistory function", "Adding agent: " + cName + " with ID: " + cId, :info)

                                                option {
                                                    value = cId
                                                    text(cName)
                                                }
                                            else
                                                ? logger("showChatHistory function", "Agent " + i + " missing required methods", :error)
                                            }
                                        else
                                            ? logger("showChatHistory function", "Agent " + i + " is not an object", :error)
                                        }
                                    }
                                else
                                    ? logger("showChatHistory function", "No agents found or agents list is not valid, adding default agents", :warning)

                                    # إضافة وكلاء افتراضيين للقائمة المنسدلة
                                    option {
                                        value = "agent_default_1"
                                        text("Default Assistant")
                                    }

                                    option {
                                        value = "agent_default_2"
                                        text("Code Assistant")
                                    }

                                    option {
                                        value = "agent_default_3"
                                        text("Education Assistant")
                                    }
                                }
                            }
                            select {
                                id = "date-filter"
                                classname = "form-control"
                                style = "width: auto;"
                                option { value = "all" text("All Time") }
                                option { value = "today" text("Today") }
                                option { value = "yesterday" text("Yesterday") }
                                option { value = "week" text("This Week") }
                                option { value = "month" text("This Month") }
                            }
                        }
                    }
                }

                # قسم عرض المحادثات
                div {
                    classname = "row"
                    div {
                        classname = "col-md-4"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-secondary text-white"
                                h5 { text("Conversations") }
                            }
                            div {
                                classname = "card-body chat-history"
                                id = "chat-history-list"
                                p { text("Loading conversations...") }
                            }
                        }
                    }
                    div {
                        classname = "col-md-8"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-primary text-white d-flex justify-content-between align-items-center"
                                h5 {
                                    id = "conversation-title"
                                    text("Conversation Details")
                                }
                                div {
                                    classname = "btn-group"
                                    button {
                                        id = "export-button"
                                        classname = "btn btn-sm btn-light"
                                        onclick = "exportConversation()"
                                        html("<i class='fas fa-download'></i> Export")
                                    }
                                    button {
                                        id = "delete-button"
                                        classname = "btn btn-sm btn-danger ml-2"
                                        onclick = "deleteConversation()"
                                        html("<i class='fas fa-trash'></i> Delete")
                                    }
                                }
                            }
                            div {
                                classname = "card-body conversation-details"
                                id = "conversation-details"
                                p { text("Select a conversation to view details") }
                            }
                        }
                    }
                }
            }
        }

        # إضافة الفوتر
        getFooter(oPage)

        # إضافة سكريبت لتحميل تاريخ المحادثات
        html("<script>
            $(document).ready(function() {
                // Load chat history
                loadChatHistory();

                // Set up event handlers
                $('#agent-filter, #date-filter').change(function() {
                    filterConversations();
                });

                $('#search-input').on('keyup', function(e) {
                    if (e.key === 'Enter') {
                        searchConversations();
                    }
                });
            });
        </script>")

        noOutput()
    }

    oServer.setHTMLPage(oPage)
