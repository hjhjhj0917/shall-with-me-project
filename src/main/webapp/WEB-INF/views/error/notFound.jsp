<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>살며시: 페이지를 찾을 수 없습니다</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');

        :root {
            --primary-color: #3399ff;
            --primary-dark: #1c407d;
            --text-color: #555;
            --bg-color: #f8f9fa;
        }

        body {
            overflow: hidden;
        }

        .error-container {
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            height: 100%;
            padding: 20px;
            box-sizing: border-box;
        }

        .error-content {
            max-width: 500px;
            margin-bottom: 300px;
        }

        .error-illustration {
            width: 180px;
            height: 180px;
        }

        .error-code {
            font-size: 6rem;
            font-weight: 700;
            color: #e0e0e0;
            margin-bottom: 20px;
            line-height: 1;
        }

        .error-title {
            font-size: 1.75rem;
            font-weight: 600;
            color: #333;
            margin: -20px 0 15px 0;
        }

        .error-description {
            color: var(--text-color);
            margin-bottom: 30px;
            line-height: 1.7;
        }

        .home-btn {
            display: inline-block;
            padding: 12px 30px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 500;
            transition: background-color 0.3s ease, transform 0.3s ease;
        }

        .home-btn:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
        }
    </style>

</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="error-container">
    <div class="error-content">
        <svg class="error-illustration" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
            <path fill="#E0F7FA" d="M48.2,-64.1C62.1,-52.3,72.9,-36.5,76.5,-19.4C80.1,-2.3,76.5,16.2,67.6,31.2C58.7,46.2,44.4,57.7,28.8,65.8C13.3,73.9,-3.6,78.6,-20.1,75.1C-36.6,71.6,-52.7,59.9,-63.3,45.4C-73.9,30.9,-79,13.6,-78.3,-3.9C-77.6,-21.4,-71.1,-39.1,-59,-50.9C-47,-62.7,-29.3,-68.6,-13.2,-70.7C2.9,-72.8,17.4,-71,32,-69.5C46.6,-68,61.1,-72.1,60.8,-71.1" transform="translate(100 100) scale(1.1)" />
            <g transform="translate(65, 65) scale(0.7)">
                <path d="M50,7.5 L50,0 C50,-5.52 45.52,-10 40,-10 L-40,-10 C-45.52,-10 -50,-5.52 -50,0 L-50,7.5" fill="none" stroke="#B0BEC5" stroke-width="6" stroke-linecap="round"/>
                <circle cx="0" cy="30" r="12" fill="#CFD8DC"/>
                <line x1="0" y1="18" x2="0" y2="-10" stroke="#B0BEC5" stroke-width="6" stroke-linecap="round"/>
                <path d="M-15,30 A15,15 0 0,1 15,30" fill="none" stroke="#78909C" stroke-width="6" stroke-linecap="round" transform="translate(0, 15)"/>
                <circle cx="-25" cy="-25" r="5" fill="#FF7043"/>
                <circle cx="25" cy="-25" r="5" fill="#FF7043"/>
            </g>
        </svg>

        <h1 class="error-code">404</h1>
        <h2 class="error-title">길을 잃으셨나요?</h2>
        <p class="error-description">
            요청하신 페이지를 찾을 수 없습니다. <br>
            주소가 정확한지 다시 한번 확인해주시거나, 아래 버튼을 눌러 홈으로 돌아가주세요.
        </p>
        <a href="/user/main" class="home-btn">홈으로 돌아가기</a>
    </div>
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
