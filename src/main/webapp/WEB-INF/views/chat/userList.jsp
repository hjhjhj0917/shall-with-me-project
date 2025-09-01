<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>채팅 목록</title>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <style>
        * {
            user-select: none;       /* 텍스트 드래그 금지 */
            pointer-events: auto;    /* 클릭 이벤트는 그대로 작동 */
            -webkit-user-select: none; /* 크로스브라우징 */
            -moz-user-select: none;
            -ms-user-select: none;
        }
        /* 기본 스타일 초기화 */
        body, html {

            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: white;
            scrollbar-width: none; /* Firefox */
            -ms-overflow-style: none; /* IE, Edge */
        }
        body::-webkit-scrollbar, html::-webkit-scrollbar {
            display: none; /* Chrome, Safari */
        }

        /* 채팅 목록을 감싸는 컨테이너 */
        .chat-list-container {
            max-width: 600px;
            background-color: white;
            border-radius: 16px;
        }

        /* 각 채팅 상대 아이템 */
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

        /* 프로필 사진 */
        .profile-pic {
            width: 50px;
            height: 50px;
            border-radius: 50%; /* 이미지를 동그랗게 */
            object-fit: cover; /* 이미지 비율 유지 */
            margin-right: 15px;
            background-color: #e0e0e0; /* 이미지가 없을 경우 배경색 */
        }

        /* 아이디와 메시지 정보 영역 */
        .info {
            flex: 1;
            overflow: hidden; /* ellipsis 효과를 위해 필수 */
        }

        /* 아이디 (List item title) */
        .title {
            font-weight: 400;
            font-size: 14px;
            color: #3399ff;
        }

        /* 마지막 메시지 (List item subtitle) */
        .subtitle {
            font-size: 12px;
            color: #666;

            /* 긴 메시지를 ...으로 처리하는 스타일 */
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* 목록이 비어있을 때 컨테이너 스타일 */
        .chat-list-container.is-empty {
            display: flex;
            justify-content: center; /* 수평 중앙 */
            align-items: center;   /* 수직 중앙 */
            min-height: 80vh;
        }

        /* [추가] 비어있을 때 표시되는 메시지 자체의 스타일 */
        .chat-list-container.is-empty p {
            color: #888;
            font-size: 1rem;
            font-weight: 500;
        }

        p {
            margin-top: 30px;
            padding-top: 30px;
        }
    </style>
</head>
<body>

<%-- JSP Scriptlet으로 로그인된 사용자 ID를 JavaScript 변수로 전달 --%>
<%
    String ssUserId = (String) session.getAttribute("SS_USER_ID");
%>
<script>
    const loggedInUserId = "<%= ssUserId %>";
</script>


<div class="chat-list-container" id="chatList">

</div>


<%-- [수정] 화면에 보이지 않는 HTML '틀(template)'을 만듭니다. --%>
<div id="chat-item-template" style="display: none;">
    <div class="chat-partner-item">
        <img class="profile-pic">
        <div class="info">
            <div class="title"></div>
            <div class="subtitle"></div>
        </div>
    </div>
</div>


<script>
    // 채팅방으로 이동하는 함수
    function openChat(otherUserId) {
        console.log("openChat 호출됨:", otherUserId);
        fetch("/chat/createOrGetRoom?otherUserId=" + encodeURIComponent(otherUserId))
            .then(res => {
                if (!res.ok) {
                    throw new Error(`HTTP error! status: ${res.status}`);
                }
                return res.json();
            })
            .then(data => {
                console.log("서버에서 받은 데이터:", data);
                if (data.roomId) {
                    const cleanedRoomId = Number(data.roomId);
                    console.log("➡️ 이동할 채팅방 ID:", cleanedRoomId);
                    const targetUrl = "/chat/chatRoom?roomId=" + cleanedRoomId;
                    console.log("이동할 URL:", targetUrl);
                    parent.location.href = targetUrl;
                } else {
                    alert("채팅방 생성 실패");
                }
            })
            .catch(err => {
                console.error("채팅방 생성 중 오류:", err);
                alert("오류가 발생했습니다.");
            });
    }

    // [수정] user 객체를 받아서 HTML 요소를 생성하고 반환하는 함수
    function createChatItem(user) {
        var template = document.getElementById('chat-item-template');
        var clone = template.cloneNode(true); // 템플릿 복제

        clone.removeAttribute('id'); // ID 속성 제거
        clone.style.display = ''; // 보이도록 설정

        // 데이터-ID 속성을 추가하여 나중에 쉽게 찾을 수 있도록 함
        clone.querySelector('.chat-partner-item').setAttribute('data-userid', user.userId);
        clone.querySelector('.chat-partner-item').onclick = function() { openChat(user.userId); };

        var profileImgSrc = user.profileImgUrl || '/images/default-profile.png';
        clone.querySelector('.profile-pic').src = profileImgSrc;
        clone.querySelector('.profile-pic').alt = user.userName + "의 프로필 사진";

        clone.querySelector('.title').textContent = user.userName;
        clone.querySelector('.subtitle').textContent = user.lastMessage || '대화 내용이 없습니다.';

        return clone.firstElementChild; // <div class="chat-partner-item">...</div> 요소 반환
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

                // [추가] 이전 상태 초기화를 위해 is-empty 클래스를 먼저 제거합니다.
                container.removeClass('is-empty');

                if (userList.length === 0) {
                    // [수정] is-empty 클래스를 추가하고, 스타일이 없는 p 태그를 넣습니다.
                    container.addClass('is-empty');
                    container.append('<p>대화 상대가 없습니다.</p>');

                } else {
                    $.each(userList, function (index, user) {
                        var chatItem = createChatItem(user);
                        container.append(chatItem);
                    });
                }
            },
            error: function (xhr) {
                // ... 에러 처리 ...
            }
        });

        // [추가] WebSocket 연결
        connectWebSocket();
    });

    // [추가] WebSocket 연결 및 구독 설정
    function connectWebSocket() {
        if (loggedInUserId && loggedInUserId !== 'null') {
            var socket = new SockJS('/ws'); // WebSocket 접속 주소
            var stompClient = Stomp.over(socket);

            stompClient.connect({}, function (frame) {
                console.log('STOMP Connected: ' + frame);

                // 개인 채널을 구독해서 목록 업데이트 알림을 받음
                stompClient.subscribe('/topic/user/' + loggedInUserId, function (message) {
                    var updatedPartnerInfo = JSON.parse(message.body);

                    // 실시간으로 목록 업데이트
                    updateChatList(updatedPartnerInfo);
                });
            });
        }
    }

    // [추가] 실시간으로 채팅 목록을 업데이트하는 함수
    function updateChatList(user) {
        var container = $("#chatList");

        // 기존에 있던 목록 아이템을 찾아서 삭제
        container.find('.chat-partner-item[data-userid="' + user.userId + '"]').remove();

        // 새로 받은 정보로 목록 아이템을 생성해서 맨 위에 추가
        var newChatItem = createChatItem(user);
        container.prepend(newChatItem);

        // "대화 상대가 없습니다" 메시지가 있다면 제거
        container.find('p').remove();
    }
</script>

</body>
</html>