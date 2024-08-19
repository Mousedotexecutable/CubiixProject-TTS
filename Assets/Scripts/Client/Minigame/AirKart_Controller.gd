extends CharacterBody3D
@onready var Core = get_node("/root/Main_Scene/CoreLoader")

const walkspeed = .5
const runspeed = 2

var speed = 3
var jumpspeed = 6
const gravity = -0.98 * 2
var gravity_control:Vector3 = Vector3.ZERO
var compiled_velocity = Vector3.ZERO

@export var spring_strength = 10.0
@export var suspension_rest_dist = .5
@export var wheel_radius = 0.33
var prev_spring_length = 0.0
@export var spring_damper = 2.0

func _physics_process(delta: float) -> void:
	
	gravity_control += (self.global_transform.basis.y * 1) * (gravity/8)
	
	if $RayCast3D.is_colliding():

		
		var raycast_origin = $RayCast3D.global_position
		var raycast_dest = $RayCast3D.get_collision_point()
		var distance = raycast_dest.distance_to(raycast_origin)
		
		var contact = raycast_dest - raycast_origin
		
		var spring_length = clamp(distance - wheel_radius, 0, suspension_rest_dist )
		
		var spring_force = spring_strength * (suspension_rest_dist - spring_length)
		
		var spring_velocity = (prev_spring_length - spring_length) / delta
		
		var damper_force = spring_damper * spring_velocity
		
		var suspension_force = (self.global_transform.basis.y * 1) * (spring_force + damper_force)
		
		prev_spring_length = spring_length
		
		gravity_control += suspension_force
		
	
	
	velocity = compiled_velocity + gravity_control
	move_and_slide()

	
func align_up(node_basis, normal, slerptime):
	var result = Basis()
	result.x = normal.cross(node_basis.z)
	result.y = normal
	result.z = node_basis.x.cross(normal)
	
	result = node_basis.slerp(result.orthonormalized(),slerptime)
	return result
