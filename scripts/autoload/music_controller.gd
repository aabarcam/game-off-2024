extends Node2D

var music : float = 1: set = set_music
var sound : float = 1: set = set_sound

@onready var music_bus_name : String = "MUSIC"
@onready var sound_bus_name : String = "SFX"

@onready var music_bus = AudioServer.get_bus_index(music_bus_name)
@onready var sound_bus = AudioServer.get_bus_index(sound_bus_name)

@onready var music_interactive_player := $Loop
@onready var playback: AudioStreamPlaybackInteractive = music_interactive_player.get_stream_playback()
@onready var sfx_ui: AudioStreamPlayer = $SfxUI
@onready var door_open_sfx: AudioStreamPlayer = $DoorOpenSFX
@onready var door_enter_sfx: AudioStreamPlayer = $DoorEnterSFX
@onready var not_sfx: AudioStreamPlayer = $NotSFX
@onready var explosion_sfx: AudioStreamPlayer = $ExplosionSFX
@onready var text_click_sfx: AudioStreamPlayer = $TextClickSFX
@onready var life_sfx: AudioStreamPlayer = $LifeSFX
@onready var grenade_hold_sfx: AudioStreamPlayer = $GrenadeHoldSFX
@onready var letter_type_sfx: AudioStreamPlayer = $LetterTypeSFX
@onready var letter_wrong_sfx: AudioStreamPlayer = $LetterWrongSFX
@onready var minigame_lost_sfx: AudioStreamPlayer = $MinigameLostSFX



## MUSIC FUNCTIONS

func play_loop() -> void:
	music_interactive_player.stream_paused = false

func stop_loop() -> void:
	music_interactive_player.stop()

func pause_loop() -> void:
	music_interactive_player.stream_paused = true
	
func play_music(clip: StringName) -> void:
	playback.switch_to_clip_by_name(clip)
	
	
## SFX FUNCTIONS

func play_sfx_ui() -> void:
	sfx_ui.play()

func play_sfx_not() -> void:
	not_sfx.play()

func play_sfx_door_open() -> void:
	door_open_sfx.play()
	
func play_sfx_door_enter() -> void:
	door_enter_sfx.play()

func play_sfx_explosion() -> void:
	explosion_sfx.play()
	
func play_sfx_lost() -> void:
	minigame_lost_sfx.play()

func play_sfx_text_click() -> void:
	text_click_sfx.play()

func play_sfx_life() -> void:
	life_sfx.play()

func play_sfx_grenade_hold() -> void:
	grenade_hold_sfx.play()

func play_sfx_letter_type() -> void:
	letter_type_sfx.play()

func play_sfx_letter_wrong() -> void:
	letter_wrong_sfx.play()
	
## SETTERS

func set_music(val: float) -> void:
	music = val
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(val))

func set_sound(val: float) -> void:
	sound = val
	AudioServer.set_bus_volume_db(sound_bus, linear_to_db(val))
