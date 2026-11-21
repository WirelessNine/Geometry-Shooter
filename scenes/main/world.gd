extends Node2D

var bullet_pools: Dictionary[PackedScene, ScenePool]


func _ready() -> void:
	Globals.spawn_bullet_requested.connect(spawn_bullet)


func spawn_bullet(turret: Turret2D, bullet_pos: Vector2) -> void:
	var pool: ScenePool = _get_bullet_pool(turret.bullet_scene)

	var bullet: Bullet2D = pool.request_scene()

	bullet.set_collision_mask_value(2, turret.enemy_turret)
	bullet.set_collision_mask_value(3, not turret.enemy_turret)

	bullet.setup(Vector2.RIGHT.rotated(turret.rotation), turret.bullet_speed)

	bullet.global_position = bullet_pos
	bullet.reset_physics_interpolation()

	bullet.start_timer(turret.bullet_lifetime)


func _get_bullet_pool(bullet_scene: PackedScene) -> ScenePool:
	if not bullet_scene in bullet_pools:
		bullet_pools[bullet_scene] = ScenePool.new(
			ScenePool.AccessMode.DYNAMIC,
			bullet_scene,
			get_tree().current_scene,
			10,
			_on_created,
			_on_requested,
			_on_returned,
		)

	return bullet_pools[bullet_scene]


func _on_created(bullet: Bullet2D) -> void:
	bullet.hide()
	bullet.reset()

	bullet.wall_collided.connect(_on_bullet_wall_collided.bind(bullet))
	bullet.max_pierces_reached.connect(_on_bullet_life_timeout.bind(bullet))
	bullet.life_timeout.connect(_on_bullet_life_timeout.bind(bullet))


func _on_requested(bullet: Bullet2D) -> void:
	bullet.show()


func _on_returned(bullet: Bullet2D) -> void:
	bullet.hide()
	bullet.reset()

	bullet.stop_timer()


func _on_bullet_wall_collided(bullet: Bullet2D) -> void:
	var pool := ScenePool.get_owner_pool(bullet)

	pool.return_scene(bullet)


func _on_bullet_life_timeout(bullet: Bullet2D) -> void:
	var pool := ScenePool.get_owner_pool(bullet)

	pool.return_scene(bullet)
