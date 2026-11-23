class_name EnemyData
extends Resource

##The max health of the enemy.
@export_range(1.0, 500.0, 1.0) var health: int = 10
##The movement speed of the enemy.
@export_range(1.0, 500.0, 0.5) var speed: float = 10
##The distance from the player where the enemy stops or back down.
@export_range(1.0, 500.0, 0.5) var distance_from_player: float = 10
##The XP the enemy gives on death.
@export_range(1.0, 500.0, 1.0) var xp: int = 10
##The scene of a [Turret2D] that the enemy uses.
@export var weapon_scene: PackedScene
