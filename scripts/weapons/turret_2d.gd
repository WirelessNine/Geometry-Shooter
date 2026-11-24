@abstract
class_name Turret2D
extends Node2D

@export var weapon_data: WeaponData
@export var space_raycast: RayCast2D
@export var spawn_pos: Marker2D
@export var enemy_turret: bool = false


@abstract func shoot() -> void
