extends Node2D
class_name LevelBase

var minigames: Array[MinigameTrigger] = []
var active_minigame: MinigameTrigger

func _ready() -> void:
	var current_level_path = get_tree().current_scene.scene_file_path
	LevelManager.set_current_level(current_level_path)
	minigames = get_scene_minigames()
	for minigame in minigames:
		minigame.clicked.connect(_on_minigame_clicked)

func get_scene_minigames() -> Array[MinigameTrigger]:
	var children: Array[Node] = get_children()
	var found_minigames: Array[MinigameTrigger] = children.filter(func (x: Node): return x.is_in_group("Minigame"))
	return found_minigames

func _on_minigame_clicked(minigame: MinigameTrigger) -> void:
	active_minigame = minigame
