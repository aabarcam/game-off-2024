extends TextureButton

func _ready() -> void:
	button_up.connect(func():get_tree().quit())
