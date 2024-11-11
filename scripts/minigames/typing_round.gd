extends BaseRound
class_name TypingRound
## Class represents a single round of the typing handshake minigame
##
## Generates random sequences of letters the player must press in order

var round_sequences: Array[Sequence] = []

@onready var sequence_container: HBoxContainer = $SequenceContainer

func start_round() -> void:
	start_next_sequence()

func start_next_sequence() -> void:
	sequence_timer.start(time_per_sequence)
	for i in range(sequence_quantity):
		var new_sequence: Sequence = get_next_sequence()
		sequence_generator.remove_child(new_sequence)
		sequence_container.add_child(new_sequence)
		previous_sequences.push_back(new_sequence)
		round_sequences.push_back(new_sequence)
		new_sequence.start_timer(time_per_sequence)
		connect_sequence_signals(new_sequence)
		#reset_sequence_position(new_sequence)
		reset_sequence_state(new_sequence)
		set_sequence_inactive(new_sequence)
		new_sequence.activate_next_letter()
		#start_sequence_move(new_sequence)

func get_next_sequence() -> Sequence:
	var sequence: String = sequence_generator.generate_word()
	return sequence_generator.string_to_letters(sequence, Letter.Mode.TYPE)

func start_sequence_move(sequence: Sequence) -> void:
	create_tween().tween_property(sequence, "position:x", letter_stop_point.x, time_per_sequence)
	#for i in sequence.size():
		#var letter: Letter = sequence[i]
		#create_tween().tween_property(letter, "position:x", letter_stop_point.x, time_per_sequence)

func reset_sequence_position(sequence: Sequence) -> void:
	sequence.position = letter_start_point
	#for i in sequence.size():
		#var letter: Letter = sequence[i]
		#letter.position = letter_start_point
		#letter.position.y += 24 * i

func reset_sequence_state(sequence: Sequence) -> void:
	sequence.reset_sequence_state()

## True if all the letters in sequence are activated at a time
func is_sequence_activated(sequence: Sequence) -> bool:
	return sequence.is_sequence_activated()

func set_sequence_inactive(sequence: Sequence) -> void:
	sequence.set_sequence_inactive()

func connect_sequence_signals(sequence: Sequence) -> void:
	for letter in sequence.letters:
		letter.activated.connect(_on_letter_activated)

func all_sequences_inactive() -> bool:
	var output: bool = true
	for seq in round_sequences:
		output = output and seq.is_sequence_inactive()
	return output

func _on_sequence_timer_timeout() -> void:
	if not all_sequences_inactive():
	#if not current_sequence.is_sequence_inactive():
		#set_sequence_inactive(current_sequence)
		lost.emit()

func _on_letter_activated() -> void:
	if current_sequence == null: # select activated sequence
		for seq in round_sequences:
			if seq.is_first_letter_activated():
				current_sequence = seq
				break
		for seq in round_sequences:
			if seq != current_sequence:
				seq.set_sequence_inactive()
	current_sequence.activate_next_letter()
	if is_sequence_activated(current_sequence):
		set_sequence_inactive(current_sequence)
		round_sequences.erase(current_sequence)
		sequence_count += 1

		for seq in round_sequences:
			if seq != current_sequence:
				seq.activate_next_letter()

		if sequence_count >= sequence_quantity:
			won.emit()
	current_sequence = null
