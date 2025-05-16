extends ProgressBar
class_name TimedBar

var start_time: float = -1

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.one_shot = true
	
	if OS.is_debug_build() and get_parent() == get_tree().root:
		start_timer(5)

func _process(_delta: float) -> void:
	if start_time >= 0:
		var progress: float = timer.time_left/start_time
		value = progress * 100

func start_timer(time: float) -> void:
	timer.start(time)
	start_time = time

func stop_timer() -> void:
	timer.stop()

func pause() -> void:
	timer.paused = true

func unpause() -> void:
	timer.paused = false
