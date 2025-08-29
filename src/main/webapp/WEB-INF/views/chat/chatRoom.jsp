<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시: 채팅방</title>

    <%-- 모달 css --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <%-- 네브바 css --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navBar.css"/>
    <%-- 채팅방 css --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chat/chat.css"/>
    <%-- js --%>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <%-- 웹소캣 관련 js --%>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <%-- 무료 아이콘 --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
</head>
<body>
<%@ include file="../includes/header.jsp"%>

<!-- 상단 버튼 -->
<div class="top-buttons">
    <div class="circle-btn" onclick="location.href='/schedule'">
        <i class="fa-regular fa-calendar fa-xl" style="color: #ffffff;"></i>
    </div>
</div>

<!-- 채팅 영역 -->
<div id="chatBox"></div>

<!-- 입력 영역 -->
<div class="input-area">
    <input type="text" id="messageInput" placeholder="채팅을 입력하세요" />
    <button class="send-btn" onclick="sendMessage()">
        <i class="fa-regular fa-paper-plane fa-xs" style="color: #ffffff;"></i>
    </button>
</div>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp"%>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>
<script>
    const userName = "<%= ssUserName %>";
</script>

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>

<script>
    const roomId = "${roomId}";
    const userId = "<%= session.getAttribute("SS_USER_ID") %>";
    const clientId = 'client-' + Math.random().toString(36).substring(2, 15);  // 고유 식별자
    let lastMessageDate = "";

    document.getElementById("messageInput").addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            sendMessage();
        }
    });

    if (!roomId) {
        alert("채팅방 ID가 없습니다. 올바른 경로로 접속해 주세요.");
        throw new Error("roomId is null or undefined");
    }

    let stompClient = null;

    function connect() {
        const socket = new SockJS("/ws-chat");
        stompClient = Stomp.over(socket);

        stompClient.debug = function (str) {
            console.log('[STOMP DEBUG]', str);
        };

        stompClient.connect({}, function () {

            // 1. 이전 메시지 불러오기
            fetch(`/chat/messages?roomId=${roomId}`)
                .then(res => res.json())
                .then(messages => {
                    messages.forEach(msg => {
                        appendMessage(msg.senderId, msg.message, msg.timestamp || new Date());
                    });
                })
                .catch(err => console.error("메시지 로딩 실패:", err))
                .finally(() => {
                    // 2. WebSocket 구독
                    stompClient.subscribe("/topic/chatroom/" + roomId, function (message) {
                        console.log("📥 수신:", message.body);
                        try {
                            const msg = JSON.parse(message.body);

                            console.log("appendMessage 호출 sender:", msg.senderId);  // 여기에 추가

                            // 🔒 같은 브라우저(탭)에서 보낸 메시지면 무시
                            if (msg.clientId === clientId) {
                                console.log("⚠️ 같은 클라이언트에서 보낸 메시지 무시됨");
                                return;
                            }

                            appendMessage(msg.senderId, msg.message, msg.timestamp || msg.sentAt || new Date());
                        } catch (e) {
                            console.error("❌ JSON 파싱 에러:", e);
                        }
                    });
                });
        });
    }

    function sendMessage() {
        const messageInput = document.getElementById("messageInput");
        const message = messageInput.value.trim();
        if (!message) return;

        const msg = {
            roomId: roomId,
            senderId: userId,
            message: message,
            timestamp: new Date().toISOString(),
            clientId: clientId  // ✅ clientId 포함
        };
        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(msg));
        messageInput.value = '';
    }

    function appendMessage(sender, text, time) {
        const chatBox = document.getElementById("chatBox");
        if (!chatBox) return;

        const msgDate = new Date(time);
        const dateStr = msgDate.getFullYear() + "년 " + (msgDate.getMonth() + 1) + "월 " + msgDate.getDate() + "일";
        const timeStr = msgDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        if (lastMessageDate !== dateStr) {
            const dateSeparator = document.createElement("div");
            dateSeparator.className = "date-separator";
            dateSeparator.innerHTML = `<span>${dateStr}</span>`;
            chatBox.appendChild(dateSeparator);
            lastMessageDate = dateStr;
        }
        console.log("fetch 시작, userId:", sender);
        console.log("fetch URL: /user/profile-image/" + sender);
        // 💡 프로필 이미지 URL 비동기 조회
        fetch("/user/profile-image/" + sender)
        fetch("/user/profile-image/" + sender)
            .then(res => {
                console.log("fetch 응답 상태:", res.status, res.statusText);
                if (!res.ok) {
                    throw new Error("네트워크 응답 상태가 정상적이지 않음: " + res.status);
                }
                return res.json();
            })
            .then(data => {
                console.log("fetch 응답 데이터:", data);

                const imageUrl = data.imageUrl || '/images/noimg.png';

                const wrapper = document.createElement("div");
                wrapper.className = "message-wrapper " + (sender === userId ? "me" : "other");

                const profileImg = document.createElement("div");
                profileImg.className = "profile-img";

                const img = document.createElement("img");
                img.src = imageUrl;
                img.alt = "profile";
                profileImg.appendChild(img);

                console.log(`이미지 url : ${imageUrl}`);

                const msgContent = document.createElement("div");
                msgContent.className = "message-content";

                const senderElem = document.createElement("div");
                senderElem.className = "sender-id";
                senderElem.textContent = sender;

                const messageBubble = document.createElement("div");
                messageBubble.className = "message-bubble";

                const safeText = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");
                messageBubble.textContent = safeText;

                const timeElem = document.createElement("div");
                timeElem.className = "message-time";
                timeElem.textContent = timeStr;

                msgContent.appendChild(senderElem);
                msgContent.appendChild(messageBubble);
                msgContent.appendChild(timeElem);

                wrapper.appendChild(profileImg);
                wrapper.appendChild(msgContent);

                chatBox.appendChild(wrapper);
                chatBox.scrollTop = chatBox.scrollHeight;
            })
            .catch(err => {
                console.error("프로필 이미지 불러오기 실패:", err);
            });
    }

    window.onload = connect;
</script>

</body>
</html>
