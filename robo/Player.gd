extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D  
@onready var tile_map = $"../TileMap"  # TileMap 노드 경로에 맞게 수정하세요
@onready var tile_size = 16  # 타일 크기

# 🛠 정확한 타일맵 경계 계산
@onready var used_rect = tile_map.get_used_rect()
@onready var map_min_x = tile_map.position.x + (used_rect.position.x * tile_size)
@onready var map_max_x = tile_map.position.x + (used_rect.end.x * tile_size) - tile_size

@onready var map_min_y = tile_map.position.y + (used_rect.position.y * tile_size)
@onready var map_max_y = tile_map.position.y + (used_rect.end.y * tile_size) - tile_size

func _process(_delta):
	var move_vector = Vector2.ZERO
	
	# print("캐릭터 X 좌표: ", position.x)  # 🔹 현재 X 좌표를 출력
	# print("캐릭터 Y 좌표: ", position.y)  # 🔹 현재 Y 좌표를 출력
	
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

	# 🔹 경계 설정: 맵의 범위를 벗어나지 않도록 위치 제한
	position.x = clamp(position.x, map_min_x, map_max_x)
	position.y = clamp(position.y, map_min_y, map_max_y)
