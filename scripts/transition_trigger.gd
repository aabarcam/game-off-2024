extends BaseTrigger
class_name TransitionTrigger

@export var interactable_component: InteractableComponent

func _ready() -> void:
	Signals.register_signal(Signals.transition_triggered, self)
	interactable_component.clicked.connect(_on_interactable_clicked)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func notify_transition_triggered() -> void:
	Signals.transition_triggered.emit()

func _on_interactable_clicked() -> void:
	if dialogue != null:
		DialogueManager.show_example_dialogue_balloon(dialogue, "start")
	else:
		notify_transition_triggered()

func _on_dialogue_ended(dialogue: DialogueResource) -> void:
		notify_transition_triggered()
	
