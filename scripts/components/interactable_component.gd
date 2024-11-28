extends TextureButton
class_name InteractableComponent
## Component to add to interactable elements
##
## Emits clicked signal when interactable area is clicked

signal clicked ## Fired when interactable is clicked

var selectable: bool = false
var focus: bool = false

func _ready() -> void:
	Signals.register_signal(clicked, self)
	
	button_up.connect(_on_button_up)

	#mouse_entered.connect(_on_mouse_entered)
	#mouse_exited.connect(_on_mouse_exited)

#func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	## Ignore non-click events
	#if not event is InputEventMouseButton:
		#return
	#event = event as InputEventMouseButton
	#
	##get_viewport().set_input_as_handled()
	#
	#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#focus = true
	#
	#if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and focus:
		#print("interactable")
		#interactable_clicked()

func interactable_clicked() -> void:
	clicked.emit()
	#if disabled:
		#mouse_default_cursor_shape = Control.CURSOR_ARROW

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"disabled":
			disabled = value
			mouse_default_cursor_shape = Control.CURSOR_ARROW
			return true
	return false

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_button_up() -> void:
	interactable_clicked()
