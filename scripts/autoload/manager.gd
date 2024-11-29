extends Node

var small_example_balloon: PackedScene = preload("res://dialogues/custom_balloon/balloon.tscn")

enum Minigames {
	STANDARD,
	TYPING_OF_THE_DEAD,
	SIMON_SAYS,
	HANGMAN,
	WHACK_A_MOLE,
	BLITZ_TYPING}

#@export 

var test = false
