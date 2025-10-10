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
            background: #3399ff; /* 파란 배경 */
            color: #fff; /* 흰 글씨 */
            border-color: #3399ff; /* 테두리 파랑 */
        }

        .card-action-btn.active:hover,
        .card-action-btn.active:focus-visible {
            background: #1c407d; /* 딥블루 */
            border-color: #1c407d;
            color: #fff;
            box-shadow: 0 2px 8px rgba(28, 64, 125, 0.25);
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

        /* 주소+지도 래퍼 */
        .addr-row {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .addr-map {
            width: 100%;
            height: 260px; /* 필요하면 여기 숫자만 조절 */
            border: 1px solid #e5efff;
            border-radius: 8px;
            overflow: hidden;
        }

        /* 드래그/선택 허용 */
        .intro-area {
            user-select: text;
            -webkit-user-select: text;
            cursor: text;
        }

        /* 편집 중 시각 피드백 */
        .intro-area.is-editing {
            outline: 2px solid rgba(51, 153, 255, .35);
            box-shadow: 0 0 0 3px rgba(51, 153, 255, .12) inset;
        }

        /* 클릭 가능한 프로필 이미지 래퍼 */
        .profile-photo-wrap {
            position: relative;
            width: 90px;
            height: 90px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        /* 파란 점선 네온 */
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

        /* 업로드 중 애니메이션(선택) */
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

        /* [ADD] 마이페이지 태그 모달 전용 최소 스타일 */
        .mytag-group {
            display: flex;
            gap: 12px;
            padding: 12px 0;
            border-bottom: 1px solid #f1f3f5
        }

        .mytag-ico {
            width: 28px;
            display: flex;
            align-items: flex-start;
            justify-content: center
        }

        .mytag-body {
            flex: 1
        }

        .mytag-title {
            font-weight: 700;
            margin-bottom: 8px
        }

        .mytag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px
        }

        .mytag-btn, .tag-btn {
            border: 1px solid #d0d7e2;
            background: #fff;
            border-radius: 999px;
            padding: 6px 10px;
            cursor: pointer;
        }

        .mytag-btn.selected, .tag-btn.selected {
            background: #3399ff;
            color: #fff;
            border-color: #3399ff;
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
                    <div class="card-body profile-section">
                        <!-- 클릭 가능 영역: 래퍼 + 네온 오버레이 -->
                        <div id="profilePhotoWrap" class="profile-photo-wrap" title="프로필 사진 변경하기">
                            <img id="profilePhotoImg"
                                 src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") %>"
                                 alt="프로필 사진"
                                 class="profile-pic-placeholder"/>
                            <div class="photo-edit-glow" aria-hidden="true"></div>
                        </div>
                        <!-- [ADD] 여기 추가 -->
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

            <!-- 태그 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>태그</h3>
                    <!-- [ADD] 태그 수정 버튼 -->
                    <%--<a href="/mypage/tagEdit" class="card-action-btn active" title="태그 수정">태그 수정</a>--%>
                    <a id="btnTagEdit" class="card-action-btn active" title="태그 수정">태그 수정</a>
                </div>
                <!-- [모달] 마이페이지 태그 수정 -->
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
                            <div id="mypageTagGroupContainer"><!-- JS로 렌더링 --></div>
                        </div>
                        <div class="modal-footer"
                             style="display:flex; gap:10px; justify-content:flex-end; padding:12px 16px; border-top:1px solid #eee;">
                            <button type="button" id="btnTagSave" class="card-action-btn active">저장</button>
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


            <!-- 자기소개 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <h3>자기소개</h3>
                    <!-- [MOD] 페이지 이동 막고 id만 부여 -->
                    <a id="introSaveBtn" class="card-action-btn active" title="수정하기">수정하기</a>
                </div>

                <div class="card-body intro-body">
                    <!-- [VIEW] 이 박스 자체를 클릭하면 contenteditable로 전환 -->
                    <div class="intro-area" id="introArea">
                        <c:choose>
                            <c:when test="${not empty rDTO.introduction}">
                                <c:out value="${rDTO.introduction}"/>
                            </c:when>
                            <c:otherwise>아직 소개글이 없습니다.</c:otherwise>
                        </c:choose>
                    </div>

                    <!-- [ADD] 숨김 폼: AJAX serialize()용 (CSRF 포함) -->
                    <form id="introForm" style="display:none;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="introduction" id="introHiddenInput"/>
                    </form>
                </div>
            </div>


            <!-- 주소 카드 -->
            <div class="mypage-card">
                <div class="card-header">
                    <div class="card-header-left">
                        <h3>주소</h3>
                        <!-- [ADD] 상세 주소: 헤더 안 한 줄 표기 + 말줄임 -->
                        <span class="header-inline-value">
                <c:out value="${not empty rDTO.addr1 ? rDTO.addr1 : '등록된 주소가 없습니다.'}"/>
            </span>
                    </div>
                    <a href="${pageContext.request.contextPath}/mypage/addressEdit"
                       class="card-action-btn active" title="주소 수정">주소 수정</a>
                </div>

                <div class="card-body">
                    <%-- 페이지 스코프로 주소 보존 (지오코딩용) --%>
                    <c:set var="addr1" value="${not empty rDTO.addr1 ? rDTO.addr1 : ''}"/>

                    <!-- 지도: 헤더 바로 아래 -->
                    <div id="kakaoMap" class="addr-map"></div>
                </div>
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

<!-- 업로드 엔드포인트 & CSRF 상수 -->
<%--<script>
    // 절대경로 안전
    const PROFILE_UPLOAD_URL = '<c:url value="/mypage/profileImageUpdate"/>';
    // 스프링 시큐리티가 내려주는 CSRF 헤더/토큰
    const CSRF_HEADER = '${_csrf.headerName}';
    const CSRF_TOKEN = '${_csrf.token}';
</script>--%>


<!-- 업로드 엔드포인트 상수 (절대경로 안전) -->
<%--<c:url value="/mypage/profileImageUpdate" var="PROFILE_UPLOAD_URL"/>
<script>const PROFILE_UPLOAD_URL = '${PROFILE_UPLOAD_URL}';</script>--%>
<script>
    // ★추가: CSRF 안전 추출 + fallback
    function getCsrf() {
        // JSP가 내려준 값 우선
        let header = ('${_csrf.headerName}'||'').trim();
        let token  = ('${_csrf.token}'||'').trim();

        // 비어있으면 숨은 input에서 대체 추출 (introForm에 이미 존재)
        if (!token) {
            const el = document.querySelector('input[name="${_csrf.parameterName}"]');
            if (el && el.value) token = el.value.trim();
        }
        // 최종 안전망: Spring Security 기본 헤더명
        if (!header) header = 'X-CSRF-TOKEN';
        return { header, token };
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

<!-- Kakao Maps SDK: autoload=false로 안전 초기화 -->
<!-- [FIX] Kakao Maps SDK: services + autoload=false 추가 -->
<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=218d70914021664c1d8e3dc194489251&libraries=services&autoload=false"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        // JSP에서 내려준 주소(없으면 빈 문자열)
        // [KEEP] 위에서 c:set var="addr1" 해둔 값을 사용
        const addrText = "<c:out value='${addr1}'/>".trim();
        const container = document.getElementById('kakaoMap');

        if (!container) return;

        // [FIX] autoload=false를 썼으니 kakao.maps.load로 안전 초기화
        kakao.maps.load(function () {
            // 1) 기본 지도 먼저 (주소 없어도 지도 보이게)
            const defaultCenter = new kakao.maps.LatLng(37.5665, 126.9780); // 서울시청
            const map = new kakao.maps.Map(container, {center: defaultCenter, level: 4});

            // 기본 마커
            const marker = new kakao.maps.Marker({position: defaultCenter});
            marker.setMap(map);

            // 반응형 레이아웃 대응 (사이드바/그리드 영향)
            function relayoutAndCenter() {
                map.relayout();
                map.setCenter(marker.getPosition());
            }

            window.addEventListener('resize', relayoutAndCenter);
            setTimeout(relayoutAndCenter, 0);

            // 2) 주소가 있으면 지오코딩 후 이동
            if (addrText && addrText.length > 0) {
                const geocoder = new kakao.maps.services.Geocoder();

                geocoder.addressSearch(addrText, function (result, status) {
                    if (status === kakao.maps.services.Status.OK && result.length) {
                        const item = result[0];
                        const pos = new kakao.maps.LatLng(item.y, item.x);

                        // 마커/지도만 이동
                        marker.setPosition(pos);
                        map.setCenter(pos);
                        map.setLevel(3);

                        // (선택) 마커에 툴팁만 주고 싶으면 title 설정 (마우스 올릴 때 브라우저 기본 툴팁)
                        // const label =
                        //   (item.address_name && item.address_name.trim()) ||
                        //   (item.road_address && item.road_address.address_name && item.road_address.address_name.trim()) ||
                        //   (addrText && addrText.trim()) || '';
                        // if (label) marker.setTitle(label);

                        // ✅ 인포윈도우 생성/오픈 코드 완전 제거
                        // const iw = new kakao.maps.InfoWindow({ content: '...' });
                        // iw.open(map, marker);
                    } else {
                        console.warn('지오코딩 실패:', status, result);
                    }
                });


            }
        });
    });
</script>

<%--<script>--%>
<%--    서버가 만들어준 절대 경로 (예: /mypage/introductionUpdate 또는 /user/mypage/introductionUpdate)--%>
<%--    const INTRO_UPDATE_URL = '<c:url value="/mypage/introductionUpdate"/>';--%>
<%--    console.log('[intro] POST to:', INTRO_UPDATE_URL);--%>
<%--</script>--%>

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
                (window.showCustomAlert || alert)('자기소개는 1000자 이하로 작성해주세요.');
                return;
            }

            $hidden.val(newText);

            $.ajax({
                url: INTRO_UPDATE_URL,        // ★ 여기만 변경
                type: 'post',
                dataType: 'text',             // 컨트롤러가 String 반환
                data: $form.serialize(),      // introduction + _csrf 포함
                success: function (msg) {
                    $area.text(newText || '아직 소개글이 없습니다.')
                        .removeAttr('contenteditable')
                        .removeClass('is-editing');
                    editing = false;
                    (window.showCustomAlert || alert)(msg || '자기소개가 저장되었어요!');
                },
                error: function (xhr) {
                    console.error('[intro] 저장 실패', xhr.status, xhr.responseText);
                    (window.showCustomAlert || alert)('저장 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.');
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

        // 클릭 → 파일 선택
        $wrap.on('click', function () {
            $wrap.addClass('active');
            $file.trigger('click');
        });

        // 파일 선택시
        $file.on('change', function (e) {
            const f = e.target.files && e.target.files[0];
            if (!f) {
                $wrap.removeClass('active');
                return;
            }

            // 1) 검증
            if (!/^image\//.test(f.type)) {
                alert('이미지 파일만 업로드할 수 있어요.');
                $wrap.removeClass('active');
                return;
            }
            if (f.size > 5 * 1024 * 1024) {
                alert('최대 5MB까지 업로드 가능합니다.');
                $wrap.removeClass('active');
                return;
            }

            // 2) 미리보기
            const blobUrl = URL.createObjectURL(f);
            $img.attr('src', blobUrl);

            // 3) 서버 업로드 (CSRF는 헤더로!)
            const fd = new FormData();
            fd.append('file', f);

            $wrap.addClass('loading');

            $.ajax({
                url: PROFILE_UPLOAD_URL,     // ex) /mypage/profileImageUpdate
                type: 'post',
                data: fd,
                processData: false,
                contentType: false,
                dataType: 'json',
                beforeSend: (xhr) => {                               // ★변경
                    const { header, token } = getCsrf();
                    if (header && token) xhr.setRequestHeader(header, token);
                    else console.warn('[profile] CSRF header/token이 없어 헤더 설정 생략');
                },

                success: function (res) {
                    if (res && res.url) {
                        const finalUrl = res.url + (res.url.includes('?') ? '&' : '?') + 'v=' + Date.now();
                        $img.attr('src', finalUrl); // 캐시 무력화된 미리보기
                    }

                    // 1) '수정 완료' 모달을 띄워주고
                    showCustomAlert('프로필 사진이 변경되었어요!', function () {
                        location.reload();
                    });
                },
                error: function (xhr) {
                    console.error('[profile] 업로드 실패', xhr.status, xhr.responseText);
                    alert('업로드 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.');
                },
                complete: function () {
                    $wrap.removeClass('active loading');
                    $file.val('');
                }
            });
        });
    });

</script>


<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>

<script>
    const CTX = '${pageContext.request.contextPath}';
    // 태그 API (컨트롤러 prefix가 /mypage 이므로 절대경로 사용)
    const TAG_ALL_URL = '<c:url value="/mypage/tags/all"/>';
    const TAG_MY_URL = '<c:url value="/mypage/tags/my"/>';
    const TAG_UPDATE_URL = '<c:url value="/mypage/tags/update"/>';
    // 기존 기능
    const INTRO_UPDATE_URL = '<c:url value="/mypage/introductionUpdate"/>';
    const PROFILE_UPLOAD_URL = '<c:url value="/mypage/profileImageUpdate"/>';
    // CSRF
    const CSRF_HEADER = '${_csrf.headerName}';
    const CSRF_TOKEN = '${_csrf.token}';
</script>

<script>
    $(function () {
        // 그룹 정의 (key는 DB TAG.tag_type 과 1:1)
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
        const $btnSave = $('#btnTagSave');
        const $wrap = $('#mypageTagGroupContainer');

        // 현재 선택 상태: group(tag_type) -> {tagId, tagName}
        const selectedByGroup = new Map();

        // 열기: 전체 태그 + 내 선택 로드
        $btnEdit.on('click', async function () {
            $wrap.empty();
            selectedByGroup.clear();
            try {
                // all: [ { tagId:int, tagName:String, tagType:String } ]
                // mine: [ { tagId:Long, tagType:String } ]
                const [allTags, myTags] = await Promise.all([
                    $.getJSON(TAG_ALL_URL),
                    $.getJSON(TAG_MY_URL)
                ]);
                const myMap = {};
                (myTags || []).forEach(s => {
                    myMap[s.tagType] = s.tagId;
                });
                renderGroups(allTags, myMap);
                $modal.css('display', 'flex');
            } catch (e) {
                console.error('태그 로드 실패', e);
                alert('태그를 불러오는 중 오류가 발생했어요.');
            }
        });

        // 닫기
        $modalClose.on('click', () => $modal.hide());
        $modal.on('click', (e) => {
            if (e.target === e.currentTarget) $modal.hide();
        });

        // 저장: DTO 한 개로(tagList만) 전송
        $btnSave.on('click', async function () {
            const payload = {tagList: []}; // UserTagDTO 형태
            selectedByGroup.forEach(v => payload.tagList.push(Number(v.tagId)));

            try {
                const res = await $.ajax({
                    url: TAG_UPDATE_URL,
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(payload),
                    dataType: 'json',
                    beforeSend: (xhr) => {
                        const { header, token } = getCsrf();          // ★변경
                        if (header && token) xhr.setRequestHeader(header, token);
                        else console.warn('[tags] CSRF header/token이 없어 헤더 설정 생략');
                    }

                });

                // 칩 갱신: res.tags => [ { tagId:int, tagName:String } ]
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
                alert('태그가 저장되었어요!');
            } catch (e) {
                console.error('태그 저장 실패', e);


                alert('저장 중 오류가 발생했어요.');
            }
        });

        function renderGroups(allTags, myMap) {
            // tagType별로 묶기
            const byGroup = new Map();
            (allTags || []).forEach(t => {
                const g = t.tagType;
                if (!byGroup.has(g)) byGroup.set(g, []);
                byGroup.get(g).push({tagId: t.tagId, tagName: t.tagName});
            });

            // 그룹 렌더
            tagGroups.forEach(g => {
                const list = byGroup.get(g.key) || [];
                const $g = $('<div class="mytag-group">');
                const $ico = $('<div class="mytag-ico">').append($('<i>').addClass(g.icon));
                const $body = $('<div class="mytag-body">');
                const $title = $('<div class="mytag-title">').text(g.title);
                const $list = $('<div class="mytag-list">');

                list.forEach(tag => {
                    const $btn = $('<button type="button" class="mytag-btn">')
                        .text(tag.tagName)
                        .attr('data-id', tag.tagId)
                        .attr('data-group', g.key);

                    // 내 선택 미리 표시
                    if (myMap[g.key] && Number(myMap[g.key]) === Number(tag.tagId)) {
                        $btn.addClass('selected');
                        selectedByGroup.set(g.key, {tagId: tag.tagId, tagName: tag.tagName});
                    }

                    // 단일 선택
                    $btn.on('click', function () {
                        $list.find('.mytag-btn').removeClass('selected');
                        $(this).addClass('selected');
                        selectedByGroup.set(g.key, {tagId: tag.tagId, tagName: tag.tagName});
                    });

                    $list.append($btn);
                });

                $body.append($title, $list);
                $g.append($ico, $body);
                $wrap.append($g);
            });
        }
    });
</script>


</body>
</html>