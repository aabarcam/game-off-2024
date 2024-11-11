extends GrenadeBaseState
## A grenade's state when it's currently being held
##
## The grenade will blow up if released

func release_grenade() -> void:
	grenade.notify_exploded()
	grenade.change_state(grenade.inactive_state)

func hold_grenade() -> void:
	return
