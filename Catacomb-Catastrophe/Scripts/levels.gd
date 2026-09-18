extends Node2D

var current_level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called upon level startup
func setup() -> void:
	MusicPlayer.play_custom_track("res://Music/Ape Escape 2 ( Panic Pyramid ) Soundtrack  OST.mp3")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when the level is cleared
func level_clear() -> void:
	$RetryButton.show()
	$NextLevelButton.show()
	print("Level Clear")
	pass

# Called upon user input
func reset_level() -> void:
	SceneManager.change_scene(get_tree().current_scene.scene_file_path)
	pass

#kills the player
func kill() -> void:
	# play death animation
	# play death sound
	reset_level()
	pass
