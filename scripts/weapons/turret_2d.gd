@abstract
class_name Turret2D
extends Node2D

@export var weapon_data: WeaponData
@export var sprite: Sprite2D
@export var space_raycast: RayCast2D
@export var spawn_pos: Marker2D

var enemy_turret: bool = false
var shoot_tween: Tween


func _ready() -> void:
	if not sprite:
		sprite = get_node(^"Sprite")


@abstract func shoot() -> void


func play_shoot_tween() -> void:
	if shoot_tween and shoot_tween.is_running():
		shoot_tween.kill()

	shoot_tween = create_tween()
	shoot_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	sprite.position.x = 5.5

	shoot_tween.tween_property(sprite, ^"position:x", 8.0, 0.8)
