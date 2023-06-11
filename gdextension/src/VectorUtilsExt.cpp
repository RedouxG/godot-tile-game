#include "VectorUtilsExt.h"

void VectorUtilsExt::_bind_methods() 
{
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_vec2i", "vec"), &VectorUtilsExt::vec3i_vec2i);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec2i_vec3i", "vec"), &VectorUtilsExt::vec2i_vec3i);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("scale_down_vec2i", "vec"), &VectorUtilsExt::scale_down_vec2i);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("scale_down_vec3i", "vec"), &VectorUtilsExt::scale_down_vec3i);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("scale_down_vec3i_no_z", "vec"), &VectorUtilsExt::scale_down_vec3i_no_z);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec2i_get_positions_in_chunk", "vec", "chunkSize"), &VectorUtilsExt::vec2i_get_positions_in_chunk);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_get_positions_in_chunk", "vec", "chunkSize"), &VectorUtilsExt::vec3i_get_positions_in_chunk);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_get_positions_in_chunk_no_z", "vec", "chunkSize"), &VectorUtilsExt::vec3i_get_positions_in_chunk_no_z);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec2i_move_array", "vec", "moveBy"), &VectorUtilsExt::vec2i_move_array);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec2i_move_array_multiply", "vec", "moveBy", "mul"), &VectorUtilsExt::vec2i_move_array_multiply);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_move_array", "vec", "moveBy"), &VectorUtilsExt::vec3i_move_array);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_move_array_multiply", "vec", "moveBy", "mul"), &VectorUtilsExt::vec3i_move_array_multiply);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec2i_get_positions_in_range", "arr", "range"), &VectorUtilsExt::vec2i_get_positions_in_range);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_get_positions_in_range", "arr", "range"), &VectorUtilsExt::vec3i_get_positions_in_range);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("vec3i_get_positions_in_range_no_z", "arr", "range"), &VectorUtilsExt::vec3i_get_positions_in_range_no_z);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("get_cells_in_rect2i", "rect", "cellSize"), &VectorUtilsExt::get_cells_in_rect2i);
    ClassDB::bind_static_method("VectorUtilsExt", 
        D_METHOD("get_positions_on_z", "arr", "z"), &VectorUtilsExt::get_positions_on_z);
}

Vector2i VectorUtilsExt::vec3i_vec2i(const Vector3i &vec)
{
    return Vector2i(vec.x, vec.y);
}

Vector3i VectorUtilsExt::vec2i_vec3i(const Vector2i &vec, int64_t z)
{
    return Vector3i(vec.x, vec.y, z);
}

Vector2i VectorUtilsExt::scale_down_vec2i(const Vector2 &vec, int64_t scale)
{
    return Vector2i(Math::floor(vec.x/scale), Math::floor(vec.y/scale));
}

Vector3i VectorUtilsExt::scale_down_vec3i(const Vector3 &vec, int64_t scale)
{
    return Vector3i(Math::floor(vec.x/scale), Math::floor(vec.y/scale), Math::floor(vec.z/scale));
}

Vector3i VectorUtilsExt::scale_down_vec3i_no_z(const Vector3 &vec, int64_t scale){
    return Vector3i(Math::floor(vec.x/scale), Math::floor(vec.y/scale), vec.z);
}

TypedArray<Vector2i> VectorUtilsExt::vec2i_get_positions_in_chunk(
    const Vector2i &vec, int64_t chunkSize)
{
    TypedArray<Vector2i> output = TypedArray<Vector2i>();
    for(int64_t x=0; x<chunkSize; x++)
    {
        for(int64_t y=0; y<chunkSize; y++)
        {
            output.append(Vector2i(vec.x*chunkSize + x, vec.y*chunkSize + y));
        }
    }
    return output;
}

TypedArray<Vector3i> VectorUtilsExt::vec3i_get_positions_in_chunk(
    const Vector3i &vec, int64_t chunkSize)
{
    TypedArray<Vector3i> output = TypedArray<Vector3i>();
    for(int64_t x=0; x<chunkSize; x++)
    {
        for(int64_t y=0; y<chunkSize; y++)
        {
            for(int64_t z=0; z<chunkSize; z++)
            { output.append(Vector3i(vec.x*chunkSize + x, vec.y*chunkSize + y, vec.z*chunkSize + z)); }
        }
    }
    return output;
}

TypedArray<Vector3i> VectorUtilsExt::vec3i_get_positions_in_chunk_no_z(
    const Vector3i &vec, int64_t chunkSize)
{
    TypedArray<Vector3i> output = TypedArray<Vector3i>();
    for(int64_t x=0; x<chunkSize; x++)
    {
        for(int64_t y=0; y<chunkSize; y++)
        {
            output.append(Vector3i(vec.x*chunkSize + x, vec.y*chunkSize + y, vec.z));
        }
    }
    return output;
}

TypedArray<Vector2i> VectorUtilsExt::vec2i_get_positions_in_range(
    const Vector2i &vec, int64_t range)
{
    TypedArray<Vector2i> output = TypedArray<Vector2i>();
    for(int64_t x=-range; x<range+1; x++)
    {
        for(int64_t y=-range; y<range+1; y++)
        {
            output.append(Vector2i(x, y) + vec);
        }
    }
    return output;
}

TypedArray<Vector3i> VectorUtilsExt::vec3i_get_positions_in_range(
    const Vector3i &vec, int64_t range)
{
    TypedArray<Vector3i> output = TypedArray<Vector3i>();
    for(int64_t x=-range; x<range+1; x++)
    {
        for(int64_t y=-range; y<range+1; y++)
        {
            for(int64_t z=-range; z<range+1; z++)
            { output.append(Vector3i(x, y, z) + vec); }
        }
    }
    return output;
}

TypedArray<Vector3i> VectorUtilsExt::vec3i_get_positions_in_range_no_z(
    const Vector3i &vec, int64_t range)
{
    TypedArray<Vector3i> output = TypedArray<Vector3i>();
    for(int64_t x=-range; x<range+1; x++)
    {
        for(int64_t y=-range; y<range+1; y++)
        {
            output.append(Vector3i(x, y, 0) + vec);
        }
    }
    return output;
}

TypedArray<Vector2i> VectorUtilsExt::vec2i_move_array(
    TypedArray<Vector2i> arr, const Vector2i &moveBy)
{
    for(int64_t index=0; index<arr.size(); index++)
    {
        arr[index] = Vector2i(arr[index]) + moveBy;
    }
    return arr;
}

TypedArray<Vector2i> VectorUtilsExt::vec2i_move_array_multiply(
    TypedArray<Vector2i> arr, const Vector2i &moveBy, const int64_t mul)
{
    for(int64_t index=0; index<arr.size(); index++)
    {
        arr[index] = Vector2i(arr[index]) + (moveBy * mul);
    }
    return arr;
}

TypedArray<Vector3i> VectorUtilsExt::vec3i_move_array(
    TypedArray<Vector3i> arr, const Vector3i &moveBy)
{
    for(int64_t index=0; index<arr.size(); index++)
    {
        arr[index] = Vector3i(arr[index]) + moveBy;
    }
    return arr;
}

TypedArray<Vector3i> VectorUtilsExt::vec3i_move_array_multiply(
    TypedArray<Vector3i> arr, const Vector3i &moveBy, const int64_t mul)
{
    for(int64_t index=0; index<arr.size(); index++)
    {
        arr[index] = Vector3i(arr[index]) + (moveBy * mul);
    }
    return arr;
}

// This is probably very slow and there should be a smarter way to do this but oh well
TypedArray<Vector2i> VectorUtilsExt::get_cells_in_rect2i(const Rect2i &rect, int64_t cellSize)
{
    TypedArray<Vector2i> output = TypedArray<Vector2i>();
    Vector2i rectEnd = rect.position + rect.size;

    int64_t startX;
    int64_t endX;
    if(rectEnd.x > rect.position.x) 
    { startX = rect.position.x; endX = rectEnd.x; }
    else 
    { startX = rectEnd.x; endX = rect.position.x; }

    int64_t startY;
    int64_t endY;
    if(rectEnd.y > rect.position.y) 
    { startY = rect.position.y; endY = rectEnd.y; }
    else 
    { startY = rectEnd.y; endY = rect.position.y; }

    for(int64_t x = startX; x<endX; x+=cellSize)
    {
        for(int64_t y = startY; y<endY; y+=cellSize)
        {
            output.append(scale_down_vec2i(Vector2i(x,y), cellSize));
        }
    }

    return output;
}

TypedArray<Vector3i> VectorUtilsExt::get_positions_on_z(const TypedArray<Vector3i> &arr, const int64_t z)
{
    TypedArray<Vector3i> result;
    for(int64_t index=0; index<arr.size(); index++)
    {
        Vector3i v = arr[index];
        if(v.z == z)
        {
            result.append(v);
        }
    }

    return result;
}