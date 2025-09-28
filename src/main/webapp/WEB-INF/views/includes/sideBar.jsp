<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<nav class="sidebar">

  <button class="sidebar-toggle-btn" id="sidebarToggle">
    <i class="fa-solid fa-bars" style="color: #1c407d;"></i>
  </button>

  <header class="sidebar-header">
    <a href="#" class="sidebar-logo">
      <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") %>" alt="프로필 사진" class="sidebar-profile-img">
      <div class="sidebar-logo-text">
        <%= session.getAttribute("SS_USER_NAME") %>
      </div>
    </a>
  </header>

  <!-- 메뉴 전체를 별도의 컨테이너로 감싸서 스크롤 제어 -->
  <div class="sidebar-menu-wrapper">
    <div class="sidebar-menu-container">
      <div class="sidebar-menu-list">
        <div onclick="location.href='/mypage/userModify'" class="sidebar-menu-item">
          <i class="fa-solid fa-user" style="color: #1c407d;"></i>
          <span class="sidebar-menu-text">개인정보/프로필 수정</span>
        </div>
        <div onclick="location.href='/mypage/sharehouseModify'" class="sidebar-menu-item">
          <i class="fa-solid fa-house" style="color: #1c407d;"></i>
          <span class="sidebar-menu-text">쉐어하우스 정보 수정</span>
        </div>
        <div onclick="location.href='/mypage/scheduleCheck'" class="sidebar-menu-item">
          <i class="fa-solid fa-calendar-days" style="color: #1c407d;"></i>
          <span class="sidebar-menu-text">일정 확인</span>
        </div>
      </div>

      <div class="sidebar-menu-list">
        <div class="sidebar-menu-item" id="sidebar-logout">
          <i class="fa-solid fa-right-from-bracket" style="color: #1c407d;"></i>
          <span class="sidebar-menu-text">로그아웃</span>
        </div>
        <div onclick="location.href='/mypage/withdraw'" class="sidebar-menu-item">
          <i class="fa-solid fa-gear" style="color: #1c407d;"></i>
          <span class="sidebar-menu-text">회원 탈퇴</span>
        </div>
      </div>
    </div>
  </div>
</nav>