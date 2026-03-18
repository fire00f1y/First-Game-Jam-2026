extends TextureProgressBar

enum StatType { HEALTH, MANA, CHAOS }
@export var stat_type: StatType
@export var bar_color: Color = Color.WHITE

func _ready() -> void:
	tint_progress = bar_color
	match stat_type:
		StatType.HEALTH:
			PlayerStats.health_changed.connect(_on_value_changed)
			max_value = PlayerStats.max_health
			value = PlayerStats.health
		StatType.MANA:
			PlayerStats.mana_changed.connect(_on_value_changed)
			max_value = PlayerStats.max_mana
			value = PlayerStats.mana
		StatType.CHAOS:
			PlayerStats.chaos_changed.connect(_on_value_changed)
			max_value = PlayerStats.max_chaos
			value = PlayerStats.chaos

func _on_value_changed(new_val: float) -> void:
	value = new_val
