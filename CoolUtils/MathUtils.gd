extends Node
class_name Maths

static func desubpixel(subpix:int, pix:int = 0) -> float:
	return pix + (float(subpix) / 256);

static func subpixel(myFloat:float):
	return round(myFloat * 256)

## returns an array with both subpixel and pixel
static func subpixel_pixel(myFloat:float):
	var subpix = int(myFloat * 256) % 256
	var pix = round(((myFloat * 256) - subpix) / 256)
	return [subpix, pix]

static func angle_fixer_deg(theAngle:float):
	return wrapf(theAngle, 0, 360)

static func angle_fixer_rad(theAngle:float):
	return wrapf(theAngle, 0, PI * 2)
