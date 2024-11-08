extends Node2D
class_name Grenade

signal held
signal exploded

var active: bool = true ## Whether to use the grenade in the minigame

@export var holding_state: GrenadeBaseState
@export var active_state: GrenadeBaseState
@export var inactive_state: GrenadeBaseState

var state: GrenadeBaseState:
	set = change_state

func _ready() -> void:
	Signals.register_signal(exploded, self)
	Signals.register_signal(held, self)
	
	change_state(inactive_state)
	
	# To debug this single scene
	if OS.is_debug_build() and get_tree().root == get_parent():
		push_warning("Debugging single Grenade scene")
		change_state(active_state)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hold_grenade_click"):
		state.hold_grenade()
	elif Input.is_action_just_released("hold_grenade_click"):
		state.release_grenade()

func activate() -> void:
	change_state(active_state)

func notify_held() -> void:
	held.emit()

func notify_exploded() -> void:
	exploded.emit()

func change_state(new_state: GrenadeBaseState) -> void:
	state = new_state
	state.set_grenade(self)
