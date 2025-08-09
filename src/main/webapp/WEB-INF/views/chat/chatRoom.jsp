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
    <script>
        $(document).ready(function () {


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
        });
    </script>
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
            <button class="menu-list" onclick="location.href='/chat/userListPage'">메세지</button>
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" id="logout">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

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

<div id="customAlertOverlay" class="modal-overlay" style="display: none;">
    <div class="modal">
        <div class="modal-title">
            <i class="fa-solid fa-circle-exclamation fa-shake fa-lg" style="color: #3399ff;"></i>
            <h2>살며시</h2>
        </div>
        <p id="customAlertMessage">메시지 내용</p>
        <div class="modal-buttons" style="text-align: right;">
            <button class="deactivate-btn" onclick="closeCustomAlert()">확인</button>
        </div>
    </div>
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
<script src="${pageContext.request.contextPath}/js/modal.js"></script>

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

        const safeText = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");
        messageBubble.textContent = safeText;

        // if (text.length >= 20) {
        //     messageBubble.classList.add("long-text");
        // }
        // messageBubble.textContent = text;

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
