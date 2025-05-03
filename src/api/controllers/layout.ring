/*
    RingAI Agents API - Layout Components
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: loadCommonStyles
الوصف: تحميل ملفات CSS المشتركة لجميع الصفحات
*/
func loadCommonStyles oPage
    oPage.html("<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css'>")
    oPage.html("<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css'>")
    oPage.html("<script src='https://code.jquery.com/jquery-3.6.0.min.js'></script>")
    oPage.html("<script src='https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js'></script>")
    oPage.html("<script src='https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.min.js'></script>")
    oPage.html("<link rel='stylesheet' href='/static/css/common.css'>")
    oPage.html("<link rel='stylesheet' href='/static/css/layout.css'>")
    oPage.html("<link rel='stylesheet' href='/static/css/user-menu.css'>")
    oPage.html("<script src='/static/js/common.js'></script>")

/*
الدالة: getHeader
الوصف: إنشاء هيدر مشترك لجميع الصفحات
*/
func getHeader oPage
    oPage.html("<header class='main-header compact-header'>
        <nav class='navbar navbar-expand-lg navbar-dark'>
            <div class='container'>
                <a class='navbar-brand compact-brand' href='/'>
                    <img src='https://cdn-icons-png.flaticon.com/512/2103/2103652.png' alt='RingAI Logo'>
                    <span>RingAI</span>
                </a>
                <button class='navbar-toggler' type='button' data-toggle='collapse' data-target='#navbarNav' aria-controls='navbarNav' aria-expanded='false' aria-label='Toggle navigation'>
                    <span class='navbar-toggler-icon'></span>
                </button>
                <div class='collapse navbar-collapse' id='navbarNav'>
                    <ul class='navbar-nav mr-auto compact-nav'>
                        <li class='nav-item " + iif(oPage.Title = "RingAI Agents Dashboard", "active", "") + "'>
                            <a class='nav-link' href='/'><i class='fas fa-home'></i> <span>Dashboard</span></a>
                        </li>
                        <li class='nav-item " + iif(oPage.Title = "RingAI Agents List", "active", "") + "'>
                            <a class='nav-link' href='/agents'><i class='fas fa-robot'></i> <span>Agents</span></a>
                        </li>
                        <li class='nav-item " + iif(oPage.Title = "RingAI Teams List", "active", "") + "'>
                            <a class='nav-link' href='/teams'><i class='fas fa-users'></i> <span>Teams</span></a>
                        </li>
                        <li class='nav-item " + iif(oPage.Title = "RingAI Tasks List", "active", "") + "'>
                            <a class='nav-link' href='/tasks'><i class='fas fa-tasks'></i> <span>Tasks</span></a>
                        </li>
                        <li class='nav-item " + iif(oPage.Title = "RingAI Users List", "active", "") + "'>
                            <a class='nav-link' href='/users'><i class='fas fa-user-cog'></i> <span>Users</span></a>
                        </li>
                        <li class='nav-item " + iif(oPage.Title = "RingAI Chat Interface", "active", "") + "'>
                            <a class='nav-link' href='/chat'><i class='fas fa-comments'></i> <span>Chat</span></a>
                        </li>
                        <li class='nav-item " + iif(oPage.Title = "RingAI API Keys Management", "active", "") + "'>
                            <a class='nav-link' href='/api-keys'><i class='fas fa-key'></i> <span>API Keys</span></a>
                        </li>
                    </ul>
                    <div class='user-menu dropdown compact-user'>
                        <a href='#' class='dropdown-toggle' id='userDropdown' role='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>
                            <img src='https://cdn-icons-png.flaticon.com/512/3135/3135715.png' alt='User'>
                            <span>Admin</span>
                        </a>
                        <div class='dropdown-menu dropdown-menu-right' aria-labelledby='userDropdown'>
                            <a class='dropdown-item' href='#'><i class='fas fa-user'></i> Profile</a>
                            <a class='dropdown-item' href='#'><i class='fas fa-cog'></i> Settings</a>
                            <div class='dropdown-divider'></div>
                            <a class='dropdown-item' href='#'><i class='fas fa-sign-out-alt'></i> Logout</a>
                        </div>
                    </div>
                </div>
            </div>
        </nav>
    </header>")


/*
الدالة: getFooter
الوصف: إنشاء فوتر مشترك لجميع الصفحات
*/
func getFooter oPage
    oPage.html("<footer class='main-footer'>
        <div class='container'>
            <div class='footer-links'>
                <a href='/'><i class='fas fa-home'></i> Dashboard</a>
                <a href='/agents'><i class='fas fa-robot'></i> Agents</a>
                <a href='/teams'><i class='fas fa-users'></i> Teams</a>
                <a href='/tasks'><i class='fas fa-tasks'></i> Tasks</a>
                <a href='/users'><i class='fas fa-user-cog'></i> Users</a>
                <a href='/chat'><i class='fas fa-comments'></i> Chat</a>
                <a href='/api-keys'><i class='fas fa-key'></i> API Keys</a>
            </div>
            <div class='footer-copyright'>
                <p>&copy; " + date() + " RingAI Agents. All rights reserved.</p>
                <p>Powered by Ring Language</p>
            </div>
        </div>
    </footer>")

