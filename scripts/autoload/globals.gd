extends Node

signal spawn_bullet_requested(turret: Turret2D, position: Vector2)
signal upgrades_changed
signal points_changed
signal level_progress_changed
signal level_changed

signal player_health_changed(new_value: int)

const BASE_LEVEL_REQUIRED: int = 50
const LEVEL_GROWTH: float = 1.15

var player: Player2D

var max_health_upgrade: UpgradeData
var regeneration_upgrade: UpgradeData
var movement_speed_upgrade: UpgradeData
var endurance_upgrade: UpgradeData
var bullet_damage_upgrade: UpgradeData
var bullet_speed_upgrade: UpgradeData
var reload_upgrade: UpgradeData

var weapon_collection: Registry.Collection

var points: int = 50
var level: int = 0
var level_progress: int = 0


func _ready() -> void:
	weapon_collection = Registry.create_collection(
		"weapon_data",
		&"WeaponData",
		"res://resources/weapons/",
	)

	max_health_upgrade = load("uid://dmcmknmhtgrju")
	regeneration_upgrade = load("uid://c72nvbdtmrhxo")
	movement_speed_upgrade = load("uid://cfavert7neptq")
	endurance_upgrade = load("uid://g84eu5brtyqa")
	bullet_damage_upgrade = load("uid://poroh1o73fig")
	bullet_speed_upgrade = load("uid://6rwservvi6k3")
	reload_upgrade = load("uid://clm8u4adlnyth")


func add_upgrade_level(upgrade: UpgradeData) -> void:
	if points <= 0:
		return

	points -= 1

	upgrade.add_level()

	points_changed.emit()
	upgrades_changed.emit()


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


func reset_stats() -> void:
	max_health_upgrade.reset()
	regeneration_upgrade.reset()
	movement_speed_upgrade.reset()
	endurance_upgrade.reset()
	bullet_damage_upgrade.reset()
	bullet_speed_upgrade.reset()
	reload_upgrade.reset()

	points = 0
	level = 0
	level_progress = 0
