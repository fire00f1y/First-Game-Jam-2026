extends CanvasLayer

@onready var info_label: Label = $InfoLabel

func _process(_delta: float) -> void:
	var fps : float = Performance.get_monitor(Performance.TIME_FPS)
	var move_x : float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_y : float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var attack : float = Input.is_action_pressed("attack")
	var interact : float = Input.is_action_pressed("interact")

	info_label.text = "FPS: %d\nMove: (%.2f, %.2f)\nAtk: %s  Int: %s" % [
		int(fps),
		move_x, move_y,
		str(attack), str(interact)
	]
