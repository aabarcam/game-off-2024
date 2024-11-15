extends LetterBaseState
## Letter activated state
##
## This letter can be deactivated

func activate_letter() -> void:
	return

func deactivate_letter() -> void:
	letter.change_state(letter.deactivated_state)
	letter.notify_deactivated()

func is_activated() -> bool:
	return true
