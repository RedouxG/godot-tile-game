### ----------------------------------------------------
### Class handles all logging procedures
### ----------------------------------------------------

extends Script
class_name Logger

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const LOG_FOLDER_PATH = "res://Temp/"
const LOG_FILE_NAME = "log.txt"
const LOG_FILE_PATH = LOG_FOLDER_PATH + LOG_FILE_NAME
const LOG_MARK = "[MSG] "
const ERR_MARK = "[ERR] "

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

static func log_session_start() -> void:
	_handle_previous_log()
	
	log_msg(["-----------------------------------------"])
	log_msg(["LOG SESSION START"], false)
	log_msg(["Platform: ", OS.get_name()], false)
	log_msg([get_date(), get_time()], false)
	log_msg(["-----------------------------------------"])

static func get_date() -> String:
	var dateDict := Time.get_datetime_dict_from_system()
	var day:String   = str(dateDict.day)
	var month:String = str(dateDict.month)
	if day.length() == 1: day = "0" + day
	if month.length() == 1: month = "0" + month
	return "[" + day + ":" + month + ":" + str(dateDict.year) + "] "

static func get_time() -> String:
	var timeDict := Time.get_datetime_dict_from_system()
	var minute:String = str(timeDict.minute)
	var second:String = str(timeDict.second)
	if minute.length() == 1: minute = "0" + minute
	if second.length() == 1: second = "0" + second
	return "[" + str(timeDict.hour) + ":" + minute + ":" + second + "] "

static func log_msg(message:Array, logTime = false, logToFile = false) -> void:
	if logTime: message.push_front(get_time())
	message.push_front(LOG_MARK)
	output_log(_format_log_msg(message), false, logToFile)

static func log_err(message:Array, logTime = false, logToFile = false) -> void:
	if logTime: message.push_front(get_time())
	message.push_front(ERR_MARK)
	output_log(_format_log_msg(message), true, logToFile)

# in:
# 	log_result(isOk, ["Doing x"])
# out:
#	Doing x | result: failed/success
static func log_result(isOk:bool, Message:Array) -> void:
	var add := " | result: "
	if(isOk):
		add += "success!"
		Message.append(add)
		log_msg(Message)
	else:
		add += "failed!"
		Message.append(add)
		log_err(Message)

static func log_result_code(result:int, Message:Array) -> void:
	var add := " | result: "
	if(result == OK):
		add += "success!"
		Message.append(add)
		log_msg(Message)
	else:
		add += "failed!"
		Message.append(add)
		log_err(Message)

static func output_log(message:String, isErr = false, logToFile = false) -> void:
	if(isErr):
		push_error(message)
	print(message)
	
	if(logToFile):
		FileUtils.file_append_line(LOG_FILE_PATH, message)

static func _format_log_msg(message:Array) -> String:
	var output:String = ""
	for part in message:
		part = str(part)
		output += part
	return output

# Function handles logs, if error detected save logs otherwise delete log file
static func _handle_previous_log() -> void:
	if(not FileUtils.file_exists(LOG_FILE_PATH)):
		return
	
	var file := FileAccess.open(LOG_FILE_PATH, FileAccess.READ)
	if(file == null):
		log_err(["Failed to open log file: ", LOG_FILE_PATH])
		return
	
	var line:String
	while(file.get_position() < file.get_length()):
		line = file.get_line()
		if(ERR_MARK in line):
			file.close()
			# Err report has time and date in name to avoid overwrite
			var reportPath:String = LOG_FOLDER_PATH + "ErrorReport" + get_date().replace(":","-") + get_time().replace(":","-") + ".txt"
			FileUtils.copy_file(LOG_FILE_PATH, reportPath.replace(" ",""))
			break
	file.close()
	
	FileUtils.delete_file(LOG_FILE_PATH)
	FileUtils.create_empty_file(LOG_FILE_PATH)
