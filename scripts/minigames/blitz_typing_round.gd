extends BaseRound
class_name BlitzTypingRound
## Class represents a single round of the blitz typing handshake minigame
##
## Generates random sequences of letters the player must press in order

@export var debug_completion_threshold: float = -1
@export var completion_threshold: float = 60.0
@export var debug_time_per_letter: float = -1
@export var time_per_letter: float = 1.0

var round_sequences: Array[Sequence] = []
var sequences_generated: int = 0
var current_position: Marker2D

@onready var sequence_container: HBoxContainer = $SequenceContainer
@onready var sequence_positions: Dictionary = {
	$Sequence1: false,
	$Sequence2: false,
	$Sequence3: false,
	$Sequence4: false
}

func _ready() -> void:
	completion_threshold = debug_completion_threshold if debug_completion_threshold >= 0 else completion_threshold
	time_per_letter = debug_time_per_letter if debug_time_per_letter >= 0 else time_per_letter
	super._ready()

func start_round() -> void:
	start_next_sequence()
	current_sequence = round_sequences.front() as Sequence
	current_sequence.enable_next_letter()
	for pos in sequence_positions:
		if sequence_positions[pos]:
			current_position = pos

func start_next_sequence() -> void:
	sequences_generated += 1
	var new_sequence: Sequence = get_next_sequence()
	var new_position: Vector2 = get_next_position()
	sequence_generator.remove_child(new_sequence)
	add_child(new_sequence)
	previous_sequences.push_back(new_sequence)
	round_sequences.push_back(new_sequence)
	connect_sequence_signals(new_sequence)
	new_sequence.position = new_position
	#reset_sequence_position(new_sequence)
	reset_sequence_state(new_sequence)
	set_sequence_inactive(new_sequence)
	#new_sequence.enable_next_letter()
	var new_timer: Timer = Timer.new()
	new_timer.name = "timer"
	new_timer.timeout.connect(_on_sequence_timer_timeout)
	new_sequence.add_child(new_timer)
	new_timer.one_shot = true
	var new_time: float = time_per_letter * new_sequence.size()
	new_sequence.start_timer(new_time)
	new_timer.start(new_time)
	#start_sequence_move(new_sequence)

func reset() -> void:
	round_sequences = []
	sequences_generated = 0
	current_position = null
	super.reset()

func get_next_sequence() -> Sequence:
	var sequence: String = sequence_generator.generate_word()
	return sequence_generator.string_to_letters(sequence, Letter.Mode.TYPE)

func get_next_position() -> Vector2:
	# choose randomly between the available positions
	var random_id: int = randi() % sequence_positions.size()
	var random_position: Marker2D = sequence_positions.keys()[random_id]
	while sequence_positions[random_position]:
		random_id = (random_id + 1) % sequence_positions.size()
		random_position = sequence_positions.keys()[random_id]
	sequence_positions[random_position] = true
	return random_position.position

func start_sequence_move(sequence: Sequence) -> void:
	pass

func reset_sequence_position(sequence: Sequence) -> void:
	pass

func reset_sequence_state(sequence: Sequence) -> void:
	sequence.reset_sequence_state()

## True if all the letters in sequence are activated at a time
func is_sequence_activated(sequence: Sequence) -> bool:
	return sequence.is_sequence_activated()

func set_sequence_inactive(sequence: Sequence) -> void:
	sequence.set_sequence_inactive()

func set_noncurrent_sequences_inactive() -> void:
	for seq in round_sequences:
		if seq != current_sequence:
			seq.set_sequence_inactive()

func connect_sequence_signals(sequence: Sequence) -> void:
	for letter in sequence.letters:
		letter.activated.connect(_on_letter_activated)

func all_sequences_inactive() -> bool:
	var output: bool = true
	for seq in round_sequences:
		output = output and seq.is_sequence_inactive()
	return output

func check_win_condition() -> bool:
	return round_sequences.is_empty()

## Signal handlers

func _on_sequence_timer_timeout() -> void:
	lost.emit()

func _on_letter_activated() -> void:
	if (round_sequences.size() == 1 and 
		current_sequence.activated_percentage() >= completion_threshold and
		sequences_generated < sequence_quantity):
		start_next_sequence()
	
	if current_sequence.is_sequence_activated():
		round_sequences.erase(current_sequence)
		sequence_positions[current_position] = false
		current_sequence.stop_timer()
		current_sequence.get_node("timer").stop()
		if check_win_condition():
			won.emit()
		else:
			# continue next word
			current_sequence.hide()
			current_sequence = round_sequences.front() as Sequence
			current_sequence.enable_next_letter()
			for pos in sequence_positions.keys():
				if sequence_positions[pos]:
					current_position = pos
					break
	else:
		current_sequence.enable_next_letter()
