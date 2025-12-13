extends CharacterBody3D

# --- PROPRIÉTÉS GLOBALES ---
const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float
var vie : float = 100.0

# --- VARIABLES DE MOUVEMENT ---
@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0
@export var damage_attack : float = 30

# --- VARIABLES DU DASH ---
@export_group("Dash variables")
@export var dash_strength : float = 25.0  # Vitesse de la ruée
@export var dash_duration : float = 0.2    # Durée du dash (réglez aussi le Timer dans l'éditeur)
var is_dashing : bool = false
var dash_direction : Vector3 = Vector3.ZERO # Stocke la direction de la ruée
var attack : bool = false
# --- ANIMATION ---
const ANIMATION_BLEND : float = 7.0

# --- NŒUDS ---
@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree
@onready var DashTimer: Timer = $Timer # S'assure que le nœud Timer est nommé "Timer"
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

func _ready() -> void:
	speed = run_speed
	
	# Connexion du signal timeout pour mettre fin au dash
	DashTimer.timeout.connect(_on_dash_timer_timeout) 
	
	# Assurez-vous que le Timer utilise la durée du script
	DashTimer.wait_time = dash_duration

func _process(_delta: float) -> void:
	
	var shift = Ui.get_node("Panel")
	if !is_dashing and dash_cooldown_timer.is_stopped():
		shift.show()
	else:
		shift.hide()
	
func _physics_process(delta):
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	# --- LOGIQUE DE DASH ---
	if is_dashing:
		# 1. Maintenir la vélocité du dash
		velocity = dash_direction * dash_strength
		# La gravité n'est pas appliquée ici
		
	else:
		# Tenter de Dasher (uniquement si l'action est pressée et le joueur bouge)
		if Input.is_action_just_pressed("dash") and !attack and move_direction.length_squared() > 0.0:	
			if dash_cooldown_timer.is_stopped():
				start_dash(move_direction)
				dash_cooldown_timer.start()
			# Sortir pour appliquer le dash immédiatement
		
		# --- LOGIQUE DE MOUVEMENT STANDARD ---
		else:
			# Application de la gravité
			velocity.y -= gravity * delta
			
			# Application de la vitesse normale (walk_speed / run_speed)
			
			velocity.x = move_direction.x * speed
			velocity.z = move_direction.z * speed
			
			
			# Rotation du Mesh
			if move_direction and !attack:
				player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)

		# --- LOGIQUE DE SAUT ET SNAP (si pas en dash) ---
		var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
		var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
		if is_jumping:
			velocity.y = jump_strength
			snap_vector = Vector3.ZERO
		elif just_landed:
			snap_vector = Vector3.DOWN
	
	# Application du mouvement final
	# NOTE : Assurez-vous d'avoir la fonction apply_floor_snap() définie
	if is_dashing and !attack:
		animator.set("parameters/dash/transition_request", "dash")
	elif !attack:
		animator.set("parameters/dash/transition_request", "locomotion")
		
	if Input.is_action_just_pressed("attack1") and !attack:
		speed = 0
		attack = true
		animator.set("parameters/dash/transition_request", "attack")
		await animator.animation_finished
		attack = false
		speed = run_speed
		
	apply_floor_snap() 
	
	move_and_slide()
	animate(delta)

# --- FONCTION DE LANCEMENT DU DASH ---
func start_dash(direction: Vector3):
	if is_dashing:
		return
		
	is_dashing = true
	
	# Définir la direction du dash et donner le coup de pouce
	dash_direction = direction.normalized()
	velocity = dash_direction * dash_strength
	
	# Stopper le snap au sol pendant le dash
	snap_vector = Vector3.ZERO
	
	# Démarrer le timer
	DashTimer.start() 

# --- FIN DU DASH ---
func _on_dash_timer_timeout():
	is_dashing = false
	dash_direction = Vector3.ZERO
	
	# Ralentir la vélocité à la vitesse normale après le dash
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)
	
	# Rétablir le snap au sol si l'on touche le sol après le dash
	if is_on_floor():
		snap_vector = Vector3.DOWN
		
# --- ANIMATION ---
func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")
		
func damage(damage):
	vie -= damage
	var PG = Ui.get_node("ProgressBar")
	PG.value = vie
	check_death()
	
func check_death():
   # Vérifie si la vie est à zéro ou en dessous
	if vie <= 0:
		# Exécute la logique de destruction
		print("i'm dead")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if attack:
		if body.has_method("damage") and body.is_in_group("enemies"):
			body.damage(damage_attack)
	
