extends TextureButton

## Target scene to transition to on button press
@export_file(".tscn") var target_scene_path: String

## Whether to change to target scene or spawn target scene
@export var scene_change: bool = true

@export var close_menu: bool = false

func _ready() -> void:
	button_up.connect(_on_button_up)

func _on_button_up() -> void:
	MusicController.play_sfx_ui()
	if close_menu:
		get_parent().queue_free()
		return
	
	if scene_change:
		get_tree().change_scene_to_file(target_scene_path)
	else:
		var new_scene: PackedScene = load(target_scene_path)
		var new_instance: Control = new_scene.instantiate()
		get_tree().current_scene.add_child(new_instance)
