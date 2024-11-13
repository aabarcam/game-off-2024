extends Node2D
class_name LevelBase

var minigames: Array[Node] = []
var active_minigame: MinigameTrigger:
	set = set_active_minigame
var finished: bool = false

func _ready() -> void:
	var current_level_path = get_tree().current_scene.scene_file_path
	LevelManager.set_current_level(current_level_path)
	minigames = get_scene_minigames()
	for minigame in minigames:
		minigame.clicked.connect(_on_minigame_clicked)

func get_scene_minigames() -> Array[Node]:
	var children: Array[Node] = get_children()
	var found_minigames: Array[Node] = children.filter(func (x: Node): return x.is_in_group("Minigame"))
	return found_minigames

func _on_minigame_clicked(minigame: MinigameTrigger) -> void:
	active_minigame = minigame
	if not active_minigame.lost.is_connected(_on_minigame_lost):
		active_minigame.lost.connect(_on_minigame_lost)
	if not active_minigame.won.is_connected(_on_minigame_won):
		active_minigame.won.connect(_on_minigame_won)
		
	for minigame_iter in minigames:
		if minigame_iter != active_minigame:
			minigame_iter.hide()

func show_minigames() -> void:
	minigames.map(func (x): x.show())

func _on_minigame_lost() -> void:
	active_minigame = null

func _on_minigame_won() -> void:
	finished = true
	active_minigame.disable_grenade()
	active_minigame.reset_trigger()
	active_minigame.set_as_cleared()
	active_minigame = null

func set_active_minigame(new_val: MinigameTrigger) -> void:
	active_minigame = new_val
	if new_val == null:
		show_minigames()
