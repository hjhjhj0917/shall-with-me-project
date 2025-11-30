<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>내 프로필</title>

    <!-- Vendor -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <!-- Project CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>

    <c:set var="profileUrl" value="${userProfile.profileImageUrl}"/>
    <c:set var="introText" value="${userProfile.introduction}"/>
    <c:set var="defaultProfileUrl" value="${pageContext.request.contextPath}/images/default-profile.png"/>

    <style>
        :root {
            --primary: #3399ff;
            --primary-dark: #1c407d;
            --border: #ddd;
            --muted: #666;
            --header-h: 0px;

            /* [ADD] 태그 2줄 보장용 변수 */
            --chip-h: 36px;           /* 칩 한 줄 높이(대략) */
            --chip-row-gap: 10px;     /* 행 간격 */
            --tag-min-rows: 2;        /* 최소 보이는 줄 수 */
        }

        html, body { height: 100% }

        body {
            margin: 0;
            display: flex;
            flex-direction: column;
            min-height: 100svh;
            overflow-x: hidden;
            font-size: 17px;
            line-height: 1.6;
        }

        @media (min-width: 1200px) { body { font-size: 18px } }

        /* 중앙 배치 컨테이너 */
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

        /* grid로 좌/우 높이 동기화 */
        #profileView {
            width: 92%;
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            align-items: stretch;
            gap: 56px;
        }

        /* 좌/우 카드 */
        .roommate-left, .roommate-right {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 32px;
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 520px;
            box-shadow: 0 14px 36px rgba(0,0,0,.08);
            gap: 20px;
            overflow: visible;
        }

        /* 섹션 카드 */
        .form-block {
            background: linear-gradient(180deg, #fff 0%, #f4f9ff 100%);
            border: 1px solid #e1ecff;
            border-radius: 16px;
            padding: 24px 24px 18px;
            box-shadow: 0 8px 22px rgba(0,0,0,.05);
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
            background: rgba(51,153,255,.12);
            border: 1px solid rgba(51,153,255,.25);
            color: var(--primary-dark);
            font-size: 1rem;
        }

        .block-help { margin-top: 12px; font-size: .95rem; color: #5f6f84 }

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
        .readonly-field .label { color: #6e7b8b; width: 72px; font-weight: 700 }
        .readonly-field .value { font-weight: 800 }

        /* 아바타 */
        .avatar-circle-wrap { display: flex; justify-content: center; align-items: center }
        .roommate-left { --upload-size: 240px; }
        .avatar-circle {
            width: var(--upload-size);
            height: var(--upload-size);
            border-radius: 50%;
            overflow: hidden;
            border: 3px solid #c7dcff;
            background: #f7fbff;
            box-shadow: 0 12px 28px rgba(0,0,0,.08);
            margin-inline: auto;
        }
        .avatar-circle img { width: 100%; height: 100%; object-fit: cover; display: block; }

        /* 소개글 카드 */
        .roommate-right { display: flex; flex-direction: column }
        .form-block.intro-block {
            position: relative;
            flex: 1 1 auto;
            display: flex;
            min-height: 0;
            padding-top: 56px;
        }
        .form-block.intro-block > .block-title {
            position: absolute; top: 12px; left: 16px; margin: 0;
        }
        .form-block.intro-block .block-body { flex: 1 1 auto; display: flex; min-height: 0; margin-top: 0; }
        .form-block.intro-block .textarea-wrap { flex: 1 1 auto; display: flex; flex-direction: column; min-height: 0; }
        .intro-display {
            flex: 1 1 auto; min-height: 0; padding: 14px 16px;
            border: 1px solid #e3eaf6; border-radius: 12px; background: #fff;
            white-space: pre-line; color: #1f2d3d; line-height: 1.65;
            overflow-wrap: anywhere; word-break: break-word;
        }


        #tagBlock{
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        #tagBlock .tag-scroll-area{
            flex: 1 1 auto;
            min-height: calc(
                    (var(--chip-h) * var(--tag-min-rows)) + var(--chip-row-gap)
            );
        }

        .tag-chip-wrap {
            display: flex;
            flex-wrap: wrap;
            align-content: flex-start;
            row-gap: 10px; column-gap: 10px;
            height: 100%;
            overflow-y: auto;
            overflow-x: hidden;
            padding-right: 6px;
            scrollbar-gutter: stable both-edges;
            scroll-behavior: smooth;
        }

        .tag-chip{
            display:inline-flex; align-items:center; gap:8px;
            padding:8px 14px; border-radius:999px;
            background:linear-gradient(180deg,#f0f6ff 0%,#e3efff 100%);
            color:var(--primary-dark); font-size:1rem; border:1px solid #c7dcff; white-space:nowrap;
            transition:transform .08s ease, box-shadow .2s ease;
        }
        .tag-chip i{ font-size:.95rem }
        .tag-chip:hover{ transform:translateY(-1px); box-shadow:0 6px 14px rgba(28,64,125,.1) }
        .tag-chip-wrap.dense .tag-chip{ padding:6px 10px; font-size:.95rem }

        .tag-chip-wrap::-webkit-scrollbar { width: 10px }
        .tag-chip-wrap::-webkit-scrollbar-track { background: #eef4ff; border-radius: 8px }
        .tag-chip-wrap::-webkit-scrollbar-thumb { background: #c7dcff; border-radius: 8px; border: 2px solid #eef4ff }
        .tag-chip-wrap { scrollbar-width: thin; scrollbar-color: #c7dcff #eef4ff }

        .fab-edit {
            position: fixed;
            right: clamp(16px, 3vw, 28px);
            bottom: calc(18px + env(safe-area-inset-bottom));
            z-index: 999;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            border: none;
            border-radius: 999px;
            background: var(--primary);
            color: #fff;
            font-weight: 800;
            font-size: 1rem;
            box-shadow: 0 10px 24px rgba(51,153,255,.35);
            cursor: default;
            transition: transform .12s ease, box-shadow .2s ease, opacity .2s ease;
        }
        .fab-edit i { font-size: 1.05rem }
        .fab-edit:hover { transform: translateY(-1px); box-shadow: 0 14px 30px rgba(51,153,255,.45) }
        .fab-edit:focus-visible { outline: 3px solid rgba(51,153,255,.35); outline-offset: 2px }

        @media (max-width: 480px){
            .fab-edit{ padding: 10px 14px; font-size: .95rem; gap: 8px; }
        }


        @media (max-width: 1100px) {
            #profileView { grid-template-columns: 1fr }
            .roommate-left, .roommate-right { height: auto; min-height: unset }
            .roommate-left { --upload-size: 240px; }
            .form-block.intro-block { padding-top: 56px; }
            .form-block.intro-block > .block-title { top: 12px; left: 16px; }
            #tagBlock{ height: auto !important; }
        }

        @media (prefers-reduced-motion: reduce) { .avatar-circle { transition: none } }
    </style>
</head>
<body>

<main class="roommate-container">
    <section id="profileView">
        <!-- Left -->
        <div class="roommate-left">

            <div class="form-block">
                <div class="block-title">
                    <span class="title-badge"><i class="fa-regular fa-image"></i></span>
                    <span>프로필 사진</span>
                </div>
                <div class="avatar-circle-wrap">
                    <div class="avatar-circle" id="profileAvatar">
                        <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") != null ? session.getAttribute("SS_USER_PROFILE_IMG_URL") : "/images/noimg.png" %>" alt="프로필 사진"/>
                    </div>
                </div>
                <div class="block-help">ㅤ</div>
            </div>

            <div class="form-block" id="basicInfoBlock"><!-- [ADD] id -->
                <div class="block-title">
                    <span class="title-badge"><i class="fa-regular fa-id-card"></i></span>
                    <span>기본 정보</span>
                </div>
                <div class="readonly-field">
                    <span class="label">이름</span>
                    <span class="value"><%= session.getAttribute("SS_USER_NAME") != null ? session.getAttribute("SS_USER_NAME") : "" %></span>
                </div>
            </div>

        </div>

        <!-- Right -->
        <div class="roommate-right">
            <div class="form-block" id="tagBlock">
                <div class="block-title">
                    <span class="title-badge"><i class="fa-solid fa-hashtag"></i></span>
                    <span>성향 태그</span>
                </div>


                <div class="tag-scroll-area">
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
                            <div class="tag-chip-wrap" id="tagWrap" tabindex="0" aria-label="텅 빈 태그 영역">
                                <span style="color:#6e7b8b; background:#f7faff; border:1px dashed #dbe9ff; border-radius:10px; padding:10px 14px; display:inline-block">
                                    <i class="fa-regular fa-circle"></i> 등록된 태그가 없습니다.
                                </span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="block-help">마이페이지에서 태그를 관리할 수 있어요.</div>
            </div>

            <div class="form-block intro-block">
                <div class="block-title">
                    <span class="title-badge"><i class="fa-regular fa-rectangle-list"></i></span>
                    <span>자기소개</span>
                </div>
                <div class="block-body">
                    <div class="textarea-wrap">
                        <div class="intro-display" id="introDisplay">
                            <c:choose>
                                <c:when test="${not empty introText}">
                                    <c:out value="${introText}"/>
                                </c:when>
                                <c:otherwise>등록된 소개글이 없습니다.</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<!-- 오른쪽 아래 떠 있는 '수정하기' 버튼 (기능 없음) -->
<button class="fab-edit" type="button" aria-label="수정하기 (아직 기능 없음)">
    <i class="fa-regular fa-pen-to-square" aria-hidden="true"></i>
    <span>수정하기</span>
</button>

<script>
    /* 태그 칩 밀도 표시 */
    (function () {
        const wrap = document.getElementById('tagWrap');
        console.log('[tag] dense-check, found=', !!wrap);
        if (wrap) {
            const chips = wrap.querySelectorAll('.tag-chip');
            if (chips.length > 12) wrap.classList.add('dense');
        }
    })();


    function calcAvatarSize() {
        const leftCard = document.querySelector('.roommate-left');
        const avatar = document.getElementById('profileAvatar');
        const introBody = document.querySelector('.roommate-right .intro-block .block-body');
        if (!leftCard || !avatar || !introBody) return;

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


    function syncTagBoxHeight() {
        const basic = document.getElementById('basicInfoBlock');
        const tagBlock = document.getElementById('tagBlock');
        if (!basic || !tagBlock) return;

        const isNarrow = window.matchMedia('(max-width:1100px)').matches;
        if (isNarrow) {
            tagBlock.style.height = '';
            console.log('[tag] mobile → unlock height');
            return;
        }

        const basicH = Math.round(basic.getBoundingClientRect().height);
        const bump   = 80; // [ADD] 살짝 키우기: 두 줄 보이게 여유
        tagBlock.style.boxSizing = 'border-box';
        tagBlock.style.height = (basicH + bump) + 'px';
        console.log('[tag] lock tagBlock height =', basicH, '+', bump);
    }

    window.addEventListener('load', () => {
        calcAvatarSize();
        requestAnimationFrame(syncTagBoxHeight);
    });
    window.addEventListener('resize', () => {
        calcAvatarSize();
        syncTagBoxHeight();
    });
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
