### ----------------------------------------------------
### Singleton handles logging
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const SUPRESSED_INDICATOR = "[SUPRESSED ERR] "

var supressErrors := false
var logTime := false
var logToFile := false

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func log_msg(message:Array) -> void:
    Logging.log_msg(message, logTime, logToFile)

func log_err(message:Array) -> void:
    if(supressErrors):
        message.push_front(SUPRESSED_INDICATOR)
        Logging.log_msg(message, logTime, logToFile)
        return
    Logging.log_err(message, logTime, logToFile)

func log_result(isOk:bool, message:Array) -> void:
    var add := " | result: "
    if(isOk):
        add += "success!"
        message.append(add)
        Logging.log_msg(message, logTime, logToFile)
    else:
        add += "failed!"
        message.append(add)
        Logging.log_err(message, logTime, logToFile)

func log_result_code(result:int, message:Array) -> void:
    var add := " | result: "
    if(result == OK):
        add += "success!"
        message.append(add)
        Logging.log_msg(message, logTime, logToFile)
    else:
        add += "failed!"
        message.append(add)
        Logging.log_err(message, logTime, logToFile)

func set_default_settings() -> void:
    supressErrors = false
    logTime = false
    logToFile = false

func set_test_settings() -> void:
    supressErrors = true
    logTime = false
    logToFile = false

func _enter_tree() -> void:
    Logging.log_session_start()
