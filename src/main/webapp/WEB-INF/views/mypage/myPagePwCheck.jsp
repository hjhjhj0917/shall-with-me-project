<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 비밀번호 확인</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sideBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <style>
        /* --- mypage.css --- */

        /* 전체 메인 콘텐츠 영역 패딩 */

        .sidebar-main-content {
            margin-top: 50px;
            padding: 40px;
        }

        /* 비밀번호 확인 폼 전체를 감싸는 컨테이너 */
        .confirm-password-wrapper {
            max-width: 900px;
            margin: 0 auto;
            padding: 40px;
            background-color: #ffffff;
            border-radius: 12px;
        }

        /* 상단 헤더 (제목, 설명) */
        .confirm-header {
            display: flex;           /* ✅ Flexbox 레이아웃 적용 */
            flex-direction: column;  /* ✅ 자식 요소(h1, p)를 세로로 쌓기 */
            align-items: center; /* ✅ 왼쪽 정렬 */
            text-align: left;
            border-bottom: 1px solid #e9ecef;
            margin-bottom: 30px;
        }

        .confirm-header h1 {
            font-size: 30px;
            color: #333;
        }

        .confirm-header p {
            padding-top: 30px;
            font-size: 15px;
            color: #666;
        }

        /* 폼 행 (라벨 + 값/입력) */
        .form-row {
            display: flex;
            align-items: center;
            padding: 20px 0;
            border-bottom: 1px solid #e9ecef;
        }
        .form-row:last-of-type {
            border-bottom: none;
        }

        .form-row label {
            width: 150px; /* 라벨 너비 고정 */
            flex-shrink: 0;
            font-weight: 500;
            color: #444;
        }

        .form-row .user-id-display {
            font-weight: 500;
            color: #111;
        }

        .form-row input {
            flex-grow: 1; /* 남은 공간을 모두 차지 */
            padding: 10px 12px;
            border: 1px solid #ccc;
            border-radius: 3px;
            font-size: 1rem;
        }

        .form-row input::placeholder {
            font-size: 13px;
        }

        /* 에러 메시지 */
        .error-msg {
            color: #e53e3e;
            font-size: 0.9rem;
            height: 20px; /* 레이아웃이 밀리지 않도록 높이 고정 */
            margin-top: 10px;
            text-align: right;
        }

        /* 버튼 영역 */
        .form-actions {
            margin-top: 30px;
            text-align: right;
        }
        .confirm-btn {
            padding: 12px 28px;
            background-color: #3399ff;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .confirm-btn:hover {
            background-color: #1c84ff;
        }

        /*에러 메시지*/
        .error-message {
            color: #3399ff;
            font-size: 14px;
            text-align: left;          /* 왼쪽 정렬 */
            height: 5px;              /* 고정 높이로 레이아웃 안정 */
            padding-left: 150px;
            padding-top: 10px;
            visibility: hidden;        /* 기본은 숨김, 자리 차지는 유지 */
        }

        .error-message.visible {
            visibility: visible;       /* 메시지가 있을 때 표시 */
        }

        /*input 디자인*/
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
    </style>

    <script>
        $(document).ready(function () {

            $(document).on("click", function (e) {
                const $target = $(e.target);

                // 클릭한 요소가 input이나 로그인 버튼이 아니면 에러 스타일 제거
                if (
                    !$target.is("#password") &&
                    !$target.is("#mypagePwCkBtn")
                ) {
                    $(".login-input").removeClass("input-error");
                    $("#mypageErrorMessage").removeClass("visible");
                }
            });

            // 폼 제출 기본 동작 막기
            $("#passwordConfirmForm").on("submit", function (e) {
                e.preventDefault();
            });

            // 엔터로도 작동하도록 개선 (선택)
            $("#password").on("keyup", function (e) {
                if (e.key === "Enter") {
                    $("#mypagePwCkBtn").click();
                }
            });

            $("#mypagePwCkBtn").on("click", function () {
                let f = document.getElementById("passwordConfirmForm");
                let password = f.password.value.trim();
                let hasError = false;

                // 초기화
                $(".login-input").removeClass("input-error");
                $("#mypageErrorMessage").removeClass("visible").text("");

                if (password === "") {

                    $("#password").addClass("input-error");
                    $("#mypageErrorMessage")
                        .text("비밀번호를 입력하세요.")
                        .addClass("visible");

                    // 2초 후 메시지 자동 숨김
                    setTimeout(function () {
                        $("#mypageErrorMessage").removeClass("visible");
                    }, 2000);

                    $("#password").focus();
                    return;
                }

                if (hasError) return;

                $.ajax({
                    url: "/mypage/pwCheckProc",
                    type: "post",
                    dataType: "JSON",
                    data: {"password" : password},
                    success: function (json) {
                        if (json.result === 1) {

                            location.href = "<%= session.getAttribute("MYPAGE_TARGET_URL") %>";

                        } else {
                            $("#password").addClass("input-error");
                            $("#mypageErrorMessage")
                                .text(json.msg)
                                .addClass("visible");

                            // 2초 후 메시지 자동 숨김
                            setTimeout(function () {
                                $("#mypageErrorMessage").removeClass("visible");
                            }, 2000);

                            $("#password").focus();
                            return;

                        }
                    }
                });
            });
        });
    </script>
</head>
<body>
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<%--사이드바--%>
<%@ include file="../includes/sideBar.jsp" %>

<main class="sidebar-main-content">
    <div class="confirm-password-wrapper">
        <div class="confirm-header">
            <h1>마이페이지</h1>
            <p>회원님의 정보를 안전하게 보호하기 위해 비밀번호를 다시 한번 확인합니다.</p>
        </div>

        <form id="passwordConfirmForm" class="confirm-form">

            <div class="form-row">
                <label>아이디</label>
                <span class="user-id-display"><%= session.getAttribute("SS_USER_ID") %></span>
            </div>
            <div class="error-message" id="mypageErrorMessage"></div>
            <div class="form-row">
                <label for="password">현재 비밀번호</label>
                <input type="password" id="password" name="password" class="login-input" placeholder="비밀번호를 입력하세요" >
            </div>

            <div class="form-actions">
                <button type="button" id="mypagePwCkBtn" class="confirm-btn">확인</button>
            </div>
        </form>
    </div>
</main>

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
