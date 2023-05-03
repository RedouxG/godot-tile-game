### ----------------------------------------------------
### Contains data regarding a single file
### ----------------------------------------------------

extends RefCounted
class_name FileData

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var name:String
var basePath:String
var fullPath:String
var isDir:bool
var isFile:bool

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(filePath:String) -> void:
	fullPath = filePath
	isDir = DirAccess.dir_exists_absolute(filePath)
	isFile = FileAccess.file_exists(filePath)
	basePath = filePath.get_base_dir() + '/'
	name = filePath.substr(basePath.length())

func _to_string() -> String:
	return str([fullPath, isDir, isFile])
