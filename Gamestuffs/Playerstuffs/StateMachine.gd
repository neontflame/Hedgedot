extends Node
class_name PlayerStateMachine

var stateIndex:Dictionary[String, PlayerStatePattern] = {}

func _ready() -> void:
	for child in self.get_children():
		stateIndex[child.name] = child
