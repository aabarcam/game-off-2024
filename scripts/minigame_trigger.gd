@tool
extends Node2D
class_name MinigameTrigger

signal clicked(minigame: MinigameTrigger) ## Minigame clicked
signal won ## Minigame won
signal lost ## Minigame lost

@export var minigame: Manager.Minigames: ## Minigame to trigger
	set = set_minigame
@export var rounds: int = 3: ## How many rounds for the minigame
	set = set_rounds

@export_category("Components")
@export var interactable_component: InteractableComponent
@export var grenade_component: GrenadeComponent

@export_category("Available minigames")
@export var standard_round: PackedScene
@export var typing_round: PackedScene
@export var simon_says_round: PackedScene

@export_category("Hand textures")
@export var player_textures: Array[Texture2D] = []
@export var handshake_textures: Array[Texture2D] = []

var current_round: BaseRound
var round_count: int = 0

@onready var minigame_label_debug: Label = $MinigameLabel ## Editor debug label
@onready var grenade_instructions: Node2D = $GrenadeInstructions
@onready var instructions: Node2D = $Instructions
@onready var instructions_bg: Sprite2D = $Instructions/Background
@onready var instructions_text: Label = $Instructions/Text
@onready var game_start_button: Button = $Instructions/StartButton
@onready var player_hand: Sprite2D = $PlayerHandSprite
@onready var opponent_hand: Sprite2D = $OpponentHandSprite
@onready var handshake: Sprite2D = $HandshakeSprite

## Ready function called in editor
func _ready_editor() -> void:
	update_debug_label()

## Ready function called in game
func _ready_game() -> void:
	Signals.register_signal(clicked, self)
	Signals.register_signal(won, self)
	Signals.register_signal(lost, self)
	
	instructions.global_position = Vector2.ZERO
	instructions.modulate.a = 1.0
	
	grenade_instructions.global_position = Vector2.ZERO
	grenade_instructions.modulate.a = 1.0
	
	player_hand.global_position = player_hand.position
	opponent_hand.global_position = opponent_hand.position
	handshake.global_position = handshake.position
	
	reset_trigger()
	
	minigame_label_debug.hide()
	
	interactable_component.clicked.connect(_on_trigger_clicked)
	game_start_button.button_up.connect(_on_instructions_start_pressed)

func _ready() -> void:
	if Engine.is_editor_hint():
		_ready_editor()
	else:
		_ready_game()

func reset_trigger() -> void:
	if current_round != null:
		current_round.queue_free()
		current_round = null
	round_count = 0
	grenade_component.reset()
	grenade_instructions.hide()
	instructions.hide()
	hide_hands()
	handshake.hide()

func show_hands() -> void:
	player_hand.show()
	opponent_hand.show()

func hide_hands() -> void:
	player_hand.hide()
	opponent_hand.hide()

func show_instructions() -> void:
	instructions.show()

func update_debug_label() -> void:
	if minigame_label_debug != null:
		minigame_label_debug.text = "MINIGAME\n" + Manager.Minigames.keys()[minigame]

func connect_round_signals(this_round: BaseRound) -> void:
	this_round.key_pressed.connect(_on_key_pressed)
	this_round.won.connect(_on_round_won)
	this_round.lost.connect(_on_round_lost)

func disconnect_round_signals(this_round: BaseRound) -> void:
	this_round.key_pressed.disconnect(_on_key_pressed)
	this_round.won.disconnect(_on_round_won)
	this_round.lost.disconnect(_on_round_lost)

func start_minigame() -> void:
	if minigame == Manager.Minigames.STANDARD:
		current_round = standard_round.instantiate() as StandardRound
	elif minigame == Manager.Minigames.TYPING_OF_THE_DEAD:
		current_round = typing_round.instantiate() as TypingRound
	elif minigame == Manager.Minigames.SIMON_SAYS:
		current_round = simon_says_round.instantiate() as SimonSaysRound
	show_hands()
	connect_round_signals(current_round)
	add_child(current_round)
	current_round.start_round()

func get_random_player_sprite() -> Texture2D:
	var rand_id: int = randi() % player_textures.size()
	var output: Texture2D = player_textures[rand_id]
	if output == player_hand.texture:
		output = player_textures[(rand_id + 1) % player_textures.size()]
	return output

func disable_grenade() -> void:
	grenade_component.change_state(grenade_component.inactive_state)

func notify_minigame_lost() -> void:
	#current_round.reset()
	reset_trigger()
	lost.emit()

func set_minigame(new_val: Manager.Minigames) -> void:
	minigame = new_val
	if Engine.is_editor_hint():
		update_debug_label()

func set_rounds(new_val: int) -> void:
	rounds = new_val

func set_as_cleared() -> void:
	modulate = Color.GREEN
	interactable_component.input_pickable = false

func _on_trigger_clicked() -> void:
	clicked.emit(self)
	show_instructions()

func _on_round_won() -> void:
	round_count += 1
	if round_count < rounds:
		current_round.reset()
		current_round.start_round()
	else:
		handshake.show()
		hide_hands()
		#reset_trigger()
		won.emit()

func _on_round_lost() -> void:
	notify_minigame_lost()

func _on_instructions_start_pressed() -> void:
	instructions.hide()
	grenade_instructions.show()
	grenade_component.activate()
	if not grenade_component.held.is_connected(_on_grenade_held):
		grenade_component.held.connect(_on_grenade_held)
	if not grenade_component.exploded.is_connected(_on_grenade_exploded):
		grenade_component.exploded.connect(_on_grenade_exploded)

func _on_grenade_held() -> void:
	# start minigame
	grenade_instructions.hide()
	start_minigame()

func _on_grenade_exploded() -> void:
	# lose minigame
	notify_minigame_lost()

func _on_key_pressed() -> void:
	# change player sprite
	player_hand.texture = get_random_player_sprite()
