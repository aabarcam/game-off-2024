@tool
extends Node2D
class_name MinigameTrigger

@export var minigame: Manager.Minigames:
	set = set_minigame

@onready var minigame_label_debug: Label = $MinigameLabel

func _ready_editor() -> void:
	pass

func _ready_game() -> void:
	minigame_label_debug.hide()

func _ready() -> void:
	if Engine.is_editor_hint():
		_ready_editor()
	else:
		_ready_game()

func update_debug_label() -> void:
	minigame_label_debug.text = "MINIGAME\n" + Manager.Minigames.keys()[minigame]

func set_minigame(new_val: Manager.Minigames) -> void:
	minigame = new_val
	update_debug_label()
