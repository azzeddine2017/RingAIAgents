/*
    RingAI Agents API - Monitor Functions
    Author: Azzeddine Remmal
    Date: 2025
*/

/*
الدالة: configureAlerts
الوصف: تكوين إعدادات التنبيهات
*/
func configureAlerts
    try {
        aAlerts = oServer["alerts"]

        for oAlert in aAlerts {
            oMonitor.addAlert(
                oAlert["metric"],
                oAlert["condition"],
                oAlert["threshold"],
                oAlert["action"]
            )
        }

        ? logger("configureAlerts function", "Alerts configured successfully", :info)
        oServer.setContent('{"status":"success","message":"Alerts configured successfully"}',
                          "application/json")
    catch
        ? logger("configureAlerts function", "Error configuring alerts: " + cCatchError, :error)
        oServer.setContent('{"status":"error","message":"' + cCatchError + '"}',
                        "application/json")
    }
