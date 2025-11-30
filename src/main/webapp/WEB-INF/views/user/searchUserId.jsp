<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>살며시: 아이디 찾기</title>


    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/> <!-- 로그인과 같은 스타일 적용 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>


    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>


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
            margin-bottom: 45px;
        }

        .user-info-display {
            text-align: left;
            margin-bottom: 30px;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
        }

        .info-label {
            font-weight: bold;
            color: #555;
            width: 60px;
            flex-shrink: 0;
        }

        .info-value {
            color: #333;
            text-align: right;
            flex-grow: 1;
        }

        .userid-value {
            color: #3399ff;
            font-weight: bold;
        }


    </style>

    <script type="text/javascript">
        $(document).ready(function () {

            $(document).on("click", function (e) {
                const $target = $(e.target);

                if (
                    !$target.is("#userName") &&
                    !$target.is("#email") &&
                    !$target.is("#btnSearchUserId") &&
                    !$target.is("#authNum") &&
                    !$target.is("#btnAuthNum")
                ) {
                    $(".login-input").removeClass("input-error");
                    $("#findIdErrorMessage").removeClass("visible");
                    $("#findIdErrorMessage1").removeClass("visible");
                }
            });

            let f = document.getElementById("f");
            let f2 = document.getElementById("f2");

            // 로그인 이동 탭
            $(".login-tab").on("click", function () {
                location.href = "/user/login";
            });

            // 비밀번호 찾기 탭
            $(".login-tab2").on("click", function () {
                location.href = "/user/searchPassword";
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
            $("#btnSearchUserId").on("click", function () {
                emailExists(f)
            });

            // 인증번호 전송 버튼
            $("#btnAuthNum").on("click", function () {
                doCheck(f2)
            });

            // 입력한 정보 확인
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

                            document.getElementById("hiddenUserName").value = f.userName.value;
                            document.getElementById("hiddenEmail").value = f.email.value;

                        } else {
                            $("#userName").addClass("input-error");
                            $("#findIdErrorMessage").text("존재하지 않는 이름 또는 메일 입니다.").addClass("visible");
                            setTimeout(() => {
                                $("#findIdErrorMessage").removeClass("visible");
                            }, 2000);
                            $("#userName").focus();
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

                            $("#displayUserName").text(json.name); // <span id="displayUserName">에
                            $("#displayUserId").text(json.msg);   // <span id="displayUserId">에 아이

                            step2.style.display = 'none';
                            step3.style.display = 'block';

                        } else {
                            showCustomAlert(json.msg);
                        }
                    }
                })
            }
        });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<!-- 아이디 찾기 폼 영역1 -->
<div id="step1" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1 active-tab">FIND ID</div>
    <div class="login-tab2">FIND PW</div>

    <div class="header">
        <div class="logo">FIND ID</div>
        <div class="logo-2">살며시</div>
    </div>

    <div id="findIdErrorMessage" class="error-message"></div>

    <form id="f">
        <input type="text" name="userName" id="userName" class="login-input" placeholder="이름"/>
        <input type="email" name="email" id="email" class="login-input" placeholder="이메일"/>

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

<!-- 아이디 찾기 폼 영역2 -->
<div id="step2" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1 active-tab">FIND ID</div>
    <div class="login-tab2">FIND PW</div>

    <div class="header">
        <div class="logo">FIND ID</div>
        <div class="logo-2">살며시</div>
    </div>

    <div id="findIdErrorMessage1" class="error-message"></div>

    <form id="f2">
        <input type="hidden" name="userName" id="hiddenUserName"/>
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

<!-- 아이디 찾기 폼 영역3 -->
<div id="step3" class="login-form-wrapper">
    <div class="login-tab">LOGIN</div>
    <div class="login-tab1 active-tab">FIND ID</div>
    <div class="login-tab2">FIND PW</div>

    <form id="f3">
        <div class="completion-icon-wrapper">
            <i class="fas fa-check-circle completion-icon"></i>
        </div>
        <h2 class="completion-message">아이디 찾기 완료</h2>

        <div class="user-info-display">
            <div class="info-row">
                <span class="info-label">이름</span>
                <span id="displayUserName" class="info-value"></span>
            </div>
            <div class="info-row">
                <span class="info-label">아이디</span>
                <span id="displayUserId" class="info-value userid-value"></span>
            </div>
        </div>

        <button id="btnLogin" type="button" class="login-btn">로그인</button>

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
