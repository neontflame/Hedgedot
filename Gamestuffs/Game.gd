extends Node2D
class_name SonicGame

#region Staticness
static var info:Dictionary = {
	"player": "Sonic",
	"zone": "Test1"
}
static var playerObject:Player
static var zoneObject:Zone
static var lives:int = 3
#endregion

@export var playersNode:Node2D
@export var zonesNode:Node2D

var player:Player
var zone:Zone

#region Make shit
func makePlayer(character:String):
	if player != null: player.free()
	
	player = GameUtils.get_char_asset(character, character + ".tscn").instantiate()
	playersNode.add_child(player)
	
	SonicGame.playerObject = player

func makeZone(zoneName:String):
	if zone != null: zone.free()
		
	zone = GameUtils.get_zone_scene(zoneName).instantiate()
	zonesNode.add_child(zone)
	
	zoneObject = zone
	
	playerGotoSpawn()

func playerGotoSpawn(spawnNode:String = "Spawnpoint"):
	if player != null and zone != null:
		player.global_position = zone.get_node(spawnNode).global_position
#endregion

func _ready() -> void:
	makePlayer(SonicGame.info["player"])
	makeZone(SonicGame.info["zone"])
