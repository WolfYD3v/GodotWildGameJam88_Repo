extends Control

@onready var progress_bar: ProgressBar = $TopArea/Nodes/ProgressBar
@onready var upgrades_area: Control = $UpgradesArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var upgrades_area_min_height: float = 0.0
var upgrades_area_max_height: float = 150.0
var upgrades_area_open: bool = false:
	set(value):
		upgrades_area_open = value
		if value: animate_with_tween(upgrades_area, "size:y", upgrades_area_max_height, upgreades_area_tween_time)
		else: animate_with_tween(upgrades_area, "size:y", upgrades_area_min_height, upgreades_area_tween_time)
var upgreades_area_tween_time: float = 0.15
var upgreades_area_tween = null

func _ready() -> void:
	upgrades_area_open = false
	upgrades_area.size.y = upgrades_area_min_height
	show()

func _on_upgrades_button_pressed() -> void:
	upgrades_area_open = true

func _on_close_upgrade_area_button_pressed() -> void:
	upgrades_area_open = false

func bounce() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("bounce")

func animate_with_tween(object: Control, property: String, new_value: Variant, time: float) -> void:
	if upgreades_area_tween:
		upgreades_area_tween.kill()
	upgreades_area_tween = get_tree().create_tween()
	upgreades_area_tween.tween_property(object, property, new_value, time)
