class_name BaseSpell extends Node2D

var direction: Vector2
var damage: float
var ttl: float # measured in seconds
var speed: float

func _ready() -> void:
	print("I am alive!")

func setup(spell: SpellData, dir: Vector2) -> void:
	print("Setting up spell: %s" % spell.spell_name)
	direction = dir
	speed = spell.speed
	scale.x = dir.x
	damage = spell.damage
	if spell.lifetime > 0:
		ttl = spell.lifetime

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	if ttl > 0:
		ttl -= delta
		if ttl <= 0:
			print("freeing fireball")
			queue_free()
