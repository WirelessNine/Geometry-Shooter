class_name Player2D
extends Entity2D

const DEFAULT_REGENERATION: float = 8.0
const DEFAULT_HEALTH: int = 100

const DEFAULT_SPEED: float = 120.0
const DASH_SPEED: float = 400.0
const SMOOTHNESS: float = 20.0

var current_turret_data: WeaponData
var current_turret: Turret2D

var can_shoot: bool = false
var has_immunity: bool = false
var can_dash: bool = true
var is_dashing: bool = false

var health: int

@onready var bullet_timer: Timer = %BulletTimer
@onready var regeneration_timer: Timer = %RegenerationTimer
@onready var dash_timer: Timer = %DashTimer
@onready var dash_cooldown: Timer = %DashCooldown


func _ready() -> void:
	health = get_max_health()
	Globals.player = self

	Globals.player_health_changed.emit(health)

	set_turret(Globals.weapon_collection.get_item("shooter_weapon"))

	bullet_timer.timeout.connect(_on_bullet_timer_timeout)
	regeneration_timer.timeout.connect((_on_regeneration_timer_timeout))
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	dash_cooldown.timeout.connect(_on_dash_cooldown_timeout)

	Globals.level_changed.connect(
		func() -> void:
			if Globals.level % 5 == 0:
				randomize_weapon(),
	)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_turret(delta)


func add_health(amount: int) -> void:
	health = mini(health + amount, get_max_health())

	Globals.player_health_changed.emit(health)


func take_damage(amount: int) -> void:
	if has_immunity:
		return

	health -= amount

	if health <= 0:
		get_tree().reload_current_scene.call_deferred()

	Globals.player_health_changed.emit(health)


func get_max_health() -> int:
	return roundi(DEFAULT_HEALTH * Globals.max_health_upgrade.value)


func set_turret(weapon_data: WeaponData) -> void:
	if is_instance_valid(current_turret):
		current_turret.queue_free()

	var turret: Turret2D = weapon_data.get_weapon_scene().instantiate()
	add_child(turret)

	current_turret = turret
	current_turret_data = weapon_data


func randomize_weapon() -> void:
	var turret_data: WeaponData = Globals.weapon_collection.get_random_item()

	if turret_data == current_turret_data:
		randomize_weapon()
		return

	set_turret(current_turret_data)


func _handle_movement(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")

	if Input.is_action_just_pressed(&"dash") and can_dash and input_vector:
		is_dashing = true
		has_immunity = true
		can_dash = false

		dash_timer.start()

		velocity = input_vector * DASH_SPEED

	if not is_dashing:
		var lerp_weight: float = delta * SMOOTHNESS
		var speed: float = DEFAULT_SPEED * Globals.movement_speed_upgrade.value

		velocity = velocity.lerp(input_vector * speed, lerp_weight)

	move_and_slide()


func _handle_turret(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var to_mouse: Vector2 = mouse_pos - current_turret.global_position

	current_turret.rotation = lerp_angle(current_turret.rotation, to_mouse.angle(), delta * 20.0)

	if Input.is_action_pressed(&"shoot") and not can_shoot:
		can_shoot = true

		current_turret.shoot()
		bullet_timer.start(current_turret.weapon_data.shoot_delay / Globals.reload_upgrade.value)


func _on_bullet_timer_timeout() -> void:
	can_shoot = false


func _on_regeneration_timer_timeout() -> void:
	add_health(roundi(get_max_health() * 0.05))

	regeneration_timer.start(DEFAULT_REGENERATION / Globals.regeneration_upgrade.value)


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	has_immunity = false

	dash_cooldown.start()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
