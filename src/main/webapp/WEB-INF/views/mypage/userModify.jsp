<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 개인정보/프로필 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sideBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        /* --- mypage.css --- */

        /* 전체 메인 콘텐츠 영역 */
        .sidebar-main-content {
            padding: 40px;
        }

        .mypage-wrapper {
            max-width: 1200px;
            margin: 80px auto;
        }

        .mypage-title {
            font-size: 2rem;
            font-weight: 800;
            color: #333;
            margin-bottom: 30px;
            text-align: center;
        }

        /* 카드 그리드 레이아웃 */
        .mypage-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr); /* 2개의 열을 동일한 너비로 */
            gap: 30px; /* 카드 사이의 간격 */
        }

        /* 카드 공통 스타일 */
        .mypage-card {
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #e9ecef;
        }

        .card-header h3 {
            margin: 0;
            font-size: 1.1rem;
            font-weight: 600;
        }

        .card-body {
            padding: 24px;
            flex-grow: 1; /* 카드가 남은 공간을 모두 채우도록 */
        }

        /* 카드별 특화 스타일 */
        .profile-section {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .profile-pic-placeholder {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            border: 2px solid #DAEDFF;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
            font-size: 2rem;
            flex-shrink: 0;
        }
        .profile-info .profile-name {
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 8px;
            display: block;
        }
        .profile-contact {
            display: flex;
            flex-direction: column;
            gap: 6px;
            font-size: 0.9rem;
            color: #555;
        }
        .profile-contact i {
            margin-right: 8px;
            color: #888;
        }

        .empty-content {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            min-height: 150px;
            color: #888;
        }

        /* 버튼 및 링크 스타일 */
        .card-action-btn.active {
            background: none;
            border: 1px solid #3399ff;
            color: #3399ff;
            padding: 6px 12px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
        }
        .card-primary-btn {
            margin-top: 16px;
            background-color: #3399ff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
        }
        .card-link {
            font-size: 0.9rem;
            color: #666;
            text-decoration: none;
        }

        /* 반응형: 화면이 좁아지면 1열로 변경 */
        @media (max-width: 992px) {
            .mypage-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<%--사이드바--%>
<%@ include file="../includes/sideBar.jsp" %>

<main class="sidebar-main-content">
    <div class="mypage-wrapper">
        <h1 class="mypage-title"></h1>

        <div class="mypage-grid">

            <!-- 정보 수정 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>정보 수정</h3>
                    <a href="/mypage/profileEdit" class="card-action-btn active">수정하기</a>
                </div>
                <div class="card-body profile-section">
                    <div class="profile-pic-placeholder">
                        <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL")  %>" alt="프로필 사진" class="profile-pic-placeholder">
                    </div>
                    <div class="profile-info">
                        <span class="profile-name"><%= session.getAttribute("SS_USER_NAME") %>님</span>
                        <div class="profile-contact">
                            <span><i class="fa-regular fa-envelope"></i> ${userInfo.email}</span>
                            <span><i class="fa-solid fa-phone"></i> 연락처 미등록</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 결제 내역 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>자기소개</h3>
                </div>
                <div class="card-body empty-content">
                    <p>결제 내역이 없습니다.</p>
                </div>
            </div>

            <!-- 문의 내역 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>문의 내역</h3>
                </div>
                <div class="card-body empty-content">
                    <p>문의 내역이 없습니다.</p>
                    <button class="card-primary-btn">문의하기</button>
                </div>
            </div>

            <!-- 결제 수단 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>결제 수단</h3>
                    <a href="#" class="card-link">더보기</a>
                </div>
                <div class="card-body empty-content">
                    <p>등록된 결제 수단이 없습니다.</p>
                </div>
            </div>

        </div>
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
