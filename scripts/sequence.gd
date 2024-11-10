extends Control
class_name Sequence
## Represents a sequence of letters
##
## To be used in minigames, letters are ordered horizontally along with a
## sequence timer

var letters: Array[Letter] = []

@onready var container: HBoxContainer = $HBoxContainer
@onready var timed_bar: TimedBar = $TimedBar

func add_letter(letter: Letter) -> void:
	letters.push_back(letter)

func reset_sequence_state() -> void:
	for letter in letters:
		letter.reset()

## True if all the letters in sequence are activated at a time
func is_sequence_activated() -> bool:
	var output = true
	for i in letters.size():
		var letter: Letter = letters[i]
		output = output and letter.is_activated()
	return output

## True if all the letters in sequence are inactive at a time
func is_sequence_inactive() -> bool:
	var output = true
	for i in letters.size():
		var letter: Letter = letters[i]
		output = output and letter.is_inactive()
	return output

func set_sequence_inactive() -> void:
	for letter in letters:
		letter.set_as_cleared()

func start_timer(time: float) -> void:
	timed_bar.start_timer(time)
