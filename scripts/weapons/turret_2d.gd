@abstract
class_name Turret2D
extends Node2D

@export var bullet_scene: PackedScene
@export var space_raycast: RayCast2D
@export var spawn_pos: Marker2D
@export var bullet_speed: float = 150.0:
	set(value):
		bullet_speed = value
	get:
		if enemy_turret:
			return bullet_speed

		return bullet_speed * Globals.get_upgrade_value(Globals.Upgrade.BULLET_SPEED)

@export var bullet_lifetime: float = 3.0
@export var shoot_delay: float = 0.2:
	set(value):
		shoot_delay = value
	get:
		if enemy_turret:
			return shoot_delay

		return shoot_delay / Globals.get_upgrade_value(Globals.Upgrade.RELOAD)

@export var enemy_turret: bool = false


@abstract func shoot() -> void
