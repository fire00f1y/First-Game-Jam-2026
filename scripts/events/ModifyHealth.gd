extends PickupAction

class_name ModifyHealth

@export var amount: int = 10

func execute(pickup: Node, target: Node) -> void:
	if target.has_method("modify_health"):
		target.modify_health(amount)
