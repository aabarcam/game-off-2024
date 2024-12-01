extends Control

@onready var music_slider: HSlider = $MusicSlider
#@onready var sfx_slider: HSlider = $SFXSlider

func _ready() -> void:
	music_slider.min_value = 0.0001
	music_slider.step = 0.0001
	music_slider.value_changed.connect(_on_music_value_changed)
	
	if OS.is_debug_build() and get_parent() == get_tree().root:
		MusicController.play_music("living")

func _on_music_value_changed(value: float) -> void:
	MusicController.music = value
