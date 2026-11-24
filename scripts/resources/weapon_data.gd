class_name WeaponData
extends Resource

@export var bullet_data: BulletData
@export_file("*.tscn") var weapon_scene: String
@export_range(1.0, 999.9, 0.1, "suffix:px/s") var bullet_speed: float = 100.0
@export_range(0.1, 100.0, 0.1, "suffix:s") var bullet_lifetime: float = 3.0
@export_range(0.1, 10.0, 0.1, "suffix:s") var shoot_delay: float = 0.5


func get_weapon_scene() -> PackedScene:
	return load(weapon_scene)
