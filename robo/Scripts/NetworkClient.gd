extends Node

const Protocol = preload("res://Addons/protobuf/Protocol.gd")

var client = StreamPeerTCP.new()
var connected = false
var test_messages = ["Hello 1", "Hello 2", "Hello 3", "Hello 4", "Hello 5"]

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

	# 서버 응답 처리
	while client.get_available_bytes() >= 4:  # 최소 헤더 크기 확보
		var size_val = client.get_u16()  # 2바이트 크기 읽기
		var msg_id = client.get_u16()    # 2바이트 메시지 ID 읽기

		# 헤더에 포함된 전체 패킷 크기가 헤더를 포함한다면:
		var data_size = size_val - 4

		# 데이터가 모두 도착했는지 확인
		if client.get_available_bytes() < data_size:
			# 데이터가 다 도착하지 않았으면 break
			break

		var data = client.get_data(data_size)
		var result_code = -1

		# msg_id에 따라 메시지 클래스 생성 및 파싱 (예시)
		match msg_id:
			2:
				var ack = Protocol.SCEchoAck.new()
				result_code = ack.from_bytes(data)
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					print("📥 서버로부터 받은 메시지:", ack.get_text())
				else:
					print("패킷 파싱 오류:", result_code)
			_:
				print("알 수 없는 메시지 ID:", msg_id)
				# 필요시 해당 데이터를 건너뛰거나 처리할 수 있음.

# 여러 개의 메시지를 서버로 전송하는 함수
func send_multiple_data():
	for msg in test_messages:
		var req = Protocol.CSEchoReq.new()
		req.set_text(msg)
		
		# Protobuf 메시지를 직렬화하여 바이트 배열로 만듭니다.
		var message_bytes = req.to_bytes()
		# 패킷 전체 크기는 헤더(4바이트)와 메시지 크기를 합한 값입니다.
		var packet_size = message_bytes.size() + 4
		# 예시로 프로토콜 ID를 1로 설정합니다.
		var protocol_id = 1

		# PacketHeader를 위한 PoolByteArray 생성 (2바이트 크기 정보, 2바이트 프로토콜 ID)
		var header = PackedByteArray()
		header.resize(4)

		header[0] = packet_size & 0xFF
		header[1] = (packet_size >> 8) & 0xFF

		header[2] = protocol_id & 0xFF
		header[3] = (protocol_id >> 8) & 0xFF

		# 전체 패킷: 헤더 + 메시지 데이터
		var full_packet = header + message_bytes
		client.put_data(full_packet)
		
		await get_tree().create_timer(0.5).timeout  # 0.5초 간격으로 전송 (서버 부하 방지)
