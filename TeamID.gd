extends Node
class_name TeamID

enum Team { GREEN, MAGENTA, GRAY }
const magenta = Color(0.55, 0, 0.534)
const green = Color(0.31, 0.545, 0)

@export var team: Team = Team.GRAY

func _ready():
	var parent = get_parent()
	assert(parent is ShipCore or parent.name == 'Player', 'TeamID must be attached to a ship core or the player')
	
	var siblings = parent.get_children()
	#assert(siblings[0] == self, "TeamID must be the first child attached to a ship")
	
	#set the parent color
	var mat: StandardMaterial3D
	var health: Health
	mat = parent.find_child("MeshInstance3D").get_active_material(0)
	if team == Team.MAGENTA:
		mat.albedo_color = Color.WHITE
	elif team == Team.GREEN:
		mat.albedo_color = green
	elif team == Team.GRAY:
		mat.albedo_color = Color.SLATE_GRAY
	health = parent.find_child('Health')
	if health:
		health.initial_color = mat.albedo_color
	
	# for each armor module sibling, paint them a specific color according to the team
	for sibling in siblings:
		if sibling is ArmorModule:
			mat = sibling.find_child("MeshInstance3D").get_active_material(0)
			if team == Team.MAGENTA:
				mat.albedo_color = magenta
			elif team == Team.GREEN:
				mat.albedo_color = Color.WHITE
			elif team == Team.GRAY:
				mat.albedo_color = Color.SLATE_GRAY
			health = sibling.find_child('Health')
			if health:
				health.initial_color = mat.albedo_color
