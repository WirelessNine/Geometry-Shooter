extends Node

signal spawn_bullet_requested(turret: Turret2D, position: Vector2)
signal upgrades_changed
signal points_changed
signal level_progress_changed
signal level_changed

signal player_health_changed(new_value: int)

enum Upgrade {
	MAX_HEALTH,
	MOVEMENT_SPEED,
	ENDURANCE,
	BULLET_SPEED,
	RELOAD,
}

const BASE_LEVEL_REQUIRED: int = 50
const LEVEL_GROWTH: float = 1.15

const UPGRADE_DEFAULTS: Dictionary[Upgrade, float] = {
	Upgrade.MAX_HEALTH: 1.0,
	Upgrade.MOVEMENT_SPEED: 1.0,
	Upgrade.ENDURANCE: 1.0,
	Upgrade.BULLET_SPEED: 1.0,
	Upgrade.RELOAD: 1.0,
}

var player: Player2D

var upgrade_values: Dictionary[Upgrade, float] = {
	Upgrade.MAX_HEALTH: 1.0,
	Upgrade.MOVEMENT_SPEED: 1.0,
	Upgrade.ENDURANCE: 1.0,
	Upgrade.BULLET_SPEED: 1.0,
	Upgrade.RELOAD: 1.0,
}

var upgrade_levels: Dictionary[Upgrade, int] = {
	Upgrade.MAX_HEALTH: 0,
	Upgrade.MOVEMENT_SPEED: 0,
	Upgrade.ENDURANCE: 0,
	Upgrade.BULLET_SPEED: 0,
	Upgrade.RELOAD: 0,
}

var weapons: Array[PackedScene]

var points: int = 0
var level: int = 0
var level_progress: int = 0


func _ready() -> void:
	weapons = [
		load("uid://2t6iabqy4880"),
		load("uid://t8037sqjyaov"),
		load("uid://da5qm6jvngm3v"),
		load("uid://bvljnc2ghoqwb"),
		load("uid://bs7lxupdl0os4"),
	]


func set_upgrade_level(upgrade: Upgrade, new_level: int) -> void:
	upgrade_levels[upgrade] = new_level

	upgrade_values[upgrade] = UPGRADE_DEFAULTS[upgrade] + (0.1 * new_level)
	upgrades_changed.emit()


func add_upgrade_level(upgrade: Upgrade) -> void:
	if points <= 0:
		return

	points -= 1

	set_upgrade_level(upgrade, upgrade_levels[upgrade] + 1)

	points_changed.emit()


func get_upgrade_level(upgrade: Upgrade) -> int:
	return upgrade_levels[upgrade]


func get_upgrade_value(upgrade: Upgrade) -> float:
	return upgrade_values[upgrade]


func add_level_progress(amount: int) -> void:
	if amount <= 0:
		return

	var next_level_requirement: int = get_next_level_requirement()

	level_progress += amount

	if level_progress >= next_level_requirement:
		level += 1
		points += 1

		level_progress = 0

		level_changed.emit()
		points_changed.emit()

	level_progress_changed.emit()


func get_next_level_requirement() -> int:
	return roundi(BASE_LEVEL_REQUIRED * pow(LEVEL_GROWTH, level))
