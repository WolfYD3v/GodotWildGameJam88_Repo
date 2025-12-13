extends CharacterBody3D
class_name Enemy

signal killed(_enemy: Enemy)

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var label: Label3D = $Label_vie
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export_group("Random speed")
@export var min_speed: float = 3.0
@export var max_speed: float = 7.5
@export_group("Random damage amount")
@export var min_damage_amount: int = 2
@export var max_damage_amount: int = 5
@export_group("Random vie")
@export var min_vie: float = 100.0
@export var max_vie: float = 150.0
@export_group("Random xperience dropped")
@export var min_experience_dropped: int = 15
@export var max_experience_dropped: int = 45
@export_group("Random attacks amount")
@export var min_attacks_amount: int = 2
@export var max_attacks_amount: int = 3
@export_group("Random scale")
@export var min_scale_value: float = 1.0
@export var max_scale_value: float = 1.5
@export_category("")
@export var attacks: Array[String] = [
	"attack_1",
	"attack_2",
	"attack_3",
	"attack_4",
	"attack_5"
]

var SPEED = 3.0
var damage_amount = 10
var vie : float = 100.0
var experience_dropped: int = 15
var scale_value: float = 1.0

var attacks_amount: int = 2
var current_attacks: Array[String] = []

func _ready() -> void:
	# Set the SPEED randomly
	SPEED = randf_range(min_speed, max_speed)
	# Set the damage_amount randomly
	damage_amount = randi_range(min_damage_amount, max_damage_amount)
	# Set the vie randomly
	vie = randf_range(min_vie, max_vie)
	label.text = str(round(vie))
	# Set the experience dropped randomly
	experience_dropped = randi_range(min_experience_dropped, max_experience_dropped)
	# Set the scale_value randomly, and so define the scale
	scale_value = randf_range(min_scale_value, max_scale_value)
	scale = Vector3(
		scale_value,
		scale_value,
		scale_value
	)
	
	# Set the attacks_amount randomly
	attacks_amount = randi_range(min_attacks_amount, max_attacks_amount)
	# Fill the used attacks
	for loop: int in range(attacks_amount):
		var attack_to_add: String = attacks.pick_random()
		attacks.erase(attack_to_add)
		current_attacks.append(attack_to_add)
	# Lil debug
	print(to_string() + ": " + str(current_attacks))

func _physics_process(_delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	velocity = new_velocity
	

func update_target_location(target_location):
	nav_agent.target_position = target_location

func _on_navigation_agent_3d_target_reached() -> void:
	print("in range")
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("damage") and body.is_in_group("player"):
		body.damage(damage_amount)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
	
func damage(damage):
	vie -= damage
	check_death()
	label.text = str(round(vie))
	
func check_death():
	# Vérifie si la vie est à zéro ou en dessous
	if vie <= 0:
		killed.emit(self)
		# Exécute la logique de destruction
		queue_free()
