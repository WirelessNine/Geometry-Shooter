extends Node2D

const BULLET: PackedScene = preload("uid://ckq0dc1qxmqx2")

const TOP_LEFT := Vector2i(-40, -34)
const BOTTOM_RIGHT := Vector2i(44, 32)

var bullet_pool: ScenePool

var active_enemies: Array[Enemy2D]
var active_bullets: Array[Bullet2D]

var wave: int = 0

var enemy_scenes: Array[PackedScene] = [
	load("uid://bwwme27d8y6y3"),
	load("uid://wv4cugjbkwhr"),
	load("uid://b6fnn5m3xa1a"),
	load("uid://bmdjvhfsiei07"),
]

@onready var walls: TileMapLayer = %Walls


func _ready() -> void:
	_create_bullet_pool()

	start_wave()
	Globals.spawn_bullet_requested.connect(spawn_bullet)


func _physics_process(delta: float) -> void:
	for x: Bullet2D in active_bullets:
		if not x.is_physics_processing():
			continue

		x.global_position += x.direction * x.speed * delta


func spawn_bullet(turret: Turret2D, bullet_pos: Vector2) -> void:
	var bullet: Bullet2D = bullet_pool.request_scene()

	var bullet_direction := Vector2.RIGHT.rotated(turret.rotation)
	var bullet_speed: float = turret.bullet_speed
	var bullet_lifetime: float = turret.bullet_lifetime
	var bullet_data: BulletData = turret.bullet_data

	bullet.set_collision_mask_value(2, turret.enemy_turret)
	bullet.set_collision_mask_value(3, not turret.enemy_turret)

	bullet.start_movement(bullet_direction, bullet_speed, bullet_lifetime, bullet_data)

	bullet.global_position = bullet_pos
	bullet.reset_physics_interpolation()


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


func _create_bullet_pool() -> void:
	bullet_pool = ScenePool.new(
		ScenePool.AccessMode.DYNAMIC,
		BULLET,
		get_tree().current_scene,
		10,
		_on_created,
		_on_requested,
		_on_returned,
	)


func _on_created(bullet: Bullet2D) -> void:
	bullet.hide()
	bullet.stop_movement()

	active_bullets.append(bullet)

	bullet.wall_collided.connect(_on_bullet_wall_collided.bind(bullet))
	bullet.max_pierces_reached.connect(_on_bullet_life_timeout.bind(bullet))
	bullet.life_timeout.connect(_on_bullet_life_timeout.bind(bullet))


func _on_requested(bullet: Bullet2D) -> void:
	bullet.show()


func _on_returned(bullet: Bullet2D) -> void:
	bullet.hide()
	bullet.stop_movement()


func _on_bullet_wall_collided(bullet: Bullet2D) -> void:
	var pool := ScenePool.get_owner_pool(bullet)

	pool.return_scene(bullet)


func _on_bullet_life_timeout(bullet: Bullet2D) -> void:
	var pool := ScenePool.get_owner_pool(bullet)

	pool.return_scene(bullet)


func _on_enemy_died(enemy: Enemy2D) -> void:
	active_enemies.erase(enemy)

	start_wave()
