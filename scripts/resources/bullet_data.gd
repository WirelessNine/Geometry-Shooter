class_name BulletData
extends Resource

##The amount of damage the bullet gives on hit.
@export_range(1.0, 50.0) var damage: int = 5
##The max amount of times a bullet can pierce targets.
@export_range(1.0, 10.0) var pierces: int = 1
##The chance for the bullet hit to be a crit hit.
@export_range(0.01, 1.0, 0.01, "suffix:%") var crit_chance: float = 0.2
##The crit amount applied on crit hit.
@export_range(1.1, 5.0, 0.1, "suffix:%") var crit_amount: float = 1.5
##The radius of the bullet's collision
@export_range(1.0, 16.0, 0.5) var collision_radius: float = 1.0
