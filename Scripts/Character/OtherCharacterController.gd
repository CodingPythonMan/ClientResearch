extends CharacterBody2D

@export var mSpeed: float = 200.0
@onready var mSprite = $AnimatedSprite2D

var mDirection: int = 0
var mIsMoving: bool = false

func _process(delta):
	if mIsMoving:
		var velocity: Vector2 = GetDirection(mDirection) * mSpeed
		position += velocity * delta

# 서버가 보내준 위치 보정
func SetPosition(newPos: Vector2) -> void:
	position = newPos

# 로컬 입력 기반 이동 시 호출 (플레이어 직접 조작용)
func UpdateMovement(dt):
	var velocity: Vector2 = GetDirection(mDirection) * mSpeed
	position += velocity * dt
	
func SetWalk():
	if mSprite:
		mSprite.play("walk")
		
		# 👉 방향에 따라 flip_h 설정
		match mDirection:
			0, 1, 7:  # 왼쪽 관련 방향
				mSprite.flip_h = true
			3, 4, 5:  # 오른쪽 관련 방향
				mSprite.flip_h = false
		
func SetIdle():
	if mSprite:
		mSprite.play("idle")

# 8방향 처리
func GetDirection(dir: int) -> Vector2:
	match dir:
		0: return Vector2(-1, 0)            # LL
		1: return Vector2(-1, -1).normalized()
		2: return Vector2(0, -1)            # UU
		3: return Vector2(1, -1).normalized()
		4: return Vector2(1, 0)             # RR
		5: return Vector2(1, 1).normalized()
		6: return Vector2(0, 1)             # DD
		7: return Vector2(-1, 1).normalized()
		_: return Vector2.ZERO
