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

func test_vector_conversion() -> void:
	for i in range(10):
		var x:int = Rng.randi_range(-10_000_000, 10_000_000)
		var y:int = Rng.randi_range(-10_000_000, 10_000_000)
		var z:int = Rng.randi_range(-10_000_000, 10_000_000)
		assert_eq(VectorUtilsExt.vec2i_vec3i(Vector2i(x,y), z), Vector3i(x,y,z),
			"vec2i_vec3i failed for Vector2i")
		assert_eq(VectorUtilsExt.vec2i_vec3i(Vector2(x,y), z), Vector3i(x,y,z),
			"vec2i_vec3i failed for Vector2")
		
		assert_eq(VectorUtilsExt.vec3i_vec2i(Vector3i(x,y,z)), Vector2i(x,y),
			"vec3i_vec2i failed for Vector3i")
		assert_eq(VectorUtilsExt.vec3i_vec2i(Vector3(x,y,z)), Vector2i(x,y),
			"vec3i_vec2i failed for Vector3")

func test_vector_scale() -> void:
	for i in range(-3,3):
		assert_eq(VectorUtilsExt.scale_down_vec2i(Vector2i(i*16,i*16), 16), Vector2i(i,i),
			"scale_down_vec2i failed for Vector2i")
		assert_eq(VectorUtilsExt.scale_down_vec2i(Vector2(i*16,i*16), 16), Vector2i(i,i),
			"scale_down_vec2i failed for Vector2")
		
		assert_eq(VectorUtilsExt.scale_down_vec3i(Vector3i(i*16,i*16,i*16), 16), Vector3i(i,i,i),
			"scale_down_vec3i failed for Vector3i")
		assert_eq(VectorUtilsExt.scale_down_vec3i(Vector3(i*16,i*16,i*16), 16), Vector3i(i,i,i),
			"scale_down_vec3i failed for Vector3")
		
		assert_eq(VectorUtilsExt.scale_down_vec3i_no_z(Vector3i(i*16,i*16,i*16), 16), Vector3i(i,i,i*16),
			"scale_down_vec3i_no_z failed for Vector3i")
		assert_eq(VectorUtilsExt.scale_down_vec3i_no_z(Vector3(i*16,i*16,i*16), 16), Vector3i(i,i,i*16),
			"scale_down_vec3i_no_z failed for Vector3")

func test_vector_chunk() -> void:
	var TEMPLATE_MINUS_VEC2:Array[Vector2i] = [
		Vector2i(-2,-2), Vector2i(-2,-1), Vector2i(-1,-2), Vector2i(-1,-1)]
	assert_eq(VectorUtilsExt.vec2i_get_positions_in_chunk(Vector2i(-1,-1), 2), TEMPLATE_MINUS_VEC2,
		"vec2i_get_positions_in_chunk failed for Vector2i")
	assert_eq(VectorUtilsExt.vec2i_get_positions_in_chunk(Vector2i(-1,-1), 2), TEMPLATE_MINUS_VEC2,
		"vec2i_get_positions_in_chunk failed for Vector2")
	var TEMPLATE_MINUS_VEC3_NO_Z:Array[Vector3i] = [
		Vector3i(-2,-2, 0), Vector3i(-2,-1, 0), Vector3i(-1,-2, 0), Vector3i(-1,-1, 0)]
	assert_eq(VectorUtilsExt.vec3i_get_positions_in_chunk_no_z(Vector3i(-1,-1, 0), 2), TEMPLATE_MINUS_VEC3_NO_Z,
		"vec2i_get_positions_in_chunk failed for Vector3i")
	assert_eq(VectorUtilsExt.vec3i_get_positions_in_chunk_no_z(Vector3(-1,-1, 0), 2), TEMPLATE_MINUS_VEC3_NO_Z,
		"vec2i_get_positions_in_chunk failed for Vector3")

func test_vector_range() ->void:
	var TEMPLATE_VEC2:Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), 
		Vector2i(0, -1),  Vector2i(0, 0),  Vector2i(0, 1), 
		Vector2i(1, -1),  Vector2i(1, 0),  Vector2i(1, 1)]
	
	assert_eq(VectorUtilsExt.vec2i_get_positions_in_range(Vector2i(0,0), 1), TEMPLATE_VEC2,
		"vec2i_get_positions_in_range failed for Vector2i")
	assert_eq(VectorUtilsExt.vec2i_get_positions_in_range(Vector2(0,0), 1), TEMPLATE_VEC2,
		"vec2i_get_positions_in_range failed for Vector2")
