
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
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
            <span class="slide-bg3"></span> <!-- 둥근 반스도 역할 -->
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span> <!-- 둥근 반스도 역할 -->
            <span class="user-name-text" id="userNameText">
        <%= session.getAttribute("SS_USER_NAME") %>님
      </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span> <!-- 둥근 반스도 역할 -->
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>


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

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
