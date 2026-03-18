extends Node

signal health_changed(new_val: float)
signal mana_changed(new_val: float)
signal chaos_changed(new_val: float)
signal chaos_maxed

var max_health: float = 100.0
var max_mana: float = 100.0
var max_chaos: float = 100.0

@onready var health: float = max_health
@onready var mana: float = max_mana
@onready var chaos: float = 0.0

func take_damage(amount: float) -> void:
	health = clamp(health - amount, 0, max_health)
	print("taking %f damage. new health: %f" % [amount, health])
	health_changed.emit(health)

func spend_mana(amount: float) -> bool:
	if mana < amount:
		return false  # can't cast
	mana = clamp(mana - amount, 0, max_mana)
	mana_changed.emit(mana)
	return true

func add_chaos(amount: float) -> void:
	chaos = clamp(chaos + amount, 0, max_chaos)
	print("adding %f chaos. new chaos: %f" % [amount, chaos])
	chaos_changed.emit(chaos)
	if chaos >= max_chaos:
		chaos_maxed.emit()

func reduce_chaos(amount: float) -> void:
	chaos = clamp(chaos - amount, 0, max_chaos)
	chaos_changed.emit(chaos)