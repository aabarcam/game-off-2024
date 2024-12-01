extends Control

@onready var music_slider: HSlider = $MusicSlider
#@onready var sfx_slider: HSlider = $SFXSlider
@onready var back_button: TextureButton = $BackButton

func _ready() -> void:
	music_slider.min_value = 0.0001
	music_slider.step = 0.0001
	music_slider.value_changed.connect(_on_music_value_changed)

func _on_music_value_changed(value: float) -> void:
	MusicController.music = value
