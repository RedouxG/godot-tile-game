#include "VectorUtils.h"

Vector2i VectorUtils::vec3i_vec2i(Vector3i vec){
    return Vector2i(vec.x, vec.y);
}

Vector3i VectorUtils::vec2i_vec3i(Vector2i vec, int32_t z){
    return Vector3i(vec.x, vec.y, z);
}

void VectorUtils::_bind_methods() 
{
    ClassDB::bind_static_method("VectorUtils", D_METHOD("vec3i_vec2i"), &VectorUtils::vec3i_vec2i);
    ClassDB::bind_static_method("VectorUtils", D_METHOD("vec2i_vec3i"), &VectorUtils::vec2i_vec3i);
}

