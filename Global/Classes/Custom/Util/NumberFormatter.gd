### ----------------------------------------------------
### Handles formatting numbers to readable string
### ----------------------------------------------------

extends Script
class_name NumberFormatter

### ----------------------------------------------------
### Scripts
### ----------------------------------------------------

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

static func clamp_increment_int(value:int, minNum:int, maxNum:int) -> int:
	value += 1
	if(value > maxNum):
		value = minNum
	return value

static func clamp_decrement_int(value:int, minNum:int, maxNum:int) -> int:
	value -= 1
	if(value < minNum):
		value = maxNum
	return value