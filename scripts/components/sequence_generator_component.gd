extends Node2D
class_name SequenceGenerator
## Letter sequence generator
##
## Generate different types of letter sequences to be used in minigames
## TODO: exclude certain sequences that are known to not work in some keyboards,
## or whitelist good sequences

@export var letter_scene: PackedScene
@export var sequence_scene: PackedScene

## TODO: Save in different file
var allowed_words: Array[String] = [ ## List of words to return for typing minigame
	"penguin",
	"computer",
	"keyboard",
	"handshake",
	"cult",
	"gamejam",
	"github",
	"grenade"
]

## All the usable letters in the alphabet, for random sequences
var alphabet: String = "qwertyuiopasdfghjklzxcvbnm"

## Generates a size n random sequence of letters
## Returns string of generated letters
## TODO: Make sure chars are not repeating
func generate_random(n: int) -> String:
	var output: String = ""
	for _i in range(n):
		var random_id: int = randi() % alphabet.length()
		output += alphabet[random_id]
	return output

## Generates a random word from a whitelisted source
## Returns word as a string of letters
## TODO: Allow selection of different difficulty words
func generate_word() -> String:
	return allowed_words.pick_random()

## Return sequence as instantiated Letters
func string_to_letters(str: String, letter_mode: Letter.Mode) -> Sequence:
	var sequence: Sequence = sequence_scene.instantiate()
	add_child(sequence)
	for char in str:
		var new_letter: Letter = letter_scene.instantiate()
		new_letter.set_character(char)
		new_letter.activation_mode = letter_mode
		sequence.container.add_child(new_letter)
		sequence.add_letter(new_letter)
	return sequence
