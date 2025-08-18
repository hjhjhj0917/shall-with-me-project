<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>아이디 찾기</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/> <!-- 로그인과 같은 스타일 적용 -->

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <!-- jQuery -->
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            // 에러 스타일 제거
            $(document).on("click", function (e) {
                const $target = $(e.target);

                if (
                    !$target.is("#userName") &&
                    !$target.is("#email") &&
                    !$target.is("#btnSearchUserId")
                ) {
                    $(".login-input").removeClass("input-error");
                    $("#findIdErrorMessage").removeClass("visible");
                }
            });

            $(".login-tab").on("click", function () {
                location.href = "/user/login";
            });

            $(".login-tab2").on("click", function () {
                location.href = "/user/searchPassword";
            });

            $("#btnLogin").on("click", function () {
                location.href = "/user/login";
            });

            $("#btnSearchUserId").on("click", function () {
                let f = document.getElementById("f");
                let userName = f.userName.value.trim();
                let email = f.email.value.trim();

                $(".login-input").removeClass("input-error");
                $("#findIdErrorMessage").removeClass("visible").text("");

                if (userName === "") {
                    $("#userName").addClass("input-error");
                    $("#findIdErrorMessage").text("이름을 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findIdErrorMessage").removeClass("visible");
                    }, 2000);
                    $("#userName").focus();
                    return;
                }

                if (email === "") {
                    $("#email").addClass("input-error");
                    $("#findIdErrorMessage").text("이메일을 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findIdErrorMessage").removeClass("visible");
                    }, 2000);
                    $("#email").focus();
                    return;
                }

                // 전송
                f.method = "post";
                f.action = "/user/searchUserIdProc";
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

<!-- 아이디 찾기 폼 영역 -->
<div class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1 active-tab">FIND ID</div>
    <div class="login-tab2">FIND PW</div>

    <div class="header">
        <div class="logo">살며시</div>
        <div class="logo-2">Shall With Me</div>
    </div>

    <div id="findIdErrorMessage" class="error-message"></div>

    <form id="f">
        <input type="text" name="userName" id="userName" class="login-input" placeholder="이름" />
        <input type="email" name="email" id="email" class="login-input" placeholder="이메일" />

        <button id="btnSearchUserId" type="button" class="login-btn">아이디 찾기</button>

        <div class="signup-link">
            계정이 없으신가요? <a href="#" id="btnUserReg">ㅤ회원가입</a>
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
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
