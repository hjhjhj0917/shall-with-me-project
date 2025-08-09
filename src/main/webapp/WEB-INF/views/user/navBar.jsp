<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 2025-07-29
  Time: 오후 12:02
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>살며시</title>

  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>

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
      <button class="menu-list" onclick="location.href='/chat/userListPage'">메세지</button>
      <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
      <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
      <button class="header-dropdown-toggle" id="headerDropdownToggle">
        <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
      </button>
    </div>
  </div>
</header>

<%
  String ssUserName = (String) session.getAttribute("SS_USER_NAME");
  if (ssUserName == null) {
    ssUserName = "";
  }
%>
<script>
  const userName = "<%= ssUserName %>";
</script>

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>
