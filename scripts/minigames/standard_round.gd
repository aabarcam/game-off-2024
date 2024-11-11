extends BaseRound
class_name StandardRound
## Class represents a single round of the standard handshake minigame
##
## Generates random sequences of letters the player must press at a time

#func _ready() -> void:
	#Signals.register_signal(won, self)
	#Signals.register_signal(lost, self)
	#
	#global_position = Vector2.ZERO
	#
	#sequence_timer.one_shot = true
	#sequence_timer.timeout.connect(_on_sequence_timer_timeout)
	#
	#start_point_debug_label.hide()
	#stop_point_debug_label.hide()
	#
	#if OS.is_debug_build() and get_parent() == get_tree().root:
		#await get_tree().create_timer(1.0).timeout
		#start_round()

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
	sequence_timer.start(time_per_sequence)
	current_sequence = get_next_sequence()
	previous_sequences.push_back(current_sequence)
	current_sequence.start_timer(time_per_sequence)
	connect_sequence_signals(current_sequence)
	reset_sequence_position(current_sequence)
	reset_sequence_state(current_sequence)
	start_sequence_move(current_sequence)

#func get_next_sequence() -> Sequence:
	#var sequence: String = sequence_generator.generate_random(sequence_size)
	#return sequence_generator.string_to_letters(sequence, Letter.Mode.HOLD)

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

func _on_sequence_timer_timeout() -> void:
	if not current_sequence.is_sequence_inactive():
		set_sequence_inactive(current_sequence)
		lost.emit()

func _on_letter_activated() -> void:
	if is_sequence_activated(current_sequence):
		set_sequence_inactive(current_sequence)
		sequence_count += 1
		key_pressed.emit()
		if sequence_count < sequence_quantity:
			start_next_sequence()
		else:
			won.emit()
