<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
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
      <button class="menu-list" id="logout">로그아웃</button>
      <button class="header-dropdown-toggle" id="headerDropdownToggle">
        <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
      </button>
    </div>
  </div>
</header>
