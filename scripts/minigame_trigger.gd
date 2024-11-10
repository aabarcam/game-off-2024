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

@export_category("Available minigames")
@export var standard_round: PackedScene

var current_round: Node2D
var round_count: int = 0

@onready var minigame_label_debug: Label = $MinigameLabel ## Editor debug label

## Ready function called in editor
func _ready_editor() -> void:
	pass

## Ready function called in game
func _ready_game() -> void:
	Signals.register_signal(clicked, self)
	Signals.register_signal(won, self)
	Signals.register_signal(lost, self)
	
	minigame_label_debug.hide()
	
	interactable_component.clicked.connect(_on_trigger_clicked)

func _ready() -> void:
	if Engine.is_editor_hint():
		_ready_editor()
	else:
		_ready_game()

func update_debug_label() -> void:
	minigame_label_debug.text = "MINIGAME\n" + Manager.Minigames.keys()[minigame]

func connect_round_signals(round: Node2D) -> void:
	round.won.connect(_on_round_won)
	round.lost.connect(_on_round_lost)

func set_minigame(new_val: Manager.Minigames) -> void:
	minigame = new_val
	if Engine.is_editor_hint():
		update_debug_label()

func set_rounds(new_val: int) -> void:
	rounds = new_val

func _on_trigger_clicked() -> void:
	clicked.emit(self)
	if minigame == Manager.Minigames.STANDARD:
		current_round = standard_round.instantiate() as StandardRound
		connect_round_signals(current_round)
		add_child(current_round)
		current_round.start_round()

func _on_round_won() -> void:
	round_count += 1
	if round_count < rounds:
		current_round.reset()
		current_round.start_round()
	else:
		won.emit()

func _on_round_lost() -> void:
	lost.emit()
