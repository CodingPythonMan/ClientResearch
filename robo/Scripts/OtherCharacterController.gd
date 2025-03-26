extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $AnimatedSprite2D  
@onready var tile_map_manager = get_node("../TileMap")

#var last_position = Vector2.ZERO  # 이전 위치 저장

func _ready():
	sprite.play("idle")

func _process(_delta):
	# 🔹 맵 이동 제한
	if tile_map_manager:
		position.x = clamp(position.x, tile_map_manager.map_min_x, tile_map_manager.map_max_x)
		position.y = clamp(position.y, tile_map_manager.map_min_y, tile_map_manager.map_max_y)
