#ifndef VECTOR_UTILS
#define VECTOR_UTILS

#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/script.hpp>
#include <godot_cpp/core/class_db.hpp>

#include <godot-cpp/include/godot_cpp/variant/vector2.hpp>
#include <godot-cpp/include/godot_cpp/variant/vector2i.hpp>
#include <godot-cpp/include/godot_cpp/variant/vector3.hpp>
#include <godot-cpp/include/godot_cpp/variant/vector3i.hpp>

using namespace godot;

class VectorUtils : public Script {
    GDCLASS(VectorUtils, Script);
public:
    static Vector3i vec2i_vec3i(Vector2i, int32_t z);
    static Vector2i vec3i_vec2i(Vector3i);

protected:
    static void _bind_methods();
};

#endif