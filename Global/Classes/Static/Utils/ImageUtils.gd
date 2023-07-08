### ----------------------------------------------------
### Sublib for image/texture related actions
### ----------------------------------------------------

extends Script
class_name ImageUtils

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

# Puts Outline texture on top of interpolated BG texture
# Returns null on failure
static func stack_images(BGImage:Image, OutlineImage:Image, addColor:Color, weight:float) -> Image:
    if(not (BGImage.get_height() == OutlineImage.get_height()) and (BGImage.get_width() == OutlineImage.get_width())):
        push_error("BGImage and OutlineImage must be same size!")
        return null
    if(weight<0 or weight>1):
        push_error("Weight must be in range from 0 - 1: " + str(weight))
        return null
    
    var blendImage := Image.create(BGImage.get_width(), BGImage.get_height(), false, Image.FORMAT_RGBA8)
    
    for x in range(BGImage.get_width()):
        for y in range(BGImage.get_height()):
            # Interpolate bg with addColor
            var BGPixel:Color = BGImage.get_pixel(x,y)
            if BGPixel.a != 0: BGPixel = BGPixel.lerp(addColor, weight) 
            
            # Put outline on
            var OutlinePixel:Color = OutlineImage.get_pixel(x,y)
            var blendPixel:Color = BGPixel
            if OutlinePixel.a != 0: blendPixel = BGPixel.lerp(OutlinePixel,1)
            
            blendImage.set_pixel(x, y, blendPixel)
    return blendImage

# Interpolates a texture with a color
# Returns null on failure
static func interpolate_image(image:Image, addColor:Color, weight:float) -> Image:
    if(weight<0 or weight>1):
        push_error("Weight must be in range from 0 - 1: " + str(weight))
        return null
    
    var blendImage := Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
    for x in range(image.get_width()):
        for y in range(image.get_height()):
            var blendPixel:Color = image.get_pixel(x,y)
            if blendPixel.a != 0: 
                blendPixel = blendPixel.lerp(addColor, weight) 
            blendImage.set_pixel(x, y, blendPixel)
    return blendImage

# Gets singular sprite from a set
static func get_sprite_from_texture(spritePos:Vector2i, spriteSize:Vector2i, setTexture:Texture2D) -> Texture2D:
    var atlas_texture := AtlasTexture.new()
    atlas_texture.set_atlas(setTexture)
    atlas_texture.set_region_enabled(Rect2(spritePos, spriteSize))
    return atlas_texture

# Returns image size as array [width,height], empty Array on fail
static func get_png_size(path:String) -> Vector2i:
    var image := Image.new()
    if(not image.load(path) == OK): return Vector2i(-1, -1)
    return Vector2i(image.get_width(), image.get_height())

static func load_image(path:String) -> Image:
    var texture:Texture2D = ResourceLoader.load(path)
    return texture.get_image()
