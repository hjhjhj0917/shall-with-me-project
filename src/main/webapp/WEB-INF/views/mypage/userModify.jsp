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
            background: linear-gradient(to right, white, #f9f9f9);
        }

        /* 전체 메인 콘텐츠 영역 */
        .sidebar-main-content {
            padding: 40px;
        }

        .mypage-wrapper {
            max-width: 1200px;
            margin: 80px auto;
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
            display: flex; /* 한 줄 정렬 */
            justify-content: space-between; /* 좌/우 배치 */
            align-items: center; /* 세로 중앙 */
            padding: 12px 16px;
            border-bottom: 1px solid #e9ecef;
            min-height: 56px;
            height: 56px; /* 필요 시 유지 */
            flex-wrap: nowrap; /* 줄바꿈 금지 */
            gap: 10px; /* 살짝 여백 */
        }

        /* 왼쪽 영역은 남는 공간을 차지하고, 말줄임 처리 */
        .card-header-left {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1 1 auto; /* 가변 */
            min-width: 0; /* ellipsis 작동 */
        }

        .card-header h3 {
            margin: 0;
            white-space: nowrap;
        }

        /* 긴 주소는 … 처리 */
        .header-inline-value {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex: 1 1 auto;
        }

        /* 버튼은 줄어들지 않게 + 한 줄 유지 */
        .card-action-btn {
            flex: 0 0 auto; /* 줄어들지 않음 */
            align-self: center; /* 세로 중앙 */
            white-space: nowrap; /* 버튼 텍스트 줄바꿈 방지 */
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

        /* === 버튼 공통 & 활성 스타일 (수정됨) === */
        .card-action-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none !important; /* 밑줄 제거 */
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 600;
            border: 1px solid transparent;
            transition: background .2s ease, border-color .2s ease, color .2s ease, box-shadow .2s ease;
        }

        .card-action-btn.active {
            background: transparent;      /* 배경 제거 */
            color: #3399ff;          /* 텍스트 색상 */
            border-color: transparent;  /* 테두리 제거 */
            text-decoration: underline !important; /* 밑줄 추가 */
            box-shadow: none;             /* 그림자 제거 */
        }

        .card-action-btn.active:hover,
        .card-action-btn.active:focus-visible {
            background: transparent;      /* 배경 없음 */
            border-color: transparent;  /* 테두리 없음 */
            color: #1c407d;          /* 텍스트 색상 (진하게) */
            box-shadow: none;             /* 그림자 제거 */
            text-decoration: underline !important; /* 밑줄 유지 */
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
            word-break: keep-all;
            overflow-wrap: break-word;
            min-height: 258px;
            display: block;
            text-align: left !important;
        }

        .addr-box {
            padding: 10px;
            border: 1px dashed #dbe9ff;
            border-radius: 8px;
            background: #f7faff;
            color: #2a3340;
            font-size: 0.9rem;
        }

        .mypage-card .card-body.intro-body {
            display: block !important;
            text-align: left !important;
            justify-content: initial !important;
            align-items: initial !important;
            padding: 16px;
        }

        .mypage-card .card-body.intro-body .intro-area {
            display: block !important;
            width: 100% !important;
            margin: 0 !important;
            text-align: left !important;
            word-break: keep-all;
            overflow-wrap: break-word;
        }

        .mypage-card .card-body.intro-body .intro-area * {
            text-align: inherit !important;
        }

        .mypage-card .card-body.intro-body #introArea {
            display: block !important;
            width: 100% !important;
            margin: 0 !important;
            text-align: left !important;
            word-break: keep-all !important;
            overflow-wrap: break-word !important;
        }

        .mypage-card .card-body.intro-body #introArea * {
            text-align: inherit !important;
        }

        .card-header-left {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1;
            min-width: 0;
        }

        .header-inline-value {
            color: #666;
            font-size: 0.85rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex: 1;
        }

        .addr-row {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .addr-map {
            width: 100%;
            height: 260px;
            border: 1px solid #e5efff;
            border-radius: 8px;
            overflow: hidden;
        }

        .intro-area {
            user-select: text;
            -webkit-user-select: text;
            cursor: text;
        }

        .intro-area.is-editing {
            outline: 2px solid rgba(51, 153, 255, .35);
            box-shadow: 0 0 0 3px rgba(51, 153, 255, .12) inset;
        }

        .profile-photo-wrap {
            position: relative;
            width: 90px;
            height: 90px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .photo-edit-glow {
            position: absolute;
            inset: 0;
            border-radius: 50%;
            border: 2px dashed rgba(51, 153, 255, .85);
            box-shadow: 0 0 12px rgba(51, 153, 255, .55), inset 0 0 8px rgba(51, 153, 255, .25);
            opacity: 0;
            pointer-events: none;
            transition: opacity .2s ease;
        }

        .profile-photo-wrap:hover .photo-edit-glow,
        .profile-photo-wrap.active .photo-edit-glow {
            opacity: 1;
        }

        .profile-photo-wrap.loading .photo-edit-glow {
            animation: glowPulse 1.2s ease-in-out infinite;
        }

        @keyframes glowPulse {
            0% {
                box-shadow: 0 0 6px rgba(51, 153, 255, .45), inset 0 0 6px rgba(51, 153, 255, .2)
            }
            50% {
                box-shadow: 0 0 16px rgba(51, 153, 255, .75), inset 0 0 10px rgba(51, 153, 255, .35)
            }
            100% {
                box-shadow: 0 0 6px rgba(51, 153, 255, .45), inset 0 0 6px rgba(51, 153, 255, .2)
            }
        }

        /* --- [START] NEW TAG MODAL STYLE (Applied to #mypageTagModal) --- */
        #mypageTagModal .search-tag-group {
            display: flex;
            align-items: center;
            padding: 16px 0;
        }

        #mypageTagModal .search-tag-group + .search-tag-group {
            border-top: 1px solid #f0f0f0;
        }

        #mypageTagModal .search-tag-group__icon-wrapper {
            flex-shrink: 0;
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background-color: #f8f9fa;
            border: 1px solid #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #mypageTagModal .search-tag-group__icon-wrapper i {
            font-size: 30px;
            color: #495057;
        }

        #mypageTagModal .search-tag-group__content-wrapper {
            flex-grow: 1;
            padding-left: 24px;
            min-width: 0; /* 텍스트 오버플로우 방지 */
        }

        #mypageTagModal .search-tag-group__title {
            font-weight: 600;
            font-size: 1rem;
            color: #343a40;
            margin-bottom: 12px;
        }

        #mypageTagModal .search-tag-group__list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            width: 100%;
        }

        #mypageTagModal .tag-btn {
            background-color: #fff;
            border: 1px solid #dee2e6;
            border-radius: 20px;
            padding: 8px 16px;
            font-size: 0.9rem;
            color: #495057;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        #mypageTagModal .tag-btn.selected {
            background-color: #3399ff;
            border-color: #3399ff;
            color: white;
            font-weight: 600;
        }

        #mypageTagModal .tag-btn:hover:not(.selected) {
            border-color: #495057;
        }

        #mypageTagModal .modal-body {
            max-height: 560px; /* profile.jsp의 기존 높이 유지 */
            overflow-y: auto;
            padding: 20px;
        }

        #mypageTagModal .modal-footer {
            display: flex;
            justify-content: space-between; /* 이미지와 동일하게 양쪽 정렬 */
            align-items: center;
            gap: 8px;
            padding: 12px 16px;
            border-top: 1px solid #eee;
            background: #fff;
        }

        #mypageTagModal .modal-footer > div:first-child { /* 0/6 선택 텍스트 */
            font-size: 0.95rem;
            color: #495057;
        }

        #mypageTagModal #tagCount { /* 0/6 선택의 '0' 부분 */
            font-weight: 600;
            color: #3399ff;
        }

        #mypageTagModal .modal-footer > div:last-child { /* 버튼 그룹 */
            display: flex;
            gap: 8px;
        }

        #mypageTagModal .modal-footer #btnTagCancel { /* 취소 버튼 */
            padding: 8px 16px;
            cursor: pointer;
            font-size: 0.9rem;
            background-color: white;
            color: #9aa1ac;
            border-radius: 40px;
            border: 2px solid #E5F2FF;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }

        #mypageTagModal .modal-footer #btnTagSave { /* 선택 완료 버튼 (저장 버튼) */
            padding: 8px 16px;
            font-weight: 600;
            cursor: pointer;
            font-size: 0.9rem;
            /* 기존 card-action-btn.active 스타일 오버라이드 */
            text-decoration: none !important;
            background-color: white;
            color: #3399ff;
            border-radius: 40px;
            border: 2px solid #E5F2FF;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }
        /* --- [END] NEW TAG MODAL STYLE --- */


        /* 헤더 버튼 클릭 보장 */
        .card-header { position: relative; }               /* 쌓임 맥락 생성 */
        .card-action-btn { position: relative; z-index: 2; }/* 버튼을 항상 위에 */
        .header-inline-value { pointer-events: none; }     /* 긴 주소 텍스트가 클릭 못 가로채게 */


    </style>

</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="main-container">
    <%@ include file="../includes/sideBar.jsp" %>

    <main class="sidebar-main-content">
        <div class="mypage-wrapper">
            <h1 class="mypage-title">마이페이지</h1>

            <div class="mypage-grid">

                <div class="mypage-card">
                    <div class="card-header">
                        <h3>정보 수정</h3>
                        <a id="btnPwChange" class="card-action-btn active">비밀번호 변경</a>
                    </div>
                    <div class="card-body profile-section">
                        <div class="card-body profile-section">
                            <div id="profilePhotoWrap" class="profile-photo-wrap" title="프로필 사진 변경하기">
                                <img id="profilePhotoImg"
                                     src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") %>"
                                     alt="프로필 사진"
                                     class="profile-pic-placeholder"/>
                                <div class="photo-edit-glow" aria-hidden="true"></div>
                            </div>
                            <input type="file" id="profileFileInput" accept="image/*" style="display:none">

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
                            <div class="profile-info">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mypage-card">
                    <div class="card-header">
                        <h3>태그</h3>
                        <a id="btnTagEdit" class="card-action-btn active" title="태그 수정">태그 수정</a>
                    </div>
                    <div class="modal-overlay" id="mypageTagModal"
                         style="display:none; align-items:center; justify-content:center; z-index:9998;">
                        <div class="modal-sheet"
                             style="width:100%; max-width:560px; background:#fff; border-radius:12px; overflow:hidden;">
                            <div class="modal-header"
                                 style="display:flex; align-items:center; justify-content:center; padding:16px; border-bottom:1px solid #eee; position:relative;">
                                <button type="button" class="modal-close" id="mypageTagModalClose"
                                        style="position:absolute; right:16px; top:50%; transform:translateY(-50%); width:32px; height:32px; border-radius:50%; border:0; background:#f7f7f7; cursor:pointer;">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
                                <div class="modal-title-text" style="font-weight:700; color:#222;">태그 수정</div>
                            </div>
                            <div class="modal-body" style="max-height:560px; overflow:auto; padding:20px;">
                                <div id="mypageTagGroupContainer"></div>
                            </div>
                            <div class="modal-footer">
                                <div style="font-size:0.95rem;color:#495057;">
                                    <span style="font-weight:600;color:#3399ff;"></span>
                                </div>
                                <div style="display:flex;gap:8px;">
                                    <button type="button" id="btnTagCancel"
                                            style="padding:8px 16px;border:1px solid #ddd;border-radius:8px;background:#fff;cursor:pointer;font-size:0.9rem;">취소</button>
                                    <button type="button" id="btnTagSave"
                                            style="padding:8px 16px;border:none;border-radius:8px;background:#3399ff;color:#fff;font-weight:600;cursor:pointer;font-size:0.9rem;">선택 완료</button>
                                </div>
                            </div>
                        </div>
                    </div>



                    <div class="modal-overlay" id="pwChangeModal"
                         style="display:none; align-items:center; justify-content:center; z-index:9998;">
                        <div class="modal-sheet"
                             style="width:100%; max-width:520px; background:#fff; border-radius:12px; overflow:hidden;">
                            <div class="modal-header"
                                 style="display:flex; align-items:center; justify-content:center; padding:16px; border-bottom:1px solid #eee; position:relative;">
                                <button type="button" class="modal-close" id="pwChangeModalClose"
                                        style="position:absolute; right:16px; top:50%; transform:translateY(-50%); width:32px; height:32px; border-radius:50%; border:0; background:#f7f7f7; cursor:pointer;">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
                                <div class="modal-title-text" style="font-weight:700; color:#222;">비밀번호 변경</div>
                            </div>

                            <div class="modal-body" style="padding:20px;">
                                <div id="findPwErrorMessage2" class="error-message" style="color:#e03131; font-size:13px; min-height:18px;"></div>

                                <form id="pwVerifyForm" style="margin-bottom:12px;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <div style="display:flex; flex-direction:column; gap:10px;">
                                        <input type="password" name="currentPw" id="currentPw" class="login-input" placeholder="현재 비밀번호"/>
                                        <button id="btnVerifyPw" type="button" class="card-action-btn active" style="justify-content:center;">
                                            현재 비밀번호 확인
                                        </button>
                                    </div>
                                </form>

                                <form id="f3" style="display:none;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                    <div style="display:flex; flex-direction:column; gap:10px;">
                                        <input type="password" name="userPw" id="userPw" class="login-input" placeholder="새 비밀번호"/>
                                        <input type="password" name="pwCheck" id="pwCheck" class="login-input" placeholder="새 비밀번호 확인"/>
                                        <button id="btnUpdatePw" type="button" class="card-action-btn active" style="justify-content:center;">
                                            비밀번호 변경
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
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

                <div class="mypage-card">
                    <div class="card-header">
                        <h3>자기소개</h3>
                        <a id="introSaveBtn" class="card-action-btn active" title="수정하기">수정하기</a>
                    </div>

                    <div class="card-body intro-body">
                        <div class="intro-area" id="introArea">
                            <c:choose>
                                <c:when test="${not empty rDTO.introduction}">
                                    <c:out value="${rDTO.introduction}"/>
                                </c:when>
                                <c:otherwise>아직 소개글이 없습니다.</c:otherwise>
                            </c:choose>
                        </div>

                        <form id="introForm" style="display:none;">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <input type="hidden" name="introduction" id="introHiddenInput"/>
                        </form>
                    </div>
                </div>

                <div class="mypage-card">
                    <div class="card-header">
                        <div class="card-header-left">
                            <h3>주소</h3>
                            <span class="header-inline-value">
                                <c:out value="${not empty rDTO.addr1 ? rDTO.addr1 : '등록된 주소가 없습니다.'}"/>
                            </span>
                        </div>
                        <button id="btnAddrEdit" class="card-action-btn active" title="주소 수정">주소 수정</button>
                    </div>

                    <div class="card-body">
                        <c:set var="addr1" value="${not empty rDTO.addr1 ? rDTO.addr1 : ''}"/>
                        <div id="kakaoMap" class="addr-map"></div>
                    </div>
                </div>

            </div>
        </div>
        <div class="modal-overlay" id="addrEditModal"
             style="display:none; align-items:center; justify-content:center; z-index:9998;">
            <div class="modal-sheet"
                 style="width:100%; max-width:560px; background:#fff; border-radius:12px; overflow:hidden;">
                <div class="modal-header"
                     style="display:flex; align-items:center; justify-content:center; padding:16px; border-bottom:1px solid #eee; position:relative;">
                    <button type="button" class="modal-close" id="addrEditModalClose"
                            style="position:absolute; right:16px; top:50%; transform:translateY(-50%); width:32px; height:32px; border-radius:50%; border:0; background:#f7f7f7; cursor:pointer;">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                    <div class="modal-title-text" style="font-weight:700; color:#222;">주소 수정</div>
                </div>
                <div class="modal-body" style="padding:20px; display:flex; flex-direction:column; gap:10px;">
                    <form id="addrForm">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        <div style="display:grid; grid-template-columns: 1fr auto; gap:8px; align-items:center;">
                            <input type="text" id="addr1" name="addr1" class="login-input" placeholder="(우편번호) 도로명 주소" readonly>
                            <button type="button" id="btnFindPost" class="card-action-btn active">주소 찾기</button>
                        </div>

                        <input type="text" id="addr2" name="addr2" class="login-input" placeholder="상세주소(동/호)">
                    </form>
                </div>
                <div class="modal-footer"
                     style="display:flex; gap:10px; justify-content:flex-end; padding:12px 16px; border-top:1px solid #eee;">
                    <button type="button" id="btnAddrSave" class="card-action-btn active">저장</button>
                </div>
            </div>
        </div>

    </main>

</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/footer.jsp" %>

<script>
    // ★추가: CSRF 안전 추출 + fallback
    function getCsrf() {
        let header = ('${_csrf.headerName}' || '').trim();
        let token = ('${_csrf.token}' || '').trim();
        if (!token) {
            const el = document.querySelector('input[name="${_csrf.parameterName}"]');
            if (el && el.value) token = el.value.trim();
        }
        if (!header) header = 'X-CSRF-TOKEN';
        return {header, token};
    }
</script>

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

<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=218d70914021664c1d8e3dc194489251&libraries=services&autoload=false"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const addrText = "<c:out value='${addr1}'/>".trim();
        const container = document.getElementById('kakaoMap');
        if (!container) return;

        kakao.maps.load(function () {
            const defaultCenter = new kakao.maps.LatLng(37.5665, 126.9780);
            const map = new kakao.maps.Map(container, {center: defaultCenter, level: 4});
            const marker = new kakao.maps.Marker({position: defaultCenter});
            marker.setMap(map);

            function relayoutAndCenter() {
                map.relayout();
                map.setCenter(marker.getPosition());
            }
            window.addEventListener('resize', relayoutAndCenter);
            setTimeout(relayoutAndCenter, 0);

            if (addrText && addrText.length > 0) {
                const geocoder = new kakao.maps.services.Geocoder();
                geocoder.addressSearch(addrText, function (result, status) {
                    if (status === kakao.maps.services.Status.OK && result.length) {
                        const item = result[0];
                        const pos = new kakao.maps.LatLng(item.y, item.x);
                        marker.setPosition(pos);
                        map.setCenter(pos);
                        map.setLevel(3);
                    } else {
                        console.warn('지오코딩 실패:', status, result);
                    }
                });
            }
        });
    });
</script>

<script>
    $(function () {
        const $area = $('#introArea');
        const $btn = $('#introSaveBtn');
        const $form = $('#introForm');
        const $hidden = $('#introHiddenInput');
        let editing = false;

        function caretToEnd(el) {
            const r = document.createRange();
            r.selectNodeContents(el);
            r.collapse(false);
            const s = window.getSelection();
            s.removeAllRanges();
            s.addRange(r);
        }

        $area.on('click', function () {
            if (editing) return;
            if ($area.text().trim() === '아직 소개글이 없습니다.') $area.text('');
            this.setAttribute('contenteditable', 'true');
            this.classList.add('is-editing');
            caretToEnd(this);
            editing = true;
        });

        $btn.on('click', function (e) {
            e.preventDefault();
            if (!editing) {
                $area.click();
                return;
            }

            const newText = ($area.text() || '').trim();
            if (newText.length > 1000) {
                showCustomAlert('자기소개는 1000자 이하로 작성해주세요.');
                return;
            }

            $hidden.val(newText);

            $.ajax({
                url: '<c:url value="/mypage/introductionUpdate"/>',
                type: 'post',
                dataType: 'text',
                data: $form.serialize(),
                success: function (msg) {
                    $area.text(newText || '아직 소개글이 없습니다.')
                        .removeAttr('contenteditable')
                        .removeClass('is-editing');
                    editing = false;
                    showCustomAlert(msg || '자기소개가 저장되었어요!');
                },
                error: function (xhr) {
                    console.error('[intro] 저장 실패', xhr.status, xhr.responseText);
                    showCustomAlert('저장 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.');
                }
            });
        });

        $area.on('keydown', function (e) {
            if (!editing) return;
            if (e.key === 'Escape') {
                $area.removeAttr('contenteditable').removeClass('is-editing');
                editing = false;
            } else if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
                $btn.click();
            }
        });
    });
</script>

<script>
    $(function () {
        const $wrap = $('#profilePhotoWrap');
        const $img = $('#profilePhotoImg');
        const $file = $('#profileFileInput');

        $wrap.on('click', function () {
            $wrap.addClass('active');
            $file.trigger('click');
        });

        $file.on('change', function (e) {
            const f = e.target.files && e.target.files[0];
            if (!f) {
                $wrap.removeClass('active');
                return;
            }
            if (!/^image\//.test(f.type)) {
                showCustomAlert('이미지 파일만 업로드할 수 있어요.');
                $wrap.removeClass('active');
                return;
            }
            if (f.size > 5 * 1024 * 1024) {
                showCustomAlert('최대 5MB까지 업로드 가능합니다.');
                $wrap.removeClass('active');
                return;
            }

            const blobUrl = URL.createObjectURL(f);
            $img.attr('src', blobUrl);

            const fd = new FormData();
            fd.append('file', f);

            $wrap.addClass('loading');

            $.ajax({
                url: '<c:url value="/mypage/profileImageUpdate"/>',
                type: 'post',
                data: fd,
                processData: false,
                contentType: false,
                dataType: 'json',
                beforeSend: (xhr) => {
                    const {header, token} = getCsrf();
                    if (header && token) xhr.setRequestHeader(header, token);
                    else console.warn('[profile] CSRF header/token이 없어 헤더 설정 생략');
                },
                success: function (res) {
                    if (res && res.url) {
                        const finalUrl = res.url + (res.url.includes('?') ? '&' : '?') + 'v=' + Date.now();
                        $img.attr('src', finalUrl);
                    }
                    showCustomAlert('프로필 사진이 변경되었어요!', function () {
                        location.reload();
                    });
                },
                error: function (xhr) {
                    console.error('[profile] 업로드 실패', xhr.status, xhr.responseText);
                    showCustomAlert('업로드 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.');
                },
                complete: function () {
                    $wrap.removeClass('active loading');
                    $file.val('');
                }
            });
        });
    });
</script>

<script>
    const CTX = '${pageContext.request.contextPath}';
    const TAG_ALL_URL = '<c:url value="/mypage/tags/all"/>';
    const TAG_MY_URL = '<c:url value="/mypage/tags/my"/>';
    const TAG_UPDATE_URL = '<c:url value="/mypage/tags/update"/>';
</script>

<script>
    $(function () {
        const tagGroups = [
            {key: "lifePattern", title: "생활패턴", icon: "fa-solid fa-sun"},
            {key: "activity", title: "활동범위", icon: "fa-solid fa-map-location-dot"},
            {key: "job", title: "직업", icon: "fa-solid fa-briefcase"},
            {key: "workTime", title: "퇴근 시간", icon: "fa-solid fa-business-time"},
            {key: "guest", title: "손님초대", icon: "fa-solid fa-door-open"},
            {key: "share", title: "물건공유", icon: "fa-solid fa-handshake"},
            {key: "personality", title: "성격", icon: "fa-solid fa-face-smile"},
            {key: "prefer", title: "선호하는 성격", icon: "fa-solid fa-heart"},
            {key: "conversation", title: "대화", icon: "fa-solid fa-comments"},
            {key: "conflict", title: "갈등", icon: "fa-solid fa-people-arrows"},
            {key: "cook", title: "요리", icon: "fa-solid fa-utensils"},
            {key: "food", title: "주식", icon: "fa-solid fa-bowl-food"},
            {key: "meal", title: "끼니", icon: "fa-solid fa-calendar-day"},
            {key: "smell", title: "음식 냄새", icon: "fa-solid fa-wind"},
            {key: "clean", title: "청결", icon: "fa-solid fa-broom"},
            {key: "cleanCircle", title: "청소 주기", icon: "fa-solid fa-broom"},
            {key: "garbage", title: "쓰레기 배출", icon: "fa-solid fa-trash-can"},
            {key: "dishWash", title: "설거지", icon: "fa-solid fa-sink"}
        ];

        const $modal = $('#mypageTagModal');
        const $modalClose = $('#mypageTagModalClose');
        const $btnEdit = $('#btnTagEdit');
        const $btnSave = $('#btnTagSave'); // 기존 '저장' 버튼
        const $btnCancel = $('#btnTagCancel'); // 추가: '취소' 버튼
        const $wrap = $('#mypageTagGroupContainer');
        const $tagCount = $('#tagCount'); // 태그 개수 표시

        const selectedByGroup = new Map();

        $btnEdit.on('click', async function () {
            $wrap.empty();
            selectedByGroup.clear();
            try {
                const [allTags, myTags] = await Promise.all([
                    $.getJSON(TAG_ALL_URL),
                    $.getJSON(TAG_MY_URL)
                ]);
                const myMap = {};
                (myTags || []).forEach(s => { myMap[s.tagType] = s.tagId; });
                renderGroups(allTags, myMap);
                updateTagCountDisplay(); // 모달 열 때 카운트 초기화
                $modal.css('display', 'flex');
            } catch (e) {
                console.error('태그 로드 실패', e);
                showCustomAlert('태그를 불러오는 중 오류가 발생했어요.');
            }
        });

        $modalClose.on('click', () => $modal.hide());
        $modal.on('click', (e) => { if (e.target === e.currentTarget) $modal.hide(); });

        $btnCancel.on('click', () => { // 취소 버튼 클릭 시 모달 닫기
            $modal.hide();
        });

        $btnSave.on('click', async function () {
            const payload = {tagList: []};
            selectedByGroup.forEach(v => payload.tagList.push(Number(v.tagId)));

            try {
                const res = await $.ajax({
                    url: TAG_UPDATE_URL,
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(payload),
                    dataType: 'json',
                    beforeSend: (xhr) => {
                        const {header, token} = getCsrf();
                        if (header && token) xhr.setRequestHeader(header, token);
                        else console.warn('[tags] CSRF header/token이 없어 헤더 설정 생략');
                    }
                });

                if (res && Array.isArray(res.tags)) {
                    const $chips = $('.tag-chip-wrap').empty();
                    if (res.tags.length === 0) {
                        $chips.append('<span style="color:#6e7b8b">등록된 태그가 없습니다.</span>');
                    } else {
                        res.tags.forEach(t => {
                            $chips.append(
                                $('<span class="tag-chip">')
                                    .append('<i class="fa-solid fa-tag"></i>')
                                    .append(document.createTextNode(' ' + t.tagName))
                            );
                        });
                    }
                }
                $modal.hide();
                showCustomAlert('태그가 저장되었어요!');
            } catch (e) {
                console.error('태그 저장 실패', e);
                showCustomAlert('저장 중 오류가 발생했어요.');
            }
        });

        function renderGroups(allTags, myMap) {
            const byGroup = new Map();
            (allTags || []).forEach(t => {
                const g = t.tagType;
                if (!byGroup.has(g)) byGroup.set(g, []);
                byGroup.get(g).push({tagId: t.tagId, tagName: t.tagName});
            });

            tagGroups.forEach(g => {
                const list = byGroup.get(g.key) || [];
                if (list.length === 0) return;

                const $groupDiv = $('<div>').addClass('search-tag-group');

                const $iconWrapper = $('<div>')
                        .addClass('search-tag-group__icon-wrapper')
                        .append($('<i>').addClass(g.icon));

                const $contentWrapper = $('<div>').addClass('search-tag-group__content-wrapper');
                const $groupTitle = $('<div>').addClass('search-tag-group__title').text(g.title);
                const $groupList = $('<div>').addClass('search-tag-group__list');

                list.forEach(tag => {
                    const $btn = $('<button type="button" class="tag-btn">')
                            .text(tag.tagName)
                            .attr('data-id', tag.tagId)
                            .attr('data-group', g.key);

                    if (myMap[g.key] && Number(myMap[g.key]) === Number(tag.tagId)) {
                        $btn.addClass('selected');
                        selectedByGroup.set(g.key, {tagId: tag.tagId, tagName: tag.tagName});
                    }

                    $btn.on('click', function () {
                        $groupList.find('.tag-btn').removeClass('selected');
                        $(this).addClass('selected');
                        selectedByGroup.set(g.key, {tagId: tag.tagId, tagName: tag.tagName});
                        updateTagCountDisplay(); // 클릭 시 카운트 업데이트
                    });

                    $groupList.append($btn);
                });

                $contentWrapper.append($groupTitle, $groupList);
                $groupDiv.append($iconWrapper, $contentWrapper);
                $wrap.append($groupDiv);
            });
        }

        function updateTagCountDisplay() { // 태그 개수 업데이트 함수
            $tagCount.text(selectedByGroup.size);
        }
    });
</script>

<script>
    // 기존 pwUpdate 로직 유지 (NEW_PASSWORD 세션이 있는 상태에서 동작)
    function pwUpdate(f3) {
        let userPw = f3.userPw.value.trim();
        let pwCheck = f3.pwCheck.value.trim();

        $(".login-input").removeClass("input-error");
        $("#findPwErrorMessage2").removeClass("visible").text("");

        if (userPw === "") {
            $("#userPw").addClass("input-error");
            $("#findPwErrorMessage2").text("새로운 비밀번호를 입력하세요.").addClass("visible");
            setTimeout(() => $("#findPwErrorMessage2").removeClass("visible"), 2000);
            $("#userPw").focus();
            return;
        }

        if (pwCheck === "") {
            $("#pwCheck").addClass("input-error");
            $("#findPwErrorMessage2").text("검증을 위한 새로운 비밀번호를 입력하세요.").addClass("visible");
            setTimeout(() => $("#findPwErrorMessage2").removeClass("visible"), 2000);
            $("#pwCheck").focus();
            return;
        }

        if (userPw !== pwCheck) {
            $("#pwCheck").addClass("input-error");
            $("#findPwErrorMessage2").text("입력한 비밀번호가 일치하지 않습니다.").addClass("visible");
            setTimeout(() => $("#findPwErrorMessage2").removeClass("visible"), 2000);
            $("#pwCheck").focus();
            return;
        }

        $.ajax({
            url: "/user/newPasswordProc",
            type: "post",
            dataType: "JSON",
            data: $("#f3").serialize(),
            beforeSend: (xhr) => {
                const {header, token} = getCsrf();
                if (header && token) xhr.setRequestHeader(header, token);
            },
            success: function (json) {
                const $pwModal = $('#pwChangeModal'); // 모달 선택자
                const goLogin = function(){ location.href = "<c:url value='/user/login'/>"; };

                if (json.result === "1" || json.result === 1) {
                    // ✅ 1) 성공 시 모달 닫기
                    $pwModal.hide();

                    // ✅ 2) 커스텀 알림 띄우기 (확인 누르면 로그인 이동)
                    showCustomAlert(json.msg || '비밀번호가 변경되었어요!', goLogin);
                } else {
                    // 실패 시 모달은 유지하고 메시지만 출력
                    showCustomAlert(json.msg || '비밀번호 변경에 실패했어요.');
                }
            },
            error: function (xhr) {
                console.error('[pw] 변경 실패', xhr.status, xhr.responseText);
                showCustomAlert('변경 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.');
            }
        });
    }

    $(function(){
        const $modal = $('#pwChangeModal');
        const $open  = $('#btnPwChange');
        const $close = $('#pwChangeModalClose');

        // 열기: STEP1 보이기 / STEP2 숨기기
        $open.on('click', function(e){
            e.preventDefault();
            $('#f3')[0].reset();
            $('#pwVerifyForm')[0].reset();
            $('#findPwErrorMessage2').removeClass('visible').text('');
            $('.login-input').removeClass('input-error');

            $('#pwVerifyForm').show();
            $('#f3').hide();

            $modal.css('display','flex');
            setTimeout(()=> $('#currentPw').focus(), 0);
        });

        // 닫기
        $close.on('click', ()=> $modal.hide());
        $modal.on('click', (e)=> { if (e.target === e.currentTarget) $modal.hide(); });

        // STEP1: 현재 비밀번호 확인 → 서버에서 NEW_PASSWORD 세션 세팅
        $('#btnVerifyPw').on('click', function(){
            const cur = ($('#currentPw').val() || '').trim();
            if (!cur) {
                $("#currentPw").addClass("input-error");
                $("#findPwErrorMessage2").text("현재 비밀번호를 입력하세요.").addClass("visible");
                setTimeout(() => $("#findPwErrorMessage2").removeClass('visible'), 2000);
                $('#currentPw').focus();
                return;
            }

            $.ajax({
                url: "/mypage/passwordVerify",
                type: "post",
                dataType: "json",
                data: $("#pwVerifyForm").serialize(),
                beforeSend: (xhr) => {
                    const {header, token} = getCsrf();
                    if (header && token) xhr.setRequestHeader(header, token);
                },
                success: function(res){
                    if (typeof res === 'string') { try { res = JSON.parse(res); } catch(e) {} }
                    if (res && (res.result === 1 || res.result === "1")) {
                        // STEP2로 전환
                        $('#pwVerifyForm').hide();
                        $('#f3').show();
                        $('#findPwErrorMessage2').removeClass('visible').text('');
                        setTimeout(()=> $('#userPw').focus(), 0);
                    } else {
                        const msg = (res && res.msg) ? res.msg : "현재 비밀번호가 일치하지 않습니다.";
                        $("#findPwErrorMessage2").text(msg).addClass('visible');
                        setTimeout(() => $("#findPwErrorMessage2").removeClass('visible'), 2000);
                    }
                },
                error: function(xhr){
                    console.error('[pw] verify 실패', xhr.status, xhr.responseText);
                    showCustomAlert('확인 중 오류가 발생했어요. 잠시 후 다시 시도해주세요.');
                }
            });
        });

        // STEP2: 새 비밀번호 제출
        $('#btnUpdatePw').on('click', ()=> pwUpdate(document.getElementById('f3')));

        // 엔터키 UX
        $('#pwVerifyForm').on('keydown', function(e){ if (e.key === 'Enter') { e.preventDefault(); $('#btnVerifyPw').click(); }});
        $('#f3').on('keydown', function(e){ if (e.key === 'Enter') { e.preventDefault(); $('#btnUpdatePw').click(); }});
    });
</script>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    // ★추가: 카카오 우편번호 → 분리 필드 채우기
    function kakaoPost(f) {
        new daum.Postcode({
            oncomplete: function (data) {
                const address = data.address;
                const zonecode = data.zonecode;
                f.addr1.value = "(" + zonecode + ") " + address;
            }
        }).open();
    }

    // ★추가: 주소 저장 전 검증
    function validateAddressForm() {
        const addr1 = ($('#addr1').val() || '').trim(); // 한 줄 주소
        const addr2 = ($('#addr2').val() || '').trim(); // 상세주소

        if (!addr1) {
            showCustomAlert('주소 찾기 버튼으로 주소를 선택해주세요.');
            return false;
        }
        if (!addr2) {
            showCustomAlert('상세주소(동/호)를 입력해주세요.');
            $('#addr2').focus();
            return false;
        }
        return true;
    }



    // ★추가: 헤더의 인라인 표시 및 지도 재배치 갱신
    function refreshAddressUI(fullLineAddress) {
        // 1) 카드 헤더의 인라인 텍스트 갱신
        const $inline = $('.card-header-left .header-inline-value').first();
        if ($inline.length) $inline.text(fullLineAddress || '등록된 주소가 없습니다.');

        // 2) 지도 리로케이션 (기존 코드 재활용)
        const container = document.getElementById('kakaoMap');
        if (!container || !window.kakao || !kakao.maps) return;

        const geocoder = new kakao.maps.services.Geocoder();
        geocoder.addressSearch(fullLineAddress, function (result, status) {
            if (status === kakao.maps.services.Status.OK && result.length) {
                const item = result[0];
                const pos = new kakao.maps.LatLng(item.y, item.x);

                // 기존 맵/마커 재사용이 어렵다면 새로 그려도 됨
                const map = new kakao.maps.Map(container, {center: pos, level: 3});
                const marker = new kakao.maps.Marker({position: pos});
                marker.setMap(map);
            } else {
                console.warn('지오코딩 실패:', status, result);
            }
        });
    }

    // ★추가: 모달 오픈/저장 이벤트 바인딩
    $(function () {
        const $modal = $('#addrEditModal');
        const $close = $('#addrEditModalClose'); // $open 제거

// 위임 바인딩: 레이아웃 변동/겹침에도 안정적으로 동작
        $(document).on('click', '#btnAddrEdit', function (e) {
            e.preventDefault();
            const currentLine = $('.card-header-left .header-inline-value').first().text().trim();
            $('#addrForm')[0].reset();
            if (currentLine && currentLine !== '등록된 주소가 없습니다.') {
                $('#addr1').val(currentLine);
            }
            $modal.css('display', 'flex');
        });


        $close.on('click', () => $modal.hide());
        $modal.on('click', (e) => { if (e.target === e.currentTarget) $modal.hide(); });

        // 주소 찾기
        $('#btnFindPost').on('click', function() {
            kakaoPost(document.getElementById('addrForm'));
        });
        // 저장
        $('#btnAddrSave').on('click', function () {
            if (!validateAddressForm()) return;

            // addr2(detail) 동기화(선택)
            $('#addr2').val($('#detailAddress').val());

            const payload = $('#addrForm').serialize();

            $.ajax({
                // ★중요: 프로젝트 규칙에 맞춘 경로
                url: '/mypage/addressUpdate',
                type: 'post',
                dataType: 'json',
                data: payload,
                beforeSend: (xhr) => {
                    const {header, token} = getCsrf();
                    if (header && token) xhr.setRequestHeader(header, token);
                },
                success: function (res) {
                    const success = (res && (res.result === 1 || res.result === "1"));
                    const msg = (res && res.msg) ? res.msg : (success ? '주소가 저장되었어요!' : '저장에 실패했어요.');

                    // 한 줄 주소를 서버에서 다시 만들어 내려줄 수도 있으나,
                    // 여기서는 클라이언트 조합값 사용
                    const line = $('#addr1').val();

                    if (success) {
                        // ✅ 1) 먼저 모달 닫기
                        $modal.hide();

                        showCustomAlert(msg, function () {
                            setTimeout(() => {
                                location.reload();
                            }, 500);
                        }); // 저장 성공 시 커스텀 알림 띄우기

                        // ✅ 확인 버튼 누르고 모달 닫힌 // 1초 후 새로고침 (커스텀 모달 닫히는 타이밍 고려)
                    } else {
                        showCustomAlert('저장에 실패했어요.');
                    }
                },
                error: function (xhr) {
                    console.error('[addr] 저장 실패', xhr.status, xhr.responseText);
                    showCustomAlert('저장 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.');
                }
            });
        });
    });
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>



</body>
</html>