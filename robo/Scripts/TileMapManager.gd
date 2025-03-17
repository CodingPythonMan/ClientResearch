extends Node2D

@export var tile_size: int = 16
@export var map_width: int = 200
@export var map_height: int = 200

@onready var tile_map: TileMap = get_node("../TileMap")  # 🔹 부모 노드에서 자동으로 `TileMap`을 찾음
@onready var player: CharacterBody2D = get_node("../Player")

var map_min_x
var map_max_x
var map_min_y
var map_max_y

func _ready():
	generate_large_map()
	calculate_map_boundaries()
	set_player_start_position()

func generate_large_map():
	var tile_set = tile_map.tile_set
	var source_count = tile_set.get_source_count()

	if source_count > 0:
		var source_id = tile_set.get_source_id(0)  # 🔹 첫 번째 TileSet 소스 ID 가져오기
		var tile_source = tile_set.get_source(source_id)  # 🔹 TileSet의 소스 가져오기

		if tile_source is TileSetAtlasSource:
			var tile_count = tile_source.get_tiles_count()
			if tile_count > 0:
				print("🔹 사용 가능한 타일 개수:", tile_count)
				
				for x in range(map_width):
					for y in range(map_height):
						var tileIndex = 0  # 🔹 랜덤 타일 선택
						var atlas_coords = tile_source.get_tile_id(tileIndex)  # 🔹 사용 가능한 첫 번째 타일 ID 가져오기

						tile_map.set_cell(0, Vector2i(x, y), source_id, atlas_coords)

				# 배치된 타일 개수 확인
				var used_cells = tile_map.get_used_cells(0)  # 🔹 0번 Layer에서 사용된 타일 가져오기
				print("🔹 최종 배치된 타일 개수:", used_cells.size())

			else:
				print("⚠️ 사용 가능한 Atlas 타일이 없습니다!")

		else:
			print("⚠️ TileSource가 Atlas Tile이 아닙니다. 일반 타일로 처리해야 할 수도 있습니다!")

	else:
		print("⚠️ TileSet이 비어 있어 타일을 배치할 수 없습니다!")

func calculate_map_boundaries():
	map_min_x = position.x
	map_max_x = position.x + (map_width * tile_size) - tile_size
	map_min_y = position.y
	map_max_y = position.y + (map_height * tile_size) - tile_size

# 🔹 플레이어 위치를 맵 중앙에 배치
func set_player_start_position():
	var start_x = float(map_width * tile_size) / 2  # 중앙 X 위치
	var start_y = float(map_height * tile_size) / 2  # 중앙 Y 위치
	player.position = Vector2(start_x, start_y)
	print("🔹 플레이어 시작 위치:", player.position)
