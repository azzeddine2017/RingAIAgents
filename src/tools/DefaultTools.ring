

class DefaultTools
    
    # Constructor
    func init
        registerDefaultTools()
        return self

    
    # Tool Registration
    func registerTool cName, cDescription, fCallback
        add(aTools, [
            :name = cName,
            :description = cDescription,
            :callback = fCallback,
            :enabled = true
        ])
        return self

    # Tool Execution
    func executeTool cName, aParams
        for tool in aTools {
            if tool[:name] = cName and tool[:enabled] {
                cCallback = tool[:callback]
                return call cCallback(aParams)
            }
        }
        return null

    # Web Tools Implementation
    func webSearch aParams
        cQuery = aParams[:query]
        cUrl = "https://api.duckduckgo.com/?q=" + URLEncode(cQuery) + "&format=json"
        cResponse = oHttp.getData(cUrl)
        return JSON2List(cResponse)

    func downloadFile aParams
        cUrl = aParams[:url]
        cDestination = aParams[:destination]
        return oHttp.download(cUrl, cDestination)

    func readWebpage aParams
        cUrl = aParams[:url]
        return oHttp.getData(cUrl)

    # File System Tools Implementation
    func readFile aParams
        cPath = aParams[:path]
        return read(cPath)

    func writeFile aParams
        cPath = aParams[:path]
        cContent = aParams[:content]
        write(cPath, cContent)
        return true

    func listDirectory aParams
        cPath = aParams[:path]
        return dir(cPath)

    func createDirectory aParams
        cPath = aParams[:path]
        system("mkdir " + cPath)
        return true

    func deleteFile aParams
        cPath = aParams[:path]
        remove(cPath)
        return true

    func zipFiles aParams
        cZipFile = aParams[:zipfile]
        aFiles = aParams[:files]
        oZip = zip_openfile(cZipFile, "w")
        for file in aFiles {
            zip_addfile(oZip, file)
        }
        zip_close(oZip)
        return true

    func unzipFile aParams
        cZipFile = aParams[:zipfile]
        cDestination = aParams[:destination]
        return zip_extract_allfiles(cZipFile, cDestination)

    # Data Processing Tools Implementation
    func parseJSON aParams
        cJson = aParams[:json]
        return JSON2List(cJson)

    func generateJSON aParams
        aData = aParams[:data]
        return List2JSON(aData)

    func csvToJSON aParams
        cCsvFile = aParams[:csv_file]
        cContent = read(cCsvFile)
        aResult = CSV2List(cContent)
        return List2JSON(aResult)

    func jsonToCSV aParams
        cJsonFile = aParams[:json_file]
        cDestination = aParams[:destination]
        aData = JSON2List(read(cJsonFile))
        write(cDestination, list2CSV(aData))
        return true

    # Image Processing Tools Implementation
    func resizeImage aParams
        cImage = aParams[:image]
        nWidth = aParams[:width]
        nHeight = aParams[:height]
        system('ffmpeg -i "' + cImage + '" -resize ' + nWidth + 'x' + nHeight + ' "' + cImage + '"')
        return true

    func convertImage aParams
        cSource = aParams[:source]
        cDestination = aParams[:destination]
        system('ffmpeg -i "' + cSource + '" "' + cDestination + '"')
        return true

    # System Tools Implementation
    func executeCommand aParams
        cCommand = aParams[:command]
        return systemCmd(cCommand)

    func getSystemInfo aParams
        aInfo = [
            :os = sysInfget("OS"),
            :cpu = sysInfget("CPU"),
            :memory = sysInfget("Memory"),
            :hostname = sysInfget("Hostname"),
            :username = sysInfget("Username")
        ]
        return aInfo

    func monitorProcess aParams
        nPid = aParams[:pid]
        return systemCmd('ps -p ' + nPid + ' -o %cpu,%mem,cmd')

    # Security Tools Implementation
    func encryptText aParams
        cText = aParams[:text]
        cKey = aParams[:key]    # 16 bytes
        for x = 0 to 15 cKey += char(x) next
        cIV = ""
        for x = 1 to 16 cIV += char(x)  next
        return Encrypt(cText,cKey,cIV,"aes128")

    func decryptText aParams
        cText = aParams[:text]
        cKey = aParams[:key]
        cIV = ""
        for x = 1 to 16 cIV += char(x)  next
        return  Decrypt(cText,cKey,cIV,"aes128")

    func hashText aParams
        cText = aParams[:text]
        cAlgorithm = aParams[:algorithm]
        switch cAlgorithm {
            On :md5
                return md5(cText)
            On :sha1
                return sha1(cText)
            On :sha256
                return sha256(cText)
            On :sha512
                return sha512(cText)
            On :SHA384
                return sha384(cText)
            On :SHA224
                return sha224(cText)
            other
                return ""    
        }

    # Network Tools Implementation
    func pingHost aParams
        cHost = aParams[:host]
        return systemCmd("ping -c 4 " + cHost)

    func portScan aParams
        cHost = aParams[:host]
        nStartPort = aParams[:start_port]
        nEndPort = aParams[:end_port]
        
        aOpenPorts = []
        for port = nStartPort to nEndPort {
            if systemCmd("nc -z -w1 " + cHost + " " + port) = 0 {
                add(aOpenPorts, port)
            }
        }
        return aOpenPorts

    func dnsLookup aParams
        cDomain = aParams[:domain]
        return systemCmd("nslookup " + cDomain)

    private

        aTools = []
        oHttp = new HttpClient()

    # Utility Functions
    func sysInfget cKey
        switch cKey {
            On :OS
                return systemCmd("uname -s")
            On :CPU
                return systemCmd("uname -p")
            On :Memory
                return systemCmd("free -h")
            On :Hostname
                return systemCmd("hostname")
            On :Username
                return systemCmd("whoami")
            other
                return ""
        }

    func URLEncode cStr
        cResult = ""
        for i = 1 to len(cStr) {
            c = substr(cStr, i, 1)
            if isalnum(c) or c = "-" or c = "_" or c = "." or c = "~" {
                cResult += c
            else
                cResult += "%" + hex(ascii(c))
            }
        }
        return cResult

    func registerDefaultTools
        # Web Tools
        registerTool(:web_search, "Search the web", method(:webSearch))
        registerTool(:download_file, "Download a file from URL", method(:downloadFile))
        registerTool(:read_webpage, "Read webpage content", method(:readWebpage))
        
        # File System Tools
        registerTool(:read_file, "Read file content", method(:readFile))
        registerTool(:write_file, "Write content to file", method(:writeFile))
        registerTool(:list_directory, "List directory contents", method(:listDirectory))
        registerTool(:create_directory, "Create new directory", method(:createDirectory))
        registerTool(:delete_file, "Delete file or directory", method(:deleteFile))
        registerTool(:zip_files, "Compress files into ZIP", method(:zipFiles))
        registerTool(:unzip_file, "Extract ZIP archive", method(:unzipFile))
        
        # Data Processing Tools
        registerTool(:parse_json, "Parse JSON string", method(:parseJSON))
        registerTool(:generate_json, "Generate JSON string", method(:generateJSON))
        registerTool(:csv_to_json, "Convert CSV to JSON", method(:csvToJSON))
        registerTool(:json_to_csv, "Convert JSON to CSV", method(:jsonToCSV))
        
        # Image Processing Tools
        registerTool(:resize_image, "Resize an image", method(:resizeImage))
        registerTool(:convert_image, "Convert image format", method(:convertImage))
        
        # System Tools
        registerTool(:execute_command, "Execute system command", method(:executeCommand))
        registerTool(:get_system_info, "Get system information", method(:getSystemInfo))
        registerTool(:monitor_process, "Monitor process resources", method(:monitorProcess))
        
        # Security Tools
        registerTool(:encrypt_text, "Encrypt text", method(:encryptText))
        registerTool(:decrypt_text, "Decrypt text", method(:decryptText))
        registerTool(:hash_text, "Generate hash of text", method(:hashText))
        
        # Network Tools
        registerTool(:ping_host, "Ping a host", method(:pingHost))
        registerTool(:port_scan, "Scan ports on host", method(:portScan))
        registerTool(:dns_lookup, "Perform DNS lookup", method(:dnsLookup))
