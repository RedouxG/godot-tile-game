### ----------------------------------------------------
### Used to get Variables from an object and load them to another
### ----------------------------------------------------

extends RefCounted
class_name ObjectMapper

### ----------------------------------------------------
### Variables
### ----------------------------------------------------

# List of variable names that will be get and set from owner
var PropertyNames:Array[String]
var Owner:Object

### ----------------------------------------------------
### Functions
### ----------------------------------------------------

func _init(owner:Object, propertiesToConvert:Array[String]) -> void:
	Owner = owner
	for propertyInfo in Owner.get_script().get_script_property_list():
		if(not propertiesToConvert.has(propertyInfo.name)):
			continue
		PropertyNames.append(propertyInfo.name)

func get_str() -> String:
	return var_to_str(_get_properties())

func set_str(data:String) -> Object:
	var converted = str_to_var(data)
	if(not converted is Array):
		return null
	if(not _set_properties(converted)):
		return null
	return Owner

func _get_properties() -> Array:
	var props:Array = []
	for propName in PropertyNames:
		props.append(Owner.get(propName))
	return props

func _set_properties(props:Array) -> bool:
	if(props.size() != PropertyNames.size()):
		Logger.log_err(["Property names are different size: ", props.size(), " != ", PropertyNames.size()])
		return false
	
	var index:int = 0
	for propName in PropertyNames:
		if(Owner.get(propName) == null):
			return false
		Owner.set(propName, props[index])
		index += 1
	return true