extends Node2D

const TOP_LEFT := Vector2i(-40, -34)
const BOTTOM_RIGHT := Vector2i(44, 32)

var bullet_pools: Dictionary[PackedScene, ScenePool]
var active_enemies: Array[Enemy2D]

var wave: int = 0

var enemy_scenes: Array[PackedScene] = [
	load("uid://bwwme27d8y6y3"),
	load("uid://wv4cugjbkwhr"),
	load("uid://b6fnn5m3xa1a"),
	load("uid://bmdjvhfsiei07"),
]

@onready var walls: TileMapLayer = %Walls


func _ready() -> void:
	Globals.spawn_bullet_requested.connect(spawn_bullet)

	start_wave()


func spawn_bullet(turret: Turret2D, bullet_pos: Vector2) -> void:
	var pool: ScenePool = _get_bullet_pool(turret.bullet_scene)

	var bullet: Bullet2D = pool.request_scene()

	bullet.set_collision_mask_value(2, turret.enemy_turret)
	bullet.set_collision_mask_value(3, not turret.enemy_turret)

	bullet.setup(Vector2.RIGHT.rotated(turret.rotation), turret.bullet_speed)

	bullet.global_position = bullet_pos
	bullet.reset_physics_interpolation()

	bullet.start_timer(turret.bullet_lifetime)


func start_wave() -> void:
	if not active_enemies.is_empty():
		return

	await get_tree().create_timer(2.0).timeout

	wave += 1

	for x: int in wave:
		_instatiate_enemy()


func _instatiate_enemy() -> void:
	var random_pos := Vector2i(
		randi_range(TOP_LEFT.x, BOTTOM_RIGHT.x),
		randi_range(TOP_LEFT.y, BOTTOM_RIGHT.y),
	)

	if walls.get_cell_tile_data(random_pos):
		_instatiate_enemy()
		return

	var local_pos: Vector2 = walls.map_to_local(random_pos)
	var enemy: Enemy2D = enemy_scenes.pick_random().instantiate()
	active_enemies.append(enemy)
	enemy.died.connect(_on_enemy_died.bind(enemy))

	add_child(enemy)

	enemy.position = local_pos
	enemy.reset_physics_interpolation()


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


func _on_enemy_died(enemy: Enemy2D) -> void:
	active_enemies.erase(enemy)

	start_wave()
