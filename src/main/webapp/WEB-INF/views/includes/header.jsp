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
                <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL")  %>" alt="프로필 사진"
                     class="user-profile-img">
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

    // 로그인한 사용자 ID가 있을 때만 실행
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
        const headerSocket = new SockJS("/ws"); // WebSocketConfig와 주소 일치
        const headerStompClient = Stomp.over(headerSocket);
        headerStompClient.debug = null;

        headerStompClient.connect({}, function () {
            // 안 읽은 개수 변경 알림을 받을 개인 채널 구독
            headerStompClient.subscribe('/topic/user/' + loggedInHeaderUserId, function (message) {
                const updateInfo = JSON.parse(message.body);
                // 서버에서 totalUnreadCount를 보내준다고 가정
                if (updateInfo.totalUnreadCount !== undefined) {
                    updateTotalUnreadBadge(updateInfo.totalUnreadCount);
                }
            });
        });
    }
</script>