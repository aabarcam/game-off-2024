extends Node2D

var music : float = 1: set = set_music
#var sound : float = 1: set = set_sound

@onready var music_bus_name : String = "Master"
#@onready var sound_bus_name : String = "SFX"

@onready var music_bus = AudioServer.get_bus_index(music_bus_name)
#@onready var sound_bus = AudioServer.get_bus_index(sound_bus_name)

@onready var music_interactive_player := $Loop
@onready var playback: AudioStreamPlaybackInteractive = music_interactive_player.get_stream_playback()
@onready var previous_clip

func play_loop() -> void:
	music_interactive_player.stream_paused = false

func stop_loop() -> void:
	music_interactive_player.stop()

func pause_loop() -> void:
	music_interactive_player.stream_paused = true
	
func play_music(clip: StringName) -> void:
	playback.switch_to_clip_by_name(clip)

## SETTERS

func set_music(val: float) -> void:
	music = val
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(val))

#func set_sound(val: float) -> void:
	#sound = val
	#AudioServer.set_bus_volume_db(sound_bus, linear_to_db(val))
