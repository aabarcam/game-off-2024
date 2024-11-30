extends BaseDialogueTestScene

func _ready() -> void:
	var balloon = Manager.small_example_balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, title)
