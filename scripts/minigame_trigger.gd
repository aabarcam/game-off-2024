#@tool
extends BaseTrigger
class_name MinigameTrigger

signal clicked(minigame: MinigameTrigger) ## Minigame clicked
signal won ## Minigame won
signal lost ## Minigame lost
#
#@export_category("Standard Config")
#@export var sequences_at_a_time: int = -1
#
#@export_category("Simon Says Config")
#@export var memorize_time: float = -1.0
#
#@export_category("Hangman Config")
#@export var missing_letters: int = -1
#
#@export_category("Blitz Config")
#@export var completion_threshold: float = -1
#@export var time_per_letter: float = -1
#
#@export_category("General Config")
#@export var sequence_sequence_quantity: int = -1
#@export var sequence_size: int = -1
#@export var time_per_sequence: float = -1

@export var required_minigames: Array[MinigameTrigger]
@export var minigames: Node2D
@export var minigame: Manager.Minigames: ## Minigame to trigger
	set = set_minigame
@export var total_rounds: int = 3: ## How many rounds for the minigame
	set = set_total_rounds
@export var lives: int = 5
@export var char_name: String
@export var balloon_scene: PackedScene
@export var is_boss: bool = false
@export var grenade_mouse: Texture2D
@export var opponent_hand_offset: Vector2 = Vector2.ZERO

@export_category("Shake Config")
@export var debug_shake_intensity: float = -1
@export var debug_shake_frequency: float = -1
@export var shake_intensities: Array[float] = [5]
@export var shake_frequencies: Array[float] = [5]
@export var shake_intensity: float = 5:
	set = set_shake_intensity
@export var shake_frequency: float = 5:
	set = set_shake_frequency

@export_category("Components")
@export var interactable_component: InteractableComponent
@export var grenade_component: GrenadeComponent

@export_category("Available minigames")
@export var standard_round: PackedScene
@export var typing_round: PackedScene
@export var simon_says_round: PackedScene
@export var hangman_round: PackedScene
@export var whack_a_mole_round: PackedScene
@export var blitz_typing: PackedScene

@export_category("Hand textures")
@export var player_textures: Array[Texture2D] = []
@export var handshake_textures: Array[Texture2D] = []
@export var oppponent_texture: Texture2D

var active: bool = false
var minigame_list: Array[Node]
var current_round: BaseRound
var round_count: int = 0
var noise_gen_x: FastNoiseLite = FastNoiseLite.new()
var noise_gen_y: FastNoiseLite = FastNoiseLite.new()
var accumulated_delta: float = 0
var player_hand_original_position: Vector2
var cleared: bool = false
var open: bool = false:
	set = set_open

@onready var minigame_label_debug: Label = $MinigameLabel ## Editor debug label
@onready var grenade_instructions: Node2D = $GrenadeInstructions
@onready var instructions: Node2D = $Instructions
@onready var instructions_bg: Sprite2D = $Instructions/Background
@onready var instructions_text: Label = $Instructions/Text
@onready var game_start_button: Button = $Instructions/StartButton
@onready var hand_sprites: Node2D = $HandSprites
@onready var player_hand: Sprite2D = $HandSprites/PlayerHandSprite
@onready var opponent_hand: Sprite2D = $HandSprites/OpponentHandSprite
@onready var handshake: Sprite2D = $HandSprites/HandshakeSprite
@onready var original_lives: int = lives
@onready var shake_test: Sprite2D = $ShakeTest
@onready var shake_test_original_position: Vector2 = shake_test.position
@onready var background: TextureRect = $Background
@onready var lives_container: HBoxContainer = $Lives
@onready var live_texture: Texture2D = preload("res://assets/lives/live1.png")
@onready var no_live_texture: Texture2D = preload("res://assets/lives/live2.png")

@export_category("Dialogues")
@export var dialogue_before_open: DialogueResource
@export var dialogue_beaten: DialogueResource
@export var dialogue_after_win: DialogueResource
@export var dialogue_instructions: DialogueResource

## Ready function called in editor
func _ready_editor() -> void:
	update_debug_label()

## Ready function called in game
func _ready_game() -> void:
	Signals.register_signal(clicked, self)
	Signals.register_signal(won, self)
	Signals.register_signal(lost, self)
	
	if lives >= 0:
		lives_container.global_position = Vector2(40, 300)
		lives_container.get_children().map(func(x):x.queue_free())
		for live in range(lives):
			var live_tex: TextureRect = TextureRect.new()
			live_tex.texture = live_texture
			lives_container.add_child(live_tex)
	
	for _minigame in required_minigames:
		_minigame.won.connect(_on_minigame_won)
	if required_minigames.is_empty():
		set_open(true)
	
	instructions.global_position = Vector2.ZERO
	instructions.modulate.a = 1.0
	
	grenade_instructions.global_position = Vector2.ZERO
	grenade_instructions.modulate.a = 1.0
	
	background.global_position = Vector2.ZERO
	background.modulate.a = 1.0
	
	grenade_component.global_position = grenade_component.position
	
	if balloon_scene == null:
		balloon_scene = Manager.small_example_balloon
	
	#player_hand.global_position = player_hand.position
	#opponent_hand.global_position = opponent_hand.position
	#handshake.global_position = handshake.position
	hand_sprites.global_position = Vector2(0, 0)
	opponent_hand.global_position += opponent_hand_offset
	player_hand_original_position = player_hand.global_position
	
	if oppponent_texture != null:
		opponent_hand.texture = oppponent_texture
	
	#opponent_hand.texture = oppponent_texture
	
	reset_trigger()
	
	minigame_label_debug.hide()
	
	interactable_component.clicked.connect(_on_trigger_clicked)
	game_start_button.button_up.connect(_on_instructions_start_pressed)
	
	grenade_component.hide()
	
	noise_gen_x.seed = randi()
	noise_gen_y.seed = randi()
	
	noise_gen_x.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_gen_y.noise_type = FastNoiseLite.TYPE_PERLIN
	
	shake_intensity = shake_intensities[round_count]
	shake_frequency = shake_frequencies[round_count]
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	shake_intensity = debug_shake_intensity if debug_shake_intensity >= 0 else shake_intensity
	shake_frequency = debug_shake_frequency if debug_shake_frequency >= 0 else shake_frequency

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		_ready_editor()
	else:
		_ready_game()

func _process(delta: float) -> void:
	accumulated_delta += delta
	var offset_x: float = noise_gen_x.get_noise_1d(accumulated_delta) * shake_intensity
	var offset_y: float = noise_gen_y.get_noise_1d(accumulated_delta) * shake_intensity
	player_hand.position.x = player_hand_original_position.x + offset_x
	player_hand.position.y = player_hand_original_position.y + offset_y

func reset_trigger() -> void:
	if current_round != null:
		#current_round.queue_free()
		current_round.reset()
		current_round = null
	minigame_list = minigames.get_children().filter(func(x:Node2D):return x.visible)
	minigame_list.map(func(x):x.reset())
	round_count = 0
	shake_intensity = shake_intensities[round_count]
	shake_frequency = shake_frequencies[round_count]
	lives = original_lives
	
	lives_container.hide()
	if lives >= 0:
		lives_container.get_children().map(func(x):x.queue_free())
		for live in range(lives):
			var live_tex: TextureRect = TextureRect.new()
			live_tex.texture = live_texture
			lives_container.add_child(live_tex)
	
	grenade_component.reset()
	grenade_component.hide()
	grenade_instructions.hide()
	background.hide()
	instructions.hide()
	hide_hands()
	handshake.hide()

func show_hands() -> void:
	player_hand.show()
	opponent_hand.show()

func hide_hands() -> void:
	player_hand.hide()
	opponent_hand.hide()

func show_instructions() -> void:
	background.show()
	if dialogue_instructions != null:
		DialogueManager.show_dialogue_balloon_scene(Manager.void_balloon, dialogue_instructions, "start", [self])
	else:
		prompt_grenade()
	#instructions.show()

func update_debug_label() -> void:
	if minigame_label_debug != null:
		minigame_label_debug.text = "MINIGAME\n" + Manager.Minigames.keys()[minigame]

func connect_round_signals(this_round: BaseRound) -> void:
	if not this_round.key_pressed.is_connected(_on_key_pressed):
		this_round.key_pressed.connect(_on_key_pressed)
	if not this_round.won.is_connected(_on_round_won):
		this_round.won.connect(_on_round_won)
	if not this_round.lost.is_connected(_on_round_lost):
		this_round.lost.connect(_on_round_lost)

func disconnect_round_signals(this_round: BaseRound) -> void:
	this_round.key_pressed.disconnect(_on_key_pressed)
	this_round.won.disconnect(_on_round_won)
	this_round.lost.disconnect(_on_round_lost)

func next_round() -> void:
	active = true
	if minigame_list.is_empty():
		disable_grenade()
		notify_minigame_won()
		return
	
	#match minigame:
		#Manager.Minigames.STANDARD:
			#current_round = standard_round.instantiate() as StandardRound
		#Manager.Minigames.TYPING_OF_THE_DEAD:
			#current_round = typing_round.instantiate() as TypingRound
		#Manager.Minigames.SIMON_SAYS:
			#current_round = simon_says_round.instantiate() as SimonSaysRound
		#Manager.Minigames.HANGMAN:
			#current_round = hangman_round.instantiate() as HangmanRound
		#Manager.Minigames.WHACK_A_MOLE:
			#current_round = whack_a_mole_round.instantiate() as WhackRound
		#Manager.Minigames.BLITZ_TYPING:
			#current_round = blitz_typing.instantiate() as BlitzTypingRound
	current_round = minigame_list.pop_front()
	show_hands()
	handshake.hide()
	connect_round_signals(current_round)
	#add_child(current_round)
	current_round.start_round()

func notify_minigame_triggered() -> void:
	clicked.emit(self)
	interacted_times += 1
	interactable_component.hide()
	show_instructions()

func get_random_player_sprite() -> Texture2D:
	var rand_id: int = randi() % player_textures.size()
	var output: Texture2D = player_textures[rand_id]
	if output == player_hand.texture:
		output = player_textures[(rand_id + 1) % player_textures.size()]
	return output

func disable_grenade() -> void:
	grenade_component.change_state(grenade_component.inactive_state)

func minigame_lost() -> void:
	#current_round.reset()
	Input.set_custom_mouse_cursor(null)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	interactable_component.show()
	reset_trigger() 

func notify_minigame_lost() -> void:
	lost.emit()

func notify_minigame_won() -> void:
	Input.set_custom_mouse_cursor(null)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	notify_done()
	if dialogue_beaten:
		#DialogueManager.show_example_dialogue_balloon(dialogue_beaten, "start", [self])
		DialogueManager.show_dialogue_balloon_scene(balloon_scene, dialogue_beaten, "start", [self])
	#else:

func notify_done() -> void:
	cleared = true
	interactable_component.show()
	won.emit()
	if is_boss:
		MusicController.play_music("title_screen")
		

func prompt_grenade() -> void:
	grenade_instructions.show()
	grenade_component.activate()
	grenade_component.show()
	if not grenade_component.held.is_connected(_on_grenade_held):
		grenade_component.held.connect(_on_grenade_held)
	if not grenade_component.exploded.is_connected(_on_grenade_exploded):
		grenade_component.exploded.connect(_on_grenade_exploded)

func update_shake_config() -> void:
	noise_gen_x.frequency = shake_frequency
	noise_gen_y.frequency = shake_frequency

func all_minigames_cleared() -> bool:
	var output: bool = true
	for _minigame in required_minigames:
		output = output and _minigame.cleared
	return output
	
## Getters/Setters

func set_minigame(new_val: Manager.Minigames) -> void:
	minigame = new_val
	if Engine.is_editor_hint():
		update_debug_label()

func set_total_rounds(new_val: int) -> void:
	total_rounds = new_val

func set_as_cleared() -> void:
	#modulate = Color.GREEN
	cleared = true
	interactable_component.disabled = dialogue_after_win == null

func set_shake_intensity(new_val: float) -> void:
	shake_intensity = new_val

func set_shake_frequency(new_val: float) -> void:
	shake_frequency = new_val
	update_shake_config()

func set_open(value: bool) -> void:
	open = value

## Signal handlers

func _on_trigger_clicked() -> void:
	LevelManager.set_char_name(char_name)
	
	if cleared:
		if dialogue_after_win != null:
			#DialogueManager.show_example_dialogue_balloon(dialogue_after_win, "start", [self])
			DialogueManager.show_dialogue_balloon_scene(balloon_scene, dialogue_after_win, "start", [self])
		return
	
	if open:
		if dialogue != null:
			#DialogueManager.show_example_dialogue_balloon(dialogue, "start", [self])
			DialogueManager.show_dialogue_balloon_scene(balloon_scene, dialogue, "start", [self])
		else:
			notify_minigame_triggered()
	else:
		clicked_disabled.emit()
		if dialogue_before_open != null:
			DialogueManager.show_dialogue_balloon_scene(balloon_scene, dialogue_before_open, "start", [self])

func _on_round_won() -> void:
	handshake.texture = handshake_textures[min(round_count, handshake_textures.size()-1)]
	
	round_count += 1
	
	if minigame_list.is_empty():
		disable_grenade()
	
	shake_intensity = shake_intensities[min(round_count, shake_intensities.size() - 1)]
	shake_frequency = shake_frequencies[min(round_count, shake_frequencies.size() - 1)]

	hide_hands()
	handshake.show()
	grenade_component.hide()
	
	await get_tree().create_timer(2.0).timeout
	
	#handshake.hide()
	#show_hands()
	if minigame_list.is_empty():
		notify_minigame_won()
	else:
		if current_round != null:
			current_round.reset()
		#current_round.start_round()
			next_round()
		#reset_trigger()

func _on_round_lost() -> void:
	lives -= 1
	lives_container.get_child(lives).texture = no_live_texture
	MusicController.play_sfx_life()
	if lives == 0:
		minigame_lost()
		notify_minigame_lost()
		if not is_boss:
			MusicController.play_music("minigame_lost")
		else:
			MusicController.play_sfx_lost()

func _on_instructions_start_pressed() -> void:
	instructions.hide()
	prompt_grenade()

func _on_grenade_held() -> void:
	# start minigame
	lives_container.show()
	MusicController.play_sfx_grenade_hold()
	Input.set_custom_mouse_cursor(grenade_mouse)
	Input.set_custom_mouse_cursor(grenade_mouse, Input.CURSOR_POINTING_HAND)
	grenade_instructions.hide()
	grenade_component.hide()
	
	next_round()
	if not is_boss:
		MusicController.play_music("minigame_loop")

func _on_grenade_exploded() -> void:
	# lose minigame
	if not is_boss:
		MusicController.play_music("explosion")
	else:
		MusicController.play_sfx_explosion()
	var explosion_scene: PackedScene = load("res://scenes/grenade_explotion.tscn")
	var explosion_instance: GrenadeExplosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion_instance)
	minigame_lost()
	await explosion_instance.animation_finished
	notify_minigame_lost()
	explosion_instance.queue_free()

func _on_key_pressed() -> void:
	# change player sprite
	player_hand.texture = get_random_player_sprite()
	MusicController.play_sfx_letter_type()

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == null:
		return
	if resource == dialogue:
		notify_minigame_triggered()
	elif resource == dialogue_instructions and get_parent().active_minigame == self:
		prompt_grenade()
	elif resource == dialogue_beaten and is_boss:
		Signals.transition_triggered.emit()

func _on_minigame_won() -> void:
	if all_minigames_cleared():
		set_open(true)
