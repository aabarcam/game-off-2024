extends Node2D

@export var interactable_component: InteractableComponent

func _ready() -> void:
	Signals.register_signal(Signals.transition_triggered, self)
	
	interactable_component.clicked.connect(_on_interactable_clicked)

func _on_interactable_clicked() -> void:
	Signals.transition_triggered.emit()
