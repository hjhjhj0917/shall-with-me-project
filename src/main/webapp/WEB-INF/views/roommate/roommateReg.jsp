<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>sample</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>

    <style>
        :root {
            --primary: #3399ff;
            --primary-dark: #1c407d;
            --border: #ddd;
            --muted: #666;
            --header-h: 0px;
            --tag-collapsed-max: 140px;
            --tag-scroll-h: clamp(140px, 24vh, 260px);
        }

        html, body {
            height: 100%
        }

        body {
            margin: 0;
            display: flex;
            flex-direction: column;
            min-height: 100svh;
            overflow-x: hidden;
            font-size: 17px;
            line-height: 1.6;
        }

        @media (min-width: 1200px) {
            body {
                font-size: 18px
            }
        }

        .roommate-container {
            flex: 1 0 auto;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            min-height: calc(100svh - var(--header-h));
            padding: 32px 20px;
            box-sizing: border-box;
        }

        #roommateForm {
            width: 92%;
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns:minmax(0, 1fr) minmax(0, 1fr);
            align-items: stretch;
            gap: 56px;
        }

        .roommate-left, .roommate-right {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 32px;
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 520px;
            box-shadow: 0 14px 36px rgba(0, 0, 0, .08);
            gap: 20px;
            overflow: visible;
        }

        .form-block {
            background: linear-gradient(180deg, #fff 0%, #f4f9ff 100%);
            border: 1px solid #e1ecff;
            border-radius: 16px;
            padding: 24px 24px 18px;
            box-shadow: 0 8px 22px rgba(0, 0, 0, .05);
        }

        .block-title {
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 800;
            color: var(--primary-dark);
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
            color: var(--primary-dark);
            font-size: 1rem;
        }

        .block-help {
            margin-top: 12px;
            font-size: .95rem;
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
            background: #f9fbff;
            color: #1f2d3d;
        }

        .readonly-field .label {
            color: #6e7b8b;
            width: 72px;
            font-weight: 700
        }

        .readonly-field .value {
            font-weight: 800
        }

        .image-upload-grid {
            display: flex;
            justify-content: center;
            align-items: center
        }

        .form-block .upload-box {
            margin-inline: auto
        }


        .roommate-left {
            --upload-size: 240px;
            --upload-icon-ratio: 0.18;
            --upload-text-ratio: 0.06;
            --upload-border-ratio: 0.012;
        }

        .upload-box {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: var(--upload-size);
            height: var(--upload-size);
            border: 2px dashed #bbb;
            border-width: clamp(2px, calc(var(--upload-size) * var(--upload-border-ratio)), 8px);
            border-radius: 100%;
            overflow: hidden;
            cursor: pointer;
            text-align: center;
            transition: width .25s ease, height .25s ease,
            border-color .2s ease, background-color .2s ease,
            border-width .2s ease,
            box-shadow .2s ease, transform .08s ease;
        }

        .upload-box:hover {
            border-color: var(--primary);
            background: #f7fbff;
            box-shadow: 0 0 0 4px rgba(51, 153, 255, .12);
            transform: translateY(-1px)
        }

        .upload-box i {
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
            box-shadow: 0 0 0 5px rgba(51, 153, 255, .18);
            animation: errorPulse 1s ease-in-out 3
        }

        @keyframes errorPulse {
            0% {
                box-shadow: 0 0 0 0 rgba(51, 153, 255, .35)
            }
            100% {
                box-shadow: 0 0 0 12px rgba(51, 153, 255, 0)
            }
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

        .textarea-wrap {
            display: flex;
            flex-direction: column;
            gap: 10px
        }

        .field-hint {
            font-size: .95rem;
            color: #5f6f84
        }

        textarea#introTextarea {
            flex: 1 1 auto;
            min-height: 0;
            width: 100%;
            padding: 18px 20px;
            border: 1px solid #c7d3e6;
            border-radius: 12px;
            resize: vertical;
            font-family: inherit;
            font-size: 1.02rem;
            line-height: 1.65;
            transition: border-color .2s, box-shadow .2s, background-color .2s;
            background: #fff;
        }

        textarea#introTextarea:hover, textarea#introTextarea:focus {
            border-color: var(--primary) !important;
            outline: none;
            box-shadow: 0 0 0 4px rgba(51, 153, 255, .15);
            background: #fcfeff
        }

        .is-error-intro {
            border: 2px solid var(--primary) !important;
            box-shadow: 0 0 0 5px rgba(51, 153, 255, .22)
        }


        .tag-chip-wrap {
            display: flex;
            flex-wrap: wrap;
            row-gap: 10px;
            column-gap: 10px;
            max-height: var(--tag-scroll-h);
            overflow: auto;
            padding-right: 6px;
            scrollbar-gutter: stable both-edges;
            scroll-behavior: smooth;
            position: relative;
        }

        .tag-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 999px;
            background: linear-gradient(180deg, #f0f6ff 0%, #e3efff 100%);
            color: var(--primary-dark);
            font-size: 1rem;
            border: 1px solid #c7dcff;
            white-space: nowrap;
            transition: transform .08s ease, box-shadow .2s ease;
        }

        .tag-chip i {
            font-size: .95rem
        }

        .tag-chip:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(28, 64, 125, .1)
        }

        .tag-chip-wrap.dense .tag-chip {
            padding: 6px 10px;
            font-size: .95rem
        }

        /* 칩 많으면 컴팩트 */


        .tag-chip-wrap:focus-visible {
            outline: 3px solid rgba(51, 153, 255, .35);
            border-radius: 12px;
        }


        .tag-chip-wrap::-webkit-scrollbar {
            width: 10px
        }

        .tag-chip-wrap::-webkit-scrollbar-track {
            background: #eef4ff;
            border-radius: 8px
        }

        .tag-chip-wrap::-webkit-scrollbar-thumb {
            background: #c7dcff;
            border-radius: 8px;
            border: 2px solid #eef4ff
        }

        .tag-chip-wrap {
            scrollbar-width: thin;
            scrollbar-color: #c7dcff #eef4ff
        }


        .tag-chip-wrap.expanded {
            max-height: var(--tag-scroll-h) !important
        }

        .tag-chip-wrap.is-clamped::after {
            display: none !important
        }

        .chip-toggle {
            display: none !important
        }


        .floating-save {
            position: fixed;
            right: 28px;
            bottom: 28px;
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
            box-shadow: 0 12px 28px rgba(0, 0, 0, .16);
        }


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
    </style>
</head>
<body>

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
                            <div class="tag-chip-wrap" id="tagWrap" tabindex="0" aria-label="사용자 태그 목록 (스크롤 가능)">
                                <c:forEach var="t" items="${userTags}">
                                    <span class="tag-chip"><i class="fa-solid fa-tag"></i>
                                        <c:out value="${empty t.tagName ? t.tag_name : t.tagName}"/>
                                    </span>
                                </c:forEach>
                            </div>
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

<!-- 저장 버튼 -->
<button type="button" id="floatingSaveBtn" class="floating-save" title="저장">
    <i class="fa-solid fa-floppy-disk"></i><span>저장</span>
</button>

<!-- Alert -->
<div id="customAlertOverlay" class="modal-overlay" style="display:none">
    <div class="modal">
        <div class="modal-title">
            <i class="fa-solid fa-circle-exclamation fa-shake fa-lg" style="color:var(--primary)"></i>
            <h2>살며시</h2>
        </div>
        <p id="customAlertMessage">메시지 내용</p>
        <div class="modal-buttons" style="text-align:right">
            <button class="deactivate-btn" onclick="closeCustomAlert()">확인</button>
        </div>
    </div>
</div>

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

            deferCalcUploadSize();
        });
    });

    document.getElementById('roommateForm').addEventListener('submit', function (e) {
        const isFirst = document.getElementById('isFirstFlag').value === 'true';
        const fileInput = document.querySelector('input[name="profileImage"]');
        const uploadBox = document.getElementById('profileUploadBox');
        const hasFile = fileInput && fileInput.files && fileInput.files.length > 0;

        const introEl = document.getElementById('introTextarea');
        const intro = (introEl.value || '').trim();
        const origIntro = (document.getElementById('originalIntro').value || '').trim();

        uploadBox.classList.remove('is-error-photo');
        introEl.classList.remove('is-error-intro');

        if (isFirst) {
            if (!hasFile) {
                e.preventDefault();
                showCustomAlert('프로필 사진을 업로드해주세요.');
                uploadBox.classList.add('is-error-photo');
                try {
                    fileInput.focus();
                } catch (_) {
                }
                uploadBox.scrollIntoView({behavior: 'smooth', block: 'center'});
                return;
            }
            if (intro.length === 0) {
                e.preventDefault();
                showCustomAlert('자기소개를 입력해주세요.');
                introEl.classList.add('is-error-intro');
                introEl.focus();
                return;
            }
        } else {
            if (!hasFile && intro === origIntro) {
                e.preventDefault();
                showCustomAlert('변경된 내용이 없습니다.');
                introEl.classList.add('is-error-intro');
                introEl.focus();
                return;
            }
        }
    });


    (function () {
        const wrap = document.getElementById('tagWrap');
        if (!wrap) {
            calcUploadSize();
            return;
        }

        const chips = wrap.querySelectorAll('.tag-chip');
        if (chips.length > 12) {
            wrap.classList.add('dense');
        }


        calcUploadSize();
    })();


    function calcUploadSize() {
        const leftCard = document.querySelector('.roommate-left');
        const uploadBox = document.getElementById('profileUploadBox');
        const introBody = document.querySelector('.roommate-right .intro-block .block-body');
        if (!leftCard || !uploadBox || !introBody) return;

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

    function deferCalcUploadSize() {
        requestAnimationFrame(() => {
            requestAnimationFrame(calcUploadSize);
        });
    }


    window.addEventListener('load', calcUploadSize);
    window.addEventListener('resize', calcUploadSize);
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
