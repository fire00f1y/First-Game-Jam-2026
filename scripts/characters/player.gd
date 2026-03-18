extends CharacterBody2D

@export var speed: float = 140.0
@export var max_health: int = 100
@export var attack_power: int = 5

@onready var visuals: Node2D = $Visuals
@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var sword_hitbox: Area2D = $Visuals/SwordHitbox
@onready var anim: AnimationPlayer = $AnimationPlayer

var current_health: int = max_health
var is_attacking: bool = false
var is_stunned: bool = false
var combo_count: int = 0
var is_combo_buffered: bool = false
var combo_timing_window_open: bool = false

var enemies_hit_in_swing: Array[Node] = []

func _ready() -> void:
	sword_hitbox.body_entered.connect(_on_sword_hitbox_entered)

func _on_sword_hitbox_entered(body: Node) -> void:
	if not is_attacking:
		return
		
	if body.is_in_group("monster"):
		enemies_hit_in_swing.append(body)
		
		if body.has_method("take_damage"):
			body.take_damage(attack_power * combo_count)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("menu"):
		get_tree().quit(0)
	
	if is_stunned:
		return
		
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			_attack()
		else:
			is_combo_buffered = combo_timing_window_open
		
	if not is_attacking:		
		_handle_movement(delta)

func _attack() -> void:
	enemies_hit_in_swing.clear()
	is_attacking = true
	is_combo_buffered = false
	combo_count += 1
	anim.play("attack" + str(combo_count))
	
	await anim.animation_finished
	_check_combo_transition()

func _check_combo_transition() -> void:
	if is_combo_buffered and combo_count < 3:
		_attack()
	else:
		combo_count = 0
		is_attacking = false
		is_combo_buffered = false
		combo_timing_window_open = false
	
func _handle_movement(delta: float) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		_handle_animations("walk", input_vector)
	else:
		velocity = Vector2.ZERO
		_handle_animations("idle", input_vector)
	
	move_and_slide()

func _handle_animations(state: String, input: Vector2) -> void:
	if is_attacking:
		return
		
	if anim.current_animation != state:
		anim.play(state)
	
	if input.x > 0:
		visuals.scale.x = 1
	elif input.x < 0:
		visuals.scale.x = -1

func modify_health(source: Node, amount: int) -> void:
	current_health = clamp(current_health + amount, -1 * abs(amount), max_health)
	print("Current health changed by %d from %s. new health: %d" % [amount, source.name, current_health])
	if amount > 0:
		_take_damage()
	
	if current_health <= 0:
		_die(source)

func _take_damage() -> void:
	is_attacking = false
	combo_count = 0
	is_combo_buffered = false
	
	is_stunned = true
	anim.play("hurt")
	await anim.animation_finished
	is_stunned = false

func _die(source: Node) -> void:
	is_stunned = true
	anim.play("death")
	print("You were slain by %s!" % [source.name])

func set_combo_timing_window(value: bool) -> void:
	combo_timing_window_open = value
