/*
    RingAI Agents API - API Keys Controller
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: showAPIKeys
الوصف: عرض صفحة إدارة مفاتيح API
*/
import System.Web

func showAPIKeys
    oPage = new BootStrapWebPage {
        Title = "RingAI API Keys Management"
        # تحميل الستايلات المشتركة
        loadCommonStyles(oPage)
        # تحميل ستايلات خاصة بالصفحة
        html("<link rel='stylesheet' href='/static/css/api-keys.css'>")
        html("<script src='/static/js/common.js'></script>")
        html("<script src='/static/js/api-keys.js'></script>")

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
                        h1 { text("API Keys Management") }
                        p { text("Manage your API keys for language models and other services") }
                    }
                }

                # قسم مفاتيح API
                div {
                    classname = "row"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-primary text-white d-flex justify-content-between align-items-center"
                                h5 { text("Language Model API Keys") }
                                button {
                                    id = "add-key-btn"
                                    classname = "btn btn-sm btn-light"
                                    onclick = "$('#add-key-modal').modal('show');"
                                    html("<i class='fas fa-plus'></i> Add New Key")
                                }
                            }
                            div {
                                classname = "card-body"
                                div {
                                    classname = "table-responsive"
                                    table {
                                        classname = "table table-striped"
                                        thead {
                                            tr {
                                                th { text("Provider") }
                                                th { text("Model") }
                                                th { text("Key") }
                                                th { text("Status") }
                                                th { text("Actions") }
                                            }
                                        }
                                        tbody {
                                            id = "api-keys-table"
                                            tr {
                                                id = "loading-row"
                                                td {
                                                    colspan = "5"
                                                    classname = "text-center"
                                                    text("Loading API keys...")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                # قسم المعلومات
                div {
                    classname = "row mt-4"
                    div {
                        classname = "col-md-12"
                        div {
                            classname = "card"
                            div {
                                classname = "card-header bg-secondary text-white"
                                h5 { text("API Keys Information") }
                            }
                            div {
                                classname = "card-body"
                                div {
                                    classname = "row"
                                    div {
                                        classname = "col-md-6"
                                        h6 { text("Supported Providers") }
                                        ul {
                                            li { text("Google (Gemini)") }
                                            li { text("OpenAI (GPT)") }
                                            li { text("Anthropic (Claude)") }
                                            li { text("Mistral AI") }
                                            li { text("Cohere") }
                                        }
                                    }
                                    div {
                                        classname = "col-md-6"
                                        h6 { text("How to Get API Keys") }
                                        ul {
                                            li {
                                                html("Google Gemini: <a href='https://ai.google.dev/' target='_blank'>Google AI Studio</a>")
                                            }
                                            li {
                                                html("OpenAI: <a href='https://platform.openai.com/' target='_blank'>OpenAI Platform</a>")
                                            }
                                            li {
                                                html("Anthropic: <a href='https://console.anthropic.com/' target='_blank'>Anthropic Console</a>")
                                            }
                                            li {
                                                html("Mistral AI: <a href='https://console.mistral.ai/' target='_blank'>Mistral AI Console</a>")
                                            }
                                            li {
                                                html("Cohere: <a href='https://dashboard.cohere.com/' target='_blank'>Cohere Dashboard</a>")
                                            }
                                        }
                                    }
                                }
                                div {
                                    classname = "alert alert-info mt-3"
                                    html("<i class='fas fa-info-circle'></i> <strong>Note:</strong> API keys are stored securely and encrypted in the database. They are only used to authenticate with the respective services.")
                                }
                            }
                        }
                    }
                }
            }
        }

        # Modal لإضافة مفتاح جديد
        div {
            id = "add-key-modal"
            classname = "modal fade"
            tabindex = "-1"
            role = "dialog"
            aria_labelledby = "add-key-modal-label"
            aria_hidden = "true"
            div {
                classname = "modal-dialog"
                role = "document"
                div {
                    classname = "modal-content"
                    div {
                        classname = "modal-header"
                        h5 {
                            id = "add-key-modal-label"
                            classname = "modal-title"
                            text("Add New API Key")
                        }
                        button {
                            type = "button"
                            classname = "close"
                            data = [
                                :dismiss = "modal"
                            ]
                            aria_label = "Close"
                            span {
                                aria_hidden = "true"
                                html("&times;")
                            }
                        }
                    }
                    div {
                        classname = "modal-body"
                        form {
                            id = "add-key-form"
                            div {
                                classname = "form-group"
                                div {
                                    text("Provider:")
                                }
                                select {
                                    id = "provider"
                                    classname = "form-control"
                                    required = "required"
                                    option { value = "" text("Select Provider") }
                                    option { value = "google" text("Google (Gemini)") }
                                    option { value = "openai" text("OpenAI (GPT)") }
                                    option { value = "anthropic" text("Anthropic (Claude)") }
                                    option { value = "mistral" text("Mistral AI") }
                                    option { value = "cohere" text("Cohere") }
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("Model:")
                                }
                                select {
                                    id = "model"
                                    classname = "form-control"
                                    required = "required"
                                    option { value = "" text("Select Model") }
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("API Key:")
                                }
                                input {
                                    type = "password"
                                    id = "api-key"
                                    classname = "form-control"
                                    placeholder = "Enter your API key"
                                    required = "required"
                                }
                                text("Your API key will be stored securely.")
                            }
                        }
                    }
                    div {
                        classname = "modal-footer"
                        button {
                            type = "button"
                            classname = "btn btn-secondary"
                            data = [
                                :dismiss = "modal"
                            ]
                            text("Cancel")
                        }
                        button {
                            type = "button"
                            id = "save-key-btn"
                            classname = "btn btn-primary"
                            text("Save Key")
                        }
                    }
                }
            }
        }

        # Modal لتعديل مفتاح
        div {
            id = "edit-key-modal"
            classname = "modal fade"
            tabindex = "-1"
            role = "dialog"
            aria_labelledby = "edit-key-modal-label"
            aria_hidden = "true"
            div {
                classname = "modal-dialog"
                role = "document"
                div {
                    classname = "modal-content"
                    div {
                        classname = "modal-header"
                        h5 {
                            id = "edit-key-modal-label"
                            classname = "modal-title"
                            text("Edit API Key")
                        }
                        button {
                            type = "button"
                            classname = "close"
                            data = [
                                :dismiss = "modal"
                            ]
                            aria_label = "Close"
                            span {
                                aria_hidden = "true"
                                html("&times;")
                            }
                        }
                    }
                    div {
                        classname = "modal-body"
                        form {
                            id = "edit-key-form"
                            input {
                                type = "hidden"
                                id = "edit-key-id"
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("Provider:")
                                }
                                input {
                                    type = "text"
                                    id = "edit-provider"
                                    classname = "form-control"
                                    readonly = "readonly"
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("Model:")
                                }
                                input {
                                    type = "text"
                                    id = "edit-model"
                                    classname = "form-control"
                                    readonly = "readonly"
                                }
                            }
                            div {
                                classname = "form-group"
                                div {
                                    text("API Key:")
                                }
                                input {
                                    type = "password"
                                    id = "edit-api-key"
                                    classname = "form-control"
                                    placeholder = "Enter new API key"
                                    required = "required"
                                }
                                text("Leave blank to keep the current key.")
                            }
                        }
                    }
                    div {
                        classname = "modal-footer"
                        button {
                            type = "button"
                            classname = "btn btn-secondary"
                            data = [
                                :dismiss = "modal"
                            ]
                            text("Cancel")
                        }
                        button {
                            type = "submit"
                            id = "update-key-btn"
                            classname = "btn btn-primary"
                            text("Update Key")
                        }
                    }
                }
            }
        }

        # إضافة الفوتر
        getFooter(oPage)

        # إضافة سكريبت لتحميل مفاتيح API
        html("<script>
            // تنفيذ الكود بعد تحميل الصفحة
            $(document).ready(function() {
                console.log('Document ready');

                // Load API keys
                loadAPIKeys();

                // Set up event handlers
                $('#provider').change(function() {
                    updateModelOptions();
                });

                // تعيين معالج حدث زر الإضافة بعدة طرق
                $('#add-key-btn').on('click', function(e) {
                    console.log('Add key button clicked via jQuery');
                    e.preventDefault();
                    $('#add-key-modal').modal('show');
                    return false;
                });

                // طريقة بديلة لفتح النافذة المنبثقة
                document.getElementById('add-key-btn').addEventListener('click', function(e) {
                    console.log('Add key button clicked via addEventListener');
                    $('#add-key-modal').modal('show');
                });

                // تعيين معالج حدث زر الحفظ بطريقة مباشرة
                document.getElementById('save-key-btn').onclick = function() {
                    console.log('Save button clicked directly');
                    alert('Save button clicked');
                    saveAPIKey();
                    return false;
                };

                // تعيين معالج حدث تقديم النموذج بطريقة مباشرة
                document.getElementById('add-key-form').onsubmit = function(e) {
                    e.preventDefault();
                    console.log('Form submitted directly');
                    saveAPIKey();
                    return false;
                };

                // تعيين معالج حدث زر التحديث بطريقة مباشرة
                document.getElementById('update-key-btn').onclick = function() {
                    console.log('Update button clicked directly');
                    updateAPIKey();
                    return false;
                };

                // تعيين معالج حدث تقديم نموذج التحديث بطريقة مباشرة
                document.getElementById('edit-key-form').onsubmit = function(e) {
                    e.preventDefault();
                    console.log('Edit form submitted directly');
                    updateAPIKey();
                    return false;
                };

                // محاولة فتح النافذة المنبثقة بعد تحميل الصفحة بفترة قصيرة
                setTimeout(function() {
                    console.log('Trying to show modal after timeout');
                    try {
                        $('#add-key-modal').modal({
                            keyboard: false,
                            backdrop: 'static',
                            show: false
                        });
                    } catch (e) {
                        console.error('Error initializing modal:', e);
                    }
                }, 1000);
            });

            // دالة مساعدة لفتح النافذة المنبثقة
            function openAddKeyModal() {
                console.log('openAddKeyModal function called');
                $('#add-key-modal').modal('show');
            }
        </script>")

        # إضافة زر إضافي لفتح النافذة المنبثقة
        html("<div class='container mt-3'>
            <button onclick='openAddKeyModal()' class='btn btn-primary'>
                <i class='fas fa-plus'></i> Open Add Key Modal (Alternative)
            </button>
        </div>")

        noOutput()
    }

    oServer.setHTMLPage(oPage)
