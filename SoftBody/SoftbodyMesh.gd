extends MeshInstance3D
@onready var collision: CollisionShape3D = $statics/CollisionShape3D

@export
var tension: float = 0.3
@export
var dampening: float = 0.2
@export
var physicsPrefab: PackedScene
@export
var mergeTreshold: float = 0.001

var vertices: PackedVector3Array
var normals: PackedVector3Array
var uvs: PackedVector2Array
var indices: PackedInt32Array

var arrayMesh: ArrayMesh

var offsets: PackedFloat32Array
var offsetIndices: PackedInt32Array

var orbs: Array[RigidBody3D]
var orbConnections: PackedInt32Array

var collissionMesh: ConcavePolygonShape3D

func _ready() -> void:
	arrayMesh = mesh as ArrayMesh
	collissionMesh = collision.shape as ConcavePolygonShape3D
	
	var arrays: Array = arrayMesh.surface_get_arrays(0)
	
	vertices = arrays[arrayMesh.ARRAY_VERTEX]
	normals = arrays[arrayMesh.ARRAY_NORMAL]
	uvs = arrays[arrayMesh.ARRAY_TEX_UV]
	indices = arrays[arrayMesh.ARRAY_INDEX]
	
	for i in range(vertices.size()):
		var orbIndex: int = -1
		for j in range(orbs.size()):
			if orbs[j].position.distance_squared_to(vertices[i]) < mergeTreshold:
				orbIndex = j
		
		if orbIndex == -1:
			var newOrb: RigidBody3D = physicsPrefab.instantiate() as RigidBody3D
			add_child(newOrb)
			newOrb.position = vertices[i]
			orbs.append(newOrb)
			orbIndex = orbs.size() - 1
		
		orbConnections.append(orbIndex)
		
	
	for i in range(0, indices.size(), 3):
		tryAddOffset(orbConnections[indices[i]], orbConnections[indices[i + 1]])
		tryAddOffset(orbConnections[indices[i]], orbConnections[indices[i + 1]])
		tryAddOffset(orbConnections[indices[i + 1]], orbConnections[indices[i + 2]])
	

func tryAddOffset(a: int, b: int) -> void:
	for i in range(0, offsetIndices.size(), 2):
		if (a == offsetIndices[i] and b == offsetIndices[i + 1])\
		or (a == offsetIndices[i + 1] and b == offsetIndices[i]):
			return
	
	offsetIndices.append(a)
	offsetIndices.append(b)
	offsets.append(orbs[a].position.distance_to(orbs[b].position))

func hooke(deviation: float, velocity: float) -> float:
	return (tension * deviation) - (dampening * velocity)

func calculateForce(a: int, b: int, offset: float) -> void:
	var deviation: float = orbs[a].position.distance_to(orbs[b].position) - offset
	var direction = orbs[a].position.direction_to(orbs[b].position)
	var velocity: float = (orbs[a].linear_velocity - orbs[b].linear_velocity).project(direction).length()
	var force: Vector3 = hooke(deviation,  velocity) * direction
	orbs[a].apply_force(force)
	orbs[b].apply_force(-force)

func _physics_process(delta: float) -> void:
	for i in range(0, offsetIndices.size(), 2):
		calculateForce(offsetIndices[i], offsetIndices[i + 1], offsets[i * 0.5])
	
	for i in range(vertices.size()):
		vertices[i] = orbs[orbConnections[i]].position
	
	
	var arrays: Array
	arrays.resize(arrayMesh.ARRAY_MAX)
	arrays[arrayMesh.ARRAY_VERTEX] = vertices
	arrays[arrayMesh.ARRAY_NORMAL] = normals
	arrays[arrayMesh.ARRAY_TEX_UV] = uvs
	arrays[arrayMesh.ARRAY_INDEX] = indices
	
	arrayMesh.clear_surfaces()
	arrayMesh.add_surface_from_arrays(arrayMesh.PRIMITIVE_TRIANGLES, arrays)
	
	var collisionFaces: PackedVector3Array
	collisionFaces.resize(indices.size())
	for i in indices.size():
		collisionFaces[i] = vertices[indices[i]]
	
	collissionMesh.set_faces(collisionFaces)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for i in range(orbs.size()):
			orbs[i].apply_impulse(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))
		
