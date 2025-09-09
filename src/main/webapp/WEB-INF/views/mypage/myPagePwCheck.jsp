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
    </style>
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
            <div class="form-row">
                <label for="password">현재 비밀번호</label>
                <input type="password" id="password" name="password" placeholder="비밀번호를 입력하세요" >
            </div>

            <p class="error-msg" id="errorMsg"></p>

            <div class="form-actions">
                <button type="submit" class="confirm-btn">확인</button>
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
