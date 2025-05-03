/*
* دوال تحويل بين Ring و JSON
* Author: Azzeddine Remmal
*/

load "stdlib.ring"


if isMainSourceFile() {
    # مثال للاستخدام
    cJSON4 = '{"name": "Ahmed", "address": {"city": "Cairo", "country": "Egypt"}}'
    //? FromJSON(cJSON4)

    aList = [
        :name = "Ahmed",
        :age = 25,
        :skills = [
            "Ring", 
            "Python", 
            "JavaScript"],
        :address = [
            :city = "Cairo",
            :country = "Egypt"
        ]
    ]

    ? listToJSON(aList, 0)
    //? FromJSON(ToJSON(aList, 0))
}


/*func FromJSON(cJSON)
    if isString(cJSON) and len(cJSON) > 0
        return json2list(cJSON)
    ok
    return NULL
*/
func listToJSON(aInput, nLevel)
    if aInput = NULL return "null" ok
    cIndent = Copy("    ", nLevel)
    cNextIndent = Copy("    ", nLevel + 1)
    
    switch type(aInput) {
        case "STRING"
            cStr = aInput
            cStr = substr(cStr,'"','\"')
            cStr = substr(cStr,nl,"\n")
            return '"' + cStr + '"'
            
        case "NUMBER"
            return "" + aInput
            
        case "LIST"
            if IsAssociativeList(aInput)
                return ListToJSONObject(aInput, nLevel)
            ok
            return ListToJSONArray(aInput, nLevel)
            
        case "OBJECT"
            return ObjectToJSON(aInput, nLevel)
            
        default
            return "null"
    }

func IsAssociativeList(aList)
    if not isList(aList) return false ok
    for item in aList
        if isList(item) and len(item) = 2 and 
           (isString(item[1]) or isNumber(item[1]))
            return true
        ok
    next
    return false

func ListToJSONObject(aList, nLevel)
    cIndent = Copy("    ", nLevel)
    cNextIndent = Copy("    ", nLevel + 1)
    
    cJSON = "{" + nl
    lStart = True
    
    for item in aList
        if isList(item) and len(item) = 2
            if !lStart  
                cJSON += "," + nl
            else
                lStart = False
            ok
            
           if isString(item[1])  cKey =  item[1] else cKey = string(item[1]) ok
            cJSON += cNextIndent + '"' + cKey + '": ' + 
                    listToJSON(item[2], nLevel + 1)
        ok
    next
    
    cJSON += nl + cIndent + "}"
    return cJSON

func ListToJSONArray(aList, nLevel)
    cIndent = Copy("    ", nLevel)
    cNextIndent = Copy("    ", nLevel + 1)
    
    cJSON = "[" + nl
    lStart = True
    
    for item in aList
        if !lStart  
            cJSON += "," + nl
        else
            lStart = False
        ok
        cJSON += cNextIndent + listToJSON(item, nLevel + 1)
    next
    
    cJSON += nl + cIndent + "]"
    return cJSON

func ObjectToJSON(oObj, nLevel)
    cIndent = Copy("    ", nLevel)
    cNextIndent = Copy("    ", nLevel + 1)
    
    cJSON = "{" + nl
    aAttributs = attributes(oObj)
    lStart = True
    
    for cAttribut in aAttributs
        if !lStart
            cJSON += "," + nl
        else 
            lStart = False
        ok
        
        value = getattribute(oObj, cAttribut)
        cJSON += cNextIndent + '"' + cAttribut + '": ' + 
                 listToJSON(value, nLevel + 1)
    next
    
    cJSON += nl + cIndent + "}"
    return cJSON