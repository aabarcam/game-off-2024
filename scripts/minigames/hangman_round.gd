extends BaseRound
class_name HangmanRound
## Class represents a single round of the hangman handshake minigame
##
## Generates random words the player must complete

@export var debug_missing_letters: int = -1
@export var missing_letters: int = 1

func _ready() -> void:
	if OS.is_debug_build() and get_parent() == get_tree().root:
		missing_letters = debug_missing_letters if debug_missing_letters >= 0 else missing_letters
	super._ready()

func start_round() -> void:
	start_next_sequence()

## Reset round to initial state to start anew
#func reset() -> void:
	#delete_previous_sequences()
	#sequence_count = 0
	#sequence_timer.stop()

#func delete_previous_sequences() -> void:
	#for seq in previous_sequences:
		#seq.queue_free()
	#previous_sequences = []

func start_next_sequence() -> void:
	var new_seq: Sequence = get_next_sequence()
	sequence_generator.remove_child(new_seq)
	add_child(new_seq)
	sequence_timer.start(time_per_sequence)
	previous_sequences.push_back(new_seq)
	new_seq.start_timer(time_per_sequence)
	connect_sequence_signals(new_seq)
	reset_sequence_position(new_seq)
	#reset_sequence_state(new_seq)
	new_seq.enable_next_letter()
	#start_sequence_move(new_seq)
	current_sequence = new_seq

func get_next_sequence() -> Sequence:
	var sequence_string: String = sequence_generator.generate_word()
	var sequence: Sequence = sequence_generator.string_to_letters(sequence_string, Letter.Mode.TYPE)
	sequence_generator.setup_hangman(sequence, missing_letters)
	return sequence

func start_sequence_move(sequence: Sequence) -> void:
	create_tween().tween_property(sequence, "position:x", letter_stop_point.x, time_per_sequence)
	#for i in sequence.size():
		#var letter: Letter = sequence[i]
		#create_tween().tween_property(letter, "position:x", letter_stop_point.x, time_per_sequence)

func reset_sequence_position(sequence: Sequence) -> void:
	sequence.position = letter_stop_point
	#for i in sequence.size():
		#var letter: Letter = sequence[i]
		#letter.position = letter_start_point
		#letter.position.y += 24 * i

func start_sequence_container_move(container: HBoxContainer) -> void:
	create_tween().tween_property(container, "position:x", letter_stop_point.x, time_per_sequence)

func reset_sequence_container_position(container: HBoxContainer) -> void:
	container.position = letter_start_point

func reset_sequence_state(sequence: Sequence) -> void:
	sequence.reset_sequence_state()

## True if all the letters in sequence are activated at a time
func is_sequence_activated(sequence: Sequence) -> bool:
	return sequence.is_sequence_activated()

func all_sequences_activated(seq_arr: Array[Sequence]) -> bool:
	var output = true
	for seq in seq_arr:
		output = output and seq.is_sequence_activated()
	return output

func all_sequences_cleared(seq_arr: Array[Sequence]) -> bool:
	var output = true
	for seq in seq_arr:
		output = output and seq.is_sequence_cleared()
	return output
 
func set_sequence_inactive(sequence: Sequence) -> void:
	sequence.set_sequence_inactive()

func set_sequence_cleared(sequence: Sequence) -> void:
	sequence.set_sequence_cleared()

func connect_sequence_signals(sequence: Sequence) -> void:
	for letter in sequence.letters:
		letter.activated.connect(_on_letter_activated)

func _on_sequence_timer_timeout() -> void:
	if not current_sequence.is_sequence_cleared():
		set_sequence_inactive(current_sequence)
		lost.emit()

func _on_letter_activated() -> void:
	key_pressed.emit()
	current_sequence.enable_next_letter()
	if is_sequence_activated(current_sequence):
		set_sequence_cleared(current_sequence)
		sequence_count += 1
		if sequence_count < sequence_quantity:
			await get_tree().create_timer(0.5).timeout
			current_sequence.hide()
			start_next_sequence()
		else:
			sequence_timer.stop()
			current_sequence.timed_bar.stop_timer()
			won.emit()
