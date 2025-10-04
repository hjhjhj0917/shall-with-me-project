<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시: 채팅방</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chat/chat.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <style>
        /* chat.css 파일에 추가 */

        /* 일정 요청 카드 스타일 */
        .message-bubble.schedule-request {
            background-color: white;
            padding: 16px;
            width: 280px; /* 너비 고정 */
        }

        .schedule-request-title {
            font-weight: 600;
            margin-bottom: 12px;
            color: #495057;
        }

        .schedule-request-info {
            font-size: 1rem;
            margin-bottom: 12px;
        }

        .schedule-request-details {
            list-style: none;
            padding: 0;
            margin: 0 0 16px 0;
            font-size: 0.85rem;
            color: #6c757d;
        }

        .schedule-request-details li {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 4px;
        }

        .schedule-request-actions {
            display: flex;
            gap: 8px;
            margin-top: 12px;
            border-top: 1px solid #e9ecef;
            padding-top: 12px;
        }

        .schedule-btn {
            flex: 1;
            padding: 8px 12px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .schedule-btn.accept {
            background-color: #3399ff;
            color: white;
        }

        .schedule-btn.accept:hover {
            background-color: #2d8ae6;
        }

        .schedule-btn.reject {
            background-color: #e9ecef;
            color: #495057;
        }

        .schedule-btn.reject:hover {
            background-color: #dee2e6;
        }

        .action-completed-text {
            color: #495057;
            font-weight: 500;
            font-size: 0.9rem;
        }

        /* 시스템 메시지 스타일 */
        .system-message {
            text-align: center;
            margin: 16px 0;
            color: #868e96;
            font-size: 0.8rem;
            background-color: #f1f3f5;
            padding: 4px 12px;
            border-radius: 12px;
            display: inline-block;
            left: 50%;
            position: relative;
            transform: translateX(-50%);
        }

        .date-separator {
            color: #5f6f84;
            font-size: 15px;
        }

        #messageInput:disabled {
            background-color: #ffffff;
            caret-color: transparent;
        }
    </style>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="top-buttons">
    <div class="circle-btn" id="scheduleBtn">
        <i class="fa-solid fa-calendar-days fa-xl" style="color: #3399ff;"></i>
    </div>
    <span class="btn-diary">일정</span>
</div>

<div id="chatBox"></div>

<div class="input-area">
    <input type="text" id="messageInput" placeholder="채팅을 입력하세요"/>
    <button class="send-btn" onclick="sendMessage()">
        <i class="fa-regular fa-paper-plane fa-xs" style="color: #ffffff;"></i>
    </button>
</div>

<%-- 챗봇 --%>
<%@ include file="../includes/chatbot.jsp" %>
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

<script>
    // 내 정보
    const myUser = {
        id: "<%= session.getAttribute("SS_USER_ID") %>",
        imageUrl: "<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") != null ? session.getAttribute("SS_USER_PROFILE_IMG_URL") : "/images/noimg.png" %>"
    };

    // 상대방 정보
    const otherUser = {
        id: "${otherUser.userId}",
        imageUrl: "${not empty otherUser.profileImageUrl ? otherUser.profileImageUrl : '/images/noimg.png'}",
        otherName: "${otherUser.userName}",
        status: "${otherUser.status}"
    };

    const roomId = "${roomId}";
    let stompClient = null;
    let lastMessageDate = "";

    // Enter 키로 메시지 전송
    document.getElementById("messageInput").addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            sendMessage();
        }
    });

    // WebSocket 연결
    function connect() {
        if (!roomId) {
            showCustomAlert("채팅방 ID가 없습니다. 올바른 경로로 접속해 주세요.");
            return;
        }
        const socket = new SockJS("/ws-chat");
        stompClient = Stomp.over(socket);
        stompClient.debug = null;

        stompClient.connect({}, function () {
            // 1. 이전 메시지 불러오기
            fetch(`/chat/messages?roomId=${roomId}`)
                .then(res => res.json())
                .then(messages => {
                    messages.forEach(msg => {
                        // --- 이 부분이 추가/수정되었습니다 ---
                        if (msg.messageType === 'SCHEDULE_REQUEST') {
                            renderScheduleRequest(msg); // 과거의 일정 요청도 올바르게 렌더링
                        } else if (msg.messageType === 'SCHEDULE_CONFIRMED' || msg.messageType === 'SCHEDULE_REJECTED') {
                            renderSystemMessage(msg.message); // 과거의 시스템 알림도 올바르게 렌더링
                        } else {
                            appendMessage(msg); // 과거의 일반 메시지
                        }
                    });
                    const chatBox = document.getElementById("chatBox");
                    chatBox.scrollTop = chatBox.scrollHeight;
                });

            // 2. WebSocket 구독
            stompClient.subscribe("/topic/chatroom/" + roomId, function (message) {
                const msg = JSON.parse(message.body);

                console.log("서버로부터 받은 메시지:", msg);

                if (msg.senderId === myUser.id) {
                    console.log("내가 보낸 메시지를 서버로부터 수신했으므로 무시합니다.");
                    return;
                }

                if (msg.messageType === 'SCHEDULE_REQUEST') {
                    renderScheduleRequest(msg);
                } else if (msg.messageType === 'SCHEDULE_CONFIRMED' || msg.messageType === 'SCHEDULE_REJECTED') {
                    renderSystemMessage(msg.message);
                } else {
                    appendMessage(msg);
                }
            });
        });
    }

    // 메시지 전송
    function sendMessage() {
        const messageInput = document.getElementById("messageInput");
        const message = messageInput.value.trim();

        if (otherUser.status === 'DEACTIVATED') {
            showCustomAlert("탈퇴한 회원입니다. 채팅할 수 없습니다.");
            messageInput.disabled = true;
            messageInput.value = '';
            document.querySelector(".send-btn").disabled = true;
            return;
        }

        if (!message) return;

        const msg = {
            roomId: roomId,
            senderId: myUser.id,
            message: message,
            sentAt: new Date().toISOString()
        };
        appendMessage(msg); // 내가 보낸 메시지 즉시 표시
        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(msg));
        messageInput.value = '';
    }

    // 일반 메시지를 화면에 추가하는 함수
    function appendMessage(msg) {
        const chatBox = document.getElementById("chatBox");
        if (!chatBox) return;

        let sentAtStr = msg.sentAt;
        if (sentAtStr) sentAtStr = sentAtStr.replace('T', ' ');

        const senderId = msg.senderId;
        const text = msg.message;
        const time = sentAtStr ? new Date(sentAtStr) : new Date();
        const msgDate = new Date(time);
        const dateStr = msgDate.getFullYear() + "년 " + (msgDate.getMonth() + 1) + "월 " + msgDate.getDate() + "일";
        const timeStr = msgDate.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});

        if (lastMessageDate !== dateStr) {
            const dateSeparator = document.createElement("div");
            dateSeparator.className = "date-separator";
            dateSeparator.textContent = dateStr;
            chatBox.appendChild(dateSeparator);
        }
        lastMessageDate = dateStr;

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

        if (!isMe) {
            const senderNameElem = document.createElement("div");
            senderNameElem.className = "sender-name";
            senderNameElem.textContent = otherUser.otherName;
            msgContent.appendChild(senderNameElem);
        }

        const bubbleWrapper = document.createElement("div");
        bubbleWrapper.className = "bubble-wrapper";

        const messageBubble = document.createElement("div");
        messageBubble.className = "message-bubble";
        if (isMe) {
            messageBubble.style.borderRadius = '18px 2px 18px 18px';
        } else {
            messageBubble.style.borderRadius = '2px 18px 18px 18px';
        }
        messageBubble.textContent = text ? text.replace(/</g, "&lt;").replace(/>/g, "&gt;") : "";

        const timeElem = document.createElement("div");
        timeElem.className = "message-time";
        timeElem.textContent = timeStr;

        if (isMe) {
            bubbleWrapper.appendChild(timeElem);
            bubbleWrapper.appendChild(messageBubble);
        } else {
            bubbleWrapper.appendChild(messageBubble);
            bubbleWrapper.appendChild(timeElem);
        }

        msgContent.appendChild(bubbleWrapper);
        wrapper.appendChild(profileImg);
        wrapper.appendChild(msgContent);
        chatBox.appendChild(wrapper);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    // 일정 '요청' UI를 렌더링하는 함수
    function renderScheduleRequest(msg) {
        const chatBox = document.getElementById("chatBox");
        const request = msg.scheduleRequest;
        if (!request) return;

        const isMe = msg.senderId === myUser.id;
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

        if (!isMe) {
            const senderNameElem = document.createElement("div");
            senderNameElem.className = "sender-name";
            senderNameElem.textContent = otherUser.otherName;
            msgContent.appendChild(senderNameElem);
        }

        const bubble = document.createElement("div");
        bubble.className = "message-bubble schedule-request";

        const scheduleDate = new Date(request.scheduleDt.replace('T', ' ')).toLocaleString('ko-KR', {
            year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'
        });

        // ✅ [수정] 일정의 'status'와 내가 보낸 요청인지('isMe')에 따라 버튼/텍스트를 다르게 설정합니다.
        let actionButtonsHTML = '';
        if (!isMe) { // 내가 요청을 받은 경우
            if (request.status === 'PENDING') {
                actionButtonsHTML =
                    '<button class="schedule-btn accept" onclick="handleScheduleAction(' + request.scheduleId + ', \'confirm\')">수락</button>' +
                    '<button class="schedule-btn reject" onclick="handleScheduleAction(' + request.scheduleId + ', \'reject\')">거절</button>';
            } else if (request.status === 'CONFIRMED') {
                actionButtonsHTML = '<span class="action-completed-text">✅ 수락됨</span>';
            } else if (request.status === 'REJECTED') {
                actionButtonsHTML = '<span class="action-completed-text">❌ 거절됨</span>';
            }
        } else { // 내가 요청을 보낸 경우
            if (request.status === 'PENDING') {
                actionButtonsHTML = '<span class="action-completed-text">상대방의 응답을 기다리는 중...</span>';
            } else if (request.status === 'CONFIRMED') {
                actionButtonsHTML = '<span class="action-completed-text">상대방이 수락했습니다.</span>';
            } else if (request.status === 'REJECTED') {
                actionButtonsHTML = '<span class="action-completed-text">상대방이 거절했습니다.</span>';
            }
        }

        bubble.innerHTML =
            '<div class="schedule-request-title">일정 조율 요청</div>' +
            '<div class="schedule-request-info"><strong>' + request.title + '</strong></div>' +
            '<ul class="schedule-request-details">' +
            '<li><i class="fa-regular fa-clock"></i> ' + scheduleDate + '</li>' +
            '<li><i class="fa-solid fa-location-dot"></i> ' + request.location + '</li>' +
            '</ul>' +
            '<div class="schedule-request-actions" id="actions-' + request.scheduleId + '">' +
            actionButtonsHTML +
            '</div>';

        msgContent.appendChild(bubble);
        wrapper.appendChild(profileImg);
        wrapper.appendChild(msgContent);
        chatBox.appendChild(wrapper);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    // 수락/거절 버튼 클릭을 처리하는 함수
    function handleScheduleAction(scheduleId, action) {

        fetch('/schedule/api/events/' + scheduleId + '/' + action, {
            method: 'POST'
        }).then(res => {
            if (res.ok) {

                const actionsDiv = document.getElementById('actions-' + scheduleId);
                if (actionsDiv) {
                    const actionText = action === 'confirm' ? '수락됨' : '거절됨';

                    actionsDiv.innerHTML = '<span class="action-completed-text">' + actionText + '</span>';
                }
            } else {
                showCustomAlert('처리 중 오류가 발생했습니다.');
            }
        });
    }

    // 시스템 알림 메시지를 렌더링하는 함수
    function renderSystemMessage(text) {
        const chatBox = document.getElementById("chatBox");
        const systemMsgDiv = document.createElement("div");
        systemMsgDiv.className = "system-message";
        systemMsgDiv.textContent = text;
        chatBox.appendChild(systemMsgDiv);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    window.onload = connect;

    $("#scheduleBtn").on("click", function () {
        if (otherUser.status === 'DEACTIVATED') {
            showCustomAlert("탈퇴한 회원입니다. 일정을 등록할 수 없습니다.");
            return;
        }
        location.href = '/schedule/scheduleReg?targetUserId=' + otherUser.id + '&roomId=' + roomId;
    });

</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>