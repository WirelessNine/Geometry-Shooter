class_name Enemy2D
extends CharacterBody2D

signal died

const SMOOTHNESS: float = 20.0
const LOOK_ACCURCY: float = 0.6
const DISTANCE_BUFFER: float = 15

var data: EnemyData

var health: int
var turret: Turret2D

@onready var sprite: Sprite2D = %Sprite
@onready var shadow: Sprite2D = %Shadow
@onready var shoot_timer: Timer = %ShootTimer


func _physics_process(delta: float) -> void:
	if not Globals.player:
		return

	var to_player: Vector2 = Globals.player.global_position - global_position
	var distance: float = to_player.length()
	var direction: Vector2 = to_player.normalized()

	var lerp_weight: float = delta * SMOOTHNESS

	if distance > data.distance_from_player + DISTANCE_BUFFER:
		velocity = velocity.lerp(direction * data.speed, lerp_weight)
	elif distance < data.distance_from_player - DISTANCE_BUFFER:
		velocity = velocity.lerp(-direction * data.speed, lerp_weight)
	else:
		velocity = velocity.lerp(Vector2.ZERO, lerp_weight)

	move_and_slide()

	_handle_turret(delta)


func set_enemy_data(new_data: EnemyData) -> void:
	if not is_node_ready():
		await ready

	data = new_data

	health = new_data.health

	if is_instance_valid(turret):
		remove_child(turret)
		turret.queue_free()

	turret = new_data.weapon_scene.instantiate()

	add_child(turret)

	sprite.texture = new_data.enemy_sprite
	shadow.texture = new_data.enemy_sprite


func take_damage(amount: int) -> void:
	health -= amount

	if health <= 0:
		Globals.add_level_progress(data.xp)
		queue_free()

		died.emit()


func _handle_turret(delta: float) -> void:
	var distance_from_turret: float = global_position.distance_to(Globals.player.global_position)
	var bullet_travel_time: float = distance_from_turret / turret.bullet_speed

	var extrapolated_position: Vector2 = Globals.player.global_position
	extrapolated_position += Globals.player.velocity * bullet_travel_time * LOOK_ACCURCY

	var to_player: Vector2 = extrapolated_position - global_position

	turret.rotation = lerp_angle(turret.rotation, to_player.angle(), delta * 20.0)


func _on_bullet_timer_timeout() -> void:
	turret.shoot()
