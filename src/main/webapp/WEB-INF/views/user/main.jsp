<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 2025-07-29
  Time: 오후 8:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>룸메이트/쉐어하우스 찾기</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css"/>

</head>
<body>
<header>
    <div class="home-logo" onclick="location.href='/home.html'">
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
            <span class="user-name-text" id="userNameText">홍길동님</span>
            <!-- <span class="user-name-text"><%= session.getAttribute("userName") %>님</span> -->
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

<div class="main-container">
    <!-- 왼쪽 텍스트 -->
    <div class="left-panel" onclick="location.href='/roommate.html'">
        <div class="left-text">
            자신과 비슷한 성향의 룸메이트를 찾아보세요
        </div>
        <div class="roommate-start">
            룸메이트 찾기
        </div>
        <div class="left">
            <img src="/images/roommate.png" class="left-image" alt="왼쪽 이미지" />
        </div>
    </div>
    <!-- 오른쪽 비스듬한 영역 -->
    <div class="right-panel" onclick="location.href='/sharehouse.html'">
        <div class="right-text">
            자신의 새로운 보금자리를 찾아보세요
        </div>
        <div class="right-start">
            쉐어하우스 찾기
        </div>
        <div class="right">
            <img src="/images/sharehouse.png" class="right-image" alt="오른쪽 이미지" />
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>


