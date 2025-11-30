<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>살며시: 비밀번호 찾기</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>

    <!-- jQuery -->
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        #step2, #step3 {
            display: none;
        }

        #step3 {
            height: 454px;
        }

        .completion-icon-wrapper {
            margin-top: 20px;
            margin-bottom: 10px;
        }

        .completion-icon {
            font-size: 50px;
            color: #4da3ff;
        }

        .completion-message {
            font-size: 22px;
            font-weight: bold;
            color: #333;
            margin-bottom: 43px;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {

            // 에러 스타일 제거
            $(document).on("click", function (e) {
                const $target = $(e.target);

                if (
                    !$target.is("#userId") &&
                    !$target.is("#email") &&
                    !$target.is("#btnSearchPassword") &&
                    !$target.is("#authNum") &&
                    !$target.is("#btnauthNum") &&
                    !$target.is("#userPw") &&
                    !$target.is("#pwCheck") &&
                    !$target.is("#btnUpdatePw")

                ) {
                    $(".login-input").removeClass("input-error");
                    $("#findPwErrorMessage").removeClass("visible");
                    $("#findPwErrorMessage1").removeClass("visible");
                    $("#findPwErrorMessage2").removeClass("visible");
                }
            });

            let f = document.getElementById("f");
            let f2 = document.getElementById("f2");
            let f3 = document.getElementById("f3");

            // 로그인 이동 탭
            $(".login-tab").on("click", function () {
                location.href = "/user/login";
            });

            // 아이디 찾기 이동 탭
            $(".login-tab1").on("click", function () {
                location.href = "/user/searchUserId";
            });

            // 로그인 이동 버튼
            $("#btnLogin").on("click", function () {
                location.href = "/user/login";
            });

            // 회원가입 이동
            $("#btnUserReg").on("click", function () {
                location.href = "/user/userRegForm";
            });

            $("#btnUserReg1").on("click", function () {
                location.href = "/user/userRegForm";
            });

            $("#btnUserReg2").on("click", function () {
                location.href = "/user/userRegForm";
            });

            // 회원정보 조회 버튼
            $("#btnSearchPassword").on("click", function () {
                emailExists(f)
            });

            // 인증번호 전송 버튼
            $("#btnAuthNum").on("click", function () {
                doCheck(f2)
            });

            // 비밀번호 변경
            $("#btnUpdatePw").on("click", function () {
                pwUpdate(f3)
            });

            // 입력한 정보 확인
            function emailExists(f) {
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

                $.ajax({
                    url: "/user/emailAuthNumberPw",
                    type: "post",
                    dataType: "JSON",
                    data: $("#f").serialize(),
                    success: function (json) {
                        if (json.existsYn === "Y") {

                            step1.style.display = 'none';
                            step2.style.display = 'block';

                            emailAuthNumber = json.authNumber;

                            document.getElementById("hiddenUserId").value = f.userId.value;
                            document.getElementById("hiddenEmail").value = f.email.value;

                        } else {
                            $("#userId").addClass("input-error");
                            $("#findPwErrorMessage").text("존재하지 않는 아이디 또는 메일 입니다.").addClass("visible");
                            setTimeout(() => {
                                $("#findPwErrorMessage").removeClass("visible");
                            }, 2000);
                            $("#userId").focus();
                            return;
                        }
                    }
                })
            }

            // 인증번호 확인
            function doCheck(f2) {

                let authNum = f2.authNum.value.trim();

                if (authNum === "") {
                    $("#authNum").addClass("input-error");
                    $("#findPwErrorMessage1").text("인증번호를 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#authNum").focus();
                    return;
                }

                if (parseInt(authNum) !== emailAuthNumber) {
                    $("#authNum").addClass("input-error");
                    $("#findPwErrorMessage1").text("잘못된 인증번호 입니다.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#authNum").focus();
                    return;
                }

                $.ajax({
                    url: "/user/searchPasswordProc",
                    type: "post",
                    dataType: "JSON",
                    data: $("#f2").serialize(),
                    success: function (json) {

                        if (json.result === 1) {

                            step2.style.display = 'none';
                            step3.style.display = 'block';

                        } else {
                            showCustomAlert(json.msg);
                        }
                    }
                })
            }

            // 비밀번호 변경
            function pwUpdate(f3) {
                let userPw = f3.userPw.value.trim();
                let pwCheck = f3.pwCheck.value.trim();

                $(".login-input").removeClass("input-error");
                $("#findPwErrorMessage2").removeClass("visible").text("");

                if (userPw === "") {
                    $("#userPw").addClass("input-error");
                    $("#findPwErrorMessage2").text("새로운 비밀번호를 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage2").removeClass("visible");
                    }, 2000);
                    $("#userPw").focus();
                    return;
                }

                if (pwCheck === "") {
                    $("#pwCheck").addClass("input-error");
                    $("#findPwErrorMessage2").text("검증을 위한 새로운 비밀번호를 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage2").removeClass("visible");
                    }, 2000);
                    $("#pwCheck").focus();
                    return;
                }

                if (userPw !== pwCheck) {
                    $("#pwCheck").addClass("input-error");
                    $("#findPwErrorMessage2").text("입력한 비밀번호가 일치하지 않습니다.").addClass("visible");
                    setTimeout(() => {
                        $("#findPwErrorMessage2").removeClass("visible");
                    }, 2000);
                    $("#pwCheck").focus();
                    return;
                }

                $.ajax({
                    url: "/user/newPasswordProc",
                    type: "post",
                    dataType: "JSON",
                    data: $("#f3").serialize(),
                    success: function (json) {
                        if (json.result === "1") {
                            showCustomAlert(json.msg, function () {
                                location.href = "/user/login"
                            })

                        } else {
                            showCustomAlert(json.msg, function () {
                                location.href = "/user/login"
                            })
                        }
                    }
                })
            }
        });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<!-- 비밀번호 찾기 폼 영역1 -->
<div id="step1" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1">FIND ID</div>
    <div class="login-tab2 active-tab">FIND PW</div>
    <div class="header">
        <div class="logo">FIND PW</div>
        <div class="logo-2">살며시</div>
    </div>

    <div id="findPwErrorMessage" class="error-message"></div>

    <form id="f">
        <input type="text" name="userId" id="userId" class="login-input" placeholder="아이디"/>
        <input type="email" name="email" id="email" class="login-input" placeholder="이메일"/>

        <button id="btnSearchPassword" type="button" class="login-btn">비밀번호 찾기</button>

        <div class="signup-link">
            계정이 없으신가요? <a href="#" id="btnUserReg">ㅤ회원가입</a>
        </div>

        <div class="login-options">
            <a>ㅤ</a>
            <a>ㅤ</a>
        </div>
    </form>
</div>

<!-- 비밀번호 찾기 폼 영역2 -->
<div id="step2" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1">FIND ID</div>
    <div class="login-tab2 active-tab">FIND PW</div>

    <div class="header">
        <div class="logo">FIND PW</div>
        <div class="logo-2">살며시</div>
    </div>

    <div id="findPwErrorMessage1" class="error-message"></div>

    <form id="f2">
        <input type="hidden" name="userId" id="hiddenUserId"/>
        <input type="hidden" name="email" id="hiddenEmail"/>
        <input type="text" name="authNum" id="authNum" class="login-input" placeholder="인증번호"/>
        <input class="login-input" id="notExists" placeholder="인증번호" tabindex="-1">

        <button id="btnAuthNum" type="button" class="login-btn">인증번호 확인</button>

        <div class="signup-link">
            계정이 없으신가요? <a href="#" id="btnUserReg1">ㅤ회원가입</a>
        </div>

        <div class="login-options">
            <a>ㅤ</a>
            <a>ㅤ</a>
        </div>
    </form>
</div>


<div id="step3" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1">FIND ID</div>
    <div class="login-tab2 active-tab">FIND PW</div>

    <div class="completion-icon-wrapper">
        <i class="fas fa-check-circle completion-icon"></i>
    </div>
    <h2 class="completion-message">비밀번호 변경</h2>

    <div id="findPwErrorMessage2" class="error-message"></div>

    <form id="f3">
        <input type="password" name="userPw" id="userPw" class="login-input" placeholder="비밀번호"/>
        <input type="password" name="pwCheck" id="pwCheck" class="login-input" placeholder="비밀번호 확인"/>

        <button id="btnUpdatePw" type="button" class="login-btn">비밀번호 변경</button>

        <div class="signup-link">
            계정이 없으신가요? <a href="#" id="btnUserReg2">ㅤ회원가입</a>
        </div>

        <div class="login-options">
            <a>ㅤ</a>
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
