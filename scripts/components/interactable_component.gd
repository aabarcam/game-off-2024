extends Area2D
class_name InteractableComponent
## Component to add to interactable elements
##
## Emits clicked signal when interactable area is clicked

signal clicked ## Fired when interactable is clicked

func _ready() -> void:
	Signals.register_signal(clicked, self)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Ignore non-click events
	if not event is InputEventMouseButton:
		return
	event = event as InputEventMouseButton
	
	if event.pressed == true and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		interactable_clicked()

func interactable_clicked() -> void:
	clicked.emit()

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
