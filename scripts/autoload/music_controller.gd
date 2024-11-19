extends Node2D

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
