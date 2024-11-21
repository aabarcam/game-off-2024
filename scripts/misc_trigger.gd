extends BaseTrigger
class_name MiscTrigger

@export var interactable_component: InteractableComponent

func _ready() -> void:
	interactable_component.clicked.connect(_on_interactable_clicked)

#func notify_transition_triggered() -> void:
	#Signals.transition_triggered.emit()

func _on_interactable_clicked() -> void:
	if dialogue != null:
		DialogueManager.show_example_dialogue_balloon(dialogue, "start", [self])
	else:
		push_error("No dialogue set for misc interactable")
	
