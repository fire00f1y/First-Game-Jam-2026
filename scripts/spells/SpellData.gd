class_name SpellData extends Resource

@export var spell_name: String
@export var combo: Array[String] = []
@export var damage: float
@export var speed: float = 1.0
@export var scene: PackedScene
@export var icon: Texture2D
@export var lifetime: float = 0.0
@export var size_scale: float = 1.0
@export var chaos_cost: float = 12.0
@export var mana_cost: float = 10.0