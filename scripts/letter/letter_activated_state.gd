extends LetterBaseState
## Letter activated state
##
## This letter can be deactivated

func set_letter(new_letter: Letter) -> void:
	super.set_letter(new_letter)
	letter.text = letter.character.to_upper()

func activate_letter() -> void:
	return

func deactivate_letter() -> void:
	letter.change_state(letter.deactivated_state)
	letter.notify_deactivated()

func wrong_letter(_char: String) -> void:
	return

func is_activated() -> bool:
	return true
