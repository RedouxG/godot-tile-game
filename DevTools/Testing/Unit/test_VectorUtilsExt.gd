### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends GutTest

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var Rng := RandomNumberGenerator.new()

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func do_test_for_v2_and_v2i(function:Callable, given:Array[Array], expected:Variant) -> void:
    assert_eq(function.callv(given[0]), expected,
            function.get_method() + " failed for Vector2i")
    assert_eq(function.callv(given[1]), expected,
            function.get_method() + " failed for Vector2")

func test_vector_conversion() -> void:
    for i in range(4):
        var x:int = Rng.randi_range(-10_000_000, 10_000_000)
        var y:int = Rng.randi_range(-10_000_000, 10_000_000)
        var z:int = Rng.randi_range(-10_000_000, 10_000_000)
        do_test_for_v2_and_v2i(
            Callable(VectorUtilsExt, "vec2i_vec3i"),
            [[Vector2i(x,y), z], [Vector2(x,y), z]], 
            Vector3i(x,y,z)
        )

        do_test_for_v2_and_v2i(
            Callable(VectorUtilsExt, "vec3i_vec2i"),
            [[Vector3i(x,y,z)], [Vector3(x,y,z)]], 
            Vector2i(x,y)
        )

func test_vector_scale() -> void:
    var SCALE = Settings.MAP.CHUNK_SIZE
    for i in range(-3,3):
        do_test_for_v2_and_v2i(
            Callable(VectorUtilsExt, "scale_down_vec2i"),
            [[Vector2i(i*SCALE,i*SCALE), SCALE], [Vector2(i*SCALE,i*SCALE), SCALE]], 
            Vector2i(i,i)
        )

        do_test_for_v2_and_v2i(
            Callable(VectorUtilsExt, "scale_down_vec3i"),
            [[Vector3i(i*SCALE,i*SCALE,i*SCALE), SCALE], [Vector3(i*SCALE,i*SCALE,i*SCALE), SCALE]], 
            Vector3i(i,i,i)
        )

        do_test_for_v2_and_v2i(
            Callable(VectorUtilsExt, "scale_down_vec3i_no_z"),
            [[Vector3i(i*SCALE,i*SCALE,i*SCALE), SCALE], [Vector3(i*SCALE,i*SCALE,i*SCALE), SCALE]], 
            Vector3i(i,i,i*SCALE)
        )

func test_vector_chunk() -> void:
    var TEMPLATE_VEC2:Array[Vector2i] = [
        Vector2i(-2,-2), Vector2i(-2,-1), Vector2i(-1,-2), Vector2i(-1,-1)]
    do_test_for_v2_and_v2i(
        Callable(VectorUtilsExt, "vec2i_get_positions_in_chunk"),
        [[Vector2i(-1,-1), 2], [Vector2(-1,-1), 2]], 
        TEMPLATE_VEC2
    )

    var TEMPLATE_VEC3_NO_Z:Array[Vector3i] = [
        Vector3i(-2,-2, 0), Vector3i(-2,-1, 0), Vector3i(-1,-2, 0), Vector3i(-1,-1, 0)]
    do_test_for_v2_and_v2i(
        Callable(VectorUtilsExt, "vec3i_get_positions_in_chunk_no_z"),
        [[Vector3i(-1,-1, 0), 2], [Vector3(-1,-1, 0), 2]], 
        TEMPLATE_VEC3_NO_Z
    )

func test_vector_range() ->void:
    var TEMPLATE_VEC2:Array[Vector2i] = [
        Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), 
        Vector2i(0, -1),  Vector2i(0, 0),  Vector2i(0, 1), 
        Vector2i(1, -1),  Vector2i(1, 0),  Vector2i(1, 1)]
    
    do_test_for_v2_and_v2i(
        Callable(VectorUtilsExt, "vec2i_get_positions_in_range"),
        [[Vector2i(0,0), 1], [Vector2(0,0), 1]], 
        TEMPLATE_VEC2
    )
