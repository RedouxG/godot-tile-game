### ----------------------------------------------------
### Sublib for image/texture related actions
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Interpolates BG texture with addColor
# Puts Outline texture on top of interpolated BG texture
# Returns null on failure
static func stack_textures(textureBG:Texture2D, textureOutline:Texture2D, addColor:Color, weight:float) -> Texture2D:
	if(not textureBG.get_size() == textureOutline.get_size()):
		push_error("Texture2D outline and bg must be same size: "+str(textureBG.get_size())+" "+str(textureOutline.get_size()))
		return null
	if(weight<0 or weight>1):
		push_error("Weight must be in range from 0 - 1: " + str(weight))
		return null
	
	var BGImage:Image = textureBG.get_data()
	var OutlineImage:Image = textureOutline.get_data()
	var blendImage := Image.create(textureBG.get_width(), textureBG.get_height(), false,Image.FORMAT_RGBA8)
	
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
	return ImageTexture.create_from_image(blendImage)


# Gets singular sprite from a set
static func get_sprite_from_texture(spritePos:Vector2, spriteSize:Vector2, setTexture:Texture2D) -> Texture2D:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(setTexture)
	atlas_texture.set_region_enabled(Rect2(spritePos, spriteSize))
	return atlas_texture

# Returns image size as array [width,height], empty Array on fail
static func get_png_size(path:String) -> Array[int]:
	var image := Image.new()
	if(not image.load(path) == OK): return []
	return [image.get_width(), image.get_height()]
