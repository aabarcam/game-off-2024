extends Node

var small_example_balloon: PackedScene = preload("res://dialogues/custom_balloon/balloon.tscn")

var portraits: Dictionary = {
	"living_room": {
		"norman": {
			"texture": preload("res://assets/living_room/living_room_textbox.png"),
			"offset": 240,
			"offset_y": 0,
		}
	},
	"hall": {
		"stanley": {
			"texture": preload("res://assets/hall/character1_text.png"),
			"offset": 260,
			"offset_y": 0,
		},
		"steven": {
			"texture": preload("res://assets/hall/character2_text.png"),
			"offset": 40,
			"offset_y": 0,
		},
		"travis": {
			"texture": preload("res://assets/hall/character3_text.png"),
			"offset": 220,
			"offset_y": 0,
		},
	},
	"conference_room": {
		"pending0": {
			"texture": preload("res://assets/conference room/character1_cr_text.png"),
			"offset": 270,
			"offset_y": 0,
		},
		"pending1": {
			"texture": preload("res://assets/conference room/character2_cr_text.png"),
			"offset": 40,
			"offset_y": 0,
		},
		"pending2": {
			"texture": preload("res://assets/conference room/character3_cr_text.png"),
			"offset": 220,
			"offset_y": 0,
		},
	},
	"sacrifice_room": {
		"wallace": {
			"texture": preload("res://assets/sacrificeroom/sc_textbox_1.png"),
			"offset": 240,
			"offset_y": 0,
		},
		"felix": {
			"texture": preload("res://assets/sacrificeroom/sc_textbox_2.png"),
			"offset": 40,
			"offset_y": 0,
		},
		"grant": {
			"texture": preload("res://assets/sacrificeroom/sc_textbox_3.png"),
			"offset": 220,
			"offset_y": 0,
		},
	},
	"void": {
		"manoel": {
			"texture": preload("res://assets/void/void_textbox.png"),
			"offset": 80,
			"offset_y": 80,
		},
	},
}

enum Minigames {
	STANDARD,
	TYPING_OF_THE_DEAD,
	SIMON_SAYS,
	HANGMAN,
	WHACK_A_MOLE,
	BLITZ_TYPING}

var test = false
