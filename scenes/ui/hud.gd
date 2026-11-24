extends MarginContainer

@onready var health_bar: TextureProgressBar = %HealthBar

@onready var level_bar: TextureProgressBar = %LevelBar
@onready var level_label: Label = %LevelLabel

@onready var points_label: Label = $UpgradesVBox/PointsLabel

@onready var max_health_bar: TextureProgressBar = %MaxHealthBar
@onready var upgrade_max_health: TextureButton = %UpgradeMaxHealth

@onready var movement_speed_bar: TextureProgressBar = %MovementSpeedBar
@onready var upgrade_movement_speed: TextureButton = %UpgradeMovementSpeed

@onready var endurance_bar: TextureProgressBar = %EnduranceBar
@onready var upgrade_endurance: TextureButton = %UpgradeEndurance

@onready var bullet_speed_bar: TextureProgressBar = %BulletSpeedBar
@onready var upgrade_bullet_speed: TextureButton = %UpgradeBulletSpeed

@onready var reload_bar: TextureProgressBar = %ReloadBar
@onready var upgrade_reload: TextureButton = %UpgradeReload


func _ready() -> void:
	refresh_upgrades()
	refresh_level()
	refresh_points()

	upgrade_max_health.pressed.connect(Globals.add_upgrade_level.bind(Globals.max_health_upgrade))
	upgrade_movement_speed.pressed.connect(
		Globals.add_upgrade_level.bind(Globals.movement_speed_upgrade)
	)
	upgrade_endurance.pressed.connect(Globals.add_upgrade_level.bind(Globals.endurance_upgrade))
	upgrade_bullet_speed.pressed.connect(
		Globals.add_upgrade_level.bind(Globals.bullet_speed_upgrade)
	)
	upgrade_reload.pressed.connect(Globals.add_upgrade_level.bind(Globals.reload_upgrade))

	Globals.player_health_changed.connect(refresh_health_bar)
	Globals.upgrades_changed.connect(refresh_upgrades)
	Globals.level_changed.connect(refresh_level)
	Globals.level_progress_changed.connect(refresh_level)
	Globals.points_changed.connect(refresh_points)


func refresh_health_bar(new_value: int) -> void:
	health_bar.value = new_value
	health_bar.max_value = Player2D.DEFAULT_HEALTH * Globals.max_health_upgrade.value


func refresh_upgrades() -> void:
	max_health_bar.value = Globals.max_health_upgrade.level
	movement_speed_bar.value = Globals.movement_speed_upgrade.level
	endurance_bar.value = Globals.endurance_upgrade.level
	bullet_speed_bar.value = Globals.bullet_speed_upgrade.level
	reload_bar.value = Globals.reload_upgrade.level

	if Globals.player:
		refresh_health_bar(Globals.player.health)


func refresh_level() -> void:
	level_label.text = "Level %d" % Globals.level

	level_bar.value = Globals.level_progress
	level_bar.max_value = Globals.get_next_level_requirement()


func refresh_points() -> void:
	points_label.text = "%d points" % Globals.points

	var has_point: bool = Globals.points > 0

	upgrade_max_health.disabled = not has_point
	upgrade_movement_speed.disabled = not has_point
	upgrade_endurance.disabled = not has_point
	upgrade_bullet_speed.disabled = not has_point
	upgrade_reload.disabled = not has_point
