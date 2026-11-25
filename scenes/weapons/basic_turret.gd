extends Turret2D


func shoot() -> void:
	if space_raycast.is_colliding():
		return

	Globals.spawn_bullet_requested.emit(self, spawn_pos.global_position)

	play_shoot_tween()
