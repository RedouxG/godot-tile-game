### ----------------------------------------------------
### Class serves as generic error template
### Can provide additional information for error tracking when stack trace is missing (release)
### ----------------------------------------------------

extends Script
class_name Errors

### ----------------------------------------------------
# Variables
### ----------------------------------------------------
 
static func NO_FILE(path:String) -> String:
    return "Missing file error! File: %s" % [path]

static func NOT_LOADED(doWhat:String, inWhat:String) -> String:
    return "Failed to perform %s operation because %s is not loaded!" % [doWhat, inWhat]

static func NO_ACCESS(toWhat:String, why:String) -> String:
    return "Unable to access %s because %s!" % [toWhat, why]