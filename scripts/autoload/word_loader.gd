extends Node

var hangman_json: JSON = preload("res://words/hangman.json")
var hangman_words: Dictionary = hangman_json.data
var hangman_normal: Dictionary = hangman_words["normal"]
var hangman_ambiguous: Dictionary = hangman_words["ambiguous"]

var typing_json: JSON = preload("res://words/typing.json")
var typing_words: Array[String] = typing_json.data

func _ready() -> void:
	print(typing_words)
