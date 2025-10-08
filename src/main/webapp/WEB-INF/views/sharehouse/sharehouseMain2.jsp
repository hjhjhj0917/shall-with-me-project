<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 쉐어하우스 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <link rel="stylesheet" href="/css/sharehouse/sharehouseMain.css"/>

    <style>
        /* (검색창 및 다른 부분 스타일은 이전과 동일) */
        .sh-searchbar {
            display: flex;
            align-items: center;
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 50px;
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.08);
            position: relative;
            height: 66px;
            padding: 7px 10px;
            width: 100%;
            max-width: 850px;
            margin-left: auto;
            margin-right: auto;
        }

        .search-section {
            flex: 1;
            padding: 8px 24px;
            cursor: pointer;
            border-radius: 30px;
            transition: background-color 0.2s;
            min-width: 0;
        }

        .search-section:hover {
            background-color: #f7f7f7;
        }

        .search-section + .search-section {
            border-left: 1px solid #eee;
        }

        .search-section-label {
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .search-section-placeholder {
            font-size: 14px;
            color: #717171;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        #sh-search-btn {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: linear-gradient(to right, #66B2FF, #3399ff);
            color: white;
            border: none;
            font-size: 16px;
            margin-left: 10px;
            flex-shrink: 0;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.1s;
        }

        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9998;
        }

        #locationSelectModalOverlay .modal-sheet,
        #tagSelectModalOverlay .modal-sheet {
            width: 100%;
            max-width: 450px;
            background: white;
            border-radius: 12px;
            animation: fadeIn 0.3s;
            overflow: hidden;
        }

        #locationSelectModalOverlay .modal-sheet {
            max-width: 500px;
        }

        #locationSelectModalOverlay .modal-header,
        #tagSelectModalOverlay .modal-header {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px;
            border-bottom: 1px solid #eee;
            position: relative;
        }

        #locationSelectModalOverlay .modal-title-text,
        #tagSelectModalOverlay .modal-title-text {
            font-weight: 700;
            color: #222;
        }

        #locationSelectModalOverlay .modal-close,
        #tagSelectModalOverlay .modal-close {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1rem;
            color: #222;
            background: #f7f7f7;
            border: none;
            cursor: pointer;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #locationSelectModalOverlay .modal-body,
        #tagSelectModalOverlay .modal-body {
            max-height: 450px;
            overflow-y: auto;
            padding: 20px;
        }

        .location-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
        }

        .location-item {
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: border-color 0.2s, background-color 0.2s, font-weight 0.2s;
            font-size: 14px;
        }

        .location-item:hover {
            border-color: #222;
        }

        .location-item.selected {
            background-color: #f7f7f7;
            border-color: #222;
            font-weight: 600;
        }

        /* ✅ [수정] 태그 모달 그룹 UI 전체 변경 */
        .search-tag-group {
            display: flex;
            align-items: center;
            padding: 16px 0;
        }

        .search-tag-group + .search-tag-group {
            border-top: 1px solid #f0f0f0;
        }

        .search-tag-group__icon-wrapper {
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

        .search-tag-group__icon-wrapper i {
            font-size: 30px;
            color: #495057;
        }

        .search-tag-group__content-wrapper {
            flex-grow: 1;
            padding-left: 24px;
        }

        .search-tag-group__title {
            font-weight: 600;
            font-size: 1rem;
            color: #343a40;
            margin-bottom: 12px;
        }

        .search-tag-group__list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .tag-btn {
            background-color: #fff;
            border: 1px solid #dee2e6;
            border-radius: 20px;
            padding: 8px 16px;
            font-size: 0.9rem;
            color: #495057;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .tag-btn.selected {
            background-color: #3399ff;
            border-color: #3399ff;
            color: white;
            font-weight: 600;
        }

        .tag-btn:hover:not(.selected) {
            border-color: #495057;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.95);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
    </style>
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
<%@ include file="../includes/footer.jsp" %>
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
        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;
            window.open(ctx + '/sharehouse/sharehouseDetail?userId=' + encodeURIComponent(id), '_blank');
        });
    })();
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<script>
    $(document).ready(function () {
        // --- 전역 변수: page 대신 offset 사용 ---
        let offset = 0, loading = false, lastPage = false;
        let selectedLocation = "";
        const selectedTags = new Map();
        const $grid = $(".sh-grid");
        const $scrollArea = $(".sh-scroll-area");

        const tagGroups = [
            {key: "lifePattern", title: "생활패턴", icon: "fa-solid fa-sun", tags: [1, 2]},
            {key: "activity", title: "활동범위", icon: "fa-solid fa-map-location-dot", tags: [3, 4]},
            {key: "job", title: "직업", icon: "fa-solid fa-briefcase", tags: [5, 6, 7]},
            {key: "workTime", title: "퇴근 시간", icon: "fa-solid fa-business-time", tags: [8, 9, 10]},
            {key: "guest", title: "손님초대", icon: "fa-solid fa-door-open", tags: [11, 12]},
            {key: "share", title: "물건공유", icon: "fa-solid fa-handshake", tags: [13, 14]},
            {key: "personality", title: "성격", icon: "fa-solid fa-face-smile", tags: [15, 16]},
            {key: "prefer", title: "선호하는 성격", icon: "fa-solid fa-heart", tags: [17, 18]},
            {key: "conversation", title: "대화", icon: "fa-solid fa-comments", tags: [19, 20]},
            {key: "conflict", title: "갈등", icon: "fa-solid fa-people-arrows", tags: [21, 22]},
            {key: "cook", title: "요리", icon: "fa-solid fa-utensils", tags: [23, 24, 25]},
            {key: "food", title: "주식", icon: "fa-solid fa-bowl-food", tags: [26, 27, 28]},
            {key: "meal", title: "라니", icon: "fa-solid fa-calendar-day", tags: [29, 30, 31]},
            {key: "smell", title: "음식 냄새", icon: "fa-solid fa-wind", tags: [32, 33]},
            {key: "clean", title: "청결", icon: "fa-solid fa-broom", tags: [34, 35, 36]},
            {key: "cleanCircle", title: "청소 주기", icon: "fa-solid fa-broom", tags: [37, 38, 39]},
            {key: "garbage", title: "쓰레기 배출", icon: "fa-solid fa-trash-can", tags: [40, 41]},
            {key: "dishWash", title: "설거지", icon: "fa-solid fa-sink", tags: [42, 43]}
        ];

        // --- 초기화 및 이벤트 핸들러 ---
        loadInitialData(); // 1. 페이지 첫 로드 시 15개 요청

        $scrollArea.on("scroll", function () {
            if (loading || lastPage) return;
            let scrollTop = $scrollArea.scrollTop();
            let innerHeight = $scrollArea.innerHeight();
            let scrollHeight = $scrollArea[0].scrollHeight;
            if (scrollTop + innerHeight + 100 >= scrollHeight) {
                loadMoreData(); // 2. 스크롤 시 5개 요청
            }
        });

        $('#location-search-trigger').on('click', openLocationModal);
        $('#tag-search-trigger').on('click', openTagModal);

        $('#sh-search-btn').on('click', function () {
            offset = 0; // 오프셋 초기화
            lastPage = false;
            $grid.empty();
            loadInitialData(); // 3. 검색 버튼 클릭 시에도 새로 15개 요청
        });

        // --- API 호출 함수 ---

        function loadInitialData() {
            loadData(0, 15); // offset: 0, pageSize: 15
        }

        function loadMoreData() {
            loadData(offset, 5); // 현재 offset에서 5개 추가
        }

        function loadData(currentOffset, size) {
            loading = true;

            const tagIds = Array.from(selectedTags.keys());

            console.log("=== API 호출 정보 ===");
            console.log("URL:", ctx + "/sharehouse/list");
            console.log("offset:", currentOffset);
            console.log("pageSize:", size);
            console.log("location:", selectedLocation || null);
            console.log("tagIds:", tagIds);

            $.ajax({
                url: ctx + "/sharehouse/list",  // ← 이 부분이 정확한지 확인!
                type: "GET",
                data: {
                    offset: currentOffset,
                    pageSize: size,
                    location: selectedLocation || null,
                    tagIds: tagIds
                },
                dataType: "json",
                success: function (data) {
                    console.log("=== API 응답 ===");
                    console.log("전체 응답:", data);

                    // const items = data.items || data.list || data || []; 수정1 삭제

                    //수정1 추가
                    // 원본 응답을 src로 받음
                    const src = data.items || data.list || data || [];
// 서버에서 내려온 모든 필드를 보존하면서(특히 tags) items를 만듦
                    const items = src.map(x => Object.assign({}, x, { tags: x.tags || [] }));


                    // 쉐어하우스 전용: 배열 tags[] -> tag1/tag2/tag3로 맞춤 (룸메이트 템플릿 재사용)
                    items.forEach(card => {
                        const arr = (card.tags || []).map(t => t.tagName);
                        card.tag1 = arr[0] || null;
                        card.tag2 = arr[1] || null;
                        card.tag3 = arr[2] || null;
                    });

                    if (items.length > 0) {
                        console.log("첫 번째 아이템:", items[0]);
                        console.log("tag1:", items[0].tag1);
                        console.log("tag2:", items[0].tag2);
                        console.log("tag3:", items[0].tag3);

                        renderHouseCards(items);
                        offset += items.length;
                    }
                    if (items.length < size || data.lastPage) {
                        lastPage = true;
                    }
                },
                error: (err) => {
                    console.error('데이터 로드 실패', err);
                    console.log("에러 상세:", err.responseText);
                },
                complete: () => loading = false
            });
        }

        // --- 지역 모달 ---
        function openLocationModal() {
            renderLocations();
            $('#locationSelectModalOverlay').css('display', 'flex');
        }

        window.closeLocationModal = function () {
            $('#locationSelectModalOverlay').hide();
        }

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

        // --- 태그 모달 ---
        function openTagModal() {
            loadAllTags();
            $('#tagSelectModalOverlay').css('display', 'flex');
        }

        window.closeTagModal = function () {
            $('#tagSelectModalOverlay').hide();
        };

        function loadAllTags() {
            $.ajax({
                url: ctx + '/sharehouse/tagAll', type: 'GET', dataType: 'json',
                success: (tags) => renderAllTags(tags),
                error: (err) => console.error('태그 불러오기 실패', err)
            });
        }

        function renderAllTags(tagsFromServer) {
            const $container = $('#all-tag-list').empty();
            const tagMap = new Map(tagsFromServer.map(t => [t.tagId, t]));

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

                        if (selectedTags.has(tag.tagId)) {
                            $btn.addClass('selected');
                        }

                        $btn.on('click', function () {
                            toggleTagSelection(tag.tagId, tag.tagName, $(this));
                        });
                        $groupList.append($btn);
                    }
                });

                $contentWrapper.append($groupTitle, $groupList);
                $groupDiv.append($iconWrapper, $contentWrapper);
                $container.append($groupDiv);
            });
        }

        function toggleTagSelection(tagId, tagName, $btn) {
            if (selectedTags.has(tagId)) {
                selectedTags.delete(tagId);
            } else {
                selectedTags.set(tagId, tagName);
            }

            $btn.toggleClass('selected');
            updateSearchBarText();
        }

        function updateSearchBarText() {
            let totalCount = selectedTags.size;
            let firstTagName = "";
            if (totalCount > 0) {
                firstTagName = selectedTags.values().next().value;
            }

            const $tagText = $('#tag-selection-text');
            if (totalCount > 0) {
                const displayText = totalCount > 1 ? firstTagName + " 외 " + (totalCount - 1) + "개" : firstTagName;
                $tagText.text(displayText).css('color', '#222');
            } else {
                $tagText.text('원하는 조건 추가').css('color', '');
            }
        }

        // --- 카드 렌더링 ---
        function renderHouseCards(items) {
            const loginUserId = "${sessionScope.SS_USER_ID}";
            $.each(items, function (i, house) {
                const houseId = house.userId || house.houseId;
                if (houseId === loginUserId) return true;

                const imgUrl = house.profileImgUrl || (ctx + "/images/noimg.png");
                const houseName = house.name || "알 수 없음";

                const $card = $("<article>").addClass("sh-card").attr("data-id", houseId);
                const $thumb = $("<div>").addClass("sh-thumb").css("background-image", "url('" + imgUrl + "')");
                const $info = $("<div>").addClass("sh-info");

                // 룸메이트와 동일한 형식: "이름 : 집이름"
                const $sub = $("<p>").addClass("sh-sub").text("이름 : " + houseName);
                $info.append($sub);

                // 태그 박스
                const $tagBox = $("<div>").addClass("tag-box");
                if (house.tag1) $tagBox.append($("<span>").addClass("tag").text(house.tag1));
                if (house.tag2) $tagBox.append($("<span>").addClass("tag").text(house.tag2));
                if (house.tag3) $tagBox.append($("<span>").addClass("tag").text(house.tag3));

                $info.append($tagBox);
                $card.append($thumb, $info);
                $grid.append($card);
            });
        }

        window.loadSharehouseFirstPage = function () {
            offset = 0;
            lastPage = false;
            $grid.empty();
            loadInitialData();
        };
    });
</script>

<script>
    let __pageScrollY = 0;

    function openSharehouseRegModal(url) {
        const ov = document.getElementById('sharehouseRegOverlay');
        const frame = document.getElementById('sharehouseRegFrame');
        if (!ov || !frame) return;

        const bust = Date.now();
        frame.src = url + (url.includes('?') ? '&' : '?') + 'v=' + bust;

        ov.style.display = 'flex';
        document.documentElement.classList.add('modal-open');

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
        document.documentElement.classList.remove('modal-open');

        document.body.classList.remove('modal-open');
        document.body.style.position = '';
        document.body.style.top = '';
        document.body.style.left = '';
        document.body.style.right = '';
        document.body.style.width = '';

        window.scrollTo(0, __pageScrollY);
        document.getElementById('sharehouseAddBtn')?.focus();
    }

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeSharehouseRegModal();
    });

    document.addEventListener('DOMContentLoaded', () => {
        const btn = document.getElementById('sharehouseRegClose');
        if (btn) btn.addEventListener('click', closeSharehouseRegModal);

        const openBtn = document.getElementById('sharehouseAddBtn');
        if (openBtn) {
            openBtn.addEventListener('click', () => {
                openSharehouseRegModal(ctx + '/sharehouse/sharehouseReg?inModal=Y');
            });
        }
    });
</script>

<script>
    // 저장 완료(postMessage) 받으면 목록 초기화 후 재조회
    window.addEventListener('message', (e) => {
        if (e?.data?.type === 'SH_SAVED') {
            if (typeof closeSharehouseRegModal === 'function') closeSharehouseRegModal();

            /* ✅ 변경: 한 줄로 리로드 */
            if (typeof window.loadSharehouseFirstPage === 'function') {
                window.loadSharehouseFirstPage();
            } else {
                location.reload();
            }
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