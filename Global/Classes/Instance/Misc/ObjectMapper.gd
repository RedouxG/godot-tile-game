### ----------------------------------------------------
### Used to get Variables from an object and load them to another
### ----------------------------------------------------

extends RefCounted
class_name ObjectMapper 

### ----------------------------------------------------
### Variables
### ----------------------------------------------------

# List of variable names that will be get and set from owner
var VariableNames:Array[String]
var Owner:Object

### ----------------------------------------------------
### Functions
### ----------------------------------------------------

func _init(owner:Object, propertiesToMap:Array[String]) -> void:
	Owner = owner
	for propertyInfo in Owner.get_script().get_script_property_list():
		if(not propertiesToMap.has(propertyInfo.name)):
			continue
		VariableNames.append(propertyInfo.name)

func equals(other:Object) -> bool:
	if(StringUtils.get_class_name(other) != StringUtils.get_class_name(Owner)):
		return false
	return other.to_string() == Owner.to_string()

func _to_string() -> String:
	return var_to_str(_get_mapped_object())

func from_string(mappedObjectStr:String) -> Object:
	var mappedObjectDict := _validate_mapped_object(mappedObjectStr)
	if(mappedObjectDict.is_empty()):
		return Owner
	_set_mapped_object(mappedObjectDict)
	return Owner

func _set_mapped_object(mappedObjectDict:Dictionary) -> void:
	for variableName in VariableNames:
		Owner.set(variableName, mappedObjectDict[variableName])

func _get_mapped_object() -> Dictionary:
	var mappedObject:Dictionary = {}
	for propName in VariableNames:
		mappedObject[propName] = Owner.get(propName)
	return mappedObject

func _validate_mapped_object(mappedObjectStr:String) -> Dictionary:
	var mappedObject = str_to_var(mappedObjectStr)
	if(not mappedObject is Dictionary):
		Logger.log_err(["Provided string: \"%s\", could not be converted to dictionary!"
			% [mappedObjectStr]])
		return {}
	
	if(mappedObject.size() != VariableNames.size()):
		Logger.log_err([Logging.Errors.SIZE_MISMATCH(
			"mapping %s" % [StringUtils.get_class_name(Owner)],
			mappedObject.size(),
			VariableNames.size())])
		return {}
	
	for variableName in mappedObject:
		if(Owner.get(variableName) == null):
			Logger.log_err(["%s should not be a name mapped to %s!" % 
			[variableName, StringUtils.get_class_name(Owner)]])
			return {}
	
	return mappedObject
