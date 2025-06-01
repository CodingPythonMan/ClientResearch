extends Node

var mTilemapPath: NodePath = "../TileMapLayer"

# 내보낼 JSON 파일의 경로 (예: 프로젝트 루트에 map_data.json 생성)
@export var mOutputPath: String = "res://map_data.json"

func _ready():
	# 씬을 Play할 때만 실행 (에디터에서 _ready()가 실행되는 것을 방지)
	if Engine.is_editor_hint():
		return

	print("[ExportTileMap] 시도 중인 mTilemapPath =", mTilemapPath)
	var tm_node := get_node_or_null(mTilemapPath)
	if tm_node == null:
		push_error("[ExportTileMap] 지정한 경로에 TileMapLayer 노드가 없습니다: %s" % str(mTilemapPath))
		return

	#export_tilemap_to_json(tm_node)

func export_tilemap_to_json(tm_node: TileMapLayer):
	# ───────────────────────────────────────────────────────────────────────────
	# (1) 타일 하나의 픽셀 크기 가져오기
	var cell_size: Vector2i = tm_node.tile_set.tile_size
	# (2) 사용된 셀들의 직사각형 영역 (Rect2i) 가져오기
	var used_rect: Rect2i = tm_node.get_used_rectangle()
	#  각 요소 설명:
	#    used_rect.position => (최소 cell 좌표.x, 최소 cell 좌표.y)
	#    used_rect.size     => (가로 셀 개수, 세로 셀 개수)
	var width_in_tiles  : int = used_rect.size.x
	var height_in_tiles : int = used_rect.size.y

	# (3) JSON에 넣을 ‘맵 정보’ 딕셔너리 구성
	var map_info = {
	"origin":    { "x": used_rect.position.x, "y": used_rect.position.y },
	"size":      { "width": width_in_tiles,   "height": height_in_tiles   },
	"cell_size": { "x": cell_size.x,           "y": cell_size.y           }
	}

	# (4) 2차원 배열 0으로 초기화: height × width
	var tile_grid := []
	for y in height_in_tiles:
		var row := []
		for x in width_in_tiles:
			row.append(0)
		tile_grid.append(row)

	# (5) 실제 배치된 셀 좌표 목록 가져오기
	var used_cells: PackedVector2Array = tm_node.get_used_cells()
	for cell in used_cells:
		# cell: Vector2i 타입, 셀(격자) 좌표.
		var local_x = int(cell.x - used_rect.position.x)
		var local_y = int(cell.y - used_rect.position.y)
		if local_x >= 0 and local_x < width_in_tiles and local_y >= 0 and local_y < height_in_tiles:
			tile_grid[local_y][local_x] = 1

	# (6) 최종 JSON 오브젝트
	var final_dict = {
	"map_info": map_info,
	"tile_data": tile_grid
	}

	# (7) FileAccess를 통해 JSON 파일로 저장
	var file: FileAccess = FileAccess.open(mOutputPath, FileAccess.WRITE)
	if file == null:
		push_error("[ExportTileMap] JSON 파일을 열 수 없습니다: %s" % mOutputPath)
		return

	var json_string := JSON.stringify(final_dict, "\t")
	file.store_string(json_string)
	file.close()
	print("[ExportTileMap] 맵 데이터를 JSON으로 저장했습니다: %s" % mOutputPath)
