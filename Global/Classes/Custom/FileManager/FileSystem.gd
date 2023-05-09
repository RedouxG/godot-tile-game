### ----------------------------------------------------
### Class used as a filesystem object
### ----------------------------------------------------

extends RefCounted
class_name FileSystem

### ----------------------------------------------------
### VARIABLES
### ----------------------------------------------------

# Dir system dictionary with FileData keys
var DictFileData := {}

# Dir system dictionary with file/dir name keys
var DictFileNames := {}

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------

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
