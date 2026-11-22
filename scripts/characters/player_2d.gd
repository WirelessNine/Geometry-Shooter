class_name Player2D
extends CharacterBody2D

const DEFAULT_HEALTH: int = 100

const DEFAULT_SPEED: float = 80.0
const SMOOTHNESS: float = 20.0

var current_turret_scene: PackedScene
var current_turret: Turret2D
var shoot_db: bool = false

@onready var bullet_timer: Timer = %BulletTimer

var health: int


func _ready() -> void:
	set_turret(Globals.weapons[0])
	health = get_max_health()

	Globals.player = self
	Globals.player_health_changed.emit(health)

	Globals.level_changed.connect(
		func() -> void:
			if Globals.level % 5 == 0:
				randomize_weapon(),
	)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_turret(delta)


func add_health(amount: int) -> void:
	print(get_max_health())
	health = mini(health + amount, get_max_health())

	Globals.player_health_changed.emit(health)


func take_damage(amount: int) -> void:
	health -= amount

	if health <= 0:
		get_tree().reload_current_scene.call_deferred()

	Globals.player_health_changed.emit(health)


func get_max_health() -> int:
	return roundi(DEFAULT_HEALTH * Globals.get_upgrade_value(Globals.Upgrade.MAX_HEALTH))


func set_turret(turret_scene: PackedScene) -> void:
	if is_instance_valid(current_turret):
		current_turret.queue_free()

	var turret: Turret2D = turret_scene.instantiate()
	add_child(turret)

	current_turret = turret
	current_turret_scene = turret_scene


func randomize_weapon() -> void:
	var turret_scene: PackedScene = Globals.weapons.pick_random()

	if turret_scene == current_turret_scene:
		randomize_weapon()
		return

	set_turret(turret_scene)


func _handle_movement(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	var lerp_weight: float = delta * SMOOTHNESS

	var speed: float = DEFAULT_SPEED * Globals.get_upgrade_value(Globals.Upgrade.MOVEMENT_SPEED)

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


func _on_regeneration_timer_timeout() -> void:
	add_health(roundi(get_max_health() * 0.05))
