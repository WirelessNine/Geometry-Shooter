class_name Player2D
extends CharacterBody2D

const WALK_SPEED: float = 80.0
const SPRINT_SPEED: float = 140.0
const SMOOTHNESS: float = 20.0

var current_turret: Turret2D
var shoot_db: bool = false

@onready var bullet_timer: Timer = %BulletTimer


func _ready() -> void:
	current_turret = get_node(^"BasicTurret")

	Globals.player = self


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_turret(delta)


func _handle_movement(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	var lerp_weight: float = delta * SMOOTHNESS

	var speed: float = SPRINT_SPEED if Input.is_action_pressed(&"sprint") else WALK_SPEED

	velocity = velocity.lerp(input_vector * speed, lerp_weight)

	move_and_slide()


func _handle_turret(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var to_mouse: Vector2 = mouse_pos - current_turret.global_position

	current_turret.rotation = lerp_angle(current_turret.rotation, to_mouse.angle(), delta * 20.0)

	if Input.is_action_pressed(&"shoot") and not shoot_db:
		shoot_db = true

		current_turret.shoot()
		bullet_timer.start(current_turret.shoot_delay)


func _on_bullet_timer_timeout() -> void:
	shoot_db = false
