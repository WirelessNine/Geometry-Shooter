class_name Turret2D
extends Node2D

@export var bullet_scene: PackedScene
@export var spawn_pos: Marker2D
@export var bullet_speed: float = 150.0
@export var bullet_lifetime: float = 3.0
@export var shoot_delay: float = 0.2

var bullet_pool: ScenePool


func _ready() -> void:
	create_pool()


func shoot() -> void:
	pass


func create_pool() -> void:
	bullet_pool = ScenePool.new(
		ScenePool.AccessMode.DYNAMIC,
		bullet_scene,
		get_tree().current_scene,
		10,
		_on_created,
		_on_requested,
		_on_returned,
	)


func _on_created(bullet: Bullet2D) -> void:
	bullet.hide()
	bullet.reset()

	bullet.body_entered.connect(_on_bullet_collided.bind(bullet))
	bullet.life_timeout.connect(_on_bullet_life_timeout.bind(bullet))


func _on_requested(bullet: Bullet2D) -> void:
	bullet.show()
	bullet.setup(Vector2.RIGHT.rotated(rotation), bullet_speed)

	bullet.global_position = spawn_pos.global_position
	bullet.reset_physics_interpolation()

	bullet.start_timer(bullet_lifetime)


func _on_returned(bullet: Bullet2D) -> void:
	bullet.hide()
	bullet.reset()

	bullet.stop_timer()


func _on_bullet_collided(body: Node2D, bullet: Bullet2D) -> void:
	if body is CharacterBody2D:
		return

	bullet_pool.return_scene(bullet)


func _on_bullet_life_timeout(bullet: Bullet2D) -> void:
	bullet_pool.return_scene(bullet)
