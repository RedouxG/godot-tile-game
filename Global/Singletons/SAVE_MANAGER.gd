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

var TEMPLATE_FOLDER := "res://Resources/Maps/Templates/":
	set(val):
		Logger.log_msg(["Changed SAVE_MANAGER.TEMPLATE_FOLDER to: ", val])
		TEMPLATE_FOLDER = val

var TEMPLATE_FILE := "Template":
	set(val):
		Logger.log_msg(["Changed TEMPLATE_FILE to: ", val])
		TEMPLATE_FILE = val

var SAVE_FOLDER := "res://Resources/Maps/Saves/":
	set(val):
		Logger.log_msg(["Changed SAVE_MANAGER.EDIT_FOLDER to: ", val])
		SAVE_FOLDER = val

var _EditableSave:SaveWriter
var _TemplateSave:SaveReader

var currentSaveName:String
var isSaveLoaded := false

var API := SaveApi.new():
	set(_a): Logger.log_err(["Tried to overwrite SaveApi"])

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func load_game(saveName:String) -> bool:
	var loadedTemplateSave := SaveReader.new(TEMPLATE_FOLDER, TEMPLATE_FILE)
	var loadedEditableSave := SaveWriter.new(SAVE_FOLDER, saveName)

	if(not loadedTemplateSave.exists()):
		Logger.log_err(["Failed to load template save file: ", loadedTemplateSave])
		return false
	
	if(not loadedEditableSave.open()):
		Logger.log_err(["Failed to load editable save file: ", loadedEditableSave])
		return false
	
	_EditableSave = loadedEditableSave
	_TemplateSave = loadedTemplateSave

	isSaveLoaded = true
	currentSaveName = saveName
	Logger.log_msg(["Loaded game save: ", saveName])
	return true

func save_game(saveName:String) -> bool:
	if(not isSaveLoaded):
		Logger.log_err(["Tried to save game when there is no loaded save! Save name:", saveName])
		return false
	
	API.save_map(_EditableSave)
	var isOk:bool = _EditableSave.Save(SAVE_FOLDER + saveName + ".db")

	Logger.log_result(isOk, ["Saving game save: ", saveName])
	return isOk

func change_map(mapName:String) -> bool:
	if(not isSaveLoaded):
		Logger.log_err(["Tried to change map when there is no loaded save! Map name:", mapName])
		return false
	
	var isOk := API.load_map(_EditableSave, _TemplateSave, mapName)
	Logger.log_result(isOk, ["Changing map: ", mapName])
	return isOk

func add_empty_map_to_save(folderPath:String, saveName:String, mapName:String) -> bool:
	var TempSave := SaveWriter.new(folderPath, saveName)
	if(not TempSave.open()):
		return false
	TempSave.set_new_empty_map(mapName)
	TempSave.Save()
	return true

func create_new_save(saveName:String) -> bool:
	var TempSave := SaveWriter.new(SAVE_FOLDER, saveName)
	return TempSave.create_new_save()

func create_new_template_save() -> bool:
	var TempSave := SaveWriter.new(TEMPLATE_FOLDER, TEMPLATE_FILE)
	return TempSave.create_new_save()

func delete_save(folderPath:String, saveName:String) -> bool:
	var TempSave := SaveWriter.new(folderPath, saveName)
	return TempSave.delete_save()

func clear_cached_save_data() -> void:
	_EditableSave = null
	_TemplateSave = null
	API._TemplateMap = null
	API._EditableMap = null
