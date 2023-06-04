#ifndef VECTOR_UTILS
#define VECTOR_UTILS

#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/script.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/math.hpp>

#include <godot-cpp/include/godot_cpp/variant/vector2.hpp>
#include <godot-cpp/include/godot_cpp/variant/vector2i.hpp>
#include <godot-cpp/include/godot_cpp/variant/vector3.hpp>
#include <godot-cpp/include/godot_cpp/variant/vector3i.hpp>

using namespace godot;

class VectorUtils : public Script {
    GDCLASS(VectorUtils, Script);
public:
    static Vector3i vec2i_vec3i(const Vector2i &vec, int32_t z);
    static Vector2i vec3i_vec2i(const Vector3i &vec);
    static Vector2i scale_down_vec2i(const Vector2 &vec, int32_t scale);
    static Vector3i scale_down_vec3i(const Vector3 &vec, int32_t scale);
    static Vector3i scale_down_vec3i_no_z(const Vector3 &vec, int32_t scale);

protected:
    static void _bind_methods();
};

#endif