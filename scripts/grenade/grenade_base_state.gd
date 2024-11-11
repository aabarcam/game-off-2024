extends Node
class_name GrenadeBaseState
## Base class of all possible grenade states
##
## Declares shared functionalities and functions to be overriden

var grenade: GrenadeComponent: ## Owner of this state
	set = set_grenade

func hold_grenade() -> void:
	push_error("Invalid state, cannot hold grenade")

func release_grenade() -> void:
	push_error("Invalid state, cannot release grenade")

func is_inactive() -> bool:
	return false

func set_grenade(new_grenade: GrenadeComponent) -> void:
	grenade = new_grenade
