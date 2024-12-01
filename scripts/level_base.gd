extends Node2D
class_name LevelBase

@export var start_dialogue: DialogueResource
@export var transition_dialogue: DialogueResource
@export var level_name: String
@export var music_name: String
@export var balloon: PackedScene
@export var transition: TransitionTrigger

var minigames: Array[Node] = []
var active_minigame: MinigameTrigger:
	set = set_active_minigame
var finished: bool = false
var input_active: bool = false
var options_menu: PackedScene = preload("res://scenes/menus/options_menu.tscn")

func _ready() -> void:
	#LevelManager.set_current_level(self)
	LevelManager.set_current_level_path(get_tree().current_scene.scene_file_path)
	LevelManager.set_next_transition_dialogue(transition_dialogue)
	LevelManager.set_level_name(level_name)
	LevelManager.music_name = music_name
	MusicController.play_music(music_name)
	minigames = get_scene_minigames()
	for minigame in minigames:
		minigame.clicked.connect(_on_minigame_clicked)
		minigame.clicked_disabled.connect(_on_clicked_disabled)
	
	if transition != null:
		transition.clicked_disabled.connect(_on_clicked_disabled)
	
	Signals.transition_triggered.connect(_on_transition_triggered)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	if balloon == null:
		balloon = Manager.small_example_balloon
	
	if start_dialogue != null:
		#DialogueManager.show_example_dialogue_balloon(start_dialogue, "start", [self])
		DialogueManager.show_dialogue_balloon_scene(balloon, start_dialogue, "start", [self])

func _process(_delta: float) -> void:
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

func get_scene_minigames() -> Array[Node]:
	var children: Array[Node] = get_children()
	var found_minigames: Array[Node] = children.filter(func (x: Node): return x.is_in_group("Minigame"))
	return found_minigames

func show_minigames() -> void:
	minigames.map(func (x): x.show())

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

## SETTERS / GETTERS

func set_active_minigame(new_val: MinigameTrigger) -> void:
	active_minigame = new_val
	if new_val == null:
		show_minigames()

## SIGNAL HANDLERS

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	pass

func _on_minigame_lost() -> void:
	active_minigame = null
	enable_triggers()
	#MusicController.play_previous_zone()

func _on_minigame_won() -> void:
	enable_triggers()
	finished = true
	MusicController.play_music("minigame_won")
	active_minigame.disable_grenade()
	active_minigame.reset_trigger()
	active_minigame.set_as_cleared()
	active_minigame = null

func _on_minigame_clicked(minigame: MinigameTrigger) -> void:
	disable_triggers()
	active_minigame = minigame
	if not active_minigame.lost.is_connected(_on_minigame_lost):
		active_minigame.lost.connect(_on_minigame_lost)
	if not active_minigame.won.is_connected(_on_minigame_won):
		active_minigame.won.connect(_on_minigame_won)
		
	for minigame_iter in minigames:
		if minigame_iter != active_minigame:
			minigame_iter.hide()

func _on_transition_triggered() -> void:
	# diable all interactables
	disable_triggers()

func _on_clicked_disabled() -> void:
	# sonido malo
	MusicController.play_sfx_not()
