extends CharacterBody2D

@export var speed: float = 140.0
@export var max_health: int = 100
@export var spell_power: int = 10

@onready var visuals: Marker2D = $Visuals
@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var hitbox: Area2D = $Visuals/HitboxContainer
@onready var anim: AnimationPlayer = $AnimationPlayer

var current_health: int = max_health
var is_attacking: bool = false
var is_stunned: bool = false
var combo_count: int = 0
var is_combo_buffered: bool = false
var combo_timing_window_open: bool = false
var facing: Vector2 = Vector2.RIGHT

var enemies_hit_in_attack: Array[Node] = []

@export var spell_book : SpellBook

const spell_rune_path_prefix : String = "res://assets/tiles/48 Magic Runes Pixel Art Icon Pack/PNG/Transperent/runes/"
const fire_icon : String = spell_rune_path_prefix + "Icon1.png"
const electric_icon : String = spell_rune_path_prefix + "Icon20.png"
const ice_icon : String = spell_rune_path_prefix + "Icon10.png"
const earth_icon : String = spell_rune_path_prefix + "Icon45.png"

@export var element_textures: Dictionary = {
	"fire": preload(fire_icon),
	"electric": preload(electric_icon),
	"ice": preload(ice_icon),
	"earth": preload(earth_icon)
}

var incantation: Array = []
@onready var slots : Array[Sprite2D] = [$IncantationRunes/rune1, $IncantationRunes/rune2, $IncantationRunes/rune3, $IncantationRunes/rune4]

func add_element(element: String):
	if incantation.size() >= 4:
		incantation.pop_front()
	incantation.append(element)
	_refresh_display()
	
func _refresh_display():
	for i : int in 4:
		if i < incantation.size():
			slots[i].texture = element_textures[incantation[i]]
			slots[i].visible = true
		else:
			slots[i].visible = false

func cast_incantation(type: String) -> void:
	if incantation.size() == 0:
		return
	
	if not spell_book:
		if OS.is_debug_build():
			print("no spell book attached to player")
		return
	
	var match : SpellData = find_spell()
	if not match:
		print("no spell found for incantation: ", incantation)
		clear_incantation()
		return
	
	if OS.is_debug_build():
		print("casting %s spell: %s with power: %f" % [type, match.spell_name, match.damage])
	
	_cast(match)
	clear_incantation()

func find_spell() -> SpellData:
	for spell: SpellData in spell_book.spells:
		if spell.combo == incantation:
			return spell
	
	return null

func _cast(spell: SpellData):
	var effect: BaseSpell = spell.scene.instantiate() as BaseSpell
	get_parent().add_child(effect)
	effect.global_position = global_position + facing * 16
	effect.setup(spell, facing)

func clear_incantation():
	incantation.clear()
	_refresh_display()

func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_entered)

func _on_hitbox_entered(body: Node) -> void:
	if not is_attacking:
		return

	if OS.is_debug_build():
		print("wizard hitbox entered: " % [body.name])
	
	if body.is_in_group("monster"):
		enemies_hit_in_attack.append(body)
		if body.has_method("modify_health"):
			body.modify_health(self, spell_power)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("menu"):
		get_tree().quit(0)
	
	if is_stunned: # cannot do anything, so don't process character input
		return
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		_handle_attack("attack2")
		cast_incantation("direct")
	elif Input.is_action_just_pressed("block") and not is_attacking:
		_handle_attack("attack1")
		cast_incantation("area")
	
	if Input.is_action_just_pressed("fire"):
		add_element("fire")
	
	if Input.is_action_just_pressed("ice"):
		add_element("ice")

	if Input.is_action_just_pressed("electric"):
		add_element("electric")
	
	if Input.is_action_just_pressed("earth"):
		add_element("earth")
	
	if not is_attacking:
		_handle_movement(delta)

# Note: damage actually happens in hitbox callback 
# this handles animation transition
func _handle_attack(attack: String):
	enemies_hit_in_attack.clear()
	is_attacking = true
	anim.play(attack)
	await anim.animation_finished
	is_attacking = false

func _handle_movement(_delta: float) -> void:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		_handle_animations("run", input_vector)
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
		facing = Vector2.RIGHT
	elif input.x < 0:
		visuals.scale.x = -1
		facing = Vector2.LEFT

func modify_health(source: Node, amount: int) -> void:
	if amount < 0: # positive is healing, negative is damage
		is_attacking = false
		is_stunned = true
		anim.play("hurt")
		current_health = clamp(current_health + amount, -1 * abs(amount), max_health)
		print("Current health changed by %d from %s. new health: %d" % [amount, source.name, current_health])
		await anim.anim_finished
		is_stunned = false
	
	if current_health <= 0:
		_die(source)

func _die(source: Node) -> void:
	is_stunned = true
	anim.play("death")
	if OS.is_debug_build():
		print("You were slain by %s!" % [source.name])
	await anim.anim_finished
	queue_free()
