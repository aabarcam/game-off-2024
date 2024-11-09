extends Node2D
## Class represents a single round of the standard handshake minigame
##
## Generates random sequences of letters the player must press at a time

signal won ## Round has been cleared
signal lost ## Round has been lost

@export_category("Config")
@export var sequence_quantity: int = 5

@export_category("Components")
@export var sequence_generator: SequenceGenerator

func _ready() -> void:
	Signals.register_signal(won, self)
	Signals.register_signal(lost, self)
