extends Node
class_name GrenadeBaseState
## Base class of all possible grenade states
##
## Declares shared functionalities and functions to be overriden

var grenade: Grenade: ## Owner of this state
	set = set_grenade

func hold_grenade() -> void:
	push_error("Invalid state, cannot hold grenade")

func release_grenade() -> void:
	push_error("Invalid state, cannot release grenade")

func set_grenade(new_grenade: Grenade) -> void:
	grenade = new_grenade
