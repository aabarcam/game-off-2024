extends Node

@export_file(".tscn") var levels: Array[String] ## List of levels for final version
@export_file(".tscn") var prototype_levels: Array[String] ## List of prototype levels

var selected_levels = levels ## Level list to use

var current_level: String: ## Level curently in play
	set = set_current_level

func _ready() -> void:
	Signals.transition_triggered.connect(_on_transition_triggered)

## Return next level in the list
func get_next_level() -> String:
	if current_level == null:
		return ""
	var current_level_id: int = selected_levels.find(current_level)
	if current_level_id == -1:
		push_warning("Current level not found in list")
		return ""
	if current_level_id + 1 >= selected_levels.size():
		push_error("Tried accessing a level with index higher than is possible")
		return ""
	return selected_levels[current_level_id + 1]

## Called when a level transition happens
func _on_transition_triggered() -> void:
	var next_level_path: String = get_next_level()
	if next_level_path == "":
		return
	var next_level: PackedScene = load(next_level_path)
	get_tree().change_scene_to_packed(next_level)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	MusicController.play_music("zone_1")

func set_current_level(new_val: String) -> void:
	current_level = new_val
	if current_level in prototype_levels:
		selected_levels = prototype_levels
