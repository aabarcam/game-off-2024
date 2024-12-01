extends Control
class_name Sequence
## Represents a sequence of letters
##
## To be used in minigames, letters are ordered horizontally along with a
## sequence timer

var letters: Array[Letter] = []
var tween: Tween

@onready var container: HBoxContainer = $HBoxContainer
@onready var timed_bar: TimedBar = $TimedBar

func add_letter(letter: Letter) -> void:
	letters.push_back(letter)
	#letter.mistake.connect(_on_letter_mistake)

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

func is_sequence_cleared() -> bool:
	var output = true
	for i in letters.size():
		var letter: Letter = letters[i]
		output = output and letter.is_cleared()
	return output

func is_sequence_deceiving() -> bool:
	var output = true
	for i in letters.size():
		var letter: Letter = letters[i]
		output = output and letter.is_deceiving()
	return output

func set_sequence_activated() -> void:
	for letter in letters:
		letter.set_as_activated()

func set_sequence_inactive() -> void:
	for letter in letters:
		letter.set_as_inactive()

func set_sequence_deactivated() -> void:
	for letter in letters:
		letter.set_as_deactivated()

func set_sequence_cleared() -> void:
	for letter in letters:
		letter.set_as_cleared()

func set_sequence_deceiving() -> void:
	for letter in letters:
		letter.set_as_deceiving()

#func set_mistake(val: bool) -> void:
	#for letter in letters:
		#letter.mistake = val

func is_mistake() -> bool:
	var output = true
	for i in letters.size():
		var letter: Letter = letters[i]
		output = output and letter.mistake
	return output

func enable_next_letter() -> void:
	for letter in letters:
		if letter.is_inactive():
			letter.reset()
			break

func is_first_letter_activated() -> bool:
	return letters[0].is_activated()

func light_on() -> void:
	for letter in letters:
		letter.light_on()

func light_off() -> void:
	for letter in letters:
		letter.light_off()

func turn_green() -> void:
	for letter in letters:
		letter.change_color(Color.LIME_GREEN)

func turn_red() -> void:
	for letter in letters:
		letter.change_color(Color.RED)

func signal_next() -> void:
	for letter in letters:
		letter.signal_next()

func set_quiet(val: bool) -> void:
	for letter in letters:
		letter.set_quiet(val)

func start_timer(time: float) -> void:
	timed_bar.start_timer(time)

func stop_timer() -> void:
	timed_bar.stop_timer()

func pause_timer() -> void:
	timed_bar.pause()
	await get_tree().create_timer(0.5).timeout
	timed_bar.unpause()

func set_can_be_wrong(val: bool) -> void:
	letters.map(func(x:Letter):x.can_be_wrong=val)

func kill_tween() -> void:
	if tween != null:
		tween.stop()

func size() -> int:
	return letters.size()

func get_letter_by_id(id: int) -> Letter:
	return letters[id]

func activated_percentage() -> float:
	return float(activated_words())/float(letters.size()) * 100.0

func activated_words() -> int:
	var output: int = 0
	for letter in letters:
		output += int(letter.is_activated())
	return output

func _on_letter_mistake() -> void:
	pause_timer()
