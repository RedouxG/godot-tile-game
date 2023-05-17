### ----------------------------------------------------
### Sublib for image/texture related actions
### ----------------------------------------------------

extends Script
class_name CompressTools

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Compresses string and saves bytes as base64 string
static func compress_str(Str:String, CMode:int) -> String:
	var B64Str := Marshalls.utf8_to_base64(Str)
	return Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64Str).compress(CMode))

# Decompresses string
static func decompress_str(B64C:String, CMode:int, DCSize:int) -> String:
	var B64DC := Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64C).decompress(DCSize,CMode))
	return Marshalls.base64_to_utf8(B64DC)
