### ----------------------------------------------------
### Sublib for file related actions
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const FILE_NEW_LINE = "\n"
const FILE_SKIP_LINE = "\n\n"
const FILE_TAB = "\t"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func get_dir_from_path(path:String) -> String:
	return path.get_base_dir() + '/'

static func file_append_line(path:String, line:String) -> int:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if(file == null):
		return FileAccess.get_open_error()
	
	file.seek_end()
	file.store_line(line)
	return OK

# Saving resource from string
static func save_res_str(content:String,path:String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	return file.get_error()

# Loading resource as string, returns empty string on failure
static func load_res_str(path:String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if(not file.get_error() == OK): return ""
	var content = file.get_as_text()
	return content

# Shortcut to copy file from path to another path
static func copy_file(from:String, to:String) -> int:
	return DirAccess.copy_absolute(from,to)

# Creates empty file
static func create_empty_file(path:String) -> int:
	var file := FileAccess.open(path, FileAccess.WRITE)
	return FileAccess.get_open_error()

static func create_dir(path:String) -> int:
	return DirAccess.make_dir_absolute(path)

# Deletes a file
static func delete_file(path:String) -> int:
	return DirAccess.remove_absolute(path)

static func delete_dir_recursive(path:String) -> int:
	for packed in get_file_list_at_dir(path):
		var filePath = packed[0]
		if(dir_exist(filePath)): 
			var err := delete_dir_recursive(filePath)
			if(err!=OK):
				return err
		if(file_exist(filePath)): 
			var err := delete_file(filePath)
			if(err!=OK):
				return err
	return DirAccess.remove_absolute(path)

# Returns [[filepath, filename], ...], empty array on failure
static func get_file_list_at_dir(path:String) -> Array:
	var dir := DirAccess.open(path)
	var fileList := []
	
	if(DirAccess.get_open_error() != OK): 
		return []
	if(dir.list_dir_begin()  != OK): # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		return []

	var fileName = dir.get_next()
	while fileName != "":
		if not "import" in fileName:
			if path[path.length()-1] != "/":
				path += "/"
			fileList.append([path + fileName, fileName])
		fileName = dir.get_next()
	dir.list_dir_end()
	
	return fileList

static func file_exist(filePath:String) -> bool:
	return FileAccess.file_exists(filePath)

static func dir_exist(dirPath:String) -> bool:
	return DirAccess.dir_exists_absolute(dirPath)

# Returns image size as array [width,height], empty Array on fail
static func get_png_size(path:String) -> Array:
	var image := Image.new()
	if(not image.load(path) == OK): return []
	return [image.get_width(),image.get_height()]

# Returns a part of string from a given startString (included),
# to endString (included)
static func get_string_fromEnd_toStart(source:String,startStr:String,endStr:String) -> String:
	var startIndex := source.find(startStr) + startStr.length()
	var span := source.rfind(endStr) - startIndex
	return source.substr(startIndex, span)


