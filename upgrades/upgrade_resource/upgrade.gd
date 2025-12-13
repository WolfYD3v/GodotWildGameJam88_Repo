extends Resource
class_name Upgrade

enum UPG_EFFECTS {
	NULL
}

@export var upg_name: String = ""
@export var upg_description: String = ""
@export var upg_texture: Texture2D = null
@export var upg_effect: UPG_EFFECTS = UPG_EFFECTS.NULL
