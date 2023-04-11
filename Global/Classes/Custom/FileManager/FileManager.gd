### ----------------------------------------------------
### Wrapper around godot built in file management
### ----------------------------------------------------

extends Script
class_name FileManager

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

static func file_append_line(path:String, line:String) -> int:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if(file == null):
		return FileAccess.get_open_error()
	
	file.seek_end()
	file.store_line(line)
	return OK

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
	return FileAccess.get_open_error()

static func create_dir(path:String) -> int:
	return DirAccess.make_dir_absolute(path)

# Deletes a file
static func delete_file(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir_recursive(path:String) -> int:
	for fileData in get_all_FileData(path):
		if(dir_exists(fileData.path)): 
			var err := delete_dir_recursive(fileData.path)
			if(err!=OK):
				return err
		if(file_exists(fileData.path)): 
			var err := delete_file(fileData.path)
			if(err!=OK):
				return err
	return DirAccess.remove_absolute(path)

static func get_all_FileData(path:String, ommitImport = true) -> Array[FileData]:
	var dir := DirAccess.open(path)
	var fileList:Array[FileData] = []
	
	if(DirAccess.get_open_error() != OK): return []
	if(dir.list_dir_begin()  != OK):      return []
	var fileName = dir.get_next()
	while fileName != "":
		fileName = dir.get_next()
		if(ommitImport and "import" in fileName):
			continue
		fileList.append(FileData.new(path + fileName))
	dir.list_dir_end()
	return fileList

static func get_dirs(path:String) -> Array[String]:
	var result:Array[String] = []
	for dir in DirAccess.get_directories_at(path):
		result.append(dir)
	return result

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
