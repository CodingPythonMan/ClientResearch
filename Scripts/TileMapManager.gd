extends Node2D

@export var mTileSize: int = 16
@export var mMapWidth: int = 200
@export var mMapHeight: int = 200

@onready var mTileMapLayer: TileMapLayer = get_node("../TileMapLayer")  # 🔹 부모 노드에서 자동으로 `TileMap`을 찾음
@onready var mPlayer: CharacterBody2D = get_node("../Player")

var mMapMinX
var mMapMaxX
var mMapMinY
var mMapMaxY

func _ready():
	# 앱 전체의 기본 클리어 컬러를 검은색으로 설정
	RenderingServer.set_default_clear_color(Color.BLACK)
	CalculateMapBoundaries()
	SetPlayerStartPosition()

func CalculateMapBoundaries():
	mMapMinX = position.x
	mMapMaxX = position.x + (mMapWidth * mTileSize) - mTileSize
	mMapMinY = position.y
	mMapMaxY = position.y + (mMapHeight * mTileSize) - mTileSize

# 🔹 플레이어 위치를 맵 중앙에 배치
func SetPlayerStartPosition():
	var startX = float(mMapWidth * mTileSize) / 2  # 중앙 X 위치
	var startY = float(mMapHeight * mTileSize) / 2  # 중앙 Y 위치
	#mPlayer.position = Vector2(startX, startY)
	mPlayer.position = Vector2.ZERO
	print("🔹 플레이어 시작 위치:", mPlayer.position)
