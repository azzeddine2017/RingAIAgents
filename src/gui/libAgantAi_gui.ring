/*
    مكتبة RingAI Agents - الواجهة الرئيسية
    تجمع كل المكونات الأساسية في مكان واحد
*/


load "sqlitelib.ring"
load "ringThreadPro.ring"
Load "jsonlib.ring"
load "consolecolors.ring"
load "../utils/ringToJson.ring"
# تحميل المكتبات المساعدة
Load "../utils/helpers.ring"
Load "../utils/http_client.ring"
Load "../core/state.ring"

# تحميل المكونات الأساسية بالترتيب الصحيح
Load "../core/tools.ring"      # لا يعتمد على أي مكون آخر
Load "../core/memory.ring"     # لا يعتمد على أي مكون آخر
Load "../core/task.ring"       # لا يعتمد على أي مكون آخر
Load "../core/llm.ring"        # يعتمد على helpers
Load "../core/monitor.ring"    # لا يعتمد على أي مكون آخر
Load "../core/reinforcement.ring" # لا يعتمد على أي مكون آخر
Load "../core/flow.ring"       # يعتمد على state
Load "../core/agent.ring"      # يعتمد على llm, task, memory, tools
Load "../core/crew.ring"       # يعتمد على agent
