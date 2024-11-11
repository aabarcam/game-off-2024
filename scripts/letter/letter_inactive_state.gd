extends LetterBaseState
## Letter inactive state
##
## This letter is inactive, and can't be activated or deactivated unless reset

func activate_letter() -> void:
	return

func deactivate_letter() -> void:
	return

func is_inactive() -> bool:
	return true
