extends BaseRound
class_name WhackRound
## Class represents a single round of the whack-a-mole handshake minigame
##
## Generates random sequences of letters, the player must press them as they
## light up

@export_category("Config")
@export var debug_whack_time: float = -1
@export var whack_time: float = 5

#var round_sequences: Array[Sequence] = []
#var lit_up_sequences: int = 0
#var sequence_id: int = 0
var completed_sequences: int = 0

@onready var sequence_container: HBoxContainer = $SequenceContainer

func _ready() -> void:	
	if OS.is_debug_build() and get_parent() == get_tree().root:
		whack_time = debug_whack_time if debug_whack_time >= 0 else whack_time
	
	super._ready()

func reset() -> void:
	completed_sequences = 0
	super.reset()

func start_round() -> void:
	start_next_sequence()

func start_next_sequence() -> void:
	for i in range(sequence_quantity):
		var new_sequence: Sequence = get_next_sequence()
		new_sequence.set_quiet(true)
		sequence_generator.remove_child(new_sequence)
		sequence_container.add_child(new_sequence)
		previous_sequences.push_back(new_sequence)
		#memorize_timer.start(memorize_time)
		connect_sequence_signals(new_sequence)
		#reset_sequence_position(new_sequence)
		reset_sequence_state(new_sequence)
		new_sequence.set_sequence_deactivated()
		new_sequence.set_mistake(true)
		#new_sequence.set_sequence_deceiving()
		#start_sequence_move(new_sequence)
	play()

func get_next_sequence() -> Sequence:
	var sequence: String = sequence_generator.generate_random(sequence_size)
	return sequence_generator.string_to_letters(sequence, Letter.Mode.HOLD)

func start_sequence_move(_sequence: Sequence) -> void:
	return

func reset_sequence_position(sequence: Sequence) -> void:
	sequence.position = letter_start_point

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

func play() -> void:
	sequence_timer.start(time_per_sequence)
	for seq in previous_sequences:
		seq.set_sequence_deactivated()
	if current_sequence != null:
		current_sequence.light_off()
		current_sequence.set_mistake(true)
	current_sequence = previous_sequences.pick_random() as Sequence
	current_sequence.set_mistake(false)
	current_sequence.signal_next()

func _on_sequence_timer_timeout() -> void:
	lost.emit()

func _on_letter_mistake() -> void:
	pass

func _on_letter_activated() -> void:
	for seq in previous_sequences:
		if is_sequence_activated(seq):
			seq.set_quiet(false)
			if not seq.is_mistake():
				# win round
				completed_sequences += 1
				sequence_timer.stop()
				seq.turn_green()
				#set_sequence_inactive(current_sequence)
				key_pressed.emit()
				#round_sequences.erase(current_sequence)
				for s in previous_sequences:
					s.set_sequence_inactive()
				if completed_sequences < sequence_quantity:
					await get_tree().create_timer(0.5).timeout
					seq.set_quiet(true)
					play()
				else:
					sequence_timer.stop()
					won.emit()
			else:
				seq.turn_red()
				seq.set_sequence_inactive()
				lost.emit()
