extends Node2D
class_name HUD

@export var lifeCounter:Node2D

func _ready() -> void:
	var name:String = GameUtils.get_char_info(SonicGame.info["player"]).hudName
	lifeCounter.get_node("LifeName").text = name.to_upper()
	lifeCounter.get_node("LifeIcon").texture = GameUtils.get_char_asset(SonicGame.info["player"], "Icon.png")

func refreshLives():
	lifeCounter.get_node("LifeCount").text = SonicGame.lives
