extends BaseRound
class_name SimonSaysRound
## Class represents a single round of the simon says handshake minigame
##
## Generates random sequences of letters to memorize, the player must then
## repeat it in order
## TODO: (maybe) use a split word

@export_category("Config")
@export var debug_memorize_time: float = -1
@export var memorize_time: float = 5

var round_sequences: Array[Sequence] = []
var lit_up_sequences: int = 0
var sequence_id: int = 0

@onready var sequence_container: HBoxContainer = $SequenceContainer
@onready var memorize_timer: Timer = $MemorizeTimer
@onready var light_timer: Timer = $LightTimer

func _ready() -> void:
	memorize_timer.one_shot = true
	memorize_timer.timeout.connect(_on_memorize_timer_timeout)
	
	light_timer.timeout.connect(_on_light_timer_timeout)
	
	if OS.is_debug_build() and get_parent() == get_tree().root:
		memorize_time = debug_memorize_time if debug_memorize_time >= 0 else memorize_time
	
	super._ready()

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
		#memorize_timer.start(memorize_time)
		light_timer.start(memorize_time)
		connect_sequence_signals(new_sequence)
		#reset_sequence_position(new_sequence)
		reset_sequence_state(new_sequence)
		set_sequence_inactive(new_sequence)
		start_sequence_move(new_sequence)

func get_next_sequence() -> Sequence:
	var sequence: String = sequence_generator.generate_random(sequence_size)
	return sequence_generator.string_to_letters(sequence, Letter.Mode.HOLD)

func start_sequence_move(sequence: Sequence) -> void:
	previous_sequences.shuffle()
	
	# light on sequences
	start_lighting_on()
	#create_tween().tween_property(sequence, "position:x", letter_stop_point.x, time_per_sequence)
	#for i in sequence.size():
		#var letter: Letter = sequence[i]
		#create_tween().tween_property(letter, "position:x", letter_stop_point.x, time_per_sequence)

func reset() -> void:
	super.reset()
	sequence_id = 0
	lit_up_sequences = 0

func light_off_sequences(sequences: Array[Sequence]) -> void:
	for seq in sequences:
		seq.light_off()
		seq.set_quiet(true)

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
	for seq in previous_sequences:
		output = output and seq.is_sequence_inactive()
	return output

func start_lighting_on() -> void:
	light_timer.start(2.0)

func play() -> void:
	current_sequence = previous_sequences[sequence_id]
	sequence_id += 1

func _on_sequence_timer_timeout() -> void:
	if not all_sequences_inactive():
	#if not current_sequence.is_sequence_inactive():
		#set_sequence_inactive(current_sequence)
		lost.emit()

func _on_letter_activated() -> void:
	if is_sequence_activated(current_sequence):
		current_sequence.set_quiet(false)
		current_sequence.turn_green()
		set_sequence_inactive(current_sequence)
		key_pressed.emit()
		#round_sequences.erase(current_sequence)
		if sequence_id < sequence_quantity:
			play()
		else:
			won.emit()
	
	for seq in previous_sequences:
		if seq != current_sequence and is_sequence_activated(seq):
			lost.emit()

func _on_memorize_timer_timeout() -> void:
	# hide letters, let player press
	pass

func _on_light_timer_timeout() -> void:
	# turn on lights one at a time
	if lit_up_sequences < sequence_quantity:
		previous_sequences[lit_up_sequences].light_on()
		lit_up_sequences += 1
	else:
		# once all lights turned on stop timer and start playing
		light_timer.stop()
		sequence_timer.start(time_per_sequence)
		light_off_sequences(previous_sequences)
		play()
		for seq in previous_sequences:
			seq.reset_sequence_state()
