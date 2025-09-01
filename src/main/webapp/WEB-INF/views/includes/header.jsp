<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<header>
<%--    메인으로 가는 사이트 로고--%>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <i class="fa-solid fa-people-roof fa-xs" style="color: #3399ff;"></i>
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
            <span class="user-name-text" id="userNameText">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>

        <%--메세지 확인--%>
        <div class="header-message-container" id="messageBox">
            <span class="slide-bg4"></span> <!-- 둥근 반스도 역할 -->
            <button class="header-dropdown-toggle" id="messageIconToggle">
                <i class="fa-solid fa-envelope fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>

        <%--메뉴--%>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span> <!-- 둥근 반스도 역할 -->
            <button class="menu-list" onclick="location.href='/user/myPage'">마이페이지</button>
            <button class="menu-list" id="logout">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<%--메세지 리스트 띄우는 모달--%>
<div id="messageModalOverlay" aria-hidden="true">
    <div class="modal-sheet" role="dialog" aria-modal="true" aria-labelledby="messageModalTitle">
        <div class="modal-body">
            <iframe id="messageModalFrame"></iframe>
        </div>
    </div>
</div>
