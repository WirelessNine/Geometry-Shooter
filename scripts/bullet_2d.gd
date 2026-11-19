class_name Bullet2D
extends Area2D

##Emitted when the bullet runs out of time.
signal life_timeout

var direction: Vector2
var speed: float

var life_timer: Timer


func _ready() -> void:
	_create_timer()


func setup(p_direction: Vector2, p_speed: float) -> void:
	set_physics_process(true)

	direction = p_direction
	speed = p_speed


func reset() -> void:
	set_physics_process(false)

	direction = Vector2.ZERO
	speed = 0.0


func start_timer(time_sec: float) -> void:
	life_timer.start(time_sec)


func stop_timer() -> void:
	life_timer.stop()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _create_timer() -> void:
	life_timer = Timer.new()
	life_timer.one_shot = true

	life_timer.timeout.connect(_on_life_timer_timeout)

	add_child(life_timer)


func _on_life_timer_timeout() -> void:
	life_timeout.emit()
