@abstract
class_name Turret2D
extends Node2D

@export var bullet_scene: PackedScene
@export var space_raycast: RayCast2D
@export var spawn_pos: Marker2D
@export var bullet_speed: float = 150.0
@export var bullet_lifetime: float = 3.0
@export var shoot_delay: float = 0.2
@export var enemy_turret: bool = false


@abstract func shoot() -> void
