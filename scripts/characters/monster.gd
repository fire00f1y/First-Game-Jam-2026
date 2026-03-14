extends CharacterBody2D

@export var speed: float = 50.0
@export var health: int = 30

@onready var visuals : Marker2D = $Visuals
@onready var hitbox : Area2D = $Visuals/AttackBox
@onready var attack_range : Area2D = $AttackRange
@onready var player : Node = get_tree().get_first_node_in_group("player")
@onready var anim : AnimationPlayer = $AnimationPlayer

var is_stunned: bool = false
var player_in_range: bool = false
var is_attacking: bool = false

func _ready() -> void:
	attack_range.body_entered.connect(_attack_range_entered)
	attack_range.body_exited.connect(_attack_range_exit)
	anim.play("run")
	hitbox.body_entered.connect(_on_hitbox_entered)

func _on_hitbox_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("modify_health"):
		body.modify_health(self, -10)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or is_stunned: return

	if player_in_range:
		_attack()
	else:
		_chase(delta)

func _chase(delta: float) -> void:
	var direction : Vector2 = global_position.direction_to(player.global_position)
	velocity = direction * speed
	visuals.scale.x = 1 if direction.x > 0 else -1 # face the right way
	attack_range.scale.x = 1 if direction.x > 0 else -1
	
	if anim.current_animation != "run":
		anim.play("run")
	
	move_and_slide()

func _attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	anim.play("attack")
	
	await anim.animation_finished
	is_attacking = false

func _attack_range_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _attack_range_exit(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func take_damage(amount: int) -> void:
	health -= amount
	print("%s health remaining: %d" % [name, health])
	
	if health <= 0:
		_die()
	else:
		is_stunned = true
		anim.play("hurt")
		await anim.animation_finished
		is_stunned = false
		anim.play("run")

func _die() -> void:
	# Disable collisions so it doesn't hit you while dying
	set_physics_process(false)
	$CollisionBoundary.set_deferred("disabled", true)
	anim.play("die")
	await anim.animation_finished
	queue_free()
