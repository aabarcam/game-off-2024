extends Sprite2D
class_name GrenadeExplosion

signal animation_finished(anim_name: StringName)

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)
