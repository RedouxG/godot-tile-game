### ----------------------------------------------------
### Singleton handles all logging procedures
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var logTime := false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _enter_tree() -> void:
	draw_line(false)
	logMS(["LOG SESSION START"], false)
	logMS(["Platform: ", OS.get_name()], false)
	logMS([get_date(), get_time()], false)
	draw_line(false)

func draw_line(logIndicator:bool = true) -> void:
	logMS(["-----------------------------------------"], logIndicator)

func get_date() -> String:
	var dateDict := Time.get_datetime_dict_from_system()
	var day:String   = str(dateDict.day)
	var month:String = str(dateDict.month)
	if day.length() == 1: day = "0" + day
	if month.length() == 1: month = "0" + month
	return "[" + day + ":" + month + ":" + str(dateDict.year) + "] "

func get_time() -> String:
	var timeDict := Time.get_datetime_dict_from_system()
	var minute:String = str(timeDict.minute)
	var second:String = str(timeDict.second)
	if minute.length() == 1: minute = "0" + minute
	if second.length() == 1: second = "0" + second
	return "[" + str(timeDict.hour) + ":" + minute + ":" + second + "] "

func logMS(message:Array, logIndicator = true):
	if logTime: message.push_front(get_time())
	if logIndicator: message.push_front("[LOG] ")
	print(_format_LOG(message))

# logErr(["This is an error message], get_stack())
func logErr(message:Array, frame:Array) -> void:
	if not frame.is_empty():
		message.push_front("[L:" + str(frame[0]["line"]) + ", S:" + frame[0]["source"] + ", F:" + frame[0]["function"] +"] ")
	if logTime: message.push_front(get_time())
	
	message.push_front("[ERR] ")
	var formattedLog := _format_LOG(message)
	print(formattedLog)
	push_error(formattedLog)

func _format_LOG(message:Array) -> String:
	var output:String = ""
	for part in message:
		part = str(part)
		
		# Modifiers to log
		if "[B]" in part: 
			part = part.replace("[B]","")
			part = part.to_upper()
		if "[TAB]" in part: 
			part = part.replace("[TAB]","")
			output = output.insert(5,"	")
		output += part
	return output

# Tries to execute a method, if fails pushes an error
func try_execute(methodReturn, expectedOK, errMSG:String = "Generic error") -> bool:
	if(methodReturn != expectedOK):
		logErr([errMSG, " | ", "Expected: ", str(expectedOK), ", Got: ", methodReturn], [])
		return false
	return true

# Tries to execute a method that returns an error code, if fails pushes an error
func try_execute_err(errCode:int, errMSG:String = "Generic error") -> bool:
	if(errCode != OK):
		logErr([errMSG, " | ", "Error: ", errCode], [])
		return false
	return true

