Load "../src/libAgentAi.ring"

/*
    Test Suite for HttpClient Class
    Tests basic HTTP operations and error handling
*/

? "=== Starting HttpClient Tests ==="

# Initialize test server URLs
cTestServer = "https://httpbin.org"
cTestEndpoint = cTestServer + "/anything"
cUploadEndpoint = cTestServer + "/post"
cDownloadEndpoint = cTestServer + "/image/png"

# Test Case 1: Basic GET Request
? "Test 1: Testing GET Request"
oClient = new HttpClient()
oResponse = oClient.getData(cTestEndpoint)
if oResponse != NULL and oResponse[:code] = 200 {
    ? "✓ GET Request successful"
else
    ? "✗ GET Request failed: " + oClient.cLastError
}

# Test Case 2: POST Request with JSON Data
? nl + "Test 2: Testing POST Request"
cTestData = '{"test": "data", "number": 123}'
oResponse = oClient.postData(cTestEndpoint, cTestData)
if oResponse != NULL and oResponse[:code] = 200 {
    ? "✓ POST Request successful"
else
    ? "✗ POST Request failed: " + oClient.cLastError
}

# Test Case 3: File Upload
? nl + "Test 3: Testing File Upload"
cTestFile = "test_upload.txt"
write(cTestFile, "Test file content")
oResponse = oClient.uploadFile(cUploadEndpoint, cTestFile, "file")
if oResponse != NULL and oResponse[:code] = 200 {
    ? "✓ File Upload successful"
else
    ? "✗ File Upload failed: " + oClient.cLastError
}
remove(cTestFile)

# Test Case 4: File Download
? nl + "Test 4: Testing File Download"
cDownloadFile = "test_download.png"
oResponse = oClient.downloadFile(cDownloadEndpoint, cDownloadFile)
if oResponse {
    ? "✓ File Download successful"
else
    ? "✗ File Download failed: " + oClient.cLastError
}
remove(cDownloadFile)

# Test Case 5: Error Handling - Invalid URL
? nl + "Test 5: Testing Error Handling"
oResponse = oClient.getData("https://invalid-url-that-does-not-exist.com")
if oResponse = NULL {
    ? "✓ Error handling working as expected"
else
    ? "✗ Error handling test failed"
}

? nl + "=== HTTP Client Tests Complete ==="
