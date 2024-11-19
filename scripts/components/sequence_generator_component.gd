extends HBoxContainer
class_name SequenceGenerator
## Letter sequence generator
##
## Generate different types of letter sequences to be used in minigames
## TODO: exclude certain sequences that are known to not work in some keyboards,
## or whitelist good sequences

@export var letter_scene: PackedScene
@export var sequence_scene: PackedScene

## TODO: Save in different file
## Dict of words and their missing letters for hangman
var allowed_words: Dictionary = {
	"penguin": [4, 0],
	"computer": [3, 7],
	"keyboard": [2, 6],
	"handshake": [0, 4],
	"cult": [2],
	"gamejam": [4],
	"github": [4, 1],
	"grenade": [2, 5]
}

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
	return allowed_words.keys().pick_random()

func setup_hangman(sequence: Sequence, missing_letters: int) -> void:
	sequence.set_sequence_activated()
	var missing_ids: Array = allowed_words[letters_to_string(sequence)]
	for i in range(min(missing_letters, missing_ids.size())):
		var letter_id = missing_ids[i]
		var letter: Letter = sequence.get_letter_by_id(letter_id)
		letter.set_as_inactive()
		letter.can_be_wrong = true
		letter.set_incognito(true)

## Return sequence as instantiated Letters
func string_to_letters(string: String, letter_mode: Letter.Mode) -> Sequence:
	var sequence: Sequence = sequence_scene.instantiate()
	add_child(sequence)
	for character in string:
		var new_letter: Letter = letter_scene.instantiate()
		new_letter.set_character(character)
		new_letter.activation_mode = letter_mode
		sequence.container.add_child(new_letter)
		sequence.add_letter(new_letter)
	return sequence

func letters_to_string(sequence: Sequence) -> String:
	var output: String = ""
	for letter in sequence.letters:
		output += letter.character
	return output
