extends TextureRect

const GAME: PackedScene = preload("uid://cq5npwj1o3jw4")

var game_started: bool = false


func _input(event: InputEvent) -> void:
	if game_started:
		return

	if not (event is InputEventKey and event.keycode == KEY_ENTER and event.is_pressed()):
		return

	Transition.fade_in()

	await Transition.transition_finished

	get_tree().change_scene_to_packed(GAME)
