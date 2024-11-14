extends BaseRound
class_name StandardRound
## Class represents a single round of the standard handshake minigame
##
## Generates random sequences of letters the player must press at a time

@export var debug_sequences_at_a_time: int = 1
@export var sequences_at_a_time: int = 1

var active_sequences: Array[Sequence] = []

func _ready() -> void:
	if OS.is_debug_build() and get_parent() == get_tree().root:
		sequences_at_a_time = debug_sequences_at_a_time if debug_sequences_at_a_time >= 0 else sequences_at_a_time
	super._ready()
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
	var sequence_qty: int = randi() % sequences_at_a_time + 1
	var seq_container: HBoxContainer = HBoxContainer.new()
	#seq_container.alignment = BoxContainer.ALIGNMENT_CENTER
	#seq_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	seq_container.add_theme_constant_override("separation", 12)
	add_child(seq_container)
	for _i in range(sequence_qty):
		var new_seq: Sequence = get_next_sequence()
		sequence_generator.remove_child(new_seq)
		seq_container.add_child(new_seq)
		sequence_timer.start(time_per_sequence)
		previous_sequences.push_back(new_seq)
		active_sequences.push_back(new_seq)
		new_seq.start_timer(time_per_sequence)
		connect_sequence_signals(new_seq)
		#reset_sequence_position(new_seq)
		reset_sequence_state(new_seq)
		#start_sequence_move(new_seq)
	reset_sequence_container_position(seq_container)
	start_sequence_container_move(seq_container)
	current_sequence = active_sequences.pop_front()

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
	if is_sequence_activated(current_sequence):
		set_sequence_cleared(current_sequence)
		key_pressed.emit()
		if not active_sequences.is_empty():
			current_sequence = active_sequences.pop_front()
			reset_sequence_state(current_sequence)
			return
		sequence_count += 1
		if sequence_count < sequence_quantity:
			start_next_sequence()
		else:
			won.emit()
