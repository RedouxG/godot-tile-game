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
#include <godot-cpp/include/godot_cpp/variant/rect2.hpp>
#include <godot-cpp/include/godot_cpp/variant/rect2i.hpp>

using namespace godot;

class VectorUtilsExt : public Script {
    GDCLASS(VectorUtilsExt, Script);
public:
    static Vector3i vec2i_vec3i(const Vector2i &vec, int64_t z);
    static Vector2i vec3i_vec2i(const Vector3i &vec);
    static Vector2i scale_down_vec2i(const Vector2 &vec, int64_t scale);
    static Vector3i scale_down_vec3i(const Vector3 &vec, int64_t scale);
    static Vector3i scale_down_vec3i_no_z(const Vector3 &vec, int64_t scale);
    static TypedArray<Vector2i> vec2i_get_positions_in_chunk(
        const Vector2i &vec, int64_t chunkSize);
    static TypedArray<Vector3i> vec3i_get_positions_in_chunk(
        const Vector3i &vec, int64_t chunkSize);
    static TypedArray<Vector3i> vec3i_get_positions_in_chunk_no_z(
        const Vector3i &vec, int64_t chunkSize);
    static TypedArray<Vector2i> vec2i_get_positions_in_range(
        const Vector2i &vec, int64_t range);
    static TypedArray<Vector3i> vec3i_get_positions_in_range(
        const Vector3i &vec, int64_t range);
    static TypedArray<Vector3i> vec3i_get_positions_in_range_no_z(
        const Vector3i &vec, int64_t range);
    static TypedArray<Vector2i> vec2i_move_array(
        TypedArray<Vector2i> arr, const Vector2i &moveBy);
    static TypedArray<Vector2i> vec2i_move_array_multiply(
        TypedArray<Vector2i> arr, const Vector2i &moveBy, const int64_t mul);
    static TypedArray<Vector3i> vec3i_move_array(
        TypedArray<Vector3i> arr, const Vector3i &moveBy);
    static TypedArray<Vector3i> vec3i_move_array_multiply(
        TypedArray<Vector3i> arr, const Vector3i &moveBy, const int64_t mul);
    static TypedArray<Vector2i> get_cells_in_rect2i(const Rect2i &rect, int64_t cellSize);
    static TypedArray<Vector3i> get_positions_on_z(const TypedArray<Vector3i> &arr, const int64_t z);
protected:
    static void _bind_methods();
};

#endif