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

        /* === 고정 높이 설정 === */
        :root {
            --mypage-card-h: 290px; /* ← 원하는 픽셀로 조절 (예: 240/260/280px) */
        }

        /* 레이아웃 */
        .mypage-container {
            padding: 24px;
        }

        .mypage-frame {
            width: 1200px;
            margin: 80px auto;
            padding: 18px;
            border-radius: 14px; /* 스샷 외곽 연한 박스 느낌 */
        }

        .mypage-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            grid-auto-rows: var(--mypage-card-h); /* ★ 행 높이 고정 */
        }

        @media (max-width: 900px) {
            .mypage-grid {
                grid-template-columns: 1fr;
                grid-auto-rows: auto;
            }

            .mypage-card {
                height: auto;
            }
        }

        /* 카드 공통 */
        .mypage-card {
            height: 100%; /* ★ 고정 행 높이를 100%로 채우기 */
            min-height: unset; /* 기존 min-height 제거 */
            background: #fff;
            border: 1px solid #e6e8ec;
            border-radius: 10px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .mypage-card-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 14px;
            background: #f7f8fa;
            border-bottom: 1px solid #e6e8ec;
        }

        .mypage-card-title {
            font-size: 14px;
            color: #2b3340;
            font-weight: 600;
        }

        .link-more {
            font-size: 12px;
            color: #8a94a6;
            text-decoration: none;
        }

        .link-more:hover {
            text-decoration: underline;
        }

        .mypage-card-body {
            overflow: auto;
        }

        .mypage-card-foot {
            padding: 12px 16px;
            border-top: 1px solid #eef1f4;
            background: #fafbfc;
        }

        .mypage-card-empty {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #a1a8b3;
            font-size: 14px;
            padding: 24px;
            text-align: center;
        }

        /* 프로필 카드 디테일 */
        .profile-body {
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .avatar-circle {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: #f0f2f5;
            color: #a7b0bb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            flex: 0 0 auto;
        }

        .profile-cols {
            flex: 1;
            min-width: 0;
        }

        .profile-name {
            font-size: 18px;
            font-weight: 600;
            color: #2b3340;
            margin: 2px 0 8px;
        }

        .profile-meta {
            list-style: none;
            margin: 0;
            padding: 0;
            color: #6c7583;
        }

        .profile-meta li {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 0;
        }

        .profile-meta i {
            width: 16px;
            text-align: center;
        }

        /* 버튼 */
        .btn {
            border-radius: 8px;
            padding: 7px 12px;
            cursor: pointer;
            border: 1px solid transparent;
            font-size: 13px;
        }

        .btn-ghost {
            background: #fff;
            border-color: #e1e5ea;
            color: #475063;
        }

        .btn-ghost:hover {
            background: #f2f4f7;
        }

        .btn-outline {
            background: #fff;
            border-color: #d6deea;
            color: #2b3340;
        }

        .btn-outline:hover {
            background: #f5f7fa;
        }

    </style>

</head>
<body>
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<%--사이드바--%>
<%@ include file="../includes/sideBar.jsp" %>

<main class="sidebar-main-content mypage-container">

    <div class="mypage-frame">
        <section class="mypage-grid">
            <!-- 정보수정 -->
            <article class="mypage-card mypage-profile">
                <div class="mypage-card-head">
                    <span class="mypage-card-title">정보수정</span>
                    <button type="button" class="btn btn-ghost" id="editProfileBtn">수정하기</button>
                </div>
                <div class="mypage-card-body profile-body">
                    <div class="avatar-circle"><i class="fa-regular fa-user"></i></div>
                    <div class="profile-cols">
                        <div class="profile-name" id="profileName">이름</div>
                        <ul class="profile-meta">
                            <li><i class="fa-solid fa-globe"></i> 홈페이지 미입력</li>
                            <li><i class="fa-regular fa-envelope"></i></li>
                            <li><i class="fa-solid fa-phone"></i></li>
                        </ul>
                    </div>
                </div>
            </article>

            <!-- 결제내역 -->
            <article class="mypage-card">
                <div class="mypage-card-head">
                    <span class="mypage-card-title">결제내역</span>
                </div>
                <div class="mypage-card-empty">결제 내역이 없습니다.</div>
            </article>

            <!-- 문의내역 -->
            <article class="mypage-card">
                <div class="mypage-card-head">
                    <span class="mypage-card-title">문의내역</span>
                </div>
                <div class="mypage-card-empty">문의 내역이 없습니다.</div>
                <div class="mypage-card-foot">
                    <button type="button" class="btn btn-outline" id="contactBtn">문의하기</button>
                </div>
            </article>

            <!-- 결제 수단 -->
            <article class="mypage-card">
                <div class="mypage-card-head">
                    <span class="mypage-card-title">결제 수단</span>
                    <a class="link-more" href="#">더보기</a>
                </div>
                <div class="mypage-card-empty">등록된 결제 수단이 없습니다.</div>
            </article>
        </section>
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
