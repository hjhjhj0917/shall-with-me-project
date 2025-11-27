<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<header>
    <%--    메인으로 가는 사이트 로고--%>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <%-- ✅ loading="lazy" 추가 --%>
            <img src="../images/logo.png" loading="lazy">
        </div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">

        <%--쉐어하우스 룸메이트 메인페이지 전환--%>
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span>
            <button class="switch-list" onclick="location.href='/roommate/roommateMain'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/sharehouse/sharehouseMain'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>

        <%--회원 이름 , 프로필--%>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span>
            <span class="user-name-text" id="userNameText" onclick="location.href='/mypage/userModify'">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <%
                    Object profileImgUrlObj = session.getAttribute("SS_USER_PROFILE_IMG_URL");
                    String profileImgUrl = null;

                    if (profileImgUrlObj != null) {
                        profileImgUrl = profileImgUrlObj.toString();
                    }

                    if (profileImgUrl != null && !profileImgUrl.isEmpty()) {
                %>
                <%-- ✅ loading="lazy" 추가 --%>
                <img src="<%= profileImgUrl %>" alt="프로필 사진" class="user-profile-img" loading="lazy">
                <%
                } else {
                %>
                <img src="/images/withdraw-profile-img.png" alt="기본 프로필 사진" class="user-profile-img" loading="lazy">
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
            <span class="slide-bg2"></span>
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
    // ✅ 배지 업데이트 함수
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

    const loggedInHeaderUserId = "<%= session.getAttribute("SS_USER_ID") %>";

    if (loggedInHeaderUserId && loggedInHeaderUserId !== 'null') {
        let pollingInterval = null;
        let lastFetchTime = 0;
        const FETCH_COOLDOWN = 5000; // 5초 쿨다운 (과도한 요청 방지)

        // ✅ 안 읽은 메시지 개수 조회 함수 (쿨다운 적용)
        function fetchUnreadCount() {
            const now = Date.now();

            // 마지막 요청 후 5초 이내면 스킵 (과도한 요청 방지)
            if (now - lastFetchTime < FETCH_COOLDOWN) {
                return;
            }

            lastFetchTime = now;

            fetch('/chat/totalUnreadCount', {
                method: 'GET',
                headers: {
                    'Cache-Control': 'no-cache' // 캐시 방지
                }
            })
                .then(res => {
                    if (!res.ok) throw new Error('Network response was not ok');
                    return res.json();
                })
                .then(data => {
                    if (data.totalCount !== undefined) {
                        updateTotalUnreadBadge(data.totalCount);
                    }
                })
                .catch(err => {
                    console.error('Unread count fetch error:', err);
                });
        }

        // ✅ 1. 페이지 로드 즉시 실행
        fetchUnreadCount();

        // ✅ 2. 15초마다 자동 갱신
        pollingInterval = setInterval(fetchUnreadCount, 15000);

        // ✅ 3. 메시지 아이콘 클릭 시 즉시 갱신 (쿨다운 적용)
        const messageIcon = document.getElementById('messageIconToggle');
        if (messageIcon) {
            messageIcon.addEventListener('click', function() {
                fetchUnreadCount();
            });
        }

        // ✅ 4. 페이지 포커스 시 갱신 (다른 탭에서 돌아올 때)
        document.addEventListener('visibilitychange', function() {
            if (!document.hidden) {
                fetchUnreadCount();
            }
        });

        // ✅ 5. 페이지 이탈 시 interval 정리
        window.addEventListener('beforeunload', function() {
            if (pollingInterval) {
                clearInterval(pollingInterval);
            }
        });
    }
</script>
