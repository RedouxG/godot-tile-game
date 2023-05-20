### ----------------------------------------------------
### Wrapper around godot built in file management
### ----------------------------------------------------

extends Script
class_name FileTools

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const NEW_LINE = "\n"
const SKIP_LINE = "\n\n"
const TAB = "\t"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func get_base_dir(path:String) -> String:
	return path.get_base_dir() + '/'

static func save_as_str(content:String,path:String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	return file.get_error()

# Loading resource as string, returns empty string on failure
static func load_as_str(path:String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if(not file.get_error() == OK): return ""
	var content = file.get_as_text()
	return content

# Shortcut to copy file from path to another path
static func copy_file(from:String, to:String) -> int:
	return DirAccess.copy_absolute(from, to)

# Creates empty file
static func create_empty_file(path:String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	return file.get_error()

static func create_dir(path:String) -> int:
	return DirAccess.make_dir_absolute(path)

# Deletes a file
static func delete_file(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir_recursive(path:String) -> int:
	for fileData in get_dirs_FileData(path):
		var err := delete_dir_recursive(fileData.path)
		if(err!=OK): return err
	
	for fileData in get_files_FileData(path):
		var err := delete_file(fileData.path)
		if(err!=OK): return err
	return DirAccess.remove_absolute(path)

static func get_dirs_FileData(path:String) -> Array[FileData]:
	var result:Array[FileData] = []
	if path[-1] != '/':
			path += '/'
	for dirName in DirAccess.get_directories_at(path):
		result.append(FileData.new(path+dirName))
	return result

static func get_files(path:String, ommitImport = true) -> Array[String]:
	var result:Array[String] = []
	for fileName in DirAccess.get_files_at(path):
		if(ommitImport and "import" in fileName):
			continue
		result.append(fileName)
	return result

static func get_files_FileData(path:String, ommitImport = true) -> Array[FileData]:
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
	
	for fileData in get_dirs_FileData(path):
		DirSystem[fileData] = get_dir_system_recursive(fileData.fullPath)
	for fileData in get_files_FileData(path):
		DirSystem[fileData] = null
	return DirSystem

static func get_FileSystem(path:String) -> FileSystem:
	return FileSystem.new(get_dir_system_recursive(path))
