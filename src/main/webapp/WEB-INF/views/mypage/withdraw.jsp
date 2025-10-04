<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 회원 탈퇴</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sideBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        body {
            background: linear-gradient(to right, white, #f9f9f9);
        }

        .logo {
            color: black;
            font-size: 50px;
            font-weight: 300;
            text-align: left;
        }

        .logo-2 {
            font-size: 15px;
            margin-top: 60px;
            color: #555;
            text-align: left;
        }

        .header {
            text-align: left;
            margin-top: 10px;
        }

        .login-form-wrapper {
            width: 500px;
            margin: 10px auto;
            padding: 24px;
            background-color: #ffffff;
            border-radius: 12px;
            /*box-shadow: -3px -3px 16px rgba(0, 0, 0, 0.1),  !* 왼쪽 위쪽 그림자 진하게 *!*/
            /*6px 5px 16px rgba(0, 0, 0, 0.27);  !* 기존 그림자 유지 *!*/
            position: relative;
            text-align: center;
            min-width: 300px;
        }

        #f {
            padding-top: 20px;
        }

        /* 입력 필드 */
        .login-input {
            width: 100%;
            padding: 12px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            box-sizing: border-box;
        }

        .login-input:focus {
            border-color: #3399ff;
            box-shadow: 0 0 0 2px rgba(51, 153, 255, 0.2);
        }

        /* 자동 로그인 & 비밀번호 찾기 */
        .login-options {
            padding-top: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            color: #666;
            margin: 8px 0 16px;
        }

        .login-options input {
            margin-right: 4px;
        }

        .login-options a {
            text-decoration: none;
            color: #3399ff;
        }

        /* 로그인 버튼 */
        .login-btn {
            width: 100%;
            background-color: #3399ff;
            color: white;
            padding: 12px;
            margin-top: 10px;
            font-size: 14px;
            font-weight: bold;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: 0.2s;
        }

        .login-btn:hover {
            background-color: #3399ff;
        }

        /* 회원가입 링크 */
        .signup-link {
            margin-top: 18px;
            font-size: 12px;
            text-align: left;
        }

        .signup-link a {
            color: #3399ff;
            text-decoration: none;
        }

        /* 소셜 로그인 */
        .social-login {
            margin-top: 20px;
            display: flex;
            justify-content: center;
            gap: 16px;
        }

        .social-btn {
            border: 1px solid #ddd;
            padding: 8px 14px;
            border-radius: 6px;
            cursor: pointer;
            background-color: white;
            transition: 0.2s;
        }

        .social-btn:hover {
            background-color: #f9f9f9;
        }

        .social-btn img {
            width: 20px;
            height: 20px;
        }

        a {
            cursor: pointer;
        }

        #withdrawErrorMessage1 {
            color: #3399ff;
            font-size: 14px;
            text-align: left; /* 왼쪽 정렬 */
            height: 5px; /* 고정 높이로 레이아웃 안정 */
            padding-left: 5px;
            visibility: hidden; /* 기본은 숨김, 자리 차지는 유지 */
            margin-bottom: 20px;
        }

        #withdrawErrorMessage1.visible {
            visibility: visible; /* 메시지가 있을 때 표시 */
        }

        #notExists {
            opacity: 0;
            pointer-events: none;
        }

        .error-message {
            color: #3399ff;
            font-size: 14px;
            text-align: left; /* 왼쪽 정렬 */
            height: 5px; /* 고정 높이로 레이아웃 안정 */
            padding-left: 5px;
            visibility: hidden; /* 기본은 숨김, 자리 차지는 유지 */
        }

        .error-message.visible {
            visibility: visible; /* 메시지가 있을 때 표시 */
        }

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
            font-size: 50px; /* 아이콘 크기 */
            color: #4da3ff; /* 아이콘 색상 */
        }

        .completion-message {
            font-size: 22px;
            font-weight: bold;
            color: #333;
            margin-bottom: 43px;
        }
    </style>

    <script>
        $(document).ready(function () {

            // 에러 스타일 제거
            $(document).on("click", function (e) {
                const $target = $(e.target);

                if (
                    !$target.is("#email") &&
                    !$target.is("#withdrawNextBtn") &&
                    !$target.is("#authNum") &&
                    !$target.is("#btnauthNum") &&
                    !$target.is("#userPw") &&
                    !$target.is("#pwCheck") &&
                    !$target.is("#btnUpdatePw")

                ) {
                    $(".login-input").removeClass("input-error");
                    $("#withdrawErrorMessage").removeClass("visible");
                    $("#withdrawErrorMessage1").removeClass("visible");
                }
            });

            let f = document.getElementById("f");
            let f2 = document.getElementById("f2");

            // 회원 탈퇴 진행시 이메일 확인 후 다음 이동
            $("#withdrawNextBtn").on("click", function () {
                emailExists(f)
            });
            // 비밀번호 변경
            $("#btnUpdatePw").on("click", function () {
                withdrawPwCheck(f2)
            });

            // 입력한 이메일 정보 확인
            function emailExists(f) {
                let email = f.email.value.trim();

                $(".login-input").removeClass("input-error");
                $("#withdrawErrorMessage").removeClass("visible").text("");

                if (email === "") {
                    $("#email").addClass("input-error");
                    $("#withdrawErrorMessage").text("이메일을 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#withdrawErrorMessage").removeClass("visible");
                    }, 2000);
                    $("#email").focus();
                    return;
                }

                $.ajax({
                    url: "/mypage/withdrawEmailChk",
                    type: "post",
                    dataType: "JSON",
                    data: {"email": email},
                    success: function (json) {
                        if (json.existsYn === "Y") {

                            step1.style.display = 'none';
                            step2.style.display = 'block';

                            // document.getElementById("hiddenEmail").value = f.email.value;

                        } else {
                            $("#email").addClass("input-error");
                            $("#withdrawErrorMessage").text("메일이 일치하지 않습니다.").addClass("visible");
                            setTimeout(() => {
                                $("#withdrawErrorMessage").removeClass("visible");
                            }, 2000);
                            $("#email").focus();
                            return;
                        }
                    }
                })
            }

            // 회원탈퇴 마지막 비밀번호 확인
            function withdrawPwCheck(f2) {
                let userPw = f2.userPw.value.trim();
                let pwCheck = f2.pwCheck.value.trim();

                $(".login-input").removeClass("input-error");
                $("#withdrawErrorMessage1").removeClass("visible").text("");

                if (userPw === "") {
                    $("#userPw").addClass("input-error");
                    $("#withdrawErrorMessage1").text("비밀번호를 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#withdrawErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#userPw").focus();
                    return;
                }

                if (pwCheck === "") {
                    $("#pwCheck").addClass("input-error");
                    $("#withdrawErrorMessage1").text("비밀번호 확인란을 입력하세요.").addClass("visible");
                    setTimeout(() => {
                        $("#withdrawErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#pwCheck").focus();
                    return;
                }

                if (userPw !== pwCheck) {
                    $("#pwCheck").addClass("input-error");
                    $("#withdrawErrorMessage1").text("입력한 비밀번호가 일치하지 않습니다.").addClass("visible");
                    setTimeout(() => {
                        $("#withdrawErrorMessage1").removeClass("visible");
                    }, 2000);
                    $("#pwCheck").focus();
                    return;
                }

                showCustomConfirm("정말 회원 탈퇴를 진행하시겠습니다.", function () {
                    $.ajax({
                        url: "/mypage/withdrawProc",
                        type: "Post",
                        dataType: "json",
                        data: {"password": userPw},
                        success: function (res) {
                            if (res.result === 1) {
                                showCustomAlert(res.msg, function () {
                                    location.href = '/'
                                });

                            } else {
                                showCustomAlert(res.msg);
                            }
                        },
                        error: function () {
                            showCustomAlert("서버 통신 중 오류가 발생했습니다.");
                        }
                    });
                });
            }
        });
    </script>

</head>
<body>
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<div class="main-container">
    <%--사이드바--%>
    <%@ include file="../includes/sideBar.jsp" %>

    <main class="sidebar-main-content">
        <div id="step1" class="login-form-wrapper">

            <div class="header">
                <div class="logo">회원 탈퇴하기</div>
                <div class="logo-2">
                    <p>회원 탈퇴를 진행하기 전에 아래 내용을 반드시 확인해주시기 바랍니다. 탈퇴 시 모든 정보는 어떤 경우에도 복구가 불가능합니다.</p>
                    <br>
                    <strong>삭제되는 정보:</strong>
                    <ul>
                        <li><strong>계정 정보:</strong> 아이디, 이름, 이메일을 포함한 모든 개인 정보</li>
                        <li>
                            <strong>활동 기록:</strong> 프로필 정보, 성향 태그, 쉐어하우스 및 룸메이트
                            <br>ㅤㅤㅤㅤㅤ관련 정보
                        </li>
                        <li><strong>커뮤니케이션 기록:</strong> 모든 대화 상대와의 채팅 기록 및 약속 일정</li>
                    </ul>
                    <br>
                    <p>위 내용에 모두 동의하시고 탈퇴를 계속 진행하시려면, 계정 소유자 확인을 위해 이메일 주소를 입력 후 '다음' 버튼을 눌러주세요.</p>
                </div>
            </div>

            <div id="withdrawErrorMessage" class="error-message"></div>

            <form id="f">

                <input type="email" name="email" id="email" class="login-input" placeholder="이메일"/>
                <button id="withdrawNextBtn" type="button" class="login-btn">다음</button>

                <div class="signup-link">
                    회원 탈퇴를 진행하시면 더이상 사이트를 이용하실 수 없습니다.
                </div>

                <div class="login-options">
                    <a>ㅤ</a>
                    <a>ㅤ</a>
                </div>
            </form>
        </div>

        <!-- 회원 탈퇴 비밀번호 확인 -->
        <div id="step2" class="login-form-wrapper">

            <div class="header">
                <div class="logo">회원 탈퇴하기</div>
                <div class="logo-2">
                    <p>본인 확인이 완료되었습니다. 회원 탈퇴를 계속 진행하려면 계정의 비밀번호를 입력해주세요.</p>
                    <br>
                    <p>'탈퇴하기' 버튼을 누르는 즉시 계정 삭제 절차가 시작되며, 이는 최종적이고 취소할 수 없습니다.
                        <br>이전에 안내된 바와 같이 회원님의 모든 개인정보, 프로필, 채팅 기록, 일정 등 모든 데이터가 영구적으로 파기됩니다.
                        <br>모든 내용에 동의하시는 경우에만 비밀번호를 입력하고 탈퇴를 완료해주시기 바랍니다.</p>
                </div>
            </div>

            <div id="withdrawErrorMessage1" class="error-message"></div>

            <form id="f2">
                <input type="password" name="userPw" id="userPw" class="login-input" placeholder="비밀번호"/>
                <input type="password" name="pwCheck" id="pwCheck" class="login-input" placeholder="비밀번호 확인"/>

                <button id="btnUpdatePw" type="button" class="login-btn">회원 탈퇴</button>

                <div class="signup-link">
                    회원 탈퇴를 진행하시면 더이상 사이트를 이용하실 수 없습니다.
                </div>

                <div class="login-options">
                    <a>ㅤ</a>
                    <a>ㅤ</a>
                </div>
            </form>
        </div>

    </main>
</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/footer.jsp" %>
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
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>

</body>
</html>
