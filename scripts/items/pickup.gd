extends Area2D

@export var value: int = 1
@export var remove_on_pickup: bool = true
@export var actions: Array[PickupAction] = []
@export var icon_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if icon_texture:
		sprite.texture = icon_texture
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
		
	for action: PickupAction in actions:
		action.execute(self, body)
	
	if remove_on_pickup:
		queue_free()