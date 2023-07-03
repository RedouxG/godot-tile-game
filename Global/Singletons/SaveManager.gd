### ----------------------------------------------------
# Manages save
# Usage:
# 1) Load _EditableSave via load_EditableSave()
# 2) Change current map via change_map()
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const NOT_LOADED_ERR_MSG = "Save is damaged or not yet loaded!"

var TEMPLATE_FOLDER := "res://Resources/Maps/Templates/":
	set(val):
		Logger.log_msg(["Changed SaveManager.TEMPLATE_FOLDER to: ", val])
		TEMPLATE_FOLDER = val

var TEMPLATE_FILE := "Template":
	set(val):
		Logger.log_msg(["Changed TEMPLATE_FILE to: ", val])
		TEMPLATE_FILE = val

var SAVE_FOLDER := "res://Resources/Maps/Saves/":
	set(val):
		Logger.log_msg(["Changed SaveManager.EDIT_FOLDER to: ", val])
		SAVE_FOLDER = val

var _EditableSave:SaveWriter
var _TemplateSave:SaveReader

var currentSaveName:String

var API := SaveApi.new():
	set(_a): Logger.log_err(["Tried to overwrite SaveApi"])

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func load_game(saveName:String) -> bool:
	var loadedTemplateSave := SaveReader.new(TEMPLATE_FOLDER, TEMPLATE_FILE)
	var loadedEditableSave := SaveWriter.new(SAVE_FOLDER, saveName)

	if(not loadedTemplateSave.has_file()):
		Logger.log_err(["Failed to load template save file: ", loadedTemplateSave])
		return false
	
	if(not loadedEditableSave.open()):
		Logger.log_err(["Failed to load editable save file: ", loadedEditableSave])
		return false
	
	_EditableSave = loadedEditableSave
	_TemplateSave = loadedTemplateSave

	currentSaveName = saveName
	Logger.log_msg(["Loaded game save: ", saveName])
	return true

func save_game(saveName:String) -> bool:
	if(not is_loaded()):
		Logger.log_err([NOT_LOADED_ERR_MSG, " (save_game) "])
		return false
	
	API.save_map(_EditableSave)
	var isOk:bool = _EditableSave.Save(SAVE_FOLDER + saveName + ".db")

	Logger.log_result(isOk, ["Saving game save: ", saveName])
	return isOk

func change_map(mapName:String) -> bool:
	if(not is_loaded()):
		Logger.log_err([NOT_LOADED_ERR_MSG, " (change_map) Map name:" , mapName])
		return false
	
	var isOk := API.load_map(_EditableSave, _TemplateSave, mapName)
	Logger.log_result(isOk, ["Changing map: ", mapName])
	return isOk

func create_new_save(saveName:String) -> bool:
	var TempSave := SaveWriter.new(SAVE_FOLDER, saveName)
	return TempSave.create_new_save()

func create_new_template_save() -> bool:
	var TempSave := SaveWriter.new(TEMPLATE_FOLDER, TEMPLATE_FILE)
	return TempSave.create_new_save()

func is_loaded() -> bool:
	return _EditableSave != null and _TemplateSave != null

func clear_cached_save_data() -> void:
	_EditableSave = null
	_TemplateSave = null
	API._TemplateMap = null
	API._EditableMap = null

func add_empty_map_to_save(folderPath:String, saveName:String, mapName:String) -> bool:
	var TempSave := SaveWriter.new(folderPath, saveName)
	if(not TempSave.open()):
		return false
	TempSave.set_new_empty_map(mapName)
	TempSave.Save()
	return true
	
func delete_save(folderPath:String, saveName:String) -> bool:
	var TempSave := SaveWriter.new(folderPath, saveName)
	return TempSave.delete_save()
