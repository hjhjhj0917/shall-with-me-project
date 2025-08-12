
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseMain.css"/>
    <link rel="icon" href="${pageContext.request.contextPath}/images/noimg.png">
</head>
<body>
<header>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <i class="fa-solid fa-people-roof fa-xs" style="color: #3399ff;"></i>
        </div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span> <!-- 둥근 반스도 역할 -->
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span> <!-- 둥근 반스도 역할 -->
            <span class="user-name-text" id="userNameText">
        <%= session.getAttribute("SS_USER_NAME") %>님
      </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span> <!-- 둥근 반스도 역할 -->
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>
<%--내가 프론트 만들부분--%>
<main id="sh-wrapper">
    <!-- 검색바 -->
    <div class="sh-searchbar">
        <input type="text" placeholder="원하는 지역, 조건 검색" id="sh-q">
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>

    <!-- 카드 그리드: 위 4개 + 아래 4개 = 총 8개 -->
    <section class="sh-grid">
        <!-- 1 -->
        <article class="sh-card" data-id="101">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 2 -->
        <article class="sh-card" data-id="102">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 3 -->
        <article class="sh-card" data-id="103">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 4 -->
        <article class="sh-card" data-id="104">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 5 -->
        <article class="sh-card" data-id="105">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 6 -->
        <article class="sh-card" data-id="106">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 7 -->
        <article class="sh-card" data-id="107">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>

        <!-- 8 -->
        <article class="sh-card" data-id="108">
            <div class="sh-thumb"></div>
            <div class="sh-info">
                <p class="sh-title">위치 : 동래구의 아파트</p>
                <p class="sh-sub">숙박일 : 9월 5일~7일</p>
                <p class="sh-price">비용 : 5,000,000</p>
            </div>
        </article>
    </section>

    <!-- (선택) 좌하단 등록 플로팅 버튼 -->
    <button class="sh-fab" title="등록">
        <i class="fa-solid fa-plus"></i>
    </button>
</main>




<%--모달창부분--%>
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
    if (ssUserName == null) {
        ssUserName = "";
    }
%>





<script>
    const userName = "<%= ssUserName %>";
</script>

<script>
    const ctx = '${pageContext.request.contextPath}';
    // 카드 클릭 → 상세 이동
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;
            location.href = ctx + '/sharehouse/detail?id=' + encodeURIComponent(id);
        });

    })();
</script>

<script>
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
                const url = ctx + '/sharehouse/list?page=' + (page + 1);  // ← 백틱 제거
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

        // 초기 1회 강제 로드 (화면을 꽉 못 채울 때 대비)
        setTimeout(fetchNext, 0);

        function renderCards(items) {
            const frag = document.createDocumentFragment();
            items.forEach(function(it){
                const article = document.createElement('article');
                article.className = 'sh-card';
                article.dataset.id = it.id;

                const thumb = document.createElement('div');
                thumb.className = 'sh-thumb';
                thumb.style.backgroundImage = "url('" + (it.imageUrl || '/images/noimg.png') + "')"; // ← 백틱 제거

                const info = document.createElement('div');
                info.className = 'sh-info';

                const t = document.createElement('p');
                t.className = 'sh-title';
                t.textContent = '위치 : ' + (it.location || ''); // ← 백틱 제거

                const s = document.createElement('p');
                s.className = 'sh-sub';
                s.textContent = it.moveInText ? ('입주일 : ' + it.moveInText) : ''; // ← 백틱 제거

                const p = document.createElement('p');
                p.className = 'sh-price';
                p.textContent = it.priceText ? ('비용 : ' + it.priceText) : ''; // ← 백틱 제거

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
