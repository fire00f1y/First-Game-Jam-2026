class_name BaseSpell extends Node2D

@export var scale_factor: Vector2 = Vector2(3.0, 1.0)

var direction: Vector2
var damage: float
var ttl: float # measured in seconds
var speed: float

func _ready() -> void:
	print("I am alive!")

func setup(spell: SpellData, dir: Vector2) -> void:
	print("Setting up spell: %s" % spell.spell_name)
	var new_scale: Vector2= spell.size_scale * scale_factor
	$Sprite2D.scale = new_scale
	$Area2D/CollisionShape2D.scale = new_scale
	direction = dir
	speed = spell.speed
	scale.x = dir.x
	damage = spell.damage
	PlayerStats.add_chaos(spell.chaos_cost)
	if spell.lifetime > 0:
		ttl = spell.lifetime

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	if ttl > 0:
		ttl -= delta
		if ttl <= 0:
			print("freeing fireball")
			queue_free()
