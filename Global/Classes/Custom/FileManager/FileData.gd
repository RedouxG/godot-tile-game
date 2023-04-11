### ----------------------------------------------------
### Contains data regarding a single file
### ----------------------------------------------------

extends RefCounted
class_name FileData

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var name:String
var path:String
var isDir:bool
var isFile:bool

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(filePath:String) -> void:
	isDir = DirAccess.dir_exists_absolute(filePath)
	isFile = FileAccess.file_exists(filePath)
	path = filePath.get_base_dir() + '/'
	name = filePath.substr(path.length())

func _to_string() -> String:
	return str([path,name, isDir, isFile])
