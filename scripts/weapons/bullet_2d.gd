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

var data: BulletData

var direction: Vector2
var speed: float
var pierces: int = 0

var life_timer: Timer

@onready var sprite: Sprite2D = %Sprite
@onready var collision: CollisionShape2D = %Collision


func _ready() -> void:
	_create_timer()

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func set_bullet_data(new_data: BulletData) -> void:
	data = new_data

	sprite.texture = new_data.bullet_sprite

	if not (collision.shape and collision.shape is CircleShape2D):
		collision.shape = CircleShape2D.new()

	collision.shape.radius = new_data.collision_radius


func start_movement(p_direction: Vector2, p_speed: float, p_lifetime: float) -> void:
	if not data:
		push_error("Bullet has no BulletData.")
		return

	if not life_timer:
		push_error("Life Timer does not exist yet.")
		return

	direction = p_direction
	speed = p_speed
	pierces = 0

	if data.rotate_sprite:
		rotation = direction.angle()

	life_timer.start(p_lifetime)

	set_deferred(&"monitoring", true)
	set_physics_process(true)


func stop_movement() -> void:
	if not is_node_ready():
		await ready

	direction = Vector2.ZERO
	speed = 0.0

	if life_timer:
		life_timer.stop()

	set_deferred(&"monitoring", false)
	set_physics_process(false)


func _create_timer() -> void:
	life_timer = Timer.new()
	life_timer.one_shot = true

	life_timer.timeout.connect(_on_life_timer_timeout)

	add_child(life_timer)

	timer_created.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.take_damage(data.damage / Globals.get_upgrade_value(Globals.Upgrade.ENDURANCE))

		pierces += 1

		if pierces >= data.pierces:
			max_pierces_reached.emit()

		entity_collided.emit()

	elif body is Enemy2D:
		body.take_damage(data.damage)

		pierces += 1

		if pierces >= data.pierces:
			max_pierces_reached.emit()

		entity_collided.emit()
	else:
		wall_collided.emit()


func _on_life_timer_timeout() -> void:
	life_timeout.emit()
