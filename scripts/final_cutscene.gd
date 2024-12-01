extends Node2D

@export var start_dialogue: DialogueResource
@export var after_cutscene_dialogue: DialogueResource
@export var level_name: String
@export var music_name: String = ""
@export var balloon: PackedScene
@export var credits_scene: PackedScene

var options_menu: PackedScene = preload("res://scenes/menus/options_menu.tscn")

@onready var background: Sprite2D = $Background

func _ready() -> void:
	#LevelManager.set_current_level(self)
	LevelManager.set_current_level_path(get_tree().current_scene.scene_file_path)
	LevelManager.set_level_name(level_name)
	LevelManager.music_name = music_name
	if music_name != "":
		MusicController.play_music(music_name)
	
	Signals.transition_triggered.connect(_on_transition_triggered)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	if balloon == null:
		balloon = Manager.small_example_balloon
	
	if start_dialogue != null:
		#DialogueManager.show_example_dialogue_balloon(start_dialogue, "start", [self])
		DialogueManager.show_dialogue_balloon_scene(balloon, start_dialogue, "start", [self])
	else:
		start_cutscene()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		var options_inst = options_menu.instantiate()
		get_tree().current_scene.add_child(options_inst)
		get_tree().paused = true

#func _unhandled_input(event: InputEvent) -> void:
	## Ignore non-click events
	#if not event is InputEventMouseButton:
		#return
	#event = event as InputEventMouseButton
	#
	#if not event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		## mouse released on nothing
		#print("unhandled clickS")
		##unfocus_triggers()

func get_triggers() -> Array[Node]:
	return get_children().filter(func(x:Node):return x is BaseTrigger)

func unfocus_triggers() -> void:
	var triggers: Array[Node] = get_triggers()
	for trigger in triggers:
		trigger.interactable_component.focus = false

func disable_triggers() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var triggers: Array[Node] = get_triggers()
	for trigger in triggers:
		#trigger.interactable_component.input_pickable = false
		trigger.interactable_component.disabled = true

func enable_triggers() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var triggers: Array[Node] = get_triggers()
	for trigger in triggers:
		#trigger.interactable_component.input_pickable = false
		trigger.interactable_component.disabled = false

func enable_triggers_click() -> void:
	var triggers: Array[Node] = get_triggers()
	for trigger in triggers:
		trigger.interactable_component.selectable = true

func start_cutscene() -> void:
	await create_tween().tween_property(background, "position:x", 640 - 856, 5.0).finished
	if after_cutscene_dialogue != null:
		DialogueManager.show_dialogue_balloon_scene(balloon, after_cutscene_dialogue, "start", [self])
	else:
		if credits_scene != null:
			get_tree().change_scene_to_packed(credits_scene)

## SETTERS / GETTERS

## SIGNAL HANDLERS

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == start_dialogue:
		start_cutscene()
	elif resource == after_cutscene_dialogue:
		get_tree().change_scene_to_packed(credits_scene)

func _on_transition_triggered() -> void:
	# diable all interactables
	disable_triggers()
