### ----------------------------------------------------
### Used to get Variables from an object and load them to another
### ----------------------------------------------------

extends RefCounted
class_name ObjectSaver

### ----------------------------------------------------
### Variables
### ----------------------------------------------------

# List of variable names that will be get and set from owner
var PropertyNames:Array[String]
var Owner

### ----------------------------------------------------
### Functions
### ----------------------------------------------------

func _init(owner, propertiesToConvert:Array[String]) -> void:
	Owner = owner
	for propertyInfo in Owner.get_script().get_script_property_list():
		if(not propertiesToConvert.has(propertyInfo.name)):
			continue
		PropertyNames.append(propertyInfo.name)

func get_properties_str() -> String:
	return var_to_str(get_properties())

func get_properties() -> Array:
	var props:Array = []
	for propName in PropertyNames:
		props.append(Owner.get(propName))
	return props

func set_properties(props:Array) -> void:
	if(props.size() != PropertyNames.size()):
		Logger.log_err(["Tried to set properties when props and PropertyNames are different size: ",
		props.size(), " != ", PropertyNames.size()])
		return
	
	var index:int = 0
	for propName in PropertyNames:
		Owner.set(propName, props[index])
		index += 1

func set_properties_str(data:String) -> void:
	var converted = str_to_var(data)
	if(converted is Array):
		set_properties(converted)
