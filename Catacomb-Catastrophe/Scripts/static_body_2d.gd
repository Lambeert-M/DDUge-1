extends StaticBody2D
 
const tile_size: Vector2 = Vector2(16, 16)
var is_moving: bool = false
 
@export var sarc_dir: Vector2
var upright: bool = true
 
@export var pushable := true
@export var maxPushes := -1
# NOTE: the "player" export is no longer needed by this script (rotation
# logic now works for any pusher), so it's safe to leave empty or delete it.
 
@onready var ray_cast_2d_lower: RayCast2D = $Raycasts/RayCast2DLower
@onready var ray_cast_2d_upper: RayCast2D = $Raycasts/RayCast2DUpper
@onready var current_rotation: int = 0
 
 
func _ready() -> void:
	if sarc_dir == Vector2(1, 0) or sarc_dir == Vector2(-1, 0):
		upright = false
	ray_cast_2d_lower.enabled = pushable
	ray_cast_2d_upper.enabled = pushable
 
 
# Returns true if this object successfully moved/rotated, false if blocked.
func push_block(dir: Vector2, raycast: RayCast2D) -> bool:
	if is_moving or not pushable:
		return false
 
	if sarc_dir == Vector2(0, -1):
		ray_cast_2d_lower.target_position = dir * tile_size
		ray_cast_2d_upper.target_position = dir * tile_size
	elif sarc_dir == Vector2(1, 0):
		ray_cast_2d_upper.target_position = Vector2((dir.y), -(dir.x)) * tile_size
		ray_cast_2d_lower.target_position = Vector2((dir.y), -(dir.x)) * tile_size
	elif sarc_dir == Vector2(0, 1):
		ray_cast_2d_upper.target_position = -Vector2(dir.x, dir.y) * tile_size
		ray_cast_2d_lower.target_position = -Vector2(dir.x, dir.y) * tile_size
	else:
		ray_cast_2d_upper.target_position = -Vector2((dir.y), -(dir.x)) * tile_size
		ray_cast_2d_lower.target_position = -Vector2((dir.y), -(dir.x)) * tile_size
 
	ray_cast_2d_lower.force_raycast_update()
	ray_cast_2d_upper.force_raycast_update()
 
	var moving_along_long_axis = (upright and dir.y != 0) or (not upright and dir.x != 0)
 
	if moving_along_long_axis:
		if not _can_pass(ray_cast_2d_lower, dir) or not _can_pass(ray_cast_2d_upper, dir):
			return false
		_move_animation(global_position + dir * tile_size)
		return true
	else:
		# Only the player may trigger a rotation. If another pushable
		# block is doing the pushing, rotation is refused outright.
		if raycast.owner.has_method("push_block"):
			return false
		return push_and_rotate(dir, raycast)
 
 
# Checks one raycast; if it's blocked by something pushable, tries to push
# that thing out of the way. Returns true if the path is (now) clear.
func _can_pass(raycast: RayCast2D, dir: Vector2) -> bool:
	if not raycast.is_colliding():
		return true
	var collider = raycast.get_collider()
	if collider and collider.has_method("push_block"):
		return collider.push_block(dir, raycast)
	return false
 
 
func _move_animation(targetPosition):
	is_moving = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", targetPosition, 0.185).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): is_moving = false)
 
 
func push_and_rotate(dir: Vector2, raycast: RayCast2D) -> bool:
	# Rotation never pushes other blocks out of the way - if anything is
	# in the way (pushable or not), the rotation is simply refused.
	if ray_cast_2d_lower.is_colliding() or ray_cast_2d_upper.is_colliding():
		return false
 
	# Whoever is pushing us (player or another block) - use their position
	# to figure out which corner to rotate around.
	var pusher = raycast.owner
	var offset = pusher.global_position - global_position
 
	if sarc_dir == Vector2(0, -1):
		if dir.x > 0:
			if offset.y < 0:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(-8, -8))
				sarc_dir = Vector2(1, 0)
			else:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(-8, 8))
				sarc_dir = Vector2(-1, 0)
		else:
			if offset.y < 0:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(8, -8))
				sarc_dir = Vector2(-1, 0)
			else:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(8, 8))
				sarc_dir = Vector2(1, 0)
	elif sarc_dir == Vector2(1, 0):
		if dir.y < 0:
			if offset.x < 0:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(-8, 8))
				sarc_dir = Vector2(0, 1)
			else:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(8, 8))
				sarc_dir = Vector2(0, -1)
		else:
			if offset.x < 0:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(-8, -8))
				sarc_dir = Vector2(0, -1)
			else:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(8, -8))
				sarc_dir = Vector2(0, 1)
	elif sarc_dir == Vector2(0, 1):
		if dir.x < 0:
			if offset.y > 0:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(8, 8))
				sarc_dir = Vector2(-1, 0)
			else:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(8, -8))
				sarc_dir = Vector2(1, 0)
		else:
			if offset.y > 0:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(-8, 8))
				sarc_dir = Vector2(1, 0)
			else:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(-8, -8))
				sarc_dir = Vector2(-1, 0)
	else:  # sarc_dir == Vector2(-1, 0)
		if dir.y > 0:
			if offset.x > 0:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(8, -8))
				sarc_dir = Vector2(0, -1)
			else:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(-8, -8))
				sarc_dir = Vector2(0, 1)
		else:
			if offset.x > 0:
				current_rotation -= 90
				do_rotation(current_rotation, Vector2(8, 8))
				sarc_dir = Vector2(0, 1)
			else:
				current_rotation += 90
				do_rotation(current_rotation, Vector2(-8, 8))
				sarc_dir = Vector2(0, -1)
 
	return true
 
 
func do_rotation(current_rotation_param, tween_vector_offset) -> void:
	is_moving = true
 
	var tween = create_tween()
	tween.set_parallel(true)
 
	var final_destination = global_position - tween_vector_offset
	tween.tween_property(self, "rotation_degrees", current_rotation_param, 0.185).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", final_destination, 0.185).set_trans(Tween.TRANS_SINE)
 
	upright = not upright
	await tween.finished
	is_moving = false
 
