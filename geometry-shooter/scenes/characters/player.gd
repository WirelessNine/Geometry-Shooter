class_name Player2D
extends CharacterBody2D

const WALK_SPEED: float = 245.0
const SPRINT_SPEED: float = 420.0
const ACCELEARTION: float = 18.0
const FRICTION: float = 10.0


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	var lerp_weight: float = delta * (ACCELEARTION if input_vector else FRICTION)

	var speed: float = SPRINT_SPEED if Input.is_action_pressed(&"sprint") else WALK_SPEED

	velocity = lerp(velocity, input_vector * speed, lerp_weight)

	move_and_slide()
