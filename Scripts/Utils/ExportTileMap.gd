extends Node

@onready var mTileMapLayer := get_node("../TileMapLayer")

# 내보낼 JSON 파일의 경로 (예: 프로젝트 루트에 map_data.json 생성)
@export var mOutputPath: String = "res://map_data.json"

func _ready():
	# 씬을 Play할 때만 실행 (에디터에서 _ready()가 실행되는 것을 방지)
	if Engine.is_editor_hint():
		print("이게 호출될 때가 있긴 한가?")
		return

	print("TileMapLayer 노드 이름:", mTileMapLayer.name)
	if mTileMapLayer == null:
		push_error("[ExportTileMap] 지정한 경로에 TileMapLayer 노드가 없습니다: %s" % mTileMapLayer.name)
		return

	# 가끔씩 맵 업데이트 할 때마다 한번씩 주석 풀어서 맵 파일 서버쪽 풀어도 좋겠다.
	# export_tilemap_to_json(mTileMapLayer)

func export_tilemap_to_json(tm_node: TileMapLayer):
	# (1) 셀 하나의 픽셀 크기
	var cell_size : Vector2i = mTileMapLayer.tile_set.tile_size

	# (2) 사용된 모든 셀 좌표를 가져온다
	var used_cells : PackedVector2Array = mTileMapLayer.get_used_cells()
	if used_cells.is_empty():
		push_error("[ExportTileMap] 사용된 셀이 없어서 Rect 계산을 못 합니다.")
		return

	# (3) 최소/최대값 계산
	var first_cell = used_cells[0]
	var min_x = first_cell.x
	var max_x = first_cell.x
	var min_y = first_cell.y
	var max_y = first_cell.y

	for cell in used_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	# (4) origin / size 구하기
	var origin_x = int(min_x)
	var origin_y = int(min_y)
	var width_in_tiles  = int(max_x - min_x + 1)
	var height_in_tiles = int(max_y - min_y + 1)

	# (5) map_info 딕셔너리 구성
	var map_info = {
		"origin":    { "x": origin_x,    "y": origin_y },
		"size":      { "width": width_in_tiles,   "height": height_in_tiles },
		"cell_size": { "x": cell_size.x,         "y": cell_size.y }
	}

	# (6) 2D 배열 초기화 (0/1)
	var tile_grid := []
	for y in height_in_tiles:
		var row := []
		for x in width_in_tiles:
			row.append(0)
		tile_grid.append(row)

	# (7) 실제 사용된 셀들을 표시(1로 바꿈)
	for cell in used_cells:
		var local_x = int(cell.x - origin_x)
		var local_y = int(cell.y - origin_y)
		if local_x >= 0 and local_x < width_in_tiles and local_y >= 0 and local_y < height_in_tiles:
			tile_grid[local_y][local_x] = 1

	# (8) 최종 JSON 오브젝트
	var final_dict = {
		"map_info": map_info,
		"tile_data": tile_grid
	}

	# (9) FileAccess로 user://map_data.json에 저장
	var file : FileAccess = FileAccess.open(mOutputPath, FileAccess.WRITE)
	if file == null:
		push_error("[ExportTileMap] JSON 파일을 열 수 없습니다: %s" % mOutputPath)
		return

	var json_string := JSON.stringify(final_dict, "\t")
	file.store_string(json_string)
	file.close()

	print("[ExportTileMap] 맵 데이터를 JSON으로 저장했습니다:", mOutputPath)
