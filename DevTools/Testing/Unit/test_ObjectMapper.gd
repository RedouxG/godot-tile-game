### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends GutTest

### ----------------------------------------------------
# classes
### ----------------------------------------------------

class DummyObject:
    var objectMapper := ObjectMapper.new(self, ["stringVar", "intVar", "floatVar"])
    var stringVar:String
    var intVar:int
    var floatVar:float

    func _init(_stringVar:String = "", _intVar:int = 0, _floatVar:float = 0) -> void:
        self.stringVar = _stringVar
        self.intVar = _intVar
        self.floatVar = _floatVar
    
    func _to_string() -> String:
        return objectMapper.to_string()
    
    func from_string(data:String) -> DummyObject:
        return objectMapper.from_string(data)

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func test_to_string_and_from_string() -> void:
    # Given
    var testObject := DummyObject.new("test", 12, 1.2)

    # When
    var mappedStr := str(testObject)
    var fromStrTestobject := DummyObject.new().from_string(mappedStr)

    # Then
    assert_eq(testObject.stringVar, fromStrTestobject.stringVar)
    assert_eq(testObject.intVar, fromStrTestobject.intVar)
    assert_eq(testObject.floatVar, fromStrTestobject.floatVar)

func test_equals() -> void:
    # Given
    var firstObject := DummyObject.new("test", 1, 1.1)
    var secondObject := DummyObject.new()
    var thirdObject := DummyObject.new("sds", 23, 2)

    # When
    secondObject.stringVar = firstObject.stringVar
    secondObject.intVar = firstObject.intVar
    secondObject.floatVar = firstObject.floatVar

    # Then
    assert_eq(firstObject.to_string(), secondObject.to_string())
    assert_ne(firstObject.to_string(), thirdObject.to_string())

func test_wrong_string_should_not_map() -> void:
    Logger.supressErrors = true
    # Given
    var stringVar := "test"
    var intVar := 1
    var floatVar := 1.1

    var testObject1 := DummyObject.new(stringVar, intVar, floatVar)
    var testObject2 := DummyObject.new(stringVar, intVar, floatVar)
    var testObject3 := DummyObject.new(stringVar, intVar, floatVar)
    
    # When
    testObject1.from_string("completely wrong input")
    testObject2.from_string(var_to_str({}))
    testObject3.from_string(var_to_str({"wrong1":"v", "wrong2":"v" ,"wrong3":"v"}))

    # Then
    assert_eq(stringVar, testObject1.stringVar)
    assert_eq(stringVar, testObject2.stringVar)
    assert_eq(stringVar, testObject3.stringVar)

    assert_eq(intVar, testObject1.intVar)
    assert_eq(intVar, testObject2.intVar)
    assert_eq(intVar, testObject3.intVar)

    assert_eq(floatVar, testObject1.floatVar)
    assert_eq(floatVar, testObject2.floatVar)
    assert_eq(floatVar, testObject3.floatVar)

    Logger.supressErrors = false