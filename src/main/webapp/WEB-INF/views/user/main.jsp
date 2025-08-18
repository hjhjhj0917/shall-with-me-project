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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script>
            $(document).ready(function () {

                function checkLoginAndRedirect(url) {
                    $.ajax({
                        url: "/user/loginCheck",
                        type: "GET",
                        dataType: "json",
                        success: function (res) {
                            if (res === 1) {
                                location.href = url;
                            } else {
                                showCustomAlert("로그인이 필요한 서비스입니다.", function() {
                                    location.href = "/user/login";
                                });
                            }
                        },
                        error: function () {
                            showCustomAlert("서버 통신 오류가 발생했습니다.");
                        }
                    });
                }

                $("#logout").on("click", function () {
                    showCustomAlert("로그아웃 하시겠습니까?", function () {
                        $.ajax({
                            url: "/user/logout",
                            type: "GET",
                            dataType: "json",
                            success: function (res) {
                                if (res.result === 1) {
                                    location.href = "/user/main";

                                } else {
                                    showCustomAlert("실패: " + res.msg);
                                }
                            },
                            error: function () {
                                showCustomAlert("서버 통신 중 오류가 발생했습니다.");
                            }
                        });
                    });
                });

                $("#roommateBtn").on("click", function () {
                    checkLoginAndRedirect("/roommate/roommateMain");
                });

                $("#sharehouseBtn").on("click", function () {
                    checkLoginAndRedirect("/sharehouse/sharehouseMain");
                });
        });
    </script>

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
            <button class="menu-list" id="logout">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<div class="main-container">

    <div class="left-panel" id="roommateBtn">
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

    <div class="right-panel" id="sharehouseBtn">
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

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<%-- 모달창 js --%>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>


</body>
</html>


