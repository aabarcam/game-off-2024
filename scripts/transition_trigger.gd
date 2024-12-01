extends BaseTrigger
class_name TransitionTrigger

@export var required_minigames: Array[MinigameTrigger]
@export var interactable_component: InteractableComponent
@export var open_texture: Texture2D
@export var open_dialogue: DialogueResource

var open: bool = false:
	set = set_open

func _ready() -> void:
	Signals.register_signal(Signals.transition_triggered, self)
	interactable_component.clicked.connect(_on_interactable_clicked)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	for minigame in required_minigames:
		minigame.won.connect(_on_minigame_won)
	
	if all_minigames_cleared():
		set_open(true)

func notify_transition_triggered() -> void:
	Signals.transition_triggered.emit()

func show_dialogue(resource: DialogueResource) -> void:
	if resource != null:
		#DialogueManager.show_example_dialogue_balloon(resource, "start", [self])
		DialogueManager.show_dialogue_balloon_scene(Manager.small_example_balloon, resource, "start", [self])
	else:
		DialogueManager.dialogue_ended.emit(resource)

func all_minigames_cleared() -> bool:
	var output: bool = true
	for minigame in required_minigames:
		output = output and minigame.cleared
	return output

func set_open(value: bool) -> void:
	open = value
	if open_texture != null:
		interactable_component.texture_normal = open_texture
	if open:
		MusicController.play_sfx_door_open()

func _on_interactable_clicked() -> void:
	if open:
		show_dialogue(open_dialogue)
	else:
		show_dialogue(dialogue)

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == open_dialogue and open:
		notify_transition_triggered()

func _on_minigame_won() -> void:
	if all_minigames_cleared():
		set_open(true)
