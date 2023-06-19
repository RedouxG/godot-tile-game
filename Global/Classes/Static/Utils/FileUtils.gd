### ----------------------------------------------------
### Wrapper around godot built in file management
### ----------------------------------------------------

extends Script
class_name FileUtils

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const NEW_LINE = "\n"
const SKIP_LINE = "\n\n"
const TAB = "\t"

### ----------------------------------------------------
# Class
### ----------------------------------------------------

# Represents a single file
class FileData extends RefCounted:
	var name:String
	var basePath:String
	var fullPath:String
	var extension:String

	var isDir:bool
	var isFile:bool

	func _init(filePath:String) -> void:
		fullPath = filePath
		isDir = DirAccess.dir_exists_absolute(filePath)
		isFile = FileAccess.file_exists(filePath)
		basePath = FileUtils.get_base_dir(fullPath)
		name = filePath.get_file()
		extension = filePath.get_extension()

	func _to_string() -> String:
		return "(FileData) " + name

class FileSystem extends RefCounted:
	# Dir system dictionary with FileData keys
	var DictFileData := {}

	# Dir system dictionary with file/dir name keys
	var DictFileNames := {}

	func _init(dictFileData:Dictionary) -> void:
		DictFileData = dictFileData
		DictFileNames = _convert_to_DictFileNames(dictFileData)

	func _convert_to_DictFileNames(dictFileData:Dictionary) -> Dictionary:
		var dictFileNames := {}
		for fileData in dictFileData:
			if(dictFileData[fileData] != null):
				dictFileNames[fileData.name] = _convert_to_DictFileNames(dictFileData[fileData])
			else:
				dictFileNames[fileData.name] = null
		return dictFileNames

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

static func get_base_dir(path:String) -> String:
	return path.get_base_dir() + '/'

static func save_string_to_file(content:String, path:String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	return file.get_error()

static func load_file_as_string(path:String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if(not file.get_error() == OK): return ""
	var content = file.get_as_text()
	return content

static func copy_file(from:String, to:String) -> int:
	return DirAccess.copy_absolute(from, to)

static func create_empty_file(path:String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	return file.get_error()

static func create_dir(path:String) -> int:
	return DirAccess.make_dir_absolute(path)

static func delete_file(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir_recursive(path:String) -> int:
	for fileData in get_directories_as_FileData_at(path):
		var err := delete_dir_recursive(fileData.path)
		if(err!=OK): return err
	
	for fileData in get_files_as_FileData_at(path):
		var err := delete_file(fileData.fullPath)
		if(err!=OK): return err
	return DirAccess.remove_absolute(path)

static func get_directories_at(path:String) -> Array[String]:
	var result:Array[String] = []
	if path[-1] != '/':
			path += '/'
	for dirName in DirAccess.get_directories_at(path):
		result.append(path+dirName)
	return result

static func get_directories_as_FileData_at(path:String) -> Array[FileData]:
	var result:Array[FileData] = []
	if path[-1] != '/':
			path += '/'
	for dirName in DirAccess.get_directories_at(path):
		result.append(FileData.new(path+dirName))
	return result

static func get_files_at(path:String, ommitImport = true) -> Array[String]:
	var result:Array[String] = []
	for fileName in DirAccess.get_files_at(path):
		if(ommitImport and "import" in fileName):
			continue
		result.append(fileName)
	return result

static func get_files_as_FileData_at(path:String, ommitImport = true) -> Array[FileData]:
	var result:Array[FileData] = []
	if path[-1] != '/':
			path += '/'
	for fileName in DirAccess.get_files_at(path):
		if(ommitImport and "import" in fileName):
			continue
		result.append(FileData.new(path+fileName))
	return result

static func file_exists(filePath:String) -> bool:
	return FileAccess.file_exists(filePath)

static func dir_exists(dirPath:String) -> bool:
	return DirAccess.dir_exists_absolute(dirPath)

static func file_append_line(path:String, line:String) -> int:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if(file == null):
		return FileAccess.get_open_error()
	
	file.seek_end()
	file.store_line(line)
	return OK

# Returns directory structure as nested dict
# value null means file, value of dict means dir
static func get_dir_system_recursive(path:String) -> Dictionary:
	var DirSystem := {}
	if(not dir_exists(path)):
		return DirSystem
	
	for fileData in get_directories_as_FileData_at(path):
		DirSystem[fileData] = get_dir_system_recursive(fileData.fullPath)
	for fileData in get_files_as_FileData_at(path):
		DirSystem[fileData] = null
	return DirSystem

static func get_FileSystem(path:String) -> FileSystem:
	return FileSystem.new(get_dir_system_recursive(path))
