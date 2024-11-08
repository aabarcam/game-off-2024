extends Node2D
class_name LevelBase

func _ready() -> void:
	var current_level_path = get_tree().current_scene.scene_file_path
	LevelManager.set_current_level(current_level_path)
