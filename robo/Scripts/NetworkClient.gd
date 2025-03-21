extends Node

var client = StreamPeerTCP.new()
var connected = false
var test_messages = ["Hello 1", "Hello 2", "Hello 3", "Hello 4", "Hello 5"]
var message_index = 0

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
		var data = client.get_utf8_string(packet_size)  # 해당 크기만큼 문자열 읽기
		print("📥 서버로부터 받은 메시지:", data)

func send_data(data: String):
	if connected == false:
		print("❌ 서버에 연결되지 않음. 데이터 전송 불가!")
		return

	client.put_utf8_string(data)
	print("📤 데이터 전송됨:", data)

# 여러 개의 메시지를 서버로 전송하는 함수
func send_multiple_data():
	for msg in test_messages:
		send_data(msg)
		await get_tree().create_timer(0.5).timeout  # 0.5초 간격으로 전송 (서버 부하 방지)
