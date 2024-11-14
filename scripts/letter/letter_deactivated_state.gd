extends LetterBaseState
## Letter deactivated state
##
## This letter can be activated

func activate_letter() -> void:
	letter.change_state(letter.activated_state)
	letter.notify_activated()

func deactivate_letter() -> void:
	return

func wrong_letter(character: String) -> void:
	letter.wrong_letter(character)

func is_deactivated() -> bool:
	return true
