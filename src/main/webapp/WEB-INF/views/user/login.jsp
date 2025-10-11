<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>살며시: 로그인</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript">
        $(document).ready(function () {
            $("#btnUserReg").on("click", function () {
                location.href = "/user/userRegForm";
            });
            $("#btnSearchUserId").on("click", function () {
                location.href = "/user/searchUserId";
            });
            $("#btnSearchPassword").on("click", function () {
                location.href = "/user/searchPassword";
            });

            $("#password").on("keydown", function (e) {
                if (e.key === "Enter") {
                    $("#btnLogin").click();
                }
            })

            // 탭 클릭 시 해당 페이지로 이동
            $(".login-tab1").on("click", function () {
                location.href = "/user/searchUserId";
            });

            $(".login-tab2").on("click", function () {
                location.href = "/user/searchPassword";
            });

            $(document).on("click", function (e) {
                const $target = $(e.target);

                // 클릭한 요소가 input이나 로그인 버튼이 아니면 에러 스타일 제거
                if (
                    !$target.is("#userId") &&
                    !$target.is("#password") &&
                    !$target.is("#btnLogin")
                ) {
                    $(".login-input").removeClass("input-error");
                    $("#loginErrorMessage").removeClass("visible");
                }
            });

            $("#btnLogin").on("click", function () {
                let f = document.getElementById("f");
                let userId = f.userId.value.trim();
                let password = f.password.value.trim();
                let hasError = false;

                // 초기화
                $(".login-input").removeClass("input-error");
                $("#loginErrorMessage").removeClass("visible").text("");

                if (userId === "") {

                    $("#userId").addClass("input-error");
                    $("#loginErrorMessage")
                        .text("아이디를 입력하세요.")
                        .addClass("visible");

                    // 2초 후 메시지 자동 숨김
                    setTimeout(function () {
                        $("#loginErrorMessage").removeClass("visible");
                    }, 2000);

                    $("#userId").focus();
                    return;

                }
                if (password === "") {

                    $("#password").addClass("input-error");
                    $("#loginErrorMessage")
                        .text("비밀번호를 입력하세요.")
                        .addClass("visible");

                    // 2초 후 메시지 자동 숨김
                    setTimeout(function () {
                        $("#loginErrorMessage").removeClass("visible");
                    }, 2000);

                    $("#password").focus();
                    return;
                }

                if (hasError) return;

                $.ajax({
                    url: "/user/loginProc",
                    type: "post",
                    dataType: "JSON",
                    data: $("#f").serialize(),
                    success: function (json) {
                        if (json.result === 1) {
                            location.href = "/user/main";
                        } else if (json.result === 3) {
                            showCustomAlert(json.msg);
                            showCustomAlert("회원님의 성향태그를 선택하여주세요", function () {
                                location.href = "/user/userTagSelect";
                            });
                        } else {
                            $("#userId").addClass("input-error");
                            $("#loginErrorMessage")
                                .text(json.msg)
                                .addClass("visible");

                            // 2초 후 메시지 자동 숨김
                            setTimeout(function () {
                                $("#loginErrorMessage").removeClass("visible");
                            }, 2000);

                            $("#userId").focus();
                            return;

                        }
                    }
                });
            });
        });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<!-- 로그인 폼 영역 -->
<div class="login-form-wrapper">
    <div class="login-tab active-tab">LOGIN</div>
    <div class="login-tab1">FIND ID</div>
    <div class="login-tab2">FIND PW</div>
    <div class="header">
        <div class="logo">LOGIN</div>
        <div class="logo-2">살며시</div>
    </div>
    <div id="loginErrorMessage" class="error-message"></div>
    <form id="f">
        <input type="text" name="userId" id="userId" class="login-input" placeholder="아이디"/>
        <input type="password" name="password" id="password" class="login-input" placeholder="비밀번호"/>

        <button id="btnLogin" type="button" class="login-btn">로그인</button>

        <div class="signup-link">
            계정이 없으신가요? <a href="#" id="btnUserReg">ㅤ회원가입</a>
        </div>

        <div class="login-options">
            <a></a>
            <a>ㅤ</a>
        </div>
    </form>
</div>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp" %>

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
