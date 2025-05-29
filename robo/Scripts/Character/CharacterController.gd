extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D  
@onready var tile_map_manager = get_node("../TileMap")
var Protocol = preload("res://Addons/protobuf/Protocol.gd")

var mUniqueID : int = 0
var mLastPosition = Vector2.ZERO
var mIsMoving := false
var mLastMoveDirection := Vector2.ZERO

func _ready():
	if tile_map_manager:
		tile_map_manager.CalculateMapBoundaries()
	NetworkClient.SetPlayerNode(self)

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

	# 👉 이동 방향 변경 감지 시 패킷 전송
	var dirNormalized = move_vector.normalized()

	if dirNormalized != mLastMoveDirection:
		mLastMoveDirection = dirNormalized

		if dirNormalized != Vector2.ZERO:
			SendMovePacket(dirNormalized)
			mIsMoving = true
		elif mIsMoving == false:
			SendStopPacket()
			mIsMoving = false

func SendMovePacket(pos: Vector2):
	var req = Protocol.CSMoveReq.new()
	
	# 👉 Vector2 → 방향 int
	var dir = GetDirectionFromVector(pos)
	req.set_Direction(dir)
	
	if NetworkClient:  # NetworkClient는 Autoload로 등록되어 있다고 가정
		NetworkClient.SendPacket(req, 6)

func SendStopPacket():
	var req = Protocol.CSStopReq.new()

	if NetworkClient:  # NetworkClient는 Autoload로 등록되어 있다고 가정
		NetworkClient.SendPacket(req, 8)
		
func GetDirectionFromVector(vec: Vector2) -> int:
	var angle = vec.angle()

	# 각도 기준을 8방향으로 나눔 (시계방향, 0이 오른쪽)
	if angle >= -PI * 1/8 and angle < PI * 1/8:
		return 4  # RR
	elif angle >= PI * 1/8 and angle < PI * 3/8:
		return 5  # RD
	elif angle >= PI * 3/8 and angle < PI * 5/8:
		return 6  # DD
	elif angle >= PI * 5/8 and angle < PI * 7/8:
		return 7  # LD
	elif angle >= PI * 7/8 or angle < -PI * 7/8:
		return 0  # LL
	elif angle >= -PI * 7/8 and angle < -PI * 5/8:
		return 1  # LU
	elif angle >= -PI * 5/8 and angle < -PI * 3/8:
		return 2  # UU
	elif angle >= -PI * 3/8 and angle < -PI * 1/8:
		return 3  # RU

	return 4  # 기본값: RR
