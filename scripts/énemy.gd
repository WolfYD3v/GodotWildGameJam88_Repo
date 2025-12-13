extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var label: Label3D = $Label_vie

@export var SPEED = 3.0
@export var damage_amount = 10

var vie : float = 100.0

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
	label.text = str(vie)
	
func check_death():
	# Vérifie si la vie est à zéro ou en dessous
	if vie <= 0:
		# Exécute la logique de destruction
		queue_free()
