extends CharacterBody2D

@export var speed: float = 140.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("menu"):
		get_tree().quit(0)
		
	if Input.is_action_just_pressed("attack") and not is_attacking:
		_start_attack()
		
	if not is_attacking:		
		_handle_movement(delta)

func _start_attack() -> void:
	is_attacking = true
	anim.play("attack1")
	
	# wait for animation to finish before allowing more movement
	await anim.animation_finished
	
	is_attacking = false
	
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
		sprite.flip_h = false
	elif input.x < 0:
		sprite.flip_h = true

func modify_health(amount: int) -> void:
	print("modifying health by %d" % [amount])
