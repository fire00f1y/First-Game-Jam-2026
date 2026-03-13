@tool
extends Area2D

@export var value: int = 1
@export var remove_on_pickup: bool = true
@export var actions: Array[PickupAction] = []

@onready var sprite: Sprite2D = $Sprite2D

@export var item_icon: Texture2D:
	set(value):
		item_icon = value
		if sprite:
			sprite.texture = value

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if item_icon:
		sprite.texture = item_icon
	
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
		
	for action: PickupAction in actions:
		action.execute(self, body)
	
	if remove_on_pickup:
		queue_free()