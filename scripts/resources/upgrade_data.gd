class_name UpgradeData
extends Resource

@export var default_value: float = 1.0
@export var increment_amount: float = 0.1

var value: float:
	get:
		return default_value + increment_amount * level
var level: int = 0


func reset() -> void:
	level = 0


func add_level() -> void:
	level += 1
