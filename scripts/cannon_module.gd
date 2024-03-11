extends ShipModule

var target: RigidBody3D = null
var possible_targets: Array[RigidBody3D] = []
var original_transform: Transform3D
@export var MIN_ANGLE_WITH_SURFACE: float = PI/8
#var target_sight_laser: MeshInstance3D
var original_parent

const SHOOT_FREQUENCY = 20 #shots/second
var last_shot_time = Time.get_ticks_msec()
const BULLET_INITIAL_SPEED = 100
const BULLET = preload("res://scenes/bullet.tscn")
var total_bullets_shot = 0





func _ready():
	var joint = PinJoint3D.new()
	link_module_to_core(joint)

	# DEBUG, replace with actual target
	target = get_tree().current_scene.find_child('Player')
	original_transform = Transform3D(transform)
	
	#target_sight_laser = $TargetSight
	#target_sight_laser.visible = false
	
	original_parent = get_parent()


func _physics_process(delta):
	try_shoot_at_target()


func set_targets(targets:Array[RigidBody3D]):
	#TODO: for use by control modules
	pass

func select_best_target():
	if len(possible_targets) == 0:
		return
	if not target:
		target = possible_targets[0]
	
	#TODO: iterate over targets, select the closest (ensuring that the turret can point at it)

func try_shoot_at_target():
	if get_parent() != original_parent:
		return
	
	if not target:
		return
	
	var expected_position = HelperFunctions.compute_expected_target_position(global_position, BULLET_INITIAL_SPEED, target.global_position, target.linear_velocity)
	#look_at(target.global_position, Vector3.UP)
	look_at(expected_position, Vector3.UP)

	# check if cannon is beyond max rotation
	if transform.basis.z.dot(original_transform.basis.z) < 0.25:
		#target_sight_laser.visible = false
		return
	#target_sight_laser.visible = true
	shoot_bullet()
	return
	
		
func shoot_bullet():
	if Time.get_ticks_msec() - last_shot_time > (1000 / SHOOT_FREQUENCY):
		var bullet = BULLET.instantiate()
		GameMaster.current_scene.add_child(bullet)
		bullet.global_basis = global_basis
		bullet.position = global_position + (target.global_position - global_position).normalized() * 2 + Vector3(randf(), randf(), randf()) * 0.5
		bullet.global_position -= 2*global_transform.basis.z
		bullet.linear_velocity = linear_velocity + BULLET_INITIAL_SPEED * -global_transform.basis.z + Vector3(randfn(0,1), randfn(0,1), randfn(0,1))*0.5
		last_shot_time = Time.get_ticks_msec()
		total_bullets_shot += 1

