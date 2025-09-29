<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>살며시: 개인정보/프로필 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sideBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        body {
            font-size: 15px;
            line-height: 1.5;
        }

        .sidebar-main-content {
            padding: 20px;
        }

        /* [MOD] 여기서 margin-left 값이 박스를 왼쪽으로 이동시킴 */
        .mypage-wrapper {
            max-width: 1000px;
            margin: 40px 0 40px 130px; /* ← 왼쪽 여백 130px */
        }

        .mypage-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 20px;
            text-align: left;
        }

        .mypage-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        @media (max-width: 992px) {
            .mypage-grid {
                grid-template-columns: 1fr;
            }
        }

        .mypage-card {
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            border-bottom: 1px solid #e9ecef;
        }

        .card-header h3 {
            margin: 0;
            font-size: 1rem;
            font-weight: 600;
        }

        .card-body {
            padding: 16px;
            flex-grow: 1;
        }

        .card-action-btn.active {
            border: 1px solid #3399ff;
            color: #3399ff;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.85rem;
        }

        .profile-section {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .profile-pic-placeholder {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            border: 2px solid #DAEDFF;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            flex-shrink: 0;
            object-fit: cover;
        }

        .profile-info .profile-name {
            font-size: 1rem;
            font-weight: 700;
            margin-bottom: 6px;
            display: block;
        }

        .profile-meta {
            display: flex;
            flex-direction: column;
            gap: 4px;
            font-size: 0.85rem;
            color: #445268
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px
        }

        .meta-item i {
            width: 16px;
            color: #7a8aa0
        }

        .tag-chip-wrap {
            display: flex;
            flex-wrap: wrap;
            row-gap: 6px;
            column-gap: 6px;
            max-height: 160px;
            overflow: auto;
            padding-right: 4px;
        }

        .tag-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 8px;
            border-radius: 999px;
            background: #f0f6ff;
            border: 1px solid #c7dcff;
            color: #1c407d;
            font-size: 0.8rem;
        }

        .tag-chip i {
            font-size: .8rem
        }

        /* [FIX] 소개글: 가운데 정렬 상속 차단 + 위·왼쪽 정렬 */
        .intro-area {
            padding: 12px;
            border: 1px solid #c7d3e6;
            border-radius: 8px;
            background: #fff;
            font-size: 0.9rem;
            line-height: 1.4;
            color: #233047;
            /*white-space: pre-wrap;*/
            word-break: keep-all;
            overflow-wrap: break-word;
            min-height: 150px;
            display: block; /* ← flex 제거 */
            text-align: left !important; /* ← 가운데 정렬 상속 차단 */
        }

        .addr-box {
            padding: 10px;
            border: 1px dashed #dbe9ff;
            border-radius: 8px;
            background: #f7faff;
            color: #2a3340;
            font-size: 0.9rem;
        }

        /* =========================
   [FIX] 자기소개 카드 위·왼쪽 정렬 강제
   ========================= */
        .mypage-card .card-body.intro-body {
            /* 부모가 empty-content 같은 flex/center여도 무력화 */
            display: block !important;
            text-align: left !important;
            justify-content: initial !important;
            align-items: initial !important;
            padding: 16px; /* 필요 시 조절 */
        }

        .mypage-card .card-body.intro-body .intro-area {
            display: block !important; /* flex 제거 */
            width: 100% !important; /* 가로 꽉 채우기 */
            margin: 0 !important;
            text-align: left !important; /* 텍스트 왼쪽 정렬 */
            white-space: pre-wrap; /* 줄바꿈 유지 */
            word-break: keep-all; /* 한글 가독성 */
            overflow-wrap: break-word; /* 긴 단어 줄바꿈 */
        }

        /* 혹시 내부에 p/span 등에 center가 인라인/외부로 걸려 있다면 이것도 함께 해제 */
        .mypage-card .card-body.intro-body .intro-area * {
            text-align: inherit !important;
        }

        /* ===== [HARD FIX] intro 카드: 어떤 외부 규칙도 무력화 ===== */
        .mypage-card .card-body.intro-body {
            display: block !important; /* 부모 flex/center 무력화 */
            text-align: left !important;
            justify-content: initial !important;
            align-items: initial !important;
            padding: 16px;
        }

        .mypage-card .card-body.intro-body #introArea {
            display: block !important; /* flex 제거 */
            width: 100% !important;
            margin: 0 !important;
            text-align: left !important; /* 텍스트 왼쪽 정렬 */
            white-space: pre-wrap !important; /* 줄바꿈 유지 */
            word-break: keep-all !important; /* 한글 가독성 */
            overflow-wrap: break-word !important;
        }

        /* 요소 내부에 center가 인라인/외부로 들어와도 상속으로 왼쪽 고정 */
        .mypage-card .card-body.intro-body #introArea * {
            text-align: inherit !important;
        }

        /* intro 안 자식이 center를 갖고 있어도 상속으로 왼쪽 고정 */
        .mypage-card .card-body.intro-body #introArea * {
            text-align: inherit !important;
        }

        /* [ADD] 카드 헤더에 값(주소) 한 줄로 붙이기 + 말줄임 처리 */
        .card-header-left {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1; /* 오른쪽 링크(더보기)와 좌우 공간 분배 */
            min-width: 0; /* ellipsis 동작을 위해 필요 */
        }

        .header-inline-value {
            color: #666;
            font-size: 0.85rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex: 1; /* 가용 너비에서 자연스럽게 줄임표 */
        }




    </style>

</head>
<body>
<%@ include file="../includes/header.jsp" %>
<%@ include file="../includes/sideBar.jsp" %>

<main class="sidebar-main-content">
    <div class="mypage-wrapper">
        <h1 class="mypage-title">마이페이지</h1>

        <div class="mypage-grid">

            <!-- 정보 수정 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>정보 수정</h3>
                    <a href="/mypage/profileEdit" class="card-action-btn active">비밀번호 변경</a>
                </div>
                <div class="card-body profile-section">
                    <div class="profile-pic-placeholder">
                        <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL")  %>" alt="프로필 사진"
                             class="profile-pic-placeholder">
                    </div>
                    <div class="profile-info">
                        <span class="profile-name"><%= session.getAttribute("SS_USER_NAME") %>님</span>
                        <div class="profile-meta">
                            <div class="meta-item">
                                <i class="fa-solid fa-id-card-clip"></i>
                                <span><c:out
                                        value="${not empty rDTO.userId ? rDTO.userId : sessionScope.SS_USER_ID}"/></span>
                            </div>
                            <div class="meta-item">
                                <i class="fa-regular fa-envelope"></i>
                                <span><c:out
                                        value="${not empty rDTO.email ? rDTO.email : sessionScope.SS_USER_EMAIL}"/></span>
                            </div>
                            <div class="meta-item">
                                <i class="fa-regular fa-calendar-days"></i>
                                <span><c:out
                                        value="${not empty rDTO.birthDate ? rDTO.birthDate : sessionScope.SS_USER_BIRTH}"/></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 태그 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>태그</h3>
                    <!-- [ADD] 태그 수정 버튼 -->
                    <a href="/mypage/tagEdit" class="card-action-btn active" title="태그 수정">태그 수정</a>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty tList}">
                            <div class="tag-chip-wrap">
                                <c:forEach var="tag" items="${tList}">
                        <span class="tag-chip">
                            <i class="fa-solid fa-tag"></i>
                            <c:out value="${empty tag.tagName ? tag.tag_name : tag.tagName}"/>
                        </span>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <span style="color:#6e7b8b">등록된 태그가 없습니다.</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>


            <!-- 자기소개 카드 -->
            <div class="mypage-card">
                <div class="card-header"><h3>자기소개</h3></div>
                <div class="card-body">
                    <div class="intro-area">
                        <c:choose>
                            <c:when test="${not empty rDTO.introduction}">
                                <c:out value="${rDTO.introduction}"/>
                            </c:when>
                            <c:otherwise>
                                아직 소개글이 없습니다.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>


            <!-- 주소 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <!-- [ADD] 왼쪽 묶음: 제목 + 주소 값(한 줄) -->
                    <div class="card-header-left">
                        <h3>주소</h3>
                        <span class="header-inline-value">
                <c:out value="${not empty rDTO.addr1 ? rDTO.addr1 : '등록된 주소가 없습니다.'}"/>
            </span>
                    </div>
                    <a href="#" class="card-link">더보기</a>
                </div>

                <!-- 본문은 그대로 두되, 중복이 싫으면 이 부분은 지워도 됨 -->
                <%--<div class="card-body">
                    <c:choose>
                        <c:when test="${not empty rDTO.addr1}">
                            <div class="addr-box"><c:out value="${rDTO.addr1}"/></div>
                        </c:when>
                        <c:otherwise>
                            <span style="color:#6e7b8b">등록된 주소가 없습니다.</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>--%>

</main>

<%@ include file="../includes/customModal.jsp" %>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>

</body>
</html>
