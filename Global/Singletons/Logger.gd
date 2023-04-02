### ----------------------------------------------------
### Singleton handles all logging procedures
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var LOG_PATH:String = "res://Temp/log.txt":
	set(path):
		if(LibK.Files.dir_exist(LibK.Files.get_dir_from_path(path))):
			logErr(["Tried to set log file path to incorrect path: ", path])
			return
		LOG_PATH = path
var logTime := false

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

# Function handles logs, if error detected save logs otherwise delete log file
func _handle_log() -> void:
	if(not LibK.Files.file_exist(LOG_PATH)):
		return
	
	var file := FileAccess.open(LOG_PATH, FileAccess.READ)
	if(file == null):
		logErr(["Failed to open log file: ", LOG_PATH])
		return
	
	print("logger lines <")
	var line:String
	while(file.get_position() < file.get_length()):
		line = file.get_line()
		print(line)
	print("logger lines >")
	
	file.close()
	var err := LibK.Files.delete_file(LOG_PATH)
	if(err != OK):
		logErr(["Failed to delete log file: ", LOG_PATH, ", err: ", err])

func draw_line(logIndicator:bool = true) -> void:
	LogMsg(["-----------------------------------------"], logIndicator)

func LogMsg(message:Array, logIndicator = true) -> void:
	if logTime: message.push_front(get_time())
	if logIndicator: message.push_front("[LOG] ")
	_save_LOG(_format_LOG(message))

# logErr(["This is an error message])
func logErr(message:Array) -> void:
	if logTime: message.push_front(get_time())
	
	message.push_front("[ERR] ")
	_save_LOG(_format_LOG(message), true)

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

func _format_LOG(message:Array) -> String:
	var output:String = ""
	for part in message:
		part = str(part)
		output += part
	return output

func _save_LOG(message:String, isErr = false) -> void:
	if(isErr): push_error(message)
	print(message)
