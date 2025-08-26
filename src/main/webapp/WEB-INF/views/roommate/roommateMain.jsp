<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>Roommate</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <!-- 룸메이트 전용 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/roommate/roommateMain.css"/>
    <link rel="icon" href="${pageContext.request.contextPath}/images/noimg.png">
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <!-- 큰 모달 스타일 + 배경 상호작용 차단 -->
    <style>
        /* 모달 열릴 때 바디 스크롤 잠금 */
        body.modal-open { overflow: hidden; }

        /* 모달 열릴 때 배경(헤더+메인) 상호작용 완전 차단 */
        body.modal-open header,
        body.modal-open #sh-wrapper {
            pointer-events: none;
            -webkit-user-select: none;
            user-select: none;
            touch-action: none;
        }

        /* 큰 모달 오버레이 */
        #profileModalOverlay{
            position: fixed; inset: 0;
            display: none;                /* open 시 flex */
            align-items: center; justify-content: center;
            background: rgba(0,0,0,0.45);
            z-index: 10000;               /* 알림 모달이 9999라면 이게 위 */
            pointer-events: auto;
        }
        #profileModalOverlay .modal-sheet{
            width: min(1200px, 95vw);
            height: min(90vh, 100svh - 40px);
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
            display: flex; flex-direction: column;
            overflow: hidden;
        }
        #profileModalOverlay .modal-header{
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
            padding: 14px 18px; border-bottom: 1px solid #eee; background: #f7faff;
        }
        #profileModalOverlay .modal-title-text{ font-size: 1.1rem; font-weight: 700; color: #1c407d; }
        #profileModalOverlay .modal-close{
            border: none; background: transparent; cursor: pointer; padding: 6px; font-size: 1.1rem;
        }
        #profileModalOverlay .modal-body{
            flex: 1 1 auto;
            padding: 0;                   /* iframe이 꽉 차도록 */
            overflow: hidden;
        }
        /* 등록 화면을 로드하는 프레임 */
        #profileModalFrame{
            width: 100%;
            height: 100%;
            display: block;
            border: 0;
        }
    </style>

    <script>
        // 전역 컨텍스트 경로
        const ctx = '${pageContext.request.contextPath}';

        // + 버튼 클릭 → 모달 열기
        $(document).ready(function () {
            $("#roommateAdd").on("click", function () {
                openProfileModal(ctx + '/roommate/roommateReg');
            });
        });

        // ===== 모달 제어 함수 (배경 상호작용 차단: inert + aria-hidden) =====
        function openProfileModal(url){
            const ov = document.getElementById('profileModalOverlay');
            const frame = document.getElementById('profileModalFrame');
            if (!ov || !frame) return;

            frame.src = url;                 // 등록 페이지 로드
            ov.style.display = 'flex';       // 모달 표시
            document.body.classList.add('modal-open');

            const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
            bgEls.forEach(el => {
                if (!el) return;
                el.setAttribute('inert', '');        // 포커스/탭 이동 차단(지원 브라우저)
                el.setAttribute('aria-hidden', 'true'); // 스크린리더 숨김
            });

            document.getElementById('profileModalClose')?.focus(); // 포커스 이동
        }

        function closeProfileModal(){
            const ov = document.getElementById('profileModalOverlay');
            const frame = document.getElementById('profileModalFrame');
            if (!ov || !frame) return;

            ov.style.display = 'none';
            document.body.classList.remove('modal-open');

            const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
            bgEls.forEach(el => {
                if (!el) return;
                el.removeAttribute('inert');
                el.removeAttribute('aria-hidden');
            });

            frame.src = 'about:blank'; // 프레임 리셋
            document.getElementById('roommateAdd')?.focus(); // 트리거로 포커스 복귀
        }

        // 배경 클릭 닫기
        document.addEventListener('click', (e)=>{
            const ov = document.getElementById('profileModalOverlay');
            if (!ov || ov.style.display !== 'flex') return;
            if (e.target === ov) closeProfileModal();
        });
        // ESC 닫기
        document.addEventListener('keydown', (e)=>{
            if (e.key === 'Escape') closeProfileModal();
        });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp"%>

<main id="sh-wrapper">
    <!-- 검색바 -->
    <div class="sh-searchbar">
        <input type="text" placeholder="원하는 지역, 조건 검색" id="sh-q">
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>

    <!-- 카드 그리드: 초기 8개 (샘플) -->
    <section class="sh-grid">
        <article class="sh-card" data-id="101">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>
        <article class="sh-card" data-id="108">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>
    </section>

    <!-- 좌하단 등록 플로팅 버튼 -->
    <button class="sh-fab" title="등록" id="roommateAdd">
        <i class="fa-solid fa-plus"></i>
    </button>
</main>

<!-- 큰 모달 (등록 페이지를 iframe으로 로드) -->
<div id="profileModalOverlay" aria-hidden="true">
    <div class="modal-sheet" role="dialog" aria-modal="true" aria-labelledby="profileModalTitle">
        <div class="modal-header">
            <div id="profileModalTitle" class="modal-title-text">프로필 등록</div>
            <button type="button" class="modal-close" id="profileModalClose" aria-label="닫기" onclick="closeProfileModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <iframe id="profileModalFrame" title="룸메이트 등록 화면"></iframe>
        </div>
    </div>
</div>

<!-- 알림 모달 -->
<div id="customAlertOverlay" class="modal-overlay" style="display: none;">
    <div class="modal">
        <div class="modal-title">
            <i class="fa-solid fa-circle-exclamation fa-shake fa-lg" style="color: #3399ff;"></i>
            <h2>살며시</h2>
        </div>
        <p id="customAlertMessage">메시지 내용</p>
        <div class="modal-buttons" style="text-align: right;">
            <button class="deactivate-btn" onclick="closeCustomAlert()">확인</button>
        </div>
    </div>
</div>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) { ssUserName = ""; }
%>

<script>
    // 카드 클릭 → 상세로 이동
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;
            location.href = ctx + '/roommate/detail?id=' + encodeURIComponent(id);
        });
    })();
</script>

<script>
    // 무한스크롤 API → /roommate/list
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        let page = 1, loading = false, last = false;

        const sentinel = document.createElement('div');
        sentinel.id = 'sh-sentinel';
        grid.after(sentinel);

        const loader = document.createElement('div');
        loader.id = 'sh-loader';
        loader.textContent = '불러오는 중...';
        loader.style.display = 'none';
        sentinel.after(loader);

        async function fetchNext() {
            if (loading || last) return;
            loading = true; loader.style.display = 'block';
            try {
                const url = ctx + '/roommate/list?page=' + (page + 1);
                const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
                if (!res.ok) throw new Error('network error');
                const data = await res.json();
                renderCards(data.items || []);
                page++;
                last = !!data.lastPage || (data.items && data.items.length === 0);
                if (last) io.disconnect();
            } catch (err) {
                console.error(err);
            } finally {
                loading = false; loader.style.display = 'none';
            }
        }

        const io = new IntersectionObserver((entries) => {
            if (entries[0].isIntersecting) fetchNext();
        }, { root: null, rootMargin: '300px 0px', threshold: 0.01 });

        io.observe(sentinel);
        setTimeout(fetchNext, 0);

        function renderCards(items) {
            const frag = document.createDocumentFragment();
            items.forEach(function(it){
                const article = document.createElement('article');
                article.className = 'sh-card';
                article.dataset.id = it.id;

                const thumb = document.createElement('div');
                thumb.className = 'sh-thumb';
                thumb.style.backgroundImage = "url('" + (it.imageUrl || '/images/noimg.png') + "')";

                const info = document.createElement('div');
                info.className = 'sh-info';

                const t = document.createElement('p');
                t.className = 'sh-title';
                t.textContent = '위치 : ' + (it.location || '');

                const s = document.createElement('p');
                s.className = 'sh-sub';
                s.textContent = it.moveInText ? ('입주일 : ' + it.moveInText) : '';

                const p = document.createElement('p');
                p.className = 'sh-price';
                p.textContent = it.priceText ? ('비용 : ' + it.priceText) : '';

                info.append(t, s, p);
                article.append(thumb, info);
                frag.append(article);
            });
            grid.append(frag);
        }
    })();
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
