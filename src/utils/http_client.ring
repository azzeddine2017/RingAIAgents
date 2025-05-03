/*
    RingAI Agents Library - HTTP Client Utility
    Enhanced with file handling and multipart support
*/

Load "subprocess.ring"

class HttpClient
    pProcess = NULL      # ProcessManager instance
    cUserAgent = "RingAI/1.0"
    aHeaders = []        # Request headers
    cLastError = ""      # Last error message

    func init
        pProcess = new ProcessManager()

    func getData cUrl
        try {
            cCommand = 'curl -s -X GET "' + cUrl + '"'
            cCommand = addHeaders(cCommand)

            pProcess.RunCommand(cCommand)
            pProcess.waitForComplete()
            cOutput = pProcess.readOutput()
            cError = pProcess.getStderr()

            if pProcess.getExitCode() = 0 {
                return [
                    :code = 200,
                    :body = cOutput,
                    :headers = aHeaders
                ]
            }
            cLastError = iif(cError != "", cError, "Request failed with no error message")
            return NULL
        catch
            cLastError = cCatchError
            return NULL
        }

    func postData cUrl, cData
        try {
            # Save data to temporary file
            cTempFile = "temp_data.json"
            write(cTempFile, cData)

            //cEncodedData = URLEncode(cData)
            cCommand = 'curl -s -X POST "' + cUrl + '" -H "Content-Type: application/json" --data @' + cTempFile
            cCommand = addHeaders(cCommand)

            # ? "Executing command: " + cCommand
            pProcess.RunCommand(cCommand)
            pProcess.waitForComplete()
            cOutput = pProcess.readOutput()
            cError = pProcess.getStderr()
            # ? "cOutput: " + cOutput
            # Clean up temp file
            remove(cTempFile)
            if pProcess.getExitCode() = 0 {
                return [
                    :code = 200,
                    :body = cOutput,
                    :headers = aHeaders
                ]
            }
            cLastError = iif(cError != "", cError, "Request failed with no error message")
            return NULL
        catch
            cLastError = cCatchError
            return NULL
        }

    func uploadFile cUrl, cFilePath, cFieldName
        try {
            if not fexists(cFilePath) {
                cLastError = "File not found: " + cFilePath
                return NULL
            }

            cCommand = 'curl -s -X POST "' + cUrl + '" -F "' + cFieldName + '=@' + cFilePath + '"'
            cCommand = addHeaders(cCommand)

            pProcess.RunCommand(cCommand)
            pProcess.waitForComplete()
            cOutput = pProcess.readOutput()
            cError = pProcess.getStderr()

            if pProcess.getExitCode() = 0 {
                return [
                    :code = 200,
                    :body = cOutput,
                    :headers = aHeaders
                ]
            }
            cLastError = iif(cError != "", cError, "Upload failed with no error message")
            return NULL
        catch
            cLastError = cCatchError
            return NULL
        }

    func downloadFile cUrl, cFilePath
        try {
            cCommand = 'curl -s -o "' + cFilePath + '" "' + cUrl + '"'
            cCommand = addHeaders(cCommand)

            pProcess.RunCommand(cCommand)
            pProcess.waitForComplete()
            cError = pProcess.getStderr()

            if pProcess.getExitCode() = 0 {
                return true
            }
            cLastError = iif(cError != "", cError, "Download failed with no error message")
            return false
        catch
            cLastError = cCatchError
            return false
        }

    func setHeader cName, cValue
        aHeaders + [cName, cValue]

    func getLastError
        return cLastError

    private

    func addHeaders cCommand
        for aHeader in aHeaders {
            cCommand += ' -H "' + aHeader[1] + ': ' + aHeader[2] + '"'
        }
        return cCommand