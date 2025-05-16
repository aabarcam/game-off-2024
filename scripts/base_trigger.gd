extends Node2D
class_name BaseTrigger

signal clicked_disabled ## Clicked disabled trigger

@export_category("Dialogues")
@export var dialogue: DialogueResource

var interacted_times: int = 0

func _ready() -> void:
	Signals.register_signal(clicked_disabled, self)
