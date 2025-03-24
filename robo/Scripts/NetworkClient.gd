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
	if connected == false:
		client.poll()  # 연결 상태 확인
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			print("✅ 서버에 정상적으로 연결됨!")
			connected = true
			send_multiple_data()  # ✅ 여러 개의 메시지를 서버로 전송
			
	# 서버 응답 처리
	while client.get_available_bytes() > 0:
		var packet_size = client.get_u32()  # 4바이트 길이 정보 읽기
		var data = client.get_data(packet_size)  # 해당 크기만큼 문자열 읽기
		# Create unpacked class (message)
		var ack = Protocol.SCEchoAck.new()
		# Unpack byte sequence to class (message) A.
		# Use from_bytes(PoolByteArray my_byte_sequence) method
		var result_code = ack.from_bytes(data)
		# result_code must be checked (see Unpack result codes section)
		if result_code == Protocol.PB_ERR.NO_ERRORS:
			print("OK")
		else:
			return
					
		print("📥 서버로부터 받은 메시지:", ack.get_text())

# 여러 개의 메시지를 서버로 전송하는 함수
func send_multiple_data():
	for msg in test_messages:
		var req = Protocol.CSEchoReq.new()
		req.set_text(msg)
		var packed_req = req.to_bytes()
		client.put_data(packed_req)
		
		# Protobuf 메시지를 직렬화하여 바이트 배열로 만듭니다.
		var message_bytes = req.to_bytes()
		# 패킷 전체 크기는 헤더(4바이트)와 메시지 크기를 합한 값입니다.
		var packet_size = message_bytes.size() + 4
		# 예시로 프로토콜 ID를 1로 설정합니다.
		var protocol_id = 1

		# PacketHeader를 위한 PoolByteArray 생성 (2바이트 크기 정보, 2바이트 프로토콜 ID)
		var header = PackedByteArray()
		header.resize(4)

		# 패킷 크기를 2바이트로 변환 (여기서는 Big Endian으로 처리)
		header[0] = (packet_size >> 8) & 0xFF
		header[1] = packet_size & 0xFF
		
		print("📤 header 확인:", header)

		# 프로토콜 ID도 2바이트로 변환
		header[2] = (protocol_id >> 8) & 0xFF
		header[3] = protocol_id & 0xFF
		
		print("📤 header 확인:", header)

		# 전체 패킷: 헤더 + 메시지 데이터
		var full_packet = header + message_bytes
		client.put_data(full_packet)
		print("📤 데이터 전송됨:", full_packet)
		
		await get_tree().create_timer(0.5).timeout  # 0.5초 간격으로 전송 (서버 부하 방지)
