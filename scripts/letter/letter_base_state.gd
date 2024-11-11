extends Node
class_name LetterBaseState
## Base class of all possible letter states
##
## Declares shared functionalities and functions to be overriden

var letter: Letter: ## Owner of this state
	set = set_letter

func activate_letter() -> void:
	push_error("Invalid state " + str(self) + ", cannot activate letter " + letter.character)

func deactivate_letter() -> void:
	push_error("Invalid state " + str(self) + ", cannot deactivate letter " + letter.character)

func is_activated() -> bool:
	return false

func is_deactivated() -> bool:
	return false

func is_inactive() -> bool:
	return false

func set_letter(new_letter: Letter) -> void:
	letter = new_letter
