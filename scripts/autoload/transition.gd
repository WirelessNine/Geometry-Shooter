extends CanvasLayer

signal transition_finished

const TIME: float = 0.4

var tween: Tween

@onready var rect: ColorRect = %Rect


func _ready() -> void:
	set_state(false)


func set_state(on: bool) -> void:
	if on:
		rect.color = Color(0.0, 0.0, 0.0, 1.0)
	else:
		rect.color = Color(0.0, 0.0, 0.0, 0.0)


func fade_in() -> void:
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()

	tween = create_tween()

	tween.tween_property(rect, ^"color", Color(0.0, 0.0, 0.0, 1.0), TIME)

	await tween.finished

	transition_finished.emit()


func fade_out() -> void:
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()

	tween = create_tween()

	tween.tween_property(rect, ^"color", Color(0.0, 0.0, 0.0, 0.0), TIME)

	await tween.finished

	transition_finished.emit()
