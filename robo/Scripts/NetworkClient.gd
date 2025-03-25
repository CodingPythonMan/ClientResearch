extends Node

const Protocol = preload("res://Addons/protobuf/Protocol.gd")

var client = StreamPeerTCP.new()
var connected = false
var test_messages = ["Hello 1", "Hello 2", "Hello 3", "Hello 4", "Hello 5"]

var packetBuffer = PackedByteArray()  # 클래스 변수로 선언하여 계속 누적

func _ready():
	print("🔄 서버 연결 시도...")
	var err = client.connect_to_host("127.0.0.1", 1537)
	if err == OK:
		print("✅ 서버에 연결 요청 성공")
	else:
		print("❌ 연결 실패: ", err)

func _process(_delta):
	if not connected:
		client.poll()  # 연결 상태 확인
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			print("✅ 서버에 정상적으로 연결됨!")
			connected = true
			send_multiple_data()  # 여러 개의 메시지를 서버로 전송
			#var req = Protocol.CSEnterGameReq.new()
			#SendPacket(req, 3)

	# 서버 응답 처리
	var recvBytes = client.get_available_bytes()
	if recvBytes > 0:
		var newData: PackedByteArray = client.get_partial_data(recvBytes)
		packetBuffer.append_array(newData)
	
	while packetBuffer.size() >= 4:  # 최소 헤더 크기 확보
		# 헤더 4바이트 읽기: 앞의 2바이트는 data 사이즈, 뒤의 2바이트는 메시지 ID (리틀 엔디안 가정)
		var header = slicePackedArray(packetBuffer, 0, 4)
		var size_val = int(header[0]) | (int(header[1]) << 8)
		var msg_id = int(header[2]) | (int(header[3]) << 8)
		# 전체 패킷 크기 = 헤더(4바이트) + data 사이즈(size_val)
		var full_packet_size = 4 + size_val
		
		# 전체 패킷이 도착하지 않았으면 대기
		if packetBuffer.size() < full_packet_size:
			break
			
		# 헤더 제거
		packetBuffer = slicePackedArray(packetBuffer, 4, packetBuffer.size() - 4)
		# 데이터 읽기 (size_val 만큼)
		var data = slicePackedArray(packetBuffer, 0, size_val)
		# 읽은 데이터 제거
		packetBuffer = slicePackedArray(packetBuffer, size_val, packetBuffer.size() - size_val)
		
		var result_code = -1
		# 메시지 ID에 따른 처리

		# msg_id에 따라 메시지 클래스 생성 및 파싱 (예시)
		match msg_id:
			2:
				var ack = Protocol.SCEchoAck.new()
				result_code = ack.from_bytes(data)
				var received_text = ack.get_text()
				print("받은 문자열 타입:", typeof(received_text))
				print("받은 문자열 길이:", received_text.length())
				print("받은 문자열 내용:", received_text)
				
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					print("📥 서버로부터 받은 메시지:", str(ack.get_text()))
				else:
					print("패킷 파싱 오류:", result_code)
			4:  # EnterGame 패킷
				var ack = Protocol.SCEnterGameAck.new()
				result_code = ack.from_bytes(data)
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					var x = ack.get_X()
					var y = ack.get_Y()
					print("EnterGame 패킷 수신됨, 좌표:(%d, %d)" % [x, y])
					# 플레이어 씬을 인스턴스화하여 위치 설정
					var player_scene = preload("res://Scenes/Player.tscn")
					var player_instance = player_scene.instantiate()
					player_instance.position = Vector2(x, y)
					player_instance.z_index = 2  # 원하는 값으로 z index 조정
					player_instance.set_process_input(false)  # 키보드 입력 비활성화
					# 예를 들어, 현재 씬의 하위 노드로 추가
					add_child(player_instance)
				else:
					print("패킷 파싱 오류:", result_code)
			_:
				print("알 수 없는 메시지 ID:", msg_id)
				
func slicePackedArray(packedArray: PackedByteArray, start: int, length: int) -> PackedByteArray:
	var result = PackedByteArray()
	for i in range(start, start + length):
		result.append(packedArray[i])
	return result

func SendPacket(packet : Object, messageID : int):
	# Protobuf 메시지를 직렬화하여 바이트 배열로 만듭니다.
	var message_bytes = packet.to_bytes()
	# 패킷 전체 크기는 헤더(4바이트)와 메시지 크기를 합한 값입니다.
	var packet_size = message_bytes.size() + 4

	# PacketHeader를 위한 PoolByteArray 생성 (2바이트 크기 정보, 2바이트 프로토콜 ID)
	var header = PackedByteArray()
	header.resize(4)

	header[0] = packet_size & 0xFF
	header[1] = (packet_size >> 8) & 0xFF

	header[2] = messageID & 0xFF
	header[3] = (messageID >> 8) & 0xFF

	# 전체 패킷: 헤더 + 메시지 데이터
	var full_packet = header + message_bytes
	client.put_data(full_packet)

# 여러 개의 메시지를 서버로 전송하는 함수
func send_multiple_data():
	for msg in test_messages:
		var req = Protocol.CSEchoReq.new()
		req.set_text(msg)
		
		SendPacket(req, 1);
		
		await get_tree().create_timer(0.5).timeout  # 0.5초 간격으로 전송 (서버 부하 방지)
