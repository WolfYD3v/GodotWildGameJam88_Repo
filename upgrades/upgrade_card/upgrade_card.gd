extends Control
class_name UpgradeCard

@onready var upgrade_name_label: Label = $UpgradeNameLabel
@onready var upgrade_description_label: Label = $UpgradeDescriptionLabel
@onready var upgrade_texture_texture_rect: TextureRect = $UpgradeTextureTextureRect

var upgrades_collection_folder_path: String = "res://upgrades/upgrades_collection/"
var upgrades_collection: Array = DirAccess.get_files_at(upgrades_collection_folder_path)
var upgrade_resource: Upgrade = null

func _ready() -> void:
	load_upgrade_resource()

func _get_upgrade_resource() -> Upgrade:
	print(upgrades_collection)
	return load(upgrades_collection_folder_path + upgrades_collection.pick_random())

func load_upgrade_resource() -> void:
	upgrade_resource = _get_upgrade_resource()
	upgrade_name_label.text = upgrade_resource.upg_name
	upgrade_description_label.text = upgrade_resource.upg_description
	upgrade_texture_texture_rect.texture = upgrade_resource.upg_texture


func _apply_upgrade() -> void:
	if upgrade_resource != null: print("Upgrade effect: " + str(upgrade_resource.upg_effect))
	else: push_warning("'upgrade_resource' variable does not contain any 'Upgrade' Resource!")
