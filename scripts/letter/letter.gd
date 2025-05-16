@tool
extends Label
class_name Letter
## Represents a single letter in a sequence
##
## Handles input and clear conditions for this single letter

signal activated ## Letter has been activated
signal deactivated ## Letter has been deactivated
signal mistake ## Incorrect letter activated

@export_category("Debug")
@export var character: String: ## Charater represented by this letter
	set = set_character
enum Mode {NOT_SET, HOLD, TYPE}
@export var debug_activation_mode: Mode = Mode.NOT_SET

@export_category("States")
@export var activated_state: LetterBaseState
@export var deactivated_state: LetterBaseState
@export var inactive_state: LetterBaseState
@export var cleared_state: LetterBaseState
@export var deceiving_state: LetterBaseState

var state: LetterBaseState
var activation_mode: Mode = Mode.NOT_SET
var can_be_wrong: bool = false
#var mistake: bool = false
var quiet: bool = false:
	set = set_quiet
var incognito: bool = false:
	set = set_incognito

## Function determining if letter has been deactivated
var deactivate_condition: Callable

## Ready function for in game
func _ready_game() -> void:
	Signals.register_signal(activated, self)
	Signals.register_signal(deactivated,self)
	Signals.register_signal(mistake, self)
	
	change_state(inactive_state)
	
	if OS.is_debug_build() and get_parent() == get_tree().root:
		if character == "":
			character = "a"
		change_state(deactivated_state)
		activation_mode = debug_activation_mode
	elif character == "":
		push_error("Character not set")
	
	if activation_mode == Mode.HOLD:
		deactivate_condition = hold_deactivate_condition
	elif activation_mode == Mode.TYPE:
		deactivate_condition = type_deactivate_condition
	elif activation_mode == Mode.NOT_SET:
		push_error("Letter activation mode not set")

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		_ready_game()
	update_text()

func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		if activation_mode == Mode.NOT_SET:
			return
		if activate_condition(event):
			#set_process_input(not can_be_wrong)
			state.activate_letter()
		if not deactivate_condition.is_null() and deactivate_condition.call(event):
			state.deactivate_letter()

## Condition to activate letter
func activate_condition(event: InputEvent) -> bool:
	if not event is InputEventKey or event.echo:
		return false
	event = event as InputEventKey
	var keycode = event.keycode
	var event_key: String = get_event_key(event)
	if not event.pressed:
		return false
	if can_be_wrong and event_key != character and keycode >= 65 and keycode <= 90:
		state.wrong_letter(event_key)
	return event_key == character

## Condition to deactivate letter in holding minigames
func hold_deactivate_condition(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	event = event as InputEventKey
	var event_key: String = get_event_key(event)
	return event.pressed == false and event_key == character

## Condition to deactivate letter in typing minigames
func type_deactivate_condition(_event: InputEvent) -> bool:
	return false

## Returns the character corresponding to the key press, in lowercase
func get_event_key(event: InputEventKey) -> String:
	var keycode: Key = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
	return OS.get_keycode_string(keycode).to_lower()

func update_text() -> void:
	text = character.to_upper()

func light_on() -> void:
	modulate = Color.RED

func light_off() -> void:
	modulate = Color.WHITE

func wrong_letter(bad_char: String) -> void:
	MusicController.play_sfx_letter_wrong()
	mistake.emit()
	var original_char: String = text
	if bad_char != "":
		text = bad_char.to_upper()
	modulate = Color.RED
	set_process_input(false)
	await get_tree().create_timer(0.25).timeout
	if bad_char != "":
		text = original_char
	modulate = Color.WHITE
	set_process_input(true)

func update_incognito() -> void:
	if incognito:
		text = "_"
	else:
		text = character.to_upper()

func set_quiet(new_val: bool) -> void:
	quiet = new_val

func notify_activated() -> void:
	change_color(Color.LIME_GREEN)
	activated.emit()

func notify_deactivated() -> void:
	change_color(Color.WHITE)
	deactivated.emit()

func set_as_activated() -> void:
	change_state(activated_state)

## Mark letter as inactive
func set_as_inactive() -> void:
	change_state(inactive_state)

func set_as_cleared() -> void:
	change_state(cleared_state)

func set_as_deactivated() -> void:
	change_state(deactivated_state)

func set_as_deceiving() -> void:
	change_state(deceiving_state)

func change_color(color: Color) -> void:
	if quiet:
		return
	modulate = color

func signal_next() -> void:
	modulate = Color.DARK_BLUE

func is_activated() -> bool:
	return state.is_activated()

func is_deactivated() -> bool:
	return state.is_deactivated()

func is_active() -> bool:
	return state.is_active()

func is_inactive() -> bool:
	return state.is_inactive()

func is_cleared() -> bool:
	return state.is_cleared()

func is_deceiving() -> bool:
	return state.is_deceiving()

func set_character(new_val: String) -> void:
	if new_val.length() > 1:
		return
	character = new_val
	if Engine.is_editor_hint():
		update_text()

func change_state(new_state: LetterBaseState) -> void:
	state = new_state
	state.set_letter(self)

func reset() -> void:
	change_state(deactivated_state)
	change_color(Color.WHITE)

func set_incognito(new_val: bool) -> void:
	incognito = new_val
	update_incognito()
