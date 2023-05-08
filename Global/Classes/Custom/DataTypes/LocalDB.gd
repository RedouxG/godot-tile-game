### ----------------------------------------------------
### Represents a local in memory database (used for small data sources)
### ----------------------------------------------------

extends RefCounted
class_name LocalDB

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["VALUES", "DB"])

var VALUES:Array[int] = []
var DB:Dictionary = {}:
	set(_db):
		return

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(valuesTemplate:Array[int]) -> void:
	VALUES = valuesTemplate

func set_record(key:Variant, values:Array[Variant]) -> bool:
	if(values.size() != VALUES.size()):
		Logger.logErr(["Sizes of values given and declared dont match: ", values.size(), "!=", VALUES.size()])
		return false
	
	for index in range(values.size()):
		if(not VALUES[index] == typeof(values[index])):
			Logger.logErr([
				str(VALUES[index]) + "!=" + str(typeof(values[index])),
				", index: ", index,
				", VALUES: " + str(VALUES)])
			return false
	DB[key] = values
	return true

func get_record(key:Variant) -> Variant:
	return DB.get(key)

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> LocalDB:
	Saver.set_properties_str(data)
	return self
