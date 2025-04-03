extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D  
@onready var tile_map_manager = get_node("../TileMap")

var mUniqueID : int = 0
var mLastPosition = Vector2.ZERO
var mIsMoving := false
var mLastMoveDirection := Vector2.ZERO

func _ready():
	if tile_map_manager:
		tile_map_manager.calculate_map_boundaries()

func _process(delta):
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
		mIsMoving = false
		sprite.play("idle")

	# 실제 이동 처리
	move_vector = move_vector.normalized() * speed
	velocity = move_vector
	move_and_slide()

	# 맵 경계 제한
	if tile_map_manager:
		position.x = clamp(position.x, tile_map_manager.map_min_x, tile_map_manager.map_max_x)
		position.y = clamp(position.y, tile_map_manager.map_min_y, tile_map_manager.map_max_y)

	# 👉 이동 방향 변경 감지 시 패킷 전송
	var dirNormalized = move_vector.normalized()

	if dirNormalized != mLastMoveDirection:
		mLastMoveDirection = dirNormalized

		if dirNormalized != Vector2.ZERO:
			sendMovePacket(dirNormalized)
			mIsMoving = true
		elif mIsMoving == false:
			sendStopPacket()
			mIsMoving = false

func sendMovePacket(pos: Vector2):
	var req = Protocol.CSMoveReq.new()
	
	if NetworkClient:  # NetworkClient는 Autoload로 등록되어 있다고 가정
		NetworkClient.sendPacket(req)

func sendStopPacket():
	var req = Protocol.CSStopReq.new()

	if NetworkClient:  # NetworkClient는 Autoload로 등록되어 있다고 가정
		NetworkClient.sendPacket(req)
