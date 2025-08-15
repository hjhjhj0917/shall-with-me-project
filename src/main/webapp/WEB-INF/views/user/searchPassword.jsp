<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>비밀번호 찾기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script type="text/javascript">
        $(document).ready(function () {

            // 에러 스타일 제거
            $(document).on("click", function (e) {
                const $target = $(e.target);

                if (
                    !$target.is("#userId") &&
                    !$target.is("#email") &&
                    !$target.is("#btnSearchPassword")
                ) {
                    $(".login-input").removeClass("input-error");
                    $("#findPwErrorMessage").removeClass("visible");
                }
            });

            $(".login-tab").on("click", function () {
                location.href = "/user/login";
            });

            $(".login-tab1").on("click", function () {
                location.href = "/user/searchUserId";
            });

            $("#btnLogin").on("click", function () {
                location.href = "/user/login";
            });

            $("#btnSearchPassword").on("click", function () {
                let f = document.getElementById("f");
                let userId = f.userId.value.trim();
                let email = f.email.value.trim();

                $(".login-input").removeClass("input-error");
                $("#findPwErrorMessage").removeClass("visible").text("");

                if (userId === "") {
                    $("#userId").addClass("input-error");
                    $("#findPwErrorMessage").text("아이디를 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage").removeClass("visible");
                    }, 2000);
                    $("#userId").focus();
                    return;
                }

                if (email === "") {
                    $("#email").addClass("input-error");
                    $("#findPwErrorMessage").text("이메일을 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage").removeClass("visible");
                    }, 2000);
                    $("#email").focus();
                    return;
                }

                // 전송
                f.method = "post";
                f.action = "/user/searchPasswordProc";
                f.submit();
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
            <span class="slide-bg3"></span>
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span>
            <span class="user-name-text" id="userNameText">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span>
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<!-- 비밀번호 찾기 폼 영역 -->
<div class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1">FIND ID</div>
    <div class="login-tab2 active-tab">FIND PW</div>
    <div class="header">
        <div class="logo">살며시</div>
        <div class="logo-2">Shall With Me</div>
    </div>

    <div id="findPwErrorMessage" class="error-message"></div>

    <form id="f">
        <input type="text" name="userId" id="userId" class="login-input" placeholder="아이디"/>
<%--        <input type="text" name="userName" id="userName" class="login-input" placeholder="이름"/>--%>
        <input type="email" name="email" id="email" class="login-input" placeholder="이메일"/>

        <button id="btnSearchPassword" type="button" class="login-btn">비밀번호 찾기</button>

        <div class="signup-link">
            이미 계정이 있으신가요? <a href="#" id="btnLogin">ㅤ로그인</a>
        </div>

        <div class="login-options">
            <a>ㅤ</a>
            <a>ㅤ</a>
        </div>
    </form>
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
