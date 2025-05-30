extends Node

var mClient = StreamPeerTCP.new()
var mConnected = false

var Protocol = preload("res://Addons/protobuf/Protocol.gd")

const HEADER_SIZE = 4

var mPacketBuffer = PackedByteArray()  # 클래스 변수로 선언하여 계속 누적

# 플레이어 씬을 인스턴스화하여 위치 설정
var mPlayer: Node = null

func SetPlayerNode(node) :
	mPlayer = node

func _ready():
	print("🔄 서버 연결 시도...")
	var err = mClient.connect_to_host("127.0.0.1", 1537)
	if err == OK:
		print("✅ 서버에 연결 요청 성공")
	else:
		print("❌ 연결 실패: ", err)

func _process(_delta):
	if not mConnected:
		mClient.poll()  # 연결 상태 확인
		if mClient.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			print("✅ 서버에 정상적으로 연결됨!")
			mConnected = true
			#send_multiple_data()  # 여러 개의 메시지를 서버로 전송
			var req = Protocol.CSEnterGameReq.new()
			SendPacket(req, 3)

	# 서버 응답 처리
	var recvBytes = mClient.get_available_bytes()
	if recvBytes > 0:
		var result = mClient.get_data(recvBytes)
		var err = result[0]
		var newData = result[1]
		
		if err != OK:
			print("에러 발생:", err)
			return

		mPacketBuffer.append_array(newData)
	
	while mPacketBuffer.size() >= HEADER_SIZE:  # 최소 헤더 크기 확보
		var header = mPacketBuffer.slice(0, 4)
		var packetSize = (header[1] << 8) | header[0]
		var msgID = (header[3] << 8) | header[2]
		
		var payloadSize = packetSize - HEADER_SIZE
		
		# 전체 패킷이 도착하지 않았으면 대기
		if mPacketBuffer.size() < packetSize:
			break
			
		# 헤더 제거한 페이로드
		var payload = mPacketBuffer.slice(HEADER_SIZE, packetSize)
		
		# 처리한 데이터는 버퍼에서 제거 (남은 부분만 slice)
		mPacketBuffer = mPacketBuffer.slice(packetSize, mPacketBuffer.size())
		
		var result_code = -1
		# 메시지 ID에 따른 처리
		# msg_id에 따라 메시지 클래스 생성 및 파싱 (예시)
		match msgID:
			2:
				var ack = Protocol.SCEchoAck.new()
				result_code = ack.from_bytes(payload)
				var received_text = ack.get_text()
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					print("📥 서버로부터 받은 메시지:", str(ack.get_text()))
				else:
					print("패킷 파싱 오류:", result_code)
			4:  # SC_EnterGameAck 패킷
				var ack = Protocol.SCEnterGameAck.new()
				result_code = ack.from_bytes(payload)
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					var x = ack.get_X()
					var y = ack.get_Y()
					
					if mPlayer:
						mPlayer.visible = true
						mPlayer.global_position = Vector2(x, y)
					
			5:  # SC_EnterGameNoti 패킷
				var ack = Protocol.SCEnterGameNoti.new()
				result_code = ack.from_bytes(payload)
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					var playerUID = ack.get_UniqueID()
					var x = ack.get_X()
					var y = ack.get_Y()
					var dir = ack.get_Direction()
					var isMove = ack.get_IsMove()

					var playerScene = preload("res://Scenes/OtherPlayer.tscn")
					var otherPlayer = playerScene.instantiate()
					otherPlayer.global_position = Vector2(x, y)
					otherPlayer.visible = true
					otherPlayer.mDirection = dir
					otherPlayer.mIsMoving = isMove

					if isMove:
						otherPlayer.SetWalk()
					else:
						otherPlayer.SetIdle()
					
					CharacterManager.RegisterCharacter(playerUID, otherPlayer)
					get_tree().current_scene.add_child(otherPlayer)
			7:  # SC_MoveNoti 패킷
				var noti = Protocol.SCMoveNoti.new()
				result_code = noti.from_bytes(payload)
				if result_code == Protocol.PB_ERR.NO_ERRORS:	
					var playerUID = noti.get_UniqueID()
					var x = noti.get_X()
					var y = noti.get_Y()
					
					if mPlayer and mPlayer.mUniqueID == playerUID:
						mPlayer.global_position = Vector2(x,y)
						return
						
					# 이미 등록된 캐릭터가 있는지 확인
					var otherPlayer = CharacterManager.FindCharacter(playerUID)
					if otherPlayer:
						otherPlayer.mDirection = noti.get_Direction()
						otherPlayer.mIsMoving = true
						otherPlayer.SetPosition(Vector2(x, y))
						otherPlayer.SetWalk()
					
			9:  # SC_StopNoti 패킷
				var noti = Protocol.SCStopNoti.new()
				result_code = noti.from_bytes(payload)
				if result_code == Protocol.PB_ERR.NO_ERRORS:
					var playerUID = noti.get_UniqueID()
					var x = noti.get_X()
					var y = noti.get_Y()
					
					if mPlayer and mPlayer.mUniqueID == playerUID:
						mPlayer.global_position = Vector2(x,y)
						return
					
					# 이미 등록된 캐릭터가 있는지 확인
					var otherPlayer = CharacterManager.FindCharacter(playerUID)
					if otherPlayer:
						otherPlayer.mIsMoving = false
						otherPlayer.SetPosition(Vector2(x, y))
						# 예: 정지 상태일 때 idle 애니메이션 재생 (캐릭터 노드에 해당 메서드가 있다면)
						otherPlayer.SetIdle()
			_:
				print("알 수 없는 메시지 ID:", msgID)

func SendPacket(packet : Object, messageID : int):
	# Protobuf 메시지를 직렬화하여 바이트 배열로 만듭니다.
	var message_bytes = packet.to_bytes()
	# 패킷 전체 크기는 헤더(4바이트)와 메시지 크기를 합한 값입니다.
	var packet_size = message_bytes.size() + HEADER_SIZE

	# PacketHeader를 위한 PoolByteArray 생성 (2바이트 크기 정보, 2바이트 프로토콜 ID)
	var header = PackedByteArray()
	header.resize(4)

	header[0] = packet_size & 0xFF
	header[1] = (packet_size >> 8) & 0xFF

	header[2] = messageID & 0xFF
	header[3] = (messageID >> 8) & 0xFF

	# 전체 패킷: 헤더 + 메시지 데이터
	var full_packet = header + message_bytes
	mClient.put_data(full_packet)
