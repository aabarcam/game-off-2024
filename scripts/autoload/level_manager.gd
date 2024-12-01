extends Node

@export_file(".tscn") var levels: Array[String] ## List of levels for final version
@export_file(".tscn") var prototype_levels: Array[String] ## List of prototype levels

var selected_levels = levels ## Level list to use
#var current_level: LevelBase: ## Level curently in play
	#set = set_current_level
var current_level_path: String:
	set = set_current_level_path
var next_transition_dialogue: DialogueResource:
	set = set_next_transition_dialogue
var level_name: String:
	set = set_level_name
var char_name: String:
	set = set_char_name
var music_name: String

@onready var transition_screen: ColorRect = $CanvasLayer/TransitionScreen

func _ready() -> void:
	Signals.transition_triggered.connect(_on_transition_triggered)

#func _input(event: InputEvent) -> void:
	## Ignore non-click events
	#if not event is InputEventMouseButton:
		#return
	#event = event as InputEventMouseButton
	#
	#if event.pressed == false and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		#print("mouse released")

## Return next level in the list
func get_next_level() -> String:
	if current_level_path == "":
		return ""
	var current_level_id: int = selected_levels.find(current_level_path)
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
	await transition_start()
	get_tree().change_scene_to_packed(next_level)
	if next_transition_dialogue != null:
		#DialogueManager.show_example_dialogue_balloon(next_transition_dialogue, "start", [self])
		DialogueManager.show_dialogue_balloon_scene(Manager.small_example_balloon, next_transition_dialogue, "start", [self])
		await DialogueManager.dialogue_ended
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	MusicController.play_music("zone_1")
	await transition_end()

func transition_start() -> void:
	transition_screen.show()
	transition_screen.modulate.a = 0
	await create_tween().tween_property(transition_screen, "modulate:a", 1.0, 1.0).finished

func transition_end() -> void:
	transition_screen.show()
	transition_screen.modulate.a = 1
	await create_tween().tween_property(transition_screen, "modulate:a", 0.0, 1.0).finished

#func set_current_level(new_val: LevelBase) -> void:
	#current_level = new_val

func set_current_level_path(new_val: String) -> void:
	current_level_path = new_val
	if current_level_path in prototype_levels:
		selected_levels = prototype_levels
	else:
		selected_levels = levels

func set_next_transition_dialogue(new_val: DialogueResource) -> void:
	next_transition_dialogue = new_val

func set_level_name(value: String) -> void:
	level_name = value

func set_char_name(value: String) -> void:
	char_name = value
