extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D  
@onready var tile_map_manager = get_node("../TileMap")

#var last_position = Vector2.ZERO  # 이전 위치 저장

func _ready():
	if tile_map_manager:
		tile_map_manager.calculate_map_boundaries()

func _process(_delta):
	var move_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_vector.x += 1
		sprite.flip_h = false
		sprite.play("walk")
	elif Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_vector.x -= 1
		sprite.flip_h = true
		sprite.play("walk")

	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		move_vector.y -= 1
		sprite.play("walk")
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		move_vector.y += 1
		sprite.play("walk")

	if move_vector == Vector2.ZERO:
		sprite.play("idle")

	move_vector = move_vector.normalized() * speed
	velocity = move_vector
	move_and_slide()
	
	#if position != last_position:
	#	print("(X, Y) Pos : (%.2f, %.2f)" % [position.x, position.y])
	#	last_position = position  # 이전 위치 업데이트

	# 🔹 맵 이동 제한
	if tile_map_manager:
		position.x = clamp(position.x, tile_map_manager.map_min_x, tile_map_manager.map_max_x)
		position.y = clamp(position.y, tile_map_manager.map_min_y, tile_map_manager.map_max_y)
