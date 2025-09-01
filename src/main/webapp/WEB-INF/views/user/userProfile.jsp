<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>살며시: 프로필 등록</title>

    <!-- Vendor -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <!-- Project CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>

    <style>
        :root {
            --primary: #3399ff;
            --primary-dark: #1c407d;
            --border: #ddd;
            --muted: #666;
            --header-h: 0px;
            --tag-collapsed-max: 140px; /* 접힘 높이 */
        }

        .register-form-wrapper {
            width: 1100px;
            margin: 0 auto;
            padding: 24px 32px;
            background-color: #FFFFFF;
            height: 820px;
            border-radius: 12px;
            border-top-right-radius: 0;
            box-shadow: -3px -3px 16px rgba(0, 0, 0, 0.1), 6px 5px 16px rgba(0, 0, 0, 0.27);
            position: relative;
            text-align: center;
            box-sizing: border-box;
            overflow: visible;
        }

        @media (min-width: 1200px) {
            body {
                font-size: 18px
            }
        }

        /* grid로 좌/우 높이 동기화 */
        #roommateForm {
            width: 92%;
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns:minmax(0, 1fr) minmax(0, 1fr);
            align-items: stretch;
            gap: 56px;
        }

        /* 좌/우 카드 */
        .roommate-left, .roommate-right {

            display: flex;
            flex-direction: column;
            gap: 20px;
            overflow: visible;
        }

        /* 섹션 카드 */
        .form-block {
            border: 1px solid #e1ecff;
            border-radius: 16px;
            padding: 24px 24px 18px;
        }

        .block-title {
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 500;
            color: var(--primary);
            font-size: 1.15rem;
            margin-bottom: 14px;
        }

        .title-badge {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            background: rgba(51, 153, 255, .12);
            border: 1px solid rgba(51, 153, 255, .25);
            color: var(--primary);
            font-size: 1rem;
        }

        .block-help {
            margin-top: 12px;
            font-size: 14px;
            color: #5f6f84
        }

        /* 읽기전용 필드(이름) */
        .readonly-field {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            border: 1px dashed #d7e7ff;
            border-radius: 10px;
            color: #1f2d3d;
        }

        .readonly-field .label {
            color: #6e7b8b;
            width: 72px;
            font-weight: 500
        }

        .readonly-field .value {
            font-weight: 500
        }

        .image-upload-grid {
            display: flex;
            justify-content: center;
            align-items: center
        }

        .form-block .upload-box {
            margin-inline: auto
        }

        /* ===============================
           ✅ 업로더 크기 & 내부 요소 동시 스케일
           - JS가 --upload-size를 바꾸면 원형/테두리/아이콘/텍스트까지 함께 커짐
           =============================== */
        .roommate-left {
            --upload-size: 240px; /* JS가 동적으로 변경 */
            --upload-icon-ratio: 0.18; /* 아이콘 크기 비율 */
            --upload-text-ratio: 0.06; /* 안내문 텍스트 비율 */
            --upload-border-ratio: 0.012; /* 테두리 두께 비율 */
        }

        .upload-box {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: var(--upload-size);
            height: var(--upload-size);
            border: 2px dashed #bbb; /* 기본값 */
            border-width: clamp(2px, calc(var(--upload-size) * var(--upload-border-ratio)), 8px); /* ★ 스케일 */
            border-radius: 100%;
            overflow: hidden;
            cursor: pointer;
            text-align: center;
            transition: width .25s ease, height .25s ease,
            border-color .2s ease, background-color .2s ease,
            border-width .2s ease
        }

        .upload-box:hover {
            border-color: var(--primary);
            background: #f7fbff;
            transform: translateY(-1px)
        }

        .upload-box i {
            /* fa-2x 대신 동적 크기 */
            font-size: clamp(18px, calc(var(--upload-size) * var(--upload-icon-ratio)), 56px);
            color: #8a8a8a;
            margin-bottom: clamp(8px, calc(var(--upload-size) * 0.04), 18px);
        }

        .upload-box span {
            font-size: clamp(12px, calc(var(--upload-size) * var(--upload-text-ratio)), 20px);
            color: var(--muted)
        }

        .upload-box input[type=file] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer
        }

        .upload-box.has-image {
            border-color: var(--primary);
            background: #f7fbff
        }

        .upload-box.has-image i, .upload-box.has-image span {
            display: none
        }

        .upload-box img.preview {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 100%;
            display: block;
            pointer-events: none
        }

        .upload-box.is-error-photo {
            border-color: var(--primary) !important;
            animation: errorPulse 1s ease-in-out 3
        }

        /* 소개글 카드 풀채움 */
        .roommate-right {
            display: flex;
            flex-direction: column
        }

        .form-block.intro-block {
            flex: 1 1 auto;
            display: flex;
            min-height: 0
        }

        .form-block.intro-block .block-body {
            flex: 1 1 auto;
            display: flex;
            min-height: 0
        }

        .form-block.intro-block .textarea-wrap {
            flex: 1 1 auto;
            display: flex;
            flex-direction: column;
            min-height: 0
        }

        textarea::placeholder {
            font-size: 14px;
        }

        .textarea-wrap {
            display: flex;
            flex-direction: column;
            gap: 10px
        }

        .field-hint {
            font-size: 14px;
            color: #5f6f84
        }

        textarea#introTextarea {
            flex: 1 1 auto;
            min-height: 0;
            width: 100%;
            padding: 18px 20px;
            border: 1px solid #c7d3e6;
            border-radius: 12px;
            font-family: inherit;
            font-size: 14px;
            line-height: 1.65;
            resize: none;
            background: #fff;
        }

        textarea#introTextarea:hover, textarea#introTextarea:focus {
            border-color: var(--primary) !important;
            outline: none;

            background: #fcfeff
        }

        .is-error-intro {
            border: 2px solid var(--primary) !important;

        }

        /* 태그 칩 + 접기/펼치기 */
        .tag-chip-wrap {
            display: flex;
            flex-wrap: wrap;
            row-gap: 10px;
            column-gap: 10px;
            position: relative;
            max-height: var(--tag-collapsed-max);
            overflow: hidden;
            transition: max-height .25s ease;
        }

        .tag-chip-wrap.expanded {
            max-height: none
        }

        .tag-chip-wrap.is-clamped::after {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            bottom: 0;
            height: 44px;
            pointer-events: none;
        }

        .tag-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 999px;
            color: var(--primary-dark);
            font-size: 1rem;
            border: 1px solid #c7dcff;
            white-space: nowrap;
            transition: transform .08s ease;
        }

        .tag-chip i {
            font-size: .95rem
        }

        .tag-chip:hover {
            transform: translateY(-1px);

        }

        .tag-chip-wrap.dense .tag-chip {
            padding: 6px 10px;
            font-size: .95rem
        }

        /* 칩 많으면 컴팩트 */
        .chip-toggle {
            margin-top: 10px;
            display: none;
            align-items: center;
            gap: 8px;
            background: #f0f6ff;
            color: var(--primary-dark);
            border: 1px solid #c7dcff;
            border-radius: 999px;
            padding: 8px 14px;
            cursor: pointer;
            font-size: .95rem;
        }

        /* 저장 버튼 */
        .floating-save {
            position: fixed;
            right: 440px;
            bottom: 70px;
            z-index: 999;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 999px;
            padding: 14px 22px;
            font-size: 1rem;
            cursor: pointer;
        }

        /* 반응형 */
        @media (max-width: 1100px) {
            #roommateForm {
                grid-template-columns:1fr
            }

            .roommate-left, .roommate-right {
                height: auto;
                min-height: unset
            }

            .roommate-left {
                --upload-size: 240px;
            }

            /* 모바일은 기본값 고정 */
            .floating-save {
                right: 16px;
                bottom: 16px;
                padding: 12px 18px
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .upload-box {
                transition: none
            }
        }
        /* 탭 디자인 */
        .register-tab, .prefer-tab, .profile-tab {
            margin-bottom: 12px;
        }

        .register-tab {
            position: absolute;
            top: 10.34%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #4da3ff;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;

            z-index: 2;
        }

        .prefer-tab {
            position: absolute;
            top: 30.5%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #91C4FB;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;

            z-index: 1;
        }

        .profile-tab {
            position: absolute;
            top: 51%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #B1B1B1;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;

        }

        .active-tab {
            right: -39px;
            font-size: 20px !important;
            z-index: 3 !important;
        }
    </style>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="register-form-wrapper">
    <div class="register-tab">REGISTER</div>
    <div class="prefer-tab">PREFER</div>
    <div class="profile-tab active-tab">PROFILE</div>

    <div class="header">
        <div class="logo">PROFILE</div>
        <div class="logo-2">살며시</div>
    </div>

    <main class="roommate-container">
        <form id="roommateForm" action="/roommate/register" method="post" enctype="multipart/form-data" novalidate>
            <!-- Left -->
            <section class="roommate-left">
                <div class="form-block">
                    <div class="block-title">
                        <span class="title-badge"><i class="fa-regular fa-id-card"></i></span><span>기본 정보</span>
                    </div>
                    <div class="readonly-field">
                        <span class="label">이름</span>
                        <span class="value"><%= session.getAttribute("SS_USER_NAME") != null ? session.getAttribute("SS_USER_NAME") : "" %></span>
                    </div>
                </div>

                <div class="form-block">
                    <div class="block-title">
                        <span class="title-badge"><i class="fa-regular fa-image"></i></span><span>프로필 사진</span>
                    </div>
                    <div class="image-upload-grid">
                        <c:set var="profileUrl" value="${userProfile.profileImageUrl}"/>
                        <c:set var="isFirst" value="${empty userProfile}"/>
                        <div class="upload-box ${not empty profileUrl ? 'has-image' : ''}" id="profileUploadBox">
                            <!-- fa-2x 제거: CSS로 동적 스케일 -->
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                            <span>프로필 사진 업로드</span>
                            <input type="file" name="profileImage" accept="image/*"
                                   <c:if test="${isFirst}">required</c:if>/>
                            <c:if test="${not empty profileUrl}">
                                <img class="preview" src="${profileUrl}" alt="profile preview"/>
                            </c:if>
                        </div>
                    </div>
                    <div class="block-help">정면, 밝은 사진 권장 (최대 5MB)</div>
                </div>
            </section>

            <!-- Right -->
            <section class="roommate-right">
                <div class="form-block">
                    <div class="block-title">
                        <span class="title-badge"><i class="fa-solid fa-hashtag"></i></span><span>보여질 태그</span>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${not empty userTags}">
                                <div class="tag-chip-wrap" id="tagWrap">
                                    <c:forEach var="t" items="${userTags}">
                                    <span class="tag-chip"><i class="fa-solid fa-tag"></i>
                                        <c:out value="${empty t.tagName ? t.tag_name : t.tagName}"/>
                                    </span>
                                    </c:forEach>
                                </div>
                                <button type="button" class="chip-toggle" id="chipToggle" aria-expanded="false">
                                    <i class="fa-solid fa-angles-down"></i> 더보기
                                </button>
                            </c:when>
                            <c:otherwise>
                            <span style="color:#6e7b8b; background:#f7faff; border:1px dashed #dbe9ff; border-radius:10px; padding:10px 14px; display:inline-block">
                                <i class="fa-regular fa-circle"></i> 등록된 태그가 없습니다.
                            </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="block-help">마이페이지에서 태그를 관리할 수 있어요.</div>
                </div>

                <div class="form-block intro-block">
                    <div class="block-body textarea-wrap">
                    <textarea id="introTextarea" name="introduction"
                              placeholder="예) 조용한 야근러 / 주말엔 등산 / 설거지 담당 좋아요"
                              <c:if test="${empty userProfile}">required</c:if>><c:out
                            value="${userProfile.introduction}"/></textarea>
                        <div class="field-hint">최소 10자 이상, 예시를 참고해 개성을 드러내 보세요.</div>
                    </div>
                </div>

                <input type="hidden" id="originalIntro" value="${fn:escapeXml(userProfile.introduction)}"/>
                <input type="hidden" id="originalUrl" value="${userProfile.profileImageUrl}"/>
                <input type="hidden" id="isFirstFlag" value="${empty userProfile}"/>
            </section>
        </form>
    </main>
</div>

<!-- 저장 버튼 -->
<button type="button" id="floatingSaveBtn" class="floating-save" title="저장">
    <i class="fa-solid fa-floppy-disk"></i><span>저장</span>
</button>

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
<%
    String ssUserId = (String) session.getAttribute("SS_USER_ID");
    if (ssUserId == null) {
        ssUserId = "";
    }
%>
<script>
    const userId = "<%= ssUserId %>";
    console.log(userId);
</script>

<script>
    /* Alert */
    function showCustomAlert(msg) {
        const ov = document.getElementById('customAlertOverlay');
        document.getElementById('customAlertMessage').textContent = msg;
        ov.style.display = 'flex';
    }

    function closeCustomAlert() {
        document.getElementById('customAlertOverlay').style.display = 'none';
    }

    /* 저장 → 제출 */
    (function () {
        const form = document.getElementById('roommateForm');
        const btn = document.getElementById('floatingSaveBtn');
        if (!form || !btn) return;
        btn.addEventListener('click', function () {
            if (form.requestSubmit) {
                form.requestSubmit();
            } else {
                const ok = form.dispatchEvent(new Event('submit', {cancelable: true}));
                if (ok) form.submit();
            }
        });
    })();

    /* 파일 미리보기 + 사진 에러 강조 단독 적용 */
    document.querySelectorAll('.upload-box input[type="file"]').forEach((input) => {
        const box = input.closest('.upload-box');
        input.addEventListener('change', (e) => {
            box.classList.remove('is-error-photo');
            const file = e.target.files && e.target.files[0];
            if (!file) return;
            if (!file.type.startsWith('image/')) {
                showCustomAlert('이미지 파일만 업로드할 수 있어요.');
                e.target.value = '';
                box.classList.add('is-error-photo');
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                showCustomAlert('파일 용량이 너무 커요. (최대 5MB)');
                e.target.value = '';
                box.classList.add('is-error-photo');
                return;
            }
            const reader = new FileReader();
            reader.onload = () => {
                box.classList.add('has-image');
                let img = box.querySelector('img.preview');
                if (!img) {
                    img = document.createElement('img');
                    img.className = 'preview';
                    box.appendChild(img);
                }
                img.src = reader.result;
            };
            reader.readAsDataURL(file);

            deferCalcUploadSize(); /* 업로드 후 크기 재계산 */
        });
    });

    /* 커스텀 검증: 첫 에러만 강조(사진 → 소개글) */
    /* 커스텀 검증: 첫 에러만 강조(사진 → 소개글) */
    document.getElementById('roommateForm').addEventListener('submit', function (e) {
        // [수정] 이 부분을 함수의 가장 위로 옮겨야 합니다.
        // 이렇게 하면 유효성 검사를 통과하더라도 페이지가 새로고침되지 않습니다.
        e.preventDefault();

        const isFirst = document.getElementById('isFirstFlag').value === 'true';
        const fileInput = document.querySelector('input[name="profileImage"]');
        const uploadBox = document.getElementById('profileUploadBox');
        const hasFile = fileInput && fileInput.files && fileInput.files.length > 0;

        const introEl = document.getElementById('introTextarea');
        const intro = (introEl.value || '').trim();
        const origIntro = (document.getElementById('originalIntro').value || '').trim();

        uploadBox.classList.remove('is-error-photo');
        introEl.classList.remove('is-error-intro');

        // 유효성 검사 실패 시 return하는 로직은 그대로 유지합니다.
        if (isFirst) {
            if (!hasFile) {
                // e.preventDefault(); // 이미 위에서 처리했으므로 여기서 또 호출할 필요는 없습니다.
                showCustomAlert('프로필 사진을 업로드해주세요.');
                uploadBox.classList.add('is-error-photo');
                uploadBox.scrollIntoView({behavior: 'smooth', block: 'center'});
                return;
            }
            if (intro.length < 10) { // 최소 글자 수 검사 추가
                // e.preventDefault();
                showCustomAlert('자기소개를 10자 이상 입력해주세요.');
                introEl.classList.add('is-error-intro');
                introEl.focus();
                return;
            }
        } else {
            const originalUrl = document.getElementById('originalUrl').value;
            if (!hasFile && intro === origIntro && originalUrl === (uploadBox.querySelector('img.preview')?.src || '')) {
                // e.preventDefault();
                showCustomAlert('변경된 내용이 없습니다.');
                introEl.classList.add('is-error-intro');
                introEl.focus();
                return;
            }
        }

        // 유효성 검사를 통과하면 이 코드가 실행됩니다.
        const formData = new FormData(this);

        $.ajax({
            url: "/roommate/register",
            type: "POST",
            data: formData,
            processData: false,
            contentType: false,
            success: function (response) {
                if (response.result === "success") {
                    showCustomAlert('저장이 완료되었습니다.', function () {
                        location.href = "/user/main";
                    });
                } else {
                    showCustomAlert(response.msg || '저장에 실패했습니다.');
                }
            },
            error: function (xhr) {
                showCustomAlert('오류가 발생했습니다. 다시 시도해주세요.');
            }
        });
    });

    /* 태그 영역: 자동 클램프 + 더보기/접기 + 많을 때 dense */
    (function () {
        const wrap = document.getElementById('tagWrap');
        const btn = document.getElementById('chipToggle');
        if (!wrap || !btn) {
            calcUploadSize();
            return;
        }

        const chips = wrap.querySelectorAll('.tag-chip');
        if (chips.length > 12) {
            wrap.classList.add('dense');
        }

        const collapsedMax = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--tag-collapsed-max')) || 140;
        const needsClamp = wrap.scrollHeight > collapsedMax + 8;
        if (needsClamp) {
            wrap.classList.add('is-clamped');
            btn.style.display = 'inline-flex';
        }

        btn.addEventListener('click', function () {
            const expanded = wrap.classList.toggle('expanded');
            btn.setAttribute('aria-expanded', expanded ? 'true' : 'false');
            btn.innerHTML = expanded ? '<i class="fa-solid fa-angles-up"></i> 접기' : '<i class="fa-solid fa-angles-down"></i> 더보기';
            wrap.classList.toggle('is-clamped', !expanded && needsClamp);

            deferCalcUploadSize(); /* 펼침/접힘 후 업로더 크기 재계산 */
        });

        calcUploadSize(); /* 초기 계산 */
    })();

    /* ============================
       ✅ 업로드 박스 크기 = '소개글 영역 높이'에 맞춤
       ============================ */
    function calcUploadSize() {
        const leftCard = document.querySelector('.roommate-left');
        const uploadBox = document.getElementById('profileUploadBox');
        const introBody = document.querySelector('.roommate-right .intro-block .block-body');
        if (!leftCard || !uploadBox || !introBody) return;

        // 모바일(1열)은 동기화 대신 기본값 유지
        const isNarrow = window.matchMedia('(max-width:1100px)').matches;
        if (isNarrow) {
            leftCard.style.setProperty('--upload-size', '240px');
            return;
        }

        const introH = Math.round(introBody.getBoundingClientRect().height);
        const correction = 6;
        const minSize = 220;
        const maxSize = Math.min(window.innerHeight - 140, 1000);
        const target = Math.max(minSize, Math.min(maxSize, introH - correction));

        leftCard.style.setProperty('--upload-size', target + 'px');
    }

    // 레이아웃 변경 직후 안전 계산
    function deferCalcUploadSize() {
        requestAnimationFrame(() => {
            requestAnimationFrame(calcUploadSize);
        });
    }

    // 초기/리사이즈 시 갱신
    window.addEventListener('load', calcUploadSize);
    window.addEventListener('resize', calcUploadSize);
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
