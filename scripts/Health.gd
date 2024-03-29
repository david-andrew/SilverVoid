#@tool
extends Node
class_name Health

@export var MAX_HEALTH: int = 100
var MESH: MeshInstance3D
var MATERIAL: StandardMaterial3D
var health: int
var initial_color: Color
var parent: RigidBody3D
var parent_is_player: bool
var audio_controller: AudioController

# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH

	# verify that the parent is a RigidBody3D
	if not get_parent().is_class("RigidBody3D"):
		print("Health node may only be attached to RigidBody3D")
		get_tree().quit()
	
	# set up contact monitoring
	parent = get_parent()
	parent.contact_monitor = true
	parent.max_contacts_reported = 10
	parent_is_player = parent.name == 'Player'
	
	audio_controller = GameMaster.current_scene.find_child("AudioController")

	# try to get a mesh (sibling of this component), and its material
	MESH = parent.get_node_or_null('MeshInstance3D')
	if MESH:
		MATERIAL = MESH.get_active_material(0)
	if MATERIAL:
		initial_color = MATERIAL.albedo_color

func _physics_process(_delta):
	handle_collisions()

func handle_collisions():
	var colliders = parent.get_colliding_bodies()
	var damagers = []
	for collider in colliders:
		if collider.has_method('give_damage'):
			damage(collider.give_damage())
			damagers.append(collider)
			if parent_is_player:
				audio_controller.get_hit()
				
	#if len(damagers) > 0:
		#print('damage: ', damagers)

func damage(pts: int):
	health -= pts
	#print('health is: ', health)

	# interpolate the color based on the health
	if MATERIAL:
		MATERIAL.albedo_color = initial_color.lerp(Color(0, 0, 0, initial_color.a), 1.0 - (float(health - 1) / (MAX_HEALTH - 1)))
		#print('color is: ', MATERIAL.albedo_color)
	
	if health <= 0:
		if parent.has_method('destroy'):
			parent.destroy()
		else:
			parent.queue_free()
