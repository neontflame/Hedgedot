extends Node
class_name GameUtils

static func get_zone_scene(zone:String):
	return load(get_zone_scene_path(zone))

static func get_zone_scene_path(zone:String):
	return "res://Gamestuffs/Zonestuffs/%s.tscn" % zone

static func get_char_asset(char:String, asset:String):
	return load(get_char_asset_path(char, asset))

static func get_char_asset_path(char:String, asset:String):
	return "res://Gamestuffs/Playerstuffs/%s/%s" % [char, asset]
	
static func get_char_info(char:String):
	var toParse = '{"name": "placeholder", "hudName": "place"}'
	if ResourceLoader.exists(get_char_asset_path(char, "Info.json")):
		toParse = FileUtils.get_text_file_content(get_char_asset_path(char, "Info.json"))
	return JSON.parse_string(toParse)
