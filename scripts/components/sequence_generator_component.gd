extends HBoxContainer
class_name SequenceGenerator
## Letter sequence generator
##
## Generate different types of letter sequences to be used in minigames
## TODO: exclude certain sequences that are known to not work in some keyboards,
## or whitelist good sequences

@export var letter_scene: PackedScene
@export var sequence_scene: PackedScene

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
## Returns word as a string of characters
func generate_typing_word(min_length: int, max_length:int, subject:String="mammals") -> String:
	return WordLoader.typing_words[subject].filter(
		func(x:String):return min_length <= x.length() and x.length() <= max_length
	).pick_random()

func generate_hangman_ambiguous() -> String:
	return WordLoader.hangman_ambiguous.keys().pick_random()

func generate_hangman_normal() -> String:
	return WordLoader.hangman_normal.keys().pick_random()

func setup_hangman(sequence: Sequence, missing_letters: int) -> void:
	sequence.set_sequence_activated()
	var string_sequence: String = letters_to_string(sequence)
	var word_dict: Dictionary
	if WordLoader.hangman_normal.has(string_sequence):
		word_dict = WordLoader.hangman_normal
	elif WordLoader.hangman_ambiguous.has(string_sequence):
		word_dict = WordLoader.hangman_ambiguous
	else:
		push_error("Invalid word.")
		get_tree().paused = true
	var missing_ids: Array = word_dict[string_sequence]
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
