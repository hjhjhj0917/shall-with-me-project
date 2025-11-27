<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<header>
    <%--    메인으로 가는 사이트 로고--%>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <%--            <i class="fa-solid fa-people-roof fa-xs" style="color: #3399ff;"></i>--%>
            <img src="../images/logo.png">
        </div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">

        <%--쉐어하우스 룸메이트 메인페이지 전환--%>
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span> <!-- 둥근 반스도 역할 -->
            <button class="switch-list" onclick="location.href='/roommate/roommateMain'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/sharehouse/sharehouseMain'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>

        <%--회원 이름 , 프로필--%>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span> <!-- 둥근 반스도 역할 -->
            <span class="user-name-text" id="userNameText" onclick="location.href='/mypage/userModify'">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <%
                    // 1. 세션에서 프로필 이미지 URL 값을 가져옵니다.
                    Object profileImgUrlObj = session.getAttribute("SS_USER_PROFILE_IMG_URL");
                    String profileImgUrl = null;

                    // 2. 값이 null이 아닌지 확인하고 문자열로 변환합니다.
                    if (profileImgUrlObj != null) {
                        profileImgUrl = profileImgUrlObj.toString();
                    }

                    // 3. URL이 유효한지(null이나 빈 문자열이 아닌지) 확인합니다.
                    if (profileImgUrl != null && !profileImgUrl.isEmpty()) {
                %>
                <%-- 조건이 참일 경우: 세션에 있는 이미지 URL로 img 태그 생성 --%>
                <img src="<%= profileImgUrl %>" alt="프로필 사진" class="user-profile-img">
                <%
                } else {
                %>
                <%-- 조건이 거짓일 경우: 기본 이미지로 img 태그 생성 --%>
                <img src="/images/withdraw-profile-img.png" alt="기본 프로필 사진" class="user-profile-img">
                <%
                    }
                %>
            </button>
        </div>

        <%--메세지 확인--%>
        <div class="header-icon-wrapper">

            <span class="notification-badge" id="totalUnreadBadge" style="display: none;"></span>

            <%--메세지 확인--%>
            <div class="header-message-container" id="messageBox">
                <span class="slide-bg4"></span>
                <button class="header-dropdown-toggle" id="messageIconToggle">
                    <i class="fa-solid fa-envelope fa-sm" style="color: #1c407d;"></i>
                </button>
            </div>

        </div>

        <%--메뉴--%>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span> <!-- 둥근 반스도 역할 -->
            <button class="menu-list" onclick="location.href='/notice/noticeList'">ㅤㅤ청년정책</button>
            <button class="menu-list" onclick="location.href='/mypage/userModify'">마이페이지</button>
            <button class="menu-list" id="logout">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<%--메시지 리스트 띄우는 모달--%>
<div id="messageModalOverlay" aria-hidden="true">
    <div class="modal-sheet" role="dialog" aria-modal="true" aria-labelledby="messageModalTitle">
        <div class="modal-body">
            <iframe id="messageModalFrame"></iframe>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>

<script>
    // 뱃지 UI를 업데이트하는 함수
    function updateTotalUnreadBadge(count) {
        const badge = document.getElementById('totalUnreadBadge');
        if (!badge) return;

        if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count;
            badge.style.display = 'flex';
        } else {
            badge.style.display = 'none';
        }
    }

    // 전역 변수로 클라이언트 선언 (연결 해제를 위해)
    let headerStompClient = null;
    const loggedInHeaderUserId = "<%= session.getAttribute("SS_USER_ID") %>";

    if (loggedInHeaderUserId && loggedInHeaderUserId !== 'null') {

        // 1. 페이지 로드 시 전체 안 읽은 개수 가져오기 (AJAX)
        fetch('/chat/totalUnreadCount')
            .then(res => res.json())
            .then(data => {
                if (data.totalCount !== undefined) {
                    updateTotalUnreadBadge(data.totalCount);
                }
            })
            .catch(err => console.error('Total unread count fetch error:', err));

        // 2. 실시간 업데이트를 위한 WebSocket 연결
        const headerSocket = new SockJS("/ws");
        headerStompClient = Stomp.over(headerSocket);

        // 디버그 로그 끄기 (성능 및 콘솔 깔끔하게 유지)
        headerStompClient.debug = null;

        headerStompClient.connect({}, function () {
            headerStompClient.subscribe('/topic/user/' + loggedInHeaderUserId, function (message) {
                const updateInfo = JSON.parse(message.body);
                if (updateInfo.totalUnreadCount !== undefined) {
                    updateTotalUnreadBadge(updateInfo.totalUnreadCount);
                }
            });
        });

        // [중요] 페이지를 벗어나거나 새로고침 할 때 명시적으로 연결 해제
        window.addEventListener('beforeunload', function() {
            if (headerStompClient !== null) {
                headerStompClient.disconnect(function() {
                    console.log("Header WebSocket disconnected gracefully.");
                });
            }
        });
    }
</script>

<%--<script>--%>
<%--    // 뱃지 UI를 업데이트하는 함수--%>
<%--    function updateTotalUnreadBadge(count) {--%>
<%--        const badge = document.getElementById('totalUnreadBadge');--%>
<%--        if (!badge) return;--%>

<%--        if (count > 0) {--%>
<%--            badge.textContent = count > 99 ? '99+' : count;--%>
<%--            badge.style.display = 'flex';--%>
<%--        } else {--%>
<%--            badge.style.display = 'none';--%>
<%--        }--%>
<%--    }--%>

<%--    // 로그인한 사용자 ID가 있을 때만 실행--%>
<%--    const loggedInHeaderUserId = "<%= session.getAttribute("SS_USER_ID") %>";--%>
<%--    if (loggedInHeaderUserId && loggedInHeaderUserId !== 'null') {--%>

<%--        // 1. 페이지 로드 시 전체 안 읽은 개수 가져오기 (AJAX)--%>
<%--        fetch('/chat/totalUnreadCount')--%>
<%--            .then(res => res.json())--%>
<%--            .then(data => {--%>
<%--                if (data.totalCount !== undefined) {--%>
<%--                    updateTotalUnreadBadge(data.totalCount);--%>
<%--                }--%>
<%--            })--%>
<%--            .catch(err => console.error('Total unread count fetch error:', err));--%>

<%--        // 2. 실시간 업데이트를 위한 WebSocket 연결--%>
<%--        const headerSocket = new SockJS("/ws"); // WebSocketConfig와 주소 일치--%>
<%--        const headerStompClient = Stomp.over(headerSocket);--%>
<%--        headerStompClient.debug = null;--%>

<%--        headerStompClient.connect({}, function () {--%>
<%--            // 안 읽은 개수 변경 알림을 받을 개인 채널 구독--%>
<%--            headerStompClient.subscribe('/topic/user/' + loggedInHeaderUserId, function (message) {--%>
<%--                const updateInfo = JSON.parse(message.body);--%>
<%--                // 서버에서 totalUnreadCount를 보내준다고 가정--%>
<%--                if (updateInfo.totalUnreadCount !== undefined) {--%>
<%--                    updateTotalUnreadBadge(updateInfo.totalUnreadCount);--%>
<%--                }--%>
<%--            });--%>
<%--        });--%>
<%--    }--%>
<%--</script>--%>