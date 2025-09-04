<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시: 채팅방</title>
    <%-- ... CSS 및 라이브러리 링크는 기존과 동일 ... --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chat/chat.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="top-buttons">
    <div class="circle-btn" onclick="location.href='/schedule'">
        <i class="fa-regular fa-calendar fa-xl" style="color: #ffffff;"></i>
    </div>
</div>

<div id="chatBox"></div>

<div class="input-area">
    <input type="text" id="messageInput" placeholder="채팅을 입력하세요"/>
    <button class="send-btn" onclick="sendMessage()">
        <i class="fa-regular fa-paper-plane fa-xs" style="color: #ffffff;"></i>
    </button>
</div>

<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>
<script>
    const userName = "<%= ssUserName %>";
</script>

<%-- [수정] JSP에서 사용할 사용자 정보를 JavaScript 객체로 미리 선언 --%>
<script>
    // 내 정보
    const myUser = {
        id: "<%= session.getAttribute("SS_USER_ID") %>",
        // 세션에 내 프로필 이미지 URL이 있다면 추가 (없으면 기본 이미지)
        imageUrl: "<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") != null ? session.getAttribute("SS_USER_PROFILE_IMG_URL") : "/images/noimg.png" %>"
    };

    // 상대방 정보 (Controller에서 전달받음)
    const otherUser = {
        id: "${otherUser.userId}",
        imageUrl: "${not empty otherUser.profileImageUrl ? otherUser.profileImageUrl : '/images/noimg.png'}"
    };

    const roomId = "${roomId}";
    const clientId = 'client-' + Math.random().toString(36).substring(2, 15);
    let lastMessageDate = "";
</script>

<%-- navbar.js, modal.js 등 다른 공통 스크립트 --%>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>

<script>
    // Enter 키로 메시지 전송
    document.getElementById("messageInput").addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            sendMessage();
        }
    });

    if (!roomId) {
        alert("채팅방 ID가 없습니다. 올바른 경로로 접속해 주세요.");
    }

    let stompClient = null;

    // WebSocket 연결
    function connect() {
        const socket = new SockJS("/ws-chat");
        stompClient = Stomp.over(socket);
        stompClient.debug = null; // 디버그 로그 끄기

        stompClient.connect({}, function () {
            // 1. 이전 메시지 불러오기
            fetch(`/chat/messages?roomId=${roomId}`)
                .then(res => res.json())
                .then(messages => {
                    messages.forEach(msg => {
                        appendMessage(msg); // DTO 전체를 전달
                    });
                })
                .catch(err => console.error("메시지 로딩 실패:", err))
                .finally(() => {
                    // 2. WebSocket 구독
                    stompClient.subscribe("/topic/chatroom/" + roomId, function (message) {
                        const msg = JSON.parse(message.body);

                        // 내가 보낸 메시지(myUser.id)이면 화면에 다시 그리지 않음
                        if (msg.senderId === myUser.id) return;

                        appendMessage(msg);
                    });
                });
        });
    }

    // 메시지 전송
    function sendMessage() {
        const messageInput = document.getElementById("messageInput");
        const message = messageInput.value.trim();
        if (!message) return;

        const msg = {
            roomId: roomId,
            senderId: myUser.id,
            message: message,
            clientId: clientId
        };

        // 내가 보낸 메시지를 화면에 즉시 표시
        appendMessage(msg);

        // 서버로 메시지 전송
        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(msg));
        messageInput.value = '';
    }

    // 메시지를 화면에 추가하는 함수
    function appendMessage(msg) {
        const chatBox = document.getElementById("chatBox");
        if (!chatBox) return;

        // msg 객체에서 필요한 정보 추출
        const senderId = msg.senderId;
        const text = msg.message;
        const time = msg.timestamp || new Date(); // timestamp가 없으면 현재 시간 사용

        const msgDate = new Date(time);
        const dateStr = msgDate.getFullYear() + "년 " + (msgDate.getMonth() + 1) + "월 " + msgDate.getDate() + "일";
        const timeStr = msgDate.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});

        if (lastMessageDate && lastMessageDate !== dateStr) {
            const dateSeparator = document.createElement("div");
            dateSeparator.className = "date-separator";

            // ✅ 기존 방식인 + 연산자를 사용합니다.
            dateSeparator.innerHTML = '<span>' + dateStr + '</span>';

            chatBox.appendChild(dateSeparator);
        }

        lastMessageDate = dateStr;

        // myUser, otherUser 객체 사용
        const isMe = (senderId === myUser.id);
        const profileImageUrl = isMe ? myUser.imageUrl : otherUser.imageUrl;

        const wrapper = document.createElement("div");
        wrapper.className = "message-wrapper " + (isMe ? "me" : "other");

        const profileImg = document.createElement("div");
        profileImg.className = "profile-img";
        const img = document.createElement("img");
        img.src = profileImageUrl;
        profileImg.appendChild(img);

        const msgContent = document.createElement("div");
        msgContent.className = "message-content";

        const messageBubble = document.createElement("div");
        messageBubble.className = "message-bubble";
        if (isMe) {
            messageBubble.style.borderRadius = '18px 2px 18px 18px';
        } else {
            messageBubble.style.borderRadius = '2px 18px 18px 18px';
        }
        messageBubble.textContent = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");

        const timeElem = document.createElement("div");
        timeElem.className = "message-time";
        timeElem.textContent = timeStr;

        msgContent.appendChild(messageBubble);
        msgContent.appendChild(timeElem);

        wrapper.appendChild(profileImg);
        wrapper.appendChild(msgContent);

        chatBox.appendChild(wrapper);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    window.onload = connect;
</script>

</body>
</html>