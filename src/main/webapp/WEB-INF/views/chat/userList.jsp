<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>채팅 목록</title>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <%-- 웹소캣 관련 js --%>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <style>
        * {
            user-select: none;
            pointer-events: auto;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
        }
        body, html {
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: white;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        body::-webkit-scrollbar, html::-webkit-scrollbar {
            display: none;
        }
        .chat-list-container {
            max-width: 600px;
            background-color: white;
            border-radius: 16px;
        }
        .chat-partner-item {
            display: flex;
            align-items: center;
            cursor: pointer;
            transition: background-color 0.2s ease;
            border-radius: 12px;
            padding: 10px;
            margin: 10px;
            background-color: #FBFDFF;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }
        .chat-partner-item:hover {
            background-color: #f5f5f5;
        }
        .profile-pic {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 15px;
            background-color: #e0e0e0;
        }
        .info {
            flex: 1;
            overflow: hidden;
            min-width: 0;
        }
        .title {
            font-weight: 400;
            font-size: 14px;
            color: #3399ff;
        }
        .subtitle {
            font-size: 12px;
            color: #666;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .timestamp {
            font-size: 11px;
            color: #888;
            white-space: nowrap;
            margin-top: 4px;
        }

        .chat-list-container.is-empty {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 80vh;
        }
        .chat-list-container.is-empty p {
            color: #888;
            font-size: 1rem;
            font-weight: 500;
        }
        p {
            margin-top: 30px;
            padding-top: 30px;
        }

        .unread-badge {
            background-color: #ff3b30;
            color: white;
            font-size: 11px;
            font-weight: bold;
            padding: 2px 6px;
            border-radius: 10px;
            min-width: 18px;
            height: 18px;
            box-sizing: border-box;

            display: flex;
            align-items: center;
            justify-content: center;


            margin-left: 0;
        }

        .right-info {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: center;
            margin-left: 10px;
            margin-top: 10px;
        }
    </style>
</head>
<body>

<%
    String ssUserId = (String) session.getAttribute("SS_USER_ID");
%>
<script>
    const loggedInUserId = "<%= ssUserId %>";
</script>

<div class="chat-list-container" id="chatList"></div>

<%-- [수정] 화면에 보이지 않는 HTML '틀(template)'에 시간 영역을 추가합니다. --%>
<div id="chat-item-template" style="display: none;">
    <div class="chat-partner-item">
        <img class="profile-pic">
        <div class="info">
            <div class="title"></div>
            <div class="subtitle"></div>
        </div>

        <div class="right-info">
            <div class="unread-badge"></div>
            <div class="timestamp"></div>
        </div>
    </div>
</div>

<script>

    /**
     * [수정] chat.jsp의 parseDate와 동일한 로직을 사용합니다.
     * .ready()의 정렬 로직과 formatTimeAgo가 이 함수를 공유합니다.
     */
    function parseListDate(dateString) {
        if (!dateString) return new Date(0); // 1970년 (정렬 시 맨 뒤)

        // 서버가 UTC 시간("...T04:39:00")을 'Z' 없이 보내는 문제 해결
        // 'Z'를 강제로 붙여 UTC임을 명시해야 브라우저가 KST로 올바르게 변환합니다.
        let isoDateString = dateString;

        // "YYYY-MM-DD HH:MM:SS" 형식을 "YYYY-MM-DDTHH:MM:SSZ"로 변경
        if (isoDateString.includes(' ') && !isoDateString.includes('T')) {
            isoDateString = isoDateString.replace(' ', 'T') + 'Z';
        }
        else if (isoDateString.includes('T') && !isoDateString.endsWith('Z')) {
            isoDateString += 'Z';
        }

        const messageDate = new Date(isoDateString);

        if (isNaN(messageDate.getTime())) {
            console.error("잘못된 날짜 형식으로 변환에 실패했습니다:", dateString);
            return new Date(0); // 1970년
        }
        return messageDate; // KST로 변환된 Date 객체
    }

    // formatTimeAgo는 이제 parseListDate를 사용
    function formatTimeAgo(dateString) {
        // parseListDate를 호출하여 KST Date 객체를 받음
        const messageDate = parseListDate(dateString);

        // 시간이 유효하지 않으면(1970년) 빈 문자열 반환
        if (messageDate.getTime() === 0) return "";

        const now = new Date(); // 브라우저의 현재 시간 (KST)
        const secondsAgo = Math.round((now.getTime() - messageDate.getTime()) / 1000);

        // 조건에 따라 정확한 상대 시간으로 변환
        if (secondsAgo < 60) {
            return '방금 전';
        }
        if (secondsAgo < 3600) { // 1시간 미만
            return Math.floor(secondsAgo / 60) + '분 전';
        }
        if (secondsAgo < 86400) { // 하루 미만
            return Math.floor(secondsAgo / 3600) + '시간 전';
        }
        if (secondsAgo < 604800) { // 7일 미만
            return Math.floor(secondsAgo / 86400) + '일 전';
        }

        // 7일 이상은 '월 일' 형식으로 표시 (messageDate는 이미 KST입니다)
        return messageDate.toLocaleDateString('ko-KR', { month: 'long', day: 'numeric' });
    }

    // 채팅방으로 이동하는 함수
    function openChat(otherUserId) {
        fetch("/chat/createOrGetRoom?user2Id=" + encodeURIComponent(otherUserId))
            .then(res => {
                if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
                return res.json();
            })
            .then(data => {
                if (data.roomId) {
                    parent.location.href = "/chat/chatRoom?roomId=" + Number(data.roomId);
                } else {
                    showCustomAlert("채팅방 생성 실패");
                }
            })
            .catch(err => {
                console.error("채팅방 생성 중 오류:", err);
                showCustomAlert("오류가 발생했습니다.");
            });
    }


    function createChatItem(user) {
        var template = document.getElementById('chat-item-template');
        var clone = template.cloneNode(true);

        clone.removeAttribute('id');
        clone.style.display = '';

        clone.querySelector('.chat-partner-item').setAttribute('data-userid', user.userId);
        clone.querySelector('.chat-partner-item').onclick = function() { openChat(user.userId); };

        var profileImgSrc = user.profileImgUrl || '/images/noimg.png';
        clone.querySelector('.profile-pic').src = profileImgSrc;
        clone.querySelector('.profile-pic').alt = user.userName + "의 프로필 사진";

        clone.querySelector('.title').textContent = user.userName;
        clone.querySelector('.subtitle').textContent = user.lastMessage || '대화 내용이 없습니다.';

        if (user.lastMessageTimestamp) {
            // [수정] 수정된 formatTimeAgo 함수가 호출됨
            clone.querySelector('.timestamp').textContent = formatTimeAgo(user.lastMessageTimestamp);
        }

        // [추가] 안 읽은 메시지 뱃지 처리 로직
        const badge = clone.querySelector('.unread-badge');
        if (user.unreadCount && user.unreadCount > 0) {
            if (user.unreadCount >= 50) {
                badge.textContent = '50+';
            } else {
                badge.textContent = user.unreadCount;
            }
            badge.style.visibility = 'visible';
        } else {
            badge.textContent = '';
            badge.style.visibility = 'hidden';
        }

        return clone.firstElementChild;
    }

    // 페이지 로드 시 채팅 목록을 가져오는 AJAX
    $(document).ready(function () {
        $.ajax({
            url: "/chat/chatPartners",
            method: "GET",
            dataType: "json",
            success: function (userList) {
                var container = $("#chatList");
                container.empty();
                container.removeClass('is-empty');

                if (userList.length === 0) {
                    container.addClass('is-empty');
                    container.append('<p>대화 상대가 없습니다.</p>');
                } else {
                    // [수정] 정렬 문제 해결:

                    //userList를 KST Date 객체와 함께 변환
                    const sortedUserList = userList.map(user => {
                        // parseListDate 함수를 사용하여 KST Date 객체 생성
                        const kstDate = parseListDate(user.lastMessageTimestamp);
                        return { ...user, kstDate: kstDate };
                    });

                    //KST Date 기준으로 내림차순 정렬 (최신순)
                    sortedUserList.sort((a, b) => b.kstDate.getTime() - a.kstDate.getTime());

                    //정렬된 목록을 화면에 .append()
                    $.each(sortedUserList, function (index, user) {
                        var chatItem = createChatItem(user);
                        container.append(chatItem);
                    });
                }
            },
            error: function (xhr) {
                console.error("채팅 목록을 불러오는 데 실패했습니다.", xhr.responseText);
                var container = $("#chatList");
                container.addClass('is-empty');
                container.append('<p>오류가 발생했습니다.</p>');
            }
        });

        connectWebSocket();
    });

    // WebSocket 연결 및 구독 설정
    function connectWebSocket() {
        if (loggedInUserId && loggedInUserId !== 'null') {
            var socket = new SockJS('/ws');
            var stompClient = Stomp.over(socket);
            stompClient.debug = null; // 콘솔 디버그 메시지 끄기

            stompClient.connect({}, function (frame) {
                console.log('STOMP Connected: ' + frame);
                stompClient.subscribe('/topic/user/' + loggedInUserId, function (message) {
                    var updatedPartnerInfo = JSON.parse(message.body);
                    updateChatList(updatedPartnerInfo);
                });
            });
        }
    }

    // 실시간으로 채팅 목록을 업데이트하는 함수
    function updateChatList(user) {
        var container = $("#chatList");



        container.find('.chat-partner-item[data-userid="' + user.userId + '"]').remove();


        var newChatItem = createChatItem(user);
        container.prepend(newChatItem);


        if(container.hasClass('is-empty')) {
            container.removeClass('is-empty');
            container.find('p').remove();
        }
    }
</script>

</body>
</html>

