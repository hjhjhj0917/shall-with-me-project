<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>채팅방</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navBar.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        body {
            /*background-image: url("../images/kpaas-background.png");*/
        }

        /* 상단 버튼 */
        .top-buttons {
            position: absolute;
            top: 180px;
            left: 100px;
            display: flex;
            gap: 15px;
        }
        .circle-btn {
            width: 55px;
            height: 55px;
            border-radius: 50%;
            background-color: #e6f0ff;
            border: 2px solid #3399ff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 13px;
            font-weight: bold;
            color: #000;
            text-align: center;
            transition: all 0.2s ease;
        }
        .circle-btn:hover {
            background-color: #d0e3ff;
            transform: scale(1.05);
        }

        /* 채팅 박스 */
        #chatBox {
            max-width: 650px;
            margin: 20px auto;
            margin-top: 100px;
            height: 500px;
            overflow-y: auto;
            padding: 15px;
            display: flex;
            flex-direction: column;
            gap: 15px;
            border-radius: 15px;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        #chatBox::-webkit-scrollbar { display: none; }

        /* 날짜 구분선 */
        .date-separator {
            display: flex;
            align-items: center;
            color: #888;
            font-size: 12px;
            margin: 10px 0;
        }
        .date-separator::before,
        .date-separator::after {
            content: "";
            flex: 1;
            height: 1px;
            background-color: #ccc;
        }
        .date-separator span {
            margin: 0 10px;
            white-space: nowrap;
        }

        /* 메시지 래퍼 */
        .message-wrapper {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            animation: fadeIn 0.2s ease;
        }
        .message-wrapper.me {
            flex-direction: row-reverse;
        }

        .profile-img {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background-color: #ccc;
            flex-shrink: 0;
        }

        /* 아이디 + 말풍선 컨테이너 */
        .message-content {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
        }
        .message-wrapper.me .message-content { align-items: flex-end; }

        /* 아이디 */
        .sender-id {
            font-size: 12px;
            color: black;
            margin-bottom: 2px;
        }

        /* 말풍선 */
        .message-bubble {
            padding: 10px 14px;
            border-radius: 18px;
            max-width: 70%;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            position: relative;
            white-space: pre-wrap;
            overflow-wrap: break-word;
            word-break: break-word;
        }
        .message-bubble.long-text { white-space: normal; }
        .message-wrapper.me .message-bubble { background-color: #e0f7fa; }
        .message-wrapper.other .message-bubble { background-color: #f1f1f1; }

        /* 시간 표시 */
        .message-time {
            font-size: 10px;
            color: gray;
            margin-top: 2px;
        }

        /* 입력 영역 */
        .input-area {
            max-width: 650px;
            margin: 10px auto 30px;
            display: flex;
            gap: 10px;
            padding: 12px;
            border-radius: 30px;
            border: 1px solid #3399ff;
            background-color: #fff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        .input-area input {
            flex: 1;
            padding: 12px 16px;
            border: none;
            outline: none;
            font-size: 14px;
        }
        .send-btn {
            background-color: #3399ff;
            color: #fff;
            border: none;
            width: 42px;
            height: 42px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
            transition: all 0.2s ease;
        }
        .send-btn:hover {
            background-color: #2b88e6;
            transform: scale(1.05);
        }

        /* 애니메이션 */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
<header>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <i class="fa-solid fa-people-roof fa-xs" style="color: #3399ff;"></i>
        </div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span>
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span>
            <span class="user-name-text" id="userNameText">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span>
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<!-- 상단 버튼 -->
<div class="top-buttons">
    <div class="circle-btn" onclick="location.href='/chat/list'">목록</div>
    <div class="circle-btn" onclick="location.href='/schedule'">일정</div>
</div>

<!-- 채팅 영역 -->
<div id="chatBox"></div>

<!-- 입력 영역 -->
<div class="input-area">
    <input type="text" id="messageInput" placeholder="채팅을 입력하세요" />
    <button class="send-btn" onclick="sendMessage()">↵</button>
</div>

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

<script>
    const roomId = "${roomId}";
    const userId = "<%= session.getAttribute("SS_USER_ID") %>";
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

        stompClient.connect({}, function () {
            stompClient.subscribe("/topic/chatroom/" + roomId, function (message) {
                const msg = JSON.parse(message.body);
                appendMessage(msg.senderId, msg.message, msg.timestamp || new Date());
            });

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
        const chatBox = document.getElementById("chatBox");
        const msgDate = new Date(time);
        const dateStr = msgDate.getFullYear() + "년 " + (msgDate.getMonth() + 1) + "월 " + msgDate.getDate() + "일";
        const timeStr = msgDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        // 날짜 변경 시 구분선 추가
        if (lastMessageDate !== dateStr) {
            const dateSeparator = document.createElement("div");
            dateSeparator.className = "date-separator";
            dateSeparator.innerHTML = `<span>${dateStr}</span>`;
            chatBox.appendChild(dateSeparator);
            lastMessageDate = dateStr;
        }

        const wrapper = document.createElement("div");
        wrapper.className = "message-wrapper " + (sender === userId ? "me" : "other");

        const profileImg = document.createElement("div");
        profileImg.className = "profile-img";

        const msgContent = document.createElement("div");
        msgContent.className = "message-content";

        const senderElem = document.createElement("div");
        senderElem.className = "sender-id";
        senderElem.textContent = sender;

        const messageBubble = document.createElement("div");
        messageBubble.className = "message-bubble";
        if (text.length >= 20) {
            messageBubble.classList.add("long-text");
        }
        messageBubble.textContent = text;

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

    window.onload = connect;
</script>

</body>
</html>
