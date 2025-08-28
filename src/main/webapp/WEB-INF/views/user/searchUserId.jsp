<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>살며시: 아이디 찾기</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/> <!-- 로그인과 같은 스타일 적용 -->

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <!-- jQuery -->
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        #step2, #step3 {
            display: none;
        }
    </style>

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

            let f = document.getElementById("f");
            let f2 = document.getElementById("f2");


            $(".login-tab").on("click", function () {
                location.href = "/user/login";
            });

            $(".login-tab2").on("click", function () {
                location.href = "/user/searchPassword";
            });

            $("#btnLogin").on("click", function () {
                location.href = "/user/login";
            });

            $("#btnUserReg").on("click", function () {
                location.href = "/user/userRegForm";
            });

            $("#btnSearchUserId").on("click", function () {
                emailExists(f)
            });

            $("#btnAuthNum").on("click", function () {
                doCheck(f2)
            });

            function emailExists(f) {
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

                $.ajax({
                    url: "/user/emailAuthNumber",
                    type: "post",
                    dataType: "JSON",
                    data: $("#f").serialize(),
                    success: function (json) {
                        if (json.existsYn === "Y") {

                            step1.style.display = 'none';
                            step2.style.display = 'block';

                            emailAuthNumber = json.authNumber;

                        } else {
                            showError("존재하지 않는 이름 또는 메일 입니다.")
                            f.email.focus();
                        }
                    }
                })
            }
            function doCheck(f2) {

                let authNum = f2.authNum.value.trim();

                if (authNum === "") {
                    $("#authNum").addClass("input-error");
                    $("#findIdErrorMessage1").text("인증번호를 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#findIdErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#authNum").focus();
                    return;
                }

                if (parseInt(authNum) !== emailAuthNumber) {
                    $("#authNum").addClass("input-error");
                    $("#findIdErrorMessage1").text("잘못된 인증번호 입니다.").addClass("visible");
                    setTimeout(() => {
                        $("#findIdErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#authNum").focus();
                    return;
                }

                $.ajax({
                    url: "/user/searchUserIdProc",
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

            // $("#btnSearchUserId").on("click", function () {
            //     let f = document.getElementById("f");
            //     let userName = f.userName.value.trim();
            //     let email = f.email.value.trim();
            //
            //     $(".login-input").removeClass("input-error");
            //     $("#findIdErrorMessage").removeClass("visible").text("");
            //
            //     if (userName === "") {
            //         $("#userName").addClass("input-error");
            //         $("#findIdErrorMessage").text("이름을 입력하세요.").addClass("visible");
            //         setTimeout(() => {
            //             $("#findIdErrorMessage").removeClass("visible");
            //         }, 2000);
            //         $("#userName").focus();
            //         return;
            //     }
            //
            //     if (email === "") {
            //         $("#email").addClass("input-error");
            //         $("#findIdErrorMessage").text("이메일을 입력하세요.").addClass("visible");
            //         setTimeout(() => {
            //             $("#findIdErrorMessage").removeClass("visible");
            //         }, 2000);
            //         $("#email").focus();
            //         return;
            //     }
            //
            //     // 전송
            //     f.method = "post";
            //     f.action = "/user/searchUserIdProc";
            //     f.submit();
            // });
        });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp"%>

<!-- 아이디 찾기 폼 영역 -->
<div id="step1" class="login-form-wrapper">
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

<div id="step2" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1 active-tab">FIND ID</div>
    <div class="login-tab2">FIND PW</div>

    <div class="header">
        <div class="logo">살며시</div>
        <div class="logo-2">Shall With Me</div>
    </div>

    <div id="findIdErrorMessage1" class="error-message"></div>

    <form id="f2">
        <input type="text" name="userName" id="authNum" class="login-input" placeholder="인증번호" />
        <input class="login-input">

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
    <div class="login-tab1 active-tab">FIND ID</div>
    <div class="login-tab2">FIND PW</div>

    <div class="header">
        <div class="logo">살며시</div>
        <div class="logo-2">Shall With Me</div>
    </div>

    <div class="error-message"></div>

    <form>
        <input>
        <input>

        <button type="button" class="login-btn">인증번호 확인</button>

        <div class="signup-link">
            계정이 없으신가요? <a href="#" id="btnUserReg3">ㅤ회원가입</a>
        </div>

        <div class="login-options">
            <a>ㅤ</a>
            <a>ㅤ</a>
        </div>
    </form>
</div>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp"%>

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
