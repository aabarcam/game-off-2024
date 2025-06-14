extends Control

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SFXSlider
@onready var back_button: TextureButton = $BackButton

func _ready() -> void:
	music_slider.min_value = 0.0001
	music_slider.step = 0.0001
	music_slider.value = MusicController.music
	music_slider.value_changed.connect(_on_music_value_changed)
	sfx_slider.min_value = 0.0001
	sfx_slider.step = 0.0001
	sfx_slider.value_changed.connect(_on_sfx_value_changed)
	sfx_slider.value = MusicController.sound

func _process(_delta: float) -> void:
	if get_tree().paused and Input.is_action_just_pressed("pause"):
		get_tree().paused = false
		queue_free()

func _on_music_value_changed(value: float) -> void:
	MusicController.music = value

func _on_sfx_value_changed(value: float) -> void:
	MusicController.sound = value
