<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 쉐어하우스 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseAddBtn.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseMain.css?v=20251006"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<main id="sh-wrapper">
    <div class="sh-searchbar">
        <div class="search-section" id="location-search-trigger">
            <div class="search-section-label">지역</div>
            <div class="search-section-placeholder" id="location-selection-text">지역 선택</div>
        </div>
        <div class="search-section" id="tag-search-trigger">
            <div class="search-section-label">태그</div>
            <div class="search-section-placeholder" id="tag-selection-text">원하는 조건 추가</div>
        </div>
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>

    <div class="sh-scroll-area">
        <section class="sh-grid"></section>
    </div>
</main>

<!-- 지역 선택 모달 -->
<div class="modal-overlay" id="locationSelectModalOverlay">
    <div class="modal-sheet">
        <div class="modal-header">
            <button type="button" class="modal-close" onclick="closeLocationModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
            <div class="modal-title-text">지역 선택</div>
        </div>
        <div class="modal-body">
            <div class="location-grid" id="location-grid-container"></div>
        </div>
    </div>
</div>

<!-- 태그 선택 모달 -->
<div class="modal-overlay" id="tagSelectModalOverlay">
    <div class="modal-sheet">
        <div class="modal-header">
            <button type="button" class="modal-close" onclick="closeTagModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
            <div class="modal-title-text">태그 선택</div>
        </div>
        <div class="modal-body">
            <div id="all-tag-list"></div>
        </div>
    </div>
</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) ssUserName = "";
%>

<script>
    const ctx = '${pageContext.request.contextPath}';
    const userName = "<%= ssUserName %>";
</script>

<script>
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        // 기존 이벤트 제거 후 다시 등록
        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card) return;

            const id = card.getAttribute('data-id'); // ← 여기! dataset 대신 attr
            console.log("🧩 클릭된 카드 ID:", id);

            if (!id) {
                alert("houseId 누락 - data-id 확인 필요");
                return;
            }

            // 새 창으로 열기
            const url = ctx + '/sharehouse/detail?houseId=' + encodeURIComponent(id);
            console.log("🔗 이동 URL:", url);
            window.open(url, "_blank");
        });
    })();
</script>


<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<script>
    $(document).ready(function () {
        // 룸메이트와 동일 규칙: 첫 15장, 이후 5장
        let page = 1, loading = false, lastPage = false, isSearching = false;
        let selectedLocation = "";
        const selectedTags = new Map();
        const $grid = $(".sh-grid");
        const $scrollArea = $(".sh-scroll-area");

        loadPage(page);

        $scrollArea.on("scroll", function () {
            if (loading || lastPage) return;
            let scrollTop = $scrollArea.scrollTop();
            let innerHeight = $scrollArea.innerHeight();
            let scrollHeight = $scrollArea[0].scrollHeight;
            if (scrollTop + innerHeight + 100 >= scrollHeight) {
                page++;
                const loadFunc = isSearching ? loadFilteredPage : loadPage;
                loadFunc(page);
            }
        });

        $('#location-search-trigger').on('click', openLocationModal);
        $('#tag-search-trigger').on('click', openTagModal);
        $('#sh-search-btn').on('click', function () {
            isSearching = true;
            page = 1;
            lastPage = false;
            $grid.empty();
            loadFilteredPage(page);
        });

        // 공통 응답 처리 (빈 데이터여도 안전)
        function handleApiResponse(data) {
            const items = data.items || data.list || data || [];
            if (!items || items.length === 0) { lastPage = true; return; }
            renderHouseCards(items);
            if (data.lastPage === true) lastPage = true;
        }

        // 기본 목록: 서버에서 15/5 규칙 적용 가능
        function loadPage(p) {
            loading = true;
            $.ajax({
                url: ctx + "/sharehouse/list",
                type: "GET",
                data: { page: p },
                dataType: "json",
                success: handleApiResponse,
                error: (xhr, status, err) => console.error("쉐어하우스 목록 불러오기 실패:", err),
                complete: () => loading = false
            });
        }

        // 필터 검색
        function loadFilteredPage(p) {
            loading = true;
            const reqData = {
                tagIds: Array.from(selectedTags.keys()),
                location: selectedLocation,
                page: p,
                pageSize: 10
            };
            $.ajax({
                url: ctx + "/sharehouse/search",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify(reqData),
                dataType: "json",
                success: handleApiResponse,
                error: (err) => console.error('검색 실패', err),
                complete: () => loading = false
            });
        }

        // 지역 모달
        function openLocationModal() {
            renderLocations();
            $('#locationSelectModalOverlay').css('display', 'flex');
        }
        window.closeLocationModal = function () { $('#locationSelectModalOverlay').hide(); }

        function renderLocations() {
            const locations = ['서울특별시', '부산광역시', '대구광역시', '인천광역시', '광주광역시', '대전광역시', '울산광역시', '세종특별자치시', '경기도', '강원특별자치도', '충청북도', '충청남도', '전북특별자치도', '전라남도', '경상북도', '경상남도', '제주특별자치도'];
            const $container = $('#location-grid-container').empty();
            locations.forEach(loc => {
                const $item = $('<div>').addClass('location-item').text(loc);
                if (loc === selectedLocation) $item.addClass('selected');
                $item.on('click', function () {
                    if (selectedLocation === loc) {
                        selectedLocation = "";
                        $('#location-selection-text').text('지역 선택').css('color', '');
                    } else {
                        selectedLocation = loc;
                        $('#location-selection-text').text(loc).css('color', '#222');
                    }
                    renderLocations();
                    closeLocationModal();
                });
                $container.append($item);
            });
        }

        // 태그 모달
        function openTagModal() {
            loadAllTags();
            $('#tagSelectModalOverlay').css('display', 'flex');
        }
        window.closeTagModal = function () { $('#tagSelectModalOverlay').hide(); };

        function loadAllTags() {
            $.ajax({
                url: ctx + '/sharehouse/tagAll',
                type: 'GET',
                dataType: 'json',
                success: (tags) => renderAllTags(tags),
                error: (err) => console.error('태그 불러오기 실패', err)
            });
        }

        // (룸메이트와 동일한 레이아웃 렌더)
        function renderAllTags(tagsFromServer) {
            const $container = $('#all-tag-list').empty();
            const tagMap = new Map(tagsFromServer.map(t => [t.tagId, t]));
            const tagGroups = [
                {title: "생활패턴", icon: "fa-solid fa-sun", tags: [1, 2]},
                {title: "활동범위", icon: "fa-solid fa-map-location-dot", tags: [3, 4]},
                {title: "직업", icon: "fa-solid fa-briefcase", tags: [5, 6, 7]},
                {title: "퇴근 시간", icon: "fa-solid fa-business-time", tags: [8, 9, 10]},
                {title: "손님초대", icon: "fa-solid fa-door-open", tags: [11, 12]},
                {title: "물건공유", icon: "fa-solid fa-handshake", tags: [13, 14]},
                {title: "성격", icon: "fa-solid fa-face-smile", tags: [15, 16]},
                {title: "선호하는 성격", icon: "fa-solid fa-heart", tags: [17, 18]},
                {title: "대화", icon: "fa-solid fa-comments", tags: [19, 20]},
                {title: "갈등", icon: "fa-solid fa-people-arrows", tags: [21, 22]},
                {title: "요리", icon: "fa-solid fa-utensils", tags: [23, 24, 25]},
                {title: "주식", icon: "fa-solid fa-bowl-food", tags: [26, 27, 28]},
                {title: "끼니", icon: "fa-solid fa-calendar-day", tags: [29, 30, 31]},
                {title: "음식 냄새", icon: "fa-solid fa-wind", tags: [32, 33]},
                {title: "청결", icon: "fa-solid fa-broom", tags: [34, 35, 36]},
                {title: "청소 주기", icon: "fa-solid fa-broom", tags: [37, 38, 39]},
                {title: "쓰레기 배출", icon: "fa-solid fa-trash-can", tags: [40, 41]},
                {title: "설거지", icon: "fa-solid fa-sink", tags: [42, 43]}
            ];
            tagGroups.forEach(group => {
                const $groupDiv = $('<div>').addClass('search-tag-group');
                const $iconWrapper = $('<div>').addClass('search-tag-group__icon-wrapper').append($('<i>').addClass(group.icon));
                const $contentWrapper = $('<div>').addClass('search-tag-group__content-wrapper');
                const $groupTitle = $('<div>').addClass('search-tag-group__title').text(group.title);
                const $groupList = $('<div>').addClass('search-tag-group__list');

                group.tags.forEach(tagId => {
                    if (tagMap.has(tagId)) {
                        const tag = tagMap.get(tagId);
                        const $btn = $('<button>').addClass('tag-btn').text(tag.tagName).attr('data-id', tag.tagId);
                        if (selectedTags.has(tag.tagId)) $btn.addClass('selected');
                        $btn.on('click', () => toggleTagSelection(tag.tagId, tag.tagName));
                        $groupList.append($btn);
                    }
                });

                $contentWrapper.append($groupTitle, $groupList);
                $groupDiv.append($iconWrapper, $contentWrapper);
                $container.append($groupDiv);
            });
        }

        function toggleTagSelection(tagId, tagName) {
            if (selectedTags.has(tagId)) selectedTags.delete(tagId);
            else selectedTags.set(tagId, tagName);
            updateTagDisplay();
        }
        function updateTagDisplay() {
            $('#all-tag-list .tag-btn').each(function () {
                $(this).toggleClass('selected', selectedTags.has($(this).data('id')));
            });
            const tagCount = selectedTags.size;
            const $tagText = $('#tag-selection-text');
            if (tagCount > 0) {
                const firstTagName = selectedTags.values().next().value;
                const displayText = tagCount > 1 ? firstTagName + " 외 " + (tagCount - 1) + "개" : firstTagName;
                $tagText.text(displayText).css('color', '#222');
            } else {
                $tagText.text('원하는 조건 추가').css('color', '');
            }
        }

        // 카드 렌더링 (쉐어하우스용: houseId/title/city/rent/thumbnailUrl/tag1/tag2)
        function renderHouseCards(items) {
            const $grid = $(".sh-grid");
            const noimg = ctx + "/images/noimg.png";
            items.forEach(house => {
                /* 임시: 어떤 키로 오는지 로그로 한번 확인 */
                console.log('sharehouse item keys:', Object.keys(house), house);

                const hid =
                    house.houseId ?? house.HOUSE_ID ??
                    house.id ?? house.ID ??
                    house.house_id ??
                    house.sharehouseId ?? house.SHAREHOUSE_ID ??
                    house.shId ?? house.SH_ID ??
                    house.seq ?? house.SEQ ?? house.idx ?? house.IDX ?? null;

                const $card = $("<article>").addClass("sh-card");
                /* data-id는 비어 있어도 일단 넣어두자(디버깅 편함) */
                $card.attr("data-id", hid ?? "");


                // 3) 썸네일/정보
                const imgUrl = house.thumbnailUrl || noimg;
                const $thumb = $("<div>").addClass("sh-thumb").css("background-image", "url('" + imgUrl + "')");

                const $info  = $("<div>").addClass("sh-info");
                const title  = house.title || "제목 없음";
                const city   = house.city  || "";
                const price  = (house.rent != null) ? (house.rent + "만원") : "";

                const $title = $("<p>").addClass("sh-title").text(title);
                const $sub   = $("<p>").addClass("sh-sub");
                if (city)  $sub.append(document.createTextNode(city));
                if (price) $sub.append($("<span>").addClass("price-pill").text(price));

                const $tagBox = $("<div>").addClass("tag-box");
                if (house.tag1) $tagBox.append($("<span>").addClass("tag").text(house.tag1));
                if (house.tag2) $tagBox.append($("<span>").addClass("tag").text(house.tag2));

// 4) 조립
                $info.append($title, $sub, $tagBox);
                $card.append($thumb, $info);
                $grid.append($card);

            });
        }
    });
</script>

<script>
    let __pageScrollY = 0;  // ← 파일 상단 스코프(함수 밖) 아무데나 한 줄 선언

    function openSharehouseRegModal(url) {
        const ov = document.getElementById('sharehouseRegOverlay');
        const frame = document.getElementById('sharehouseRegFrame');
        if (!ov || !frame) return;

        const bust = Date.now(); // 캐시 방지 토큰
        frame.src = url + (url.includes('?') ? '&' : '?') + 'v=' + bust;

        ov.style.display = 'flex';
        document.documentElement.classList.add('modal-open');   // ← html에도 잠금 클래스

        // ★ 배경 스크롤 완전 잠금 (iOS 대응)
        __pageScrollY = window.scrollY || document.documentElement.scrollTop || 0;
        document.body.classList.add('modal-open');
        document.body.style.position = 'fixed';
        document.body.style.top = `-${__pageScrollY}px`;
        document.body.style.left = '0';
        document.body.style.right = '0';
        document.body.style.width = '100%';

        document.getElementById('sharehouseRegClose')?.focus();
    }

    function closeSharehouseRegModal() {
        const ov = document.getElementById('sharehouseRegOverlay');
        const frame = document.getElementById('sharehouseRegFrame');
        if (!ov || !frame) return;

        ov.style.display = 'none';
        frame.src = 'about:blank';
        document.documentElement.classList.remove('modal-open'); // ← html 쪽 잠금 해제

        // ★ 배경 스크롤 잠금 해제 + 위치 복원
        document.body.classList.remove('modal-open');
        document.body.style.position = '';
        document.body.style.top = '';
        document.body.style.left = '';
        document.body.style.right = '';
        document.body.style.width = '';

        window.scrollTo(0, __pageScrollY);
        document.getElementById('sharehouseAddBtn')?.focus();
    }

    // ✅ 1) 배경 클릭으로는 닫히지 않게 (유지)
    // document 클릭 리스너 "삭제" 또는 사용 안 함
    // (배경 클릭 닫기 코드였던 줄은 그대로 주석 유지)
    // document.addEventListener('click', (e) => {
    //   const ov = document.getElementById('sharehouseRegOverlay');
    //   if (!ov || ov.style.display !== 'flex') return;
    //   // if (e.target === ov) closeSharehouseRegModal();  // ← 배경 클릭 닫기 금지
    // });

    // ✅ 2) ESC로 닫기 — 전역에서 한 번만 등록 (중첩 금지)
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeSharehouseRegModal();  // ← ESC 정상 작동
    });

    // ✅ 3) X 버튼으로 닫기 — DOM 준비된 후에 안전하게 리스너 부착
    document.addEventListener('DOMContentLoaded', () => {
        const btn = document.getElementById('sharehouseRegClose');
        if (btn) {
            btn.addEventListener('click', closeSharehouseRegModal); // ← X 정상 작동
        }

        // (참고) 등록 버튼로 모달 열기 리스너도 여기에서 붙이면 안전
        const openBtn = document.getElementById('sharehouseAddBtn');
        if (openBtn) {
            openBtn.addEventListener('click', () => {
                openSharehouseRegModal(ctx + '/sharehouse/sharehouseReg?inModal=Y');
            });
        }
    });
</script>

<!-- 왼쪽 하단 + 버튼 -->
<button type="button" class="sh-fab-left" id="sharehouseAddBtn" aria-label="쉐어하우스 등록">
    <i class="fa-solid fa-plus icon-plus"></i>
</button>
<div class="sh-tooltip">쉐어하우스 등록</div>

<!-- 쉐어하우스 등록 모달(iframe) -->
<div class="modal-overlay" id="sharehouseRegOverlay" style="display:none; z-index:10000;">
    <div class="modal-sheet">
        <div class="modal-header" style="justify-content:space-between;">
            <div class="modal-title-text">쉐어하우스 등록</div>
<%--            <button type="button" class="modal-close" id="sharehouseRegClose" aria-label="닫기">--%>
<%--                <i class="fa-solid fa-xmark"></i>--%>
<%--            </button> 닫기버튼 임시삭제--%>
        </div>
        <div class="modal-body">
            <iframe id="sharehouseRegFrame" title="쉐어하우스 등록 화면" style="width:100%; height:100%; border:0;"></iframe>
        </div>
    </div>
</div>

</body>
</html>
