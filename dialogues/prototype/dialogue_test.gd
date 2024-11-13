extends Node2D

@export var testing: bool = true
@export var action: String = "hold_grenade_click"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(action):
		DialogueManager.show_example_dialogue_balloon(load("res://dialogues/prototype/test_dialogue.dialogue"), "test", [self])
