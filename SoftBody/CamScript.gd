extends Camera3D

@export
var physicsParent: Node3D
@export
var maxDistSqr: float = 1
@export
var dragForce: float = 10

var lastHeldPos: Vector3
var heldDist: float
var held: bool = false

var heldPoints: Array[RigidBody3D]
var heldPowers: Array[float]

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var rayOrigin: Vector3 = project_ray_origin(event.position)
			var rayDir: Vector3 = project_ray_normal(event.position)
			var state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
			
			var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
			params.from = rayOrigin
			params.to = rayOrigin + rayDir * 10000
			params.collision_mask = 0b10
			
			var rayResults = state.intersect_ray(params)
			
			if rayResults.has("position"):
				lastHeldPos = rayResults.get("position")
				heldDist = rayOrigin.distance_to(lastHeldPos)
				
				for child in physicsParent.get_children():
					if child is RigidBody3D:
						var distSqr = lastHeldPos.distance_squared_to(child.position)
						if distSqr < maxDistSqr:
							heldPoints.append(child)
							heldPowers.append(inverse_lerp(maxDistSqr, 0, distSqr))
				
				held = true
				
			
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			held = false
			heldPoints.clear()
			heldPowers.clear()
			
		
	elif event is InputEventMouseMotion:
		if held && not heldPoints.is_empty():
			var rayOrigin: Vector3 = project_ray_origin(event.position)
			var rayDir: Vector3 = project_ray_normal(event.position)
			
			lastHeldPos = rayOrigin + (rayDir * heldDist)
			
		
	

func _process(delta: float) -> void:
	if held && not heldPoints.is_empty():
		var movement: Vector3 = lastHeldPos - heldPoints[0].position
		for i in heldPoints.size():
			heldPoints[i].apply_impulse(movement * dragForce * heldPowers[i])
			
		
	
