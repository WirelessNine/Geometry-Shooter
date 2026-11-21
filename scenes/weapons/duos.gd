extends Turret2D


func shoot() -> void:
	if space_raycast.is_colliding():
		return

	var offset: Vector2 = Vector2(0.0, 4.0).rotated(global_rotation)

	Globals.spawn_bullet_requested.emit(self, spawn_pos.global_position + offset)
	Globals.spawn_bullet_requested.emit(self, spawn_pos.global_position - offset)
