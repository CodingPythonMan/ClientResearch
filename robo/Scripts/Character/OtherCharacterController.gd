extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D  
@onready var tile_map_manager = get_node("../TileMap")

var uniqueID: int = 0
var direction: int = 0

# 네트워크 업데이트를 위한 target_position 변수
var targetPosition: Vector2

# 로컬 이동 업데이트를 위한 변수 (예: 입력 기반 이동에 사용)
const UPDATE_INTERVAL: float = 0.02
var update_accumulator: float = 0.0

func _ready():
	sprite.play("idle")
	targetPosition = position  # 초기값 설정

func _process(delta):
	update_accumulator += delta
	if update_accumulator >= UPDATE_INTERVAL:
		# 네트워크에 의해 업데이트된 target_position으로 부드럽게 보간합니다.
		position = position.move_toward(targetPosition, speed * delta)
		update_accumulator = 0.0
	
	# 맵 경계 클램핑
	if tile_map_manager:
		position.x = clamp(position.x, tile_map_manager.map_min_x, tile_map_manager.map_max_x)
		position.y = clamp(position.y, tile_map_manager.map_min_y, tile_map_manager.map_max_y)

# 서버 패킷으로부터 전달받은 좌표를 적용할 때 호출하는 함수
func SetPosition(newPos: Vector2) -> void:
	targetPosition = newPos

# (로컬 입력 기반 이동용) 기존 UpdateMovement 함수 – 로컬 플레이어용으로 사용
func UpdateMovement(dt):
	var velocity: Vector2 = GetDirection(direction) * speed
	position += velocity * dt
	# 네트워크 업데이트 시에는 target_position과 일치하도록 할 수도 있음
	targetPosition = position

# 8방향에 따른 벡터 반환 (예시)
func GetDirection(dir: int) -> Vector2:
	match dir:
		0: return Vector2(-1, 0)           # Left
		1: return Vector2(-1, -1).normalized()  # Left-Up
		2: return Vector2(0, -1)           # Up
		3: return Vector2(1, -1).normalized()   # Right-Up
		4: return Vector2(1, 0)            # Right
		5: return Vector2(1, 1).normalized()    # Right-Down
		6: return Vector2(0, 1)            # Down
		7: return Vector2(-1, 1).normalized()   # Left-Down
		_: return Vector2.ZERO
