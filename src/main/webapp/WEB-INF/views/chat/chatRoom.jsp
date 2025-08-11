<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>채팅방</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chat/chat.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
</head>
<body>

<%-- 헤더, 메뉴 부분은 그대로 유지 --%>
<header>
    ...
</header>

<!-- 채팅 영역 -->
<div id="chatBox"></div>

<!-- 입력 영역 -->
<div class="input-area">
    <input type="text" id="messageInput" placeholder="채팅을 입력하세요" />
    <button class="send-btn" onclick="sendMessage()">
        <i class="fa-regular fa-paper-plane fa-xs" style="color: #ffffff;"></i>
    </button>
</div>

<!-- 모달 영역 -->
<div id="customAlertOverlay" class="modal-overlay" style="display: none;">
    ...
</div>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>
<script>
    const userName = "<%= ssUserName %>";
    const roomId = "${roomId}";
    const userId = "<%= session.getAttribute("SS_USER_ID") %>";
    let lastMessageDate = "";
    let chatBox = null;
    let stompClient = null;

    $(document).ready(function () {
        chatBox = document.getElementById("chatBox");

        // Enter 키로 전송
        $("#messageInput").on("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
                sendMessage();
            }
        });

        // 로그아웃
        $("#logout").on("click", function () {
            showCustomAlert("로그아웃 하시겠습니까?", function () {
                $.ajax({
                    url: "/user/logout",
                    type: "GET",
                    dataType: "json",
                    success: function (res) {
                        if (res.result === 1) {
                            location.href = "/user/main";
                        } else {
                            showCustomAlert("실패: " + res.msg);
                        }
                    },
                    error: function () {
                        showCustomAlert("서버 통신 중 오류가 발생했습니다.");
                    }
                });
            });
        });

        if (!roomId) {
            alert("채팅방 ID가 없습니다. 올바른 경로로 접속해 주세요.");
            throw new Error("roomId is null or undefined");
        }

        connect();
    });

    function connect() {
        const socket = new SockJS("/ws-chat");
        stompClient = Stomp.over(socket);

        stompClient.connect({}, function () {
            stompClient.subscribe("/topic/chatroom/" + roomId, function (message) {
                console.log("📥 수신:", message.body);

                try {
                    const msg = JSON.parse(message.body);
                    console.log("✅ appendMessage 호출:", msg);
                    appendMessage(msg.senderId, msg.message, msg.timestamp || msg.sentAt || new Date());
                } catch (e) {
                    console.error("❌ JSON 파싱 에러:", e);
                }
            });

            // 이전 메시지 불러오기
            fetch(`/chat/messages?roomId=${roomId}`)
                .then(res => res.json())
                .then(messages => {
                    messages.forEach(msg => {
                        appendMessage(msg.senderId, msg.message, msg.timestamp || new Date());
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
            timestamp: new Date().toISOString()
        };
        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(msg));
        messageInput.value = '';
    }

    function appendMessage(sender, text, time) {
        console.log("📌 appendMessage 실행됨", { sender, text, time });
        console.log("sender:", sender, "| userId:", userId);

        if (!chatBox) {
            console.error("❌ chatBox 요소를 찾을 수 없습니다.");
            return;
        }

        const msgDate = new Date(time);
        const dateStr = `${msgDate.getFullYear()}년 ${msgDate.getMonth() + 1}월 ${msgDate.getDate()}일`;
        const timeStr = msgDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        if (lastMessageDate !== dateStr) {
            const dateSeparator = document.createElement("div");
            dateSeparator.className = "date-separator";
            dateSeparator.innerHTML = `<span>${dateStr}</span>`;
            chatBox.appendChild(dateSeparator);
            lastMessageDate = dateStr;
        }

        const wrapper = document.createElement("div");
        wrapper.className = "message-wrapper " + (String(sender) === String(userId) ? "me" : "other");

        const profileImg = document.createElement("div");
        profileImg.className = "profile-img";

        const msgContent = document.createElement("div");
        msgContent.className = "message-content";

        const senderElem = document.createElement("div");
        senderElem.className = "sender-id";
        senderElem.textContent = sender;

        const messageBubble = document.createElement("div");
        messageBubble.className = "message-bubble";
        messageBubble.textContent = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");

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
    }
</script>

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>

</body>
</html>
