extends GrenadeBaseState
## A grenade's starting state
##
## The grenade has not been activated, and the player must hold it to continue

func hold_grenade() -> void:
	grenade.notify_held()
	grenade.change_state(grenade.holding_state)
