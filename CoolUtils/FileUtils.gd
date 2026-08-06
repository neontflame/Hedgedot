extends Node
class_name FileUtils

static func get_text_file_content(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

static func format_bytes(Bytes:int):
	# https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/FlxStringUtil.hx
	var units:Array = ["B", "kB", "MB", "GB", "TB", "PB"]
	var curUnit = 0
	while (Bytes >= 1024 && curUnit < len(units) - 1):
		Bytes /= 1024;
		curUnit += 1
	return Bytes + units[curUnit]
