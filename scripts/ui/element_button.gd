@tool
extends NinePatchRect

@export var button_text: String:
	set(value):
		button_text = value
		if is_node_ready() and button_label:
			button_label.text = value

@export var button_icon: Texture2D:
	set(value):
		button_icon = value
		if is_node_ready() and button_image:
			button_image.texture = value

@onready var button_label: Label = $MarginContainer/VBoxContainer/ButtonLabel
@onready var button_image: TextureRect = $MarginContainer/VBoxContainer/ButtonImage

func _ready() -> void:
	button_label.text = button_text
	if button_icon:
		button_image.texture = button_icon
