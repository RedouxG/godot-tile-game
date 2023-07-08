### ----------------------------------------------------
### Extends on string Functions
### ----------------------------------------------------

extends Script
class_name StringUtils

### ----------------------------------------------------
### Functions
### ----------------------------------------------------

# Compresses string and saves bytes as base64 string
static func compress_str(Str:String, CMode:int) -> String:
    var B64Str := Marshalls.utf8_to_base64(Str)
    return Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64Str).compress(CMode))

# Decompresses string
static func decompress_str(B64C:String, CMode:int, DCSize:int) -> String:
    var B64DC := Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64C).decompress(DCSize,CMode))
    return Marshalls.base64_to_utf8(B64DC)

# Format string example:
# 120s -> "hh:mm:ss" -> 00:02:00 
static func seconds_to_time(seconds:int, format:String) -> String:
    var hours:int = int(float(seconds) / 3600)
    var minutes:int = int(float((seconds - hours * 3600)) / 60)
    seconds = seconds - (hours * 3600) - (minutes*60)
    format = format.to_lower()
    format = format.replace("hh", num_to_str_trim(hours, 2))
    format = format.replace("mm", num_to_str_trim(minutes, 2))
    format = format.replace("ss", num_to_str_trim(seconds, 2))
    return format

static func num_to_str_trim(number:int, trimLen:int) -> String:
    var result := str(number)
    while(result.length() < trimLen):
        result = "0" + result
    if(result.length() > trimLen):
        result = result.substr(0, trimLen)
    return result

static func get_class_name(object:Object) -> String:
    var regex := RegEx.new()
    if(regex.compile("class_name\\s.*") != OK):
        return object.get_class()
    var result := regex.search(object.get_script().source_code)
    if(result == null):
        return object.get_class()
    return result.get_string().replace("class_name ", "")
