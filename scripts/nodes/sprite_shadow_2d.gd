class_name SpriteShadow2D
extends Sprite2D

const DROP_SHADOW_MATERIAL: ShaderMaterial = preload("uid://bipoqgphw5eb0")

var parent: Sprite2D


func _ready() -> void:
	parent = get_parent()
	z_index = -1
	material = DROP_SHADOW_MATERIAL

	update_sprite()

	parent.texture_changed.connect(update_sprite)


func update_sprite() -> void:
	texture = parent.texture
