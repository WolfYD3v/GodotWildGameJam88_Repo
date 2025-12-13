extends Node3D

@export_group("FOV")
@export var change_fov_on_run : bool
@export var normal_fov : float = 75.0
@export var run_fov : float = 90.0

const CAMERA_BLEND : float = 0.05

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/Camera3D

func _ready():
	# Capture le curseur au démarrage
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Cette fonction gère toutes les entrées non gérées par l'UI
func _unhandled_input(event):
	# 1. GESTION DE LA TOUCHE ESCAPE POUR LE CURSEUR
	if event.is_action_pressed("ui_cancel"):
		toggle_mouse_mode()

	# 2. ROTATION DE LA CAMÉRA (uniquement si le curseur est capturé)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_x(-event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/3, PI/3)

# Nouvelle fonction _input pour gérer les clics.
func _input(event):
	# Si le curseur est visible (libéré) ET que l'utilisateur clique (bouton gauche)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			# Re-capture le curseur
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle_mouse_mode():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Libère le curseur pour le menu
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		# Capture le curseur pour jouer (Cette partie est maintenant gérée par _input)
		# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # REMARQUE : Cette ligne est redondante si on clique
		pass # Laisser cette fonction s'occuper uniquement du mode VISIBLE

func _physics_process(_delta):
	if change_fov_on_run:
		if owner.is_on_floor():
			if Input.is_action_pressed("run"):
				camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
