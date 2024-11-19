extends LetterBaseState

func activate_letter() -> void:
	return

func deactivate_letter() -> void:
	return

func is_deceiving() -> bool:
	return true

func wrong_letter(character: String) -> void:
	letter.wrong_letter(character)

func is_deactivated() -> bool:
	return true
