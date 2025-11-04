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
        /* ... (CSS 스타일은 동일) ... */
        .message-bubble.schedule-request {
            background-color: white;
            padding: 16px;
            width: 280px;
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
            background-color: white;
            border-radius: 45px;
            color: #3399ff;
            border: 2px solid #E5F2FF;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }

        .schedule-btn.reject {
            background-color: white;
            border-radius: 45px;
            color: #dc3545;
            border: 2px solid #E5F2FF;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
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

        .read-marker {
            font-size: 10px;
            color: #888;
            margin: 0 5px;
            align-self: flex-end;
            font-weight: 500;
            white-space: nowrap;
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
    let isSubscribed = false;

    // 중복 연결 방지를 위한 잠금 플래그
    let isConnecting = false;

    // ⭐ 추가: 이미 렌더링된 메시지 ID를 추적하는 Set
    const renderedMessageIds = new Set();

    // Enter 키로 메시지 전송
    document.getElementById("messageInput").addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            sendMessage();
        }
    });

    // ⭐ 최종 수정: 서버가 보내는 시간 형식 처리
    function parseDate(dateStr) {
        if (!dateStr) return new Date(0);

        console.log("📅 원본 시간:", dateStr); // 디버깅용

        // 1. 이미 'Z'가 있으면 UTC로 해석 후 자동 변환
        if (dateStr.endsWith('Z')) {
            const date = new Date(dateStr);
            console.log("✅ UTC → KST 변환:", date.toLocaleString('ko-KR'));
            return date;
        }

        // 2. '+09:00' 같은 타임존 정보가 있으면 그대로 사용
        if (dateStr.includes('+') || (dateStr.includes('T') && dateStr.split('T')[1] && dateStr.split('T')[1].includes('-'))) {
            const date = new Date(dateStr);
            console.log("✅ 타임존 포함:", date.toLocaleString('ko-KR'));
            return date;
        }

        // 3. ⭐ 타임존 정보 없음 → KST로 가정
        // "2025-11-03T15:30:00" 또는 "2025-11-03 15:30:00" 또는 "2025-11-07T5:00:00"

        // 공백을 T로 변환
        let isoString = dateStr.replace(' ', 'T');

        // ⭐ 시간 형식 정규화: "T5:00:00" → "T05:00:00"
        // 정규표현식: T 다음에 한자리 숫자가 오면 앞에 0을 추가
        isoString = isoString.replace(/T(\d):/, 'T0$1:');

        console.log("🔧 정규화된 시간:", isoString); // 디버깅용

        // Date 생성 (로컬 시간으로 해석 = 브라우저의 타임존)
        const localDate = new Date(isoString);

        if (isNaN(localDate.getTime())) {
            console.warn("⚠️ 잘못된 날짜 형식:", dateStr, "→", isoString);
            return new Date(0);
        }

        console.log("✅ KST 그대로 사용:", localDate.toLocaleString('ko-KR'));
        return localDate;
    }

    // ⭐ 최종 수정: connect 함수
    function connect() {
        if (stompClient || isConnecting) {
            console.warn("STOMP connection already exists or is in progress.");
            return;
        }
        isConnecting = true;

        if (!roomId) {
            showCustomAlert("채팅방 ID가 없습니다. 올바른 경로로 접속해 주세요.");
            isConnecting = false;
            return;
        }

        const socket = new SockJS("/ws");
        stompClient = Stomp.over(socket);
        stompClient.debug = null;

        stompClient.connect({}, function () {
            isConnecting = false;

            // ⭐ 수정: 1. 이전 메시지 불러오기 (새로고침 시)
            fetch(`/chat/messages?roomId=${roomId}`)
                .then(res => res.json())
                .then(messages => {
                    messages.forEach(msg => {
                        // ⭐ messageId가 없으면 임시 ID 생성 (DB에 messageId 컬럼이 없는 경우)
                        if (!msg.messageId) {
                            // scheduleId나 다른 고유 값으로 임시 ID 생성
                            if (msg.messageType === 'SCHEDULE_REQUEST' && msg.scheduleRequest?.scheduleId) {
                                msg.messageId = 'db-schedule-' + msg.scheduleRequest.scheduleId;
                            } else {
                                msg.messageId = 'db-msg-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
                            }
                            console.log("⚙️ DB 메시지에 임시 ID 부여:", msg.messageId);
                        }

                        // ⭐ 추가: 메시지 ID를 Set에 저장하여 중복 렌더링 방지
                        if (msg.messageId && renderedMessageIds.has(msg.messageId)) {
                            console.log("🔄 이미 렌더링된 DB 메시지 스킵:", msg.messageId);
                            return; // 이미 렌더링된 메시지는 스킵
                        }
                        if (msg.messageId) {
                            renderedMessageIds.add(msg.messageId);
                        }

                        if (msg.messageType === 'SCHEDULE_REQUEST') {
                            renderScheduleRequest(msg);
                        } else if (msg.messageType === 'SCHEDULE_CONFIRMED' || msg.messageType === 'SCHEDULE_REJECTED') {
                            renderSystemMessage(msg.message);
                        } else {
                            appendMessage(msg);
                        }
                    });
                    const chatBox = document.getElementById("chatBox");
                    chatBox.scrollTop = chatBox.scrollHeight;

                    // 읽음 처리
                    if (myUser.id && myUser.id !== 'null' && myUser.id !== '') {
                        stompClient.send("/app/chat.readMessage", {}, JSON.stringify({ roomId: roomId, readerId: myUser.id }));
                    }
                });

            // ⭐ 수정: 2. 실시간 메시지 구독 (올바른 경로로 수정)
            stompClient.subscribe('/topic/chatroom/' + roomId, function (message) {
                const msg = JSON.parse(message.body);

                // 🔍 상세 디버깅 로그
                console.log("====================================");
                console.log("📨 메시지 수신");
                console.log("메시지 ID:", msg.messageId);
                console.log("메시지 타입:", msg.messageType);
                console.log("발신자:", msg.senderId);

                if (msg.messageType === 'SCHEDULE_REQUEST') {
                    console.log("📅 일정 요청 정보:");
                    console.log("  scheduleId:", msg.scheduleRequest?.scheduleId);
                    console.log("  title:", msg.scheduleRequest?.title);
                }

                console.log("🔍 중복 체크:");
                console.log("  messageId 존재?", !!msg.messageId);
                console.log("  이미 렌더링됨?", msg.messageId ? renderedMessageIds.has(msg.messageId) : 'N/A');
                console.log("  저장된 ID 개수:", renderedMessageIds.size);
                console.log("====================================");

                // ⭐ 추가: 중복 메시지 방지 - 이미 렌더링된 메시지 ID인지 확인
                if (msg.messageId && renderedMessageIds.has(msg.messageId)) {
                    console.error("❌ 중복 메시지 발견! 렌더링 건너뜀");
                    return;
                }

                if (msg.messageId) {
                    renderedMessageIds.add(msg.messageId);
                    console.log("✅ 메시지 ID 저장 완료:", msg.messageId);
                } else {
                    console.warn("⚠️ 경고: messageId가 없습니다! 중복 체크 불가능");
                }

                if (msg.messageType === 'SCHEDULE_REQUEST') {
                    console.log("📅 일정 요청 렌더링 시작");
                    renderScheduleRequest(msg);
                } else if (msg.messageType === 'SCHEDULE_CONFIRMED' || msg.messageType === 'SCHEDULE_REJECTED') {
                    renderSystemMessage(msg.message);
                } else {
                    appendMessage(msg);
                }

                // 읽음 처리
                if (msg.senderId === otherUser.id) {
                    if (myUser.id && myUser.id !== 'null' && myUser.id !== '') {
                        stompClient.send("/app/chat.readMessage", {}, JSON.stringify({ roomId: roomId, readerId: myUser.id }));
                    }
                }
            });

            // 3. 읽음 상태 업데이트 구독
            stompClient.subscribe('/topic/read/' + roomId, function(readUpdate) {
                const updateInfo = JSON.parse(readUpdate.body);
                if (updateInfo.readerId === otherUser.id) {
                    const unreadMarkers = document.querySelectorAll('.read-marker.is-unread');
                    unreadMarkers.forEach(marker => {
                        marker.textContent = '';
                        marker.classList.remove('is-unread');
                    });
                }
            });

            // ⭐ 4. localStorage에서 대기 중인 일정 메시지 확인 및 표시
            setTimeout(function() {
                try {
                    const pendingMessages = JSON.parse(localStorage.getItem('pendingScheduleMessages') || '[]');
                    console.log("📦 대기 중인 메시지:", pendingMessages.length + "개");

                    // 현재 roomId에 해당하는 메시지만 필터링
                    const currentRoomMessages = pendingMessages.filter(msg => msg.roomId === roomId);
                    const otherRoomMessages = pendingMessages.filter(msg => msg.roomId !== roomId);

                    // 현재 방의 메시지 렌더링
                    currentRoomMessages.forEach(msg => {
                        console.log("📅 대기 메시지 표시:", msg);

                        // 중복 체크
                        if (msg.messageId && renderedMessageIds.has(msg.messageId)) {
                            console.log("🔄 이미 렌더링된 메시지 스킵");
                            return;
                        }
                        if (msg.messageId) {
                            renderedMessageIds.add(msg.messageId);
                        }

                        renderScheduleRequest(msg);
                    });

                    // 현재 방 메시지 제거, 다른 방 메시지 유지
                    localStorage.setItem('pendingScheduleMessages', JSON.stringify(otherRoomMessages));
                    console.log("✅ 대기 메시지 처리 완료");
                } catch (e) {
                    console.error("localStorage 읽기 실패:", e);
                }
            }, 500); // 0.5초 대기 후 실행 (DB 메시지 로딩 후)

        }, function (error) {
            isConnecting = false;
            stompClient = null;
            console.error('STOMP connection error:', error);
        });
    }

    // 메시지 전송 함수
    function sendMessage() {
        const messageInput = document.getElementById("messageInput");
        const message = messageInput.value.trim();

        if (otherUser.status === 'DEACTIVATED') {
            showCustomAlert("탈퇴한 회원입니다. 채팅할 수 없습니다.");
            return;
        }
        if (!message) return;

        const msg = {
            roomId: roomId,
            senderId: myUser.id,
            message: message,
            sentAt: new Date().toISOString() // UTC 표준시로 저장
        };
        stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(msg));
        messageInput.value = '';
    }

    // ⭐ 최종 수정: appendMessage 함수
    function appendMessage(msg) {
        const msgId = msg.messageId ? msg.messageId : 'temp-' + new Date().getTime() + Math.random();

        // ⭐ 추가: DOM에 이미 존재하는지 확인 (이중 안전장치)
        if (document.getElementById('message-' + msgId)) {
            return;
        }

        if (!msg.message) {
            return;
        }
        const chatBox = document.getElementById("chatBox");
        if (!chatBox) return;
        const isScrolledToBottom = chatBox.scrollHeight - chatBox.clientHeight <= chatBox.scrollTop + 1;
        const senderId = msg.senderId;
        const text = msg.message;

        // ⭐ 수정: 시간 처리 로직 - UTC를 KST로 변환
        const msgDate = parseDate(msg.sentAt);

        const dateStr = msgDate.getFullYear() + "년 " + (msgDate.getMonth() + 1) + "월 " + msgDate.getDate() + "일";

        // ⭐ 수정: 시간이 유효한 경우에만 표시
        const timeStr = msgDate.getTime() === 0 ? "" : msgDate.toLocaleTimeString('ko-KR', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });

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

        wrapper.id = 'message-' + msgId;

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
        messageBubble.textContent = text.replace(/</g, "&lt;").replace(/>/g, "&gt;");
        const timeElem = document.createElement("div");
        timeElem.className = "message-time";
        timeElem.textContent = timeStr;
        if (isMe) {
            const readMarker = document.createElement("div");
            readMarker.className = "read-marker";
            if (msg.read === false) {
                readMarker.textContent = "1";
                readMarker.classList.add("is-unread");
            }
            bubbleWrapper.appendChild(readMarker);
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
        if (isMe || isScrolledToBottom) {
            chatBox.scrollTop = chatBox.scrollHeight;
        }
    }

    // ⭐ 최종 수정: renderScheduleRequest 함수
    function renderScheduleRequest(msg) {
        const msgId = msg.messageId ? msg.messageId : 'temp-' + new Date().getTime() + Math.random();

        // ⭐ 추가: DOM에 이미 존재하는지 확인 (이중 안전장치)
        if (document.getElementById('message-' + msgId)) {
            return;
        }

        const chatBox = document.getElementById("chatBox");
        const request = msg.scheduleRequest;
        if (!request) return;
        const isMe = msg.senderId === myUser.id;
        const profileImageUrl = isMe ? myUser.imageUrl : otherUser.imageUrl;
        const wrapper = document.createElement("div");

        wrapper.id = 'message-' + msgId;

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

        // ⭐ 수정: 시간 처리 로직
        const scheduleDateObj = parseDate(request.scheduleDt);
        const scheduleDate = scheduleDateObj.toLocaleString('ko-KR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });

        let actionButtonsHTML = '';
        if (!isMe) {
            if (request.status === 'PENDING') {
                actionButtonsHTML =
                    '<button class="schedule-btn accept" onclick="handleScheduleAction(' + request.scheduleId + ', \'confirm\')">수락</button>' +
                    '<button class="schedule-btn reject" onclick="handleScheduleAction(' + request.scheduleId + ', \'reject\')">거절</button>';
            } else if (request.status === 'CONFIRMED') {
                actionButtonsHTML = '<span class="action-completed-text">수락됨</span>';
            } else if (request.status === 'REJECTED') {
                actionButtonsHTML = '<span class="action-completed-text">거절됨</span>';
            }
        } else {
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
