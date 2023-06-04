#include "VectorUtils.h"

void VectorUtils::_bind_methods() 
{
    ClassDB::bind_static_method("VectorUtils", D_METHOD("vec3i_vec2i"), &VectorUtils::vec3i_vec2i);
    ClassDB::bind_static_method("VectorUtils", D_METHOD("vec2i_vec3i"), &VectorUtils::vec2i_vec3i);
    ClassDB::bind_static_method("VectorUtils", D_METHOD("scale_down_vec2i"), &VectorUtils::scale_down_vec2i);
    ClassDB::bind_static_method("VectorUtils", D_METHOD("scale_down_vec3i"), &VectorUtils::scale_down_vec3i);
    ClassDB::bind_static_method("VectorUtils", D_METHOD("scale_down_vec3i_no_z"), &VectorUtils::scale_down_vec3i_no_z);
}

Vector2i VectorUtils::vec3i_vec2i(const Vector3i &vec)
{
    return Vector2i(vec.x, vec.y);
}

Vector3i VectorUtils::vec2i_vec3i(const Vector2i &vec, int32_t z)
{
    UtilityFunctions::print(vec);
    return Vector3i(vec.x, vec.y, z);
}

Vector2i VectorUtils::scale_down_vec2i(const Vector2 &vec, int32_t scale)
{
    return Vector2i(Math::floor(vec.x/scale), Math::floor(vec.y/scale));
}

Vector3i VectorUtils::scale_down_vec3i(const Vector3 &vec, int32_t scale)
{
    return Vector3i(Math::floor(vec.x/scale), Math::floor(vec.y/scale), Math::floor(vec.z/scale));
}

Vector3i VectorUtils::scale_down_vec3i_no_z(const Vector3 &vec, int32_t scale){
    return Vector3i(Math::floor(vec.x/scale), Math::floor(vec.y/scale), vec.z);
}



