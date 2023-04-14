### ----------------------------------------------------
### Singleton handles all logging procedures
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const LOG_FOLDER = "res://Temp/"
const LOF_FILE = "log.txt"
const LOG_PATH = LOG_FOLDER + LOF_FILE
const LOG_MARK = "[LOG] "
const ERR_MARK = "[ERR] "

var logTime := false
var logFile := false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _enter_tree() -> void:
	_handle_log()
	draw_line(false)
	LogMsg(["LOG SESSION START"], false)
	LogMsg(["Platform: ", OS.get_name()], false)
	LogMsg([get_date(), get_time()], false)
	draw_line(false)

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

# Function handles logs, if error detected save logs otherwise delete log file
func _handle_log() -> void:
	if(not FileManager.file_exists(LOG_PATH)):
		return
	
	var file := FileAccess.open(LOG_PATH, FileAccess.READ)
	if(file == null):
		logErr(["Failed to open log file: ", LOG_PATH])
		return
	
	var line:String
	while(file.get_position() < file.get_length()):
		line = file.get_line()
		if(ERR_MARK in line):
			file.close()
			# Err report has time and date in name to avoid overwrite
			var reportPath:String = LOG_FOLDER + "ErrorReport" + get_date().replace(":","-") + get_time().replace(":","-") + ".txt"
			FileManager.copy_file(LOG_PATH, reportPath.replace(" ",""))
			break
	file.close()
	FileManager.delete_file(LOG_PATH)

func draw_line(logIndicator:bool = true) -> void:
	LogMsg(["-----------------------------------------"], logIndicator)

func LogMsg(message:Array, logIndicator = true) -> void:
	if logTime: message.push_front(get_time())
	if logIndicator: message.push_front(LOG_MARK)
	_process_LOG(_format_LOG(message))

# logErr(["This is an error message])
func logErr(message:Array) -> void:
	if logTime: message.push_front(get_time())
	
	message.push_front(ERR_MARK)
	_process_LOG(_format_LOG(message), true)

func _format_LOG(message:Array) -> String:
	var output:String = ""
	for part in message:
		part = str(part)
		output += part
	return output

func _process_LOG(message:String, isErr = false) -> void:
	if(isErr): push_error(message)
	print(message)
	
	if(not logFile):
		return
	if(not FileManager.file_exist(LOG_PATH)):
		FileManager.create_empty_file(LOG_PATH)
	FileManager.file_append_line(LOG_PATH, message)
