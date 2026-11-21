class_name Bullet2D
extends Area2D

##Emitted when the bullet runs out of time.
signal life_timeout
##Emitted when the bullet collides with a wall.
signal wall_collided
##Emitted when the bullet collides with an enemy or the player.
signal entity_collided
##Emitted when the bullet pierces entities the max amount of times.
signal max_pierces_reached
##Emitted when the life timer is created.
signal timer_created

@export var damage: int
@export var max_pierces: int = 1
@export var sprite: Sprite2D

var direction: Vector2
var speed: float
var pierces: int = 0

var life_timer: Timer


func _ready() -> void:
	_create_timer()

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func setup(p_direction: Vector2, p_speed: float) -> void:
	set_physics_process(true)

	direction = p_direction
	speed = p_speed
	pierces = 0

	set_deferred(&"monitoring", true)

	if sprite:
		rotation = direction.angle()


func reset() -> void:
	set_physics_process(false)

	direction = Vector2.ZERO
	speed = 0.0

	set_deferred(&"monitoring", false)


func start_timer(time_sec: float) -> void:
	if not life_timer:
		await timer_created

	life_timer.start(time_sec)


func stop_timer() -> void:
	life_timer.stop()


func _create_timer() -> void:
	life_timer = Timer.new()
	life_timer.one_shot = true

	life_timer.timeout.connect(_on_life_timer_timeout)

	add_child(life_timer)

	timer_created.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.take_damage(damage / Globals.get_upgrade_value(Globals.Upgrade.ENDURANCE))

		pierces += 1

		if pierces >= max_pierces:
			max_pierces_reached.emit()

		entity_collided.emit()

	elif body is Enemy2D:
		body.take_damage(damage)

		pierces += 1

		if pierces >= max_pierces:
			max_pierces_reached.emit()

		entity_collided.emit()
	else:
		wall_collided.emit()


func _on_life_timer_timeout() -> void:
	life_timeout.emit()
