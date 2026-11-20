class_name Enemy2D
extends CharacterBody2D

const SMOOTHNESS: float = 20.0
const LOOK_ACCURCY: float = 0.6

@export_range(1.0, 9999.9, 1.0) var max_health: int = 10
@export var speed: float = 60.0
@export var player_distance: float = 50.0
@export var distance_buffer: float = 30.0
@export var turret: Turret2D

var bullet_timer: Timer


func _ready() -> void:
	_create_bullet_timer()


func _physics_process(delta: float) -> void:
	if not Globals.player:
		return

	var to_player: Vector2 = Globals.player.global_position - global_position
	var distance: float = to_player.length()
	var direction: Vector2 = to_player.normalized()

	var lerp_weight: float = delta * SMOOTHNESS

	if distance > player_distance + distance_buffer:
		velocity = velocity.lerp(direction * speed, lerp_weight)
	elif distance < player_distance - distance_buffer:
		velocity = velocity.lerp(-direction * speed, lerp_weight)
	else:
		velocity = velocity.lerp(Vector2.ZERO, lerp_weight)

	move_and_slide()

	_handle_turret(delta)


func _handle_turret(delta: float) -> void:
	var distance_from_turret: float = global_position.distance_to(Globals.player.global_position)
	var bullet_travel_time: float = distance_from_turret / turret.bullet_speed

	var extrapolated_position: Vector2 = Globals.player.global_position
	extrapolated_position += Globals.player.velocity * bullet_travel_time * LOOK_ACCURCY

	var to_player: Vector2 = extrapolated_position - global_position

	turret.rotation = lerp_angle(turret.rotation, to_player.angle(), delta * 20.0)


func _create_bullet_timer() -> void:
	bullet_timer = Timer.new()
	bullet_timer.timeout.connect(_on_bullet_timer_timeout)

	add_child(bullet_timer)

	await get_tree().create_timer(randf_range(0.5, 2.0)).timeout

	bullet_timer.start(turret.shoot_delay)


func _on_bullet_timer_timeout() -> void:
	turret.shoot()
