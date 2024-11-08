extends Node

@warning_ignore("unused_signal")
signal transition_triggered ## Fired when transition object is clicked

var signals: Dictionary = {} ## Store all signals and their origin scene for logging

## Register a signal for logging
func register_signal(sig: Signal, scene: Object) -> void:
	if not OS.is_debug_build():
		return
	signals[sig] = scene
	sig.connect(create_log_func(sig))

## Log a fired signal
func log_signal(sig: Signal) -> void:
	print_rich("[color=yellow]<Signal fired> ", signals[sig], " -> ", sig)

## Return a function that logs the received signal
func create_log_func(sig: Signal) -> Callable:
	return func(): log_signal(sig)
