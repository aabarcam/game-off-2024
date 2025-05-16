extends BaseRound
class_name MixRound

@export var minigames: Array[BaseRound] = []

var current_minigame: BaseRound

#func _ready() -> void:
	#pass

func start_round() -> void:
	stop_minigame(current_minigame)
	current_minigame = get_next_minigame()
	connect_minigame_signals(current_minigame)
	start_minigame(current_minigame)
	
	for minigame in minigames:
		minigame.global_position = Vector2.ZERO

func get_valid_minigames() -> Array[BaseRound]:
	var valid_minigames: Array[BaseRound] = minigames.filter(func(x:BaseRound):return x!=current_minigame)
	return valid_minigames

func get_next_minigame() -> BaseRound:
	var valid_minigames: Array[BaseRound] = get_valid_minigames()
	return valid_minigames.pick_random()

func stop_minigame(minigame: BaseRound) -> void:
	if minigame != null:
		disconnect_minigame_signals(minigame)
		minigame.reset()

func start_minigame(minigame: BaseRound) -> void:
	minigame.start_round()

func connect_minigame_signals(minigame: BaseRound) -> void:
	if not minigame.won.is_connected(_on_minigame_won):
		minigame.won.connect(_on_minigame_won)
	if not minigame.lost.is_connected(_on_minigame_lost):
		minigame.lost.connect(_on_minigame_lost)
	if not minigame.key_pressed.is_connected(_on_minigame_key_pressed):
		minigame.key_pressed.connect(_on_minigame_key_pressed)

func disconnect_minigame_signals(minigame: BaseRound) -> void:
	if minigame.won.is_connected(_on_minigame_won):
		minigame.won.disconnect(_on_minigame_won)
	if minigame.lost.is_connected(_on_minigame_lost):
		minigame.lost.disconnect(_on_minigame_lost)
	if minigame.key_pressed.is_connected(_on_minigame_key_pressed):
		minigame.key_pressed.disconnect(_on_minigame_key_pressed)

func _on_minigame_won() -> void:
	await get_tree().create_timer(0.5).timeout
	sequence_count += 1
	if sequence_count >= sequence_quantity:
		won.emit()
	else:
		start_round()

func _on_minigame_lost() -> void:
	lost.emit()

func _on_minigame_key_pressed() -> void:
	key_pressed.emit()
