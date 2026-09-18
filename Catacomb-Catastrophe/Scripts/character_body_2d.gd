extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16)
var sprite_node_pos_tween: Tween

func _ready() -> void:
	$HurtBox.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer and body.name == "SpikesTileMapLayer":
		kill()

func _physics_process(delta: float) -> void:
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_pressed("ui_up"):
			_try_move(Vector2(0, -1), $up)
		elif Input.is_action_pressed("ui_down"):
			_try_move(Vector2(0, 1), $down)
		elif Input.is_action_pressed("ui_left"):
			_try_move(Vector2(-1, 0), $left)
		elif Input.is_action_pressed("ui_right"):
			_try_move(Vector2(1, 0), $right)

func _try_move (dir: Vector2, raycast: RayCast2D) -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_method("push_block"):
			$Sprite2D.play("push")
			collider.push_block(dir, raycast)
		return
	_move(dir)

func _move(dir: Vector2):
	global_position += dir * tile_size
	$Sprite2D.global_position -=dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($Sprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

# Proccesses every frame
func _process(delta: float) -> void:
	# Checks if "r" is pressed
	if Input.is_key_pressed(KEY_R):
		Levels.reset_level()



func kill() -> void:
	print("Killed")
	return
