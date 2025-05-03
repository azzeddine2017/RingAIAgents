? "Current date: " + date()
? "Current time: " + time()
? "Current datetime: " + date() + " " + time()

# Test timelist()
aTimeList = timelist()
? "Time list: "
for i = 1 to len(aTimeList)
    ? "  " + i + ": " + aTimeList[i]
next 