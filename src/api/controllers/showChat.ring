/*
    RingAI Agents API - Chat Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showChat
الوصف: عرض واجهة الشات
*/
import System.Web

func showChat
    oPage = new BootStrapWebPage {
        Title = "RingAI Chat Interface"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/chat.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/chat.js'></script>")

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
                        h1 { text("RingAI Chat Interface") }
                        p { text("Interact with AI agents through natural language") }
                    }
                }

                # قسم اختيار العميل والتحكم
                div {
                    classname = "row mb-3"
                    div {
                        classname = "col-md-8"
                        div {
                            classname = "agent-selector"
                            text("Select Agent:")
                            select {
                                id = "agent-selector"
                                classname = "form-control"
                                option { value = "0" text("Default AI Assistant") }

                                # التحقق من وجود عملاء
                                if isList(aAgents) and len(aAgents) > 0 {
                                    ? logger("showChat function", "Number of agents: " + len(aAgents), :info)

                                    # طباعة معلومات عن كل عميل
                                    for i = 1 to len(aAgents) {
                                        ? logger("showChat function", "Agent " + i + " type: " + type(aAgents[i]), :info)
                                        if isObject(aAgents[i]) {
                                            ? logger("showChat function", "Agent " + i + " class: " + classname(aAgents[i]), :info)
                                            ? logger("showChat function", "Checking agent " + i, :info)

                                            # طباعة قائمة بجميع الدوال المتاحة في العميل
                                            aMethods = methods(aAgents[i])
                                           /// ? logger("showChat function", "Agent " + i + " methods: " + list2str(aMethods), :info)

                                            # لغة الرينج ليست حساسة لحالة الأحرف، لذلك نتحقق من وجود الدوال بأحرف صغيرة
                                            if methodExists(aAgents[i], "getname") and methodExists(aAgents[i], "getrole") and methodExists(aAgents[i], "getid") {
                                                cName = aAgents[i].getname()
                                                cRole = aAgents[i].getrole()
                                                cId = aAgents[i].getid()

                                                ? logger("showChat function", "Adding agent: " + cName + " (" + cRole + ") with ID: " + cId, :info)

                                                option {
                                                    value = cId
                                                    text(cName + " (" + cRole + ")")
                                                    if i = 1 {
                                                        selected = "selected"
                                                    }
                                                }
                                            else
                                                ? logger("showChat function", "Agent " + i + " missing required methods", :error)
                                            }
                                        else
                                            ? logger("showChat function", "Agent " + i + " is not an object", :error)
                                        }
                                    }
                                else
                                    ? logger("showChat function", "No agents found or agents list is not valid, adding default agents", :warning)

                                    # إضافة وكلاء افتراضيين للقائمة المنسدلة
                                    option {
                                        value = "agent_default_1"
                                        name = "Default Assistant"
                                        text("Default Assistant (Assistant)")
                                    }

                                    option {
                                        value = "agent_default_2"
                                        name = "Code Assistant"
                                        text("Code Assistant (Developer)")
                                    }

                                    option {
                                        value = "agent_default_3"
                                        name = "Education Assistant"
                                        text("Education Assistant (Teacher)")
                                    }
                                }
                            }
                        }
                    }
                    div {
                        classname = "col-md-4 text-right"
                        button {
                            id = "clear-chat"
                            classname = "btn btn-outline-secondary"
                            onclick = "clearChat()"
                            html("<i class='fas fa-trash'></i> Clear Chat")
                        }
                        button {
                            id = "save-chat"
                            classname = "btn btn-outline-primary ml-2"
                            onclick = "saveChat()"
                            html("<i class='fas fa-save'></i> Save Chat")
                        }
                    }
                }

                # واجهة الشات الرئيسية
                div {
                    classname = "row"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "chat-container"
                            div {
                                classname = "chat-header"
                                Image {
                                    src = "https://cdn-icons-png.flaticon.com/512/4712/4712010.png"
                                    alt = "AI Assistant"
                                    classname = "agent-avatar"
                                }
                                div {
                                    classname = "chat-header-info"
                                    h4 { id = "chat-title" text("AI Assistant") }
                                    p {
                                        id = "agent-status"
                                        classname = "status-online"
                                        text("Ready to chat")
                                    }
                                }
                            }
                            div {
                                classname = "chat-messages"
                                id = "chat-messages"
                                div {
                                    classname = "ai-message message"
                                    text("Hello! I'm your AI assistant. How can I help you today?")
                                    div {
                                        classname = "message-time"
                                        text(TimeList()[5])
                                    }
                                }
                                div {
                                    classname = "typing-indicator"
                                    id = "typing-indicator"
                                    span {}
                                    span {}
                                    span {}
                                }
                            }
                            div {
                                classname = "chat-input"
                                form {
                                    id = "chat-form"
                                    onsubmit = "sendMessage(event)"
                                    div {
                                        classname = "input-group"
                                        input {
                                            type = "text"
                                            id = "message-input"
                                            classname = "form-control"
                                            placeholder = "Type your message here..."
                                            autocomplete = "off"
                                        }
                                        div {
                                            classname = "input-group-append"
                                            button {
                                                type = "submit"
                                                classname = "btn btn-primary"
                                                html("<i class='fas fa-paper-plane'></i>")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                # قسم تاريخ المحادثات
                div {
                    classname = "row mt-4"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-secondary text-white"
                                h5 { text("Chat History") }
                            }
                            div {
                                classname = "card-body chat-history"
                                id = "chat-history"
                                p { text("Your recent conversations will appear here.") }
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
            });
        </script>")

        noOutput()
    }

    oServer.setHTMLPage(oPage)
