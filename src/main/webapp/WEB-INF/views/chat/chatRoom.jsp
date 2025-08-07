<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>채팅방</title>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
</head>
<body>

<h2>채팅방 ID: <span id="roomIdText"></span></h2>

<div id="chatBox" style="border: 1px solid #000; height: 300px; overflow-y: scroll; padding: 10px;"></div>

<input type="text" id="messageInput" placeholder="메시지를 입력하세요" />
<button onclick="sendMessage()">전송</button>

<script>
    const roomId = "${roomId}";
    const userId = "<%= session.getAttribute("SS_USER_ID") %>";

    if (!roomId) {
        alert("채팅방 ID가 없습니다. 올바른 경로로 접속해 주세요.");
        throw new Error("roomId is null or undefined");
    }

    document.getElementById("roomIdText").innerText = roomId;

    let stompClient = null;

    function connect() {
        const socket = new SockJS("/ws-chat");
        stompClient = Stomp.over(socket);

        stompClient.connect({}, function () {
            console.log("✅ WebSocket connected");

            stompClient.subscribe("/topic/chatroom/" + roomId, function (message) {
                const msg = JSON.parse(message.body);
                console.log("📩 메시지 수신:", msg);
                appendMessage(msg.senderId, msg.message);
            });

            // 이전 메시지 불러오기
            fetch(`/chat/messages?roomId=${roomId}`)
                .then(res => {
                    if (!res.ok) throw new Error("이전 메시지 불러오기 실패");
                    return res.json();
                })
                .then(messages => {
                    messages.forEach(msg => {
                        appendMessage(msg.senderId, msg.message);
                    });
                })
                .catch(err => console.error("❌ 메시지 로딩 오류:", err));
        }, function (error) {
            console.error("❌ WebSocket 연결 실패:", error);
        });
    }

    function sendMessage() {
        const messageInput = document.getElementById("messageInput");
        const message = messageInput.value.trim();

        if (!message) {
            alert("메시지를 입력하세요.");
            return;
        }

        const msg = {
            roomId: roomId,
            senderId: userId,
            message: message
        };

        console.log("📤 메시지 전송:", msg);

        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(msg));
        messageInput.value = '';
    }

    function appendMessage(sender, text) {
        console.log("📌 appendMessage 호출:", sender, text);
        console.log("📌 typeof text:", typeof text, "length:", text.length);

        const chatBox = document.getElementById("chatBox");

        const messageDiv = document.createElement("div");
        messageDiv.style.margin = "5px 0";

        // 본인이 보낸 메시지면 오른쪽 정렬
        if (sender === userId) {
            messageDiv.style.textAlign = "right";
            messageDiv.style.backgroundColor = "#e0f7fa"; // 밝은 파랑
            messageDiv.style.padding = "5px 10px";
            messageDiv.style.borderRadius = "10px";
            messageDiv.style.display = "inline-block";
            messageDiv.style.maxWidth = "70%";
            messageDiv.style.alignSelf = "flex-end";
        } else {
            messageDiv.style.textAlign = "left";
            messageDiv.style.backgroundColor = "#f1f1f1"; // 회색
            messageDiv.style.padding = "5px 10px";
            messageDiv.style.borderRadius = "10px";
            messageDiv.style.display = "inline-block";
            messageDiv.style.maxWidth = "70%";
        }

        const senderElem = document.createElement("b");
        senderElem.textContent = sender + ": ";

        const messageText = document.createTextNode(text);

        messageDiv.appendChild(senderElem);
        messageDiv.appendChild(messageText);

        // 메시지 래퍼
        const wrapper = document.createElement("div");
        wrapper.style.display = "flex";
        wrapper.style.justifyContent = sender === userId ? "flex-end" : "flex-start";
        wrapper.appendChild(messageDiv);

        chatBox.appendChild(wrapper);
        chatBox.scrollTop = chatBox.scrollHeight;
    }



    window.onload = connect;
</script>

</body>
</html>
