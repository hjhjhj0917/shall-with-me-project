<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 룸메이트 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="/css/roommate/roommateMain.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        .sh-searchbar {
            display: flex;
            align-items: center;
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 50px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            position: relative;
        }

        #tagSelectModalOverlay {
            position: absolute;
            top: 100%;
            left: 30%;
            transform: translateX(-50%);
            z-index: 9999;
            width: 100%;
            max-width: 370px;
            background: white;
            border-radius: 25px;
            margin-top: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        /* ✅ [수정] 모달 시트를 Flexbox 컨테이너로 변경 */
        #tagSelectModalOverlay .modal-sheet {
            border: none;
            box-shadow: none;
            height: auto;
            max-height: 450px;
            display: flex; /* Flex 컨테이너로 설정 */
            flex-direction: column; /* 자식 요소들을 세로로 쌓음 */
            overflow: hidden; /* 시트 자체의 스크롤은 숨김 */
            border-radius: 25px; /* 부모 radius 상속 */
        }

        #tagSelectModalOverlay .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 14px;
            /*border-bottom: 1px solid #eee;*/
            position: sticky;
            top: 0;
            background-color: white;
        }

        #tagSelectModalOverlay .modal-title-text {
            font-weight: 600;
            color: #1c407d;
            font-size: 1rem;
        }

        #tagSelectModalOverlay .modal-close {
            font-size: 1.1rem;
            color: #666;
            background: transparent;
            border: none;
            cursor: pointer;
            transition: color 0.2s;
            margin-top: 17px;
            margin-right: 8px;
        }

        #tagSelectModalOverlay .modal-close:hover {
            color: #1c407d;
        }

        #tagSelectModalOverlay .modal-body {
            padding: 8px 20px 20px 20px; /* 패딩 위치 이동 */
            overflow-y: auto; /* Y축 스크롤을 본문에서 담당 */
            flex: 1; /* 남은 공간을 모두 차지하도록 설정 */
        }

        /* ✅ [수정] 외부 스타일 덮어쓰기를 위해 ID 선택자로 우선순위 높이고 !important 추가 */
        #tagSelectModalOverlay .search-tag-group {
            width: 100% !important;
            margin-bottom: 10px !important;
        }
        #tagSelectModalOverlay .search-tag-group__title {
            font-weight: 600 !important;
            color: #333 !important;
            margin-bottom: 12px !important;
            padding-bottom: 6px !important;
            border-bottom: 1px solid #f0f0f0 !important;
            font-size: 0.95rem !important;
            text-align: left !important;
        }
        #tagSelectModalOverlay .search-tag-group__list {
            display: flex !important;
            flex-wrap: wrap !important;
            gap: 8px !important;
            justify-content: flex-start !important;
            margin-top: 40px !important;
            margin-left: 20px !important;
        }

        #tagSelectModalOverlay .tag-btn {
            display: inline-block !important;
            width: auto !important;
            height: auto !important;
            position: static !important;
            text-align: center !important;
            vertical-align: middle !important;
            background-color: #f0f4ff !important;
            border: 1px solid #c2d1ff !important;
            border-radius: 16px !important;
            padding: 6px 14px !important;
            font-size: 0.9rem !important;
            color: #1c407d !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
            user-select: none !important;
        }

        #tagSelectModalOverlay .tag-btn.selected {
            background-color: #1c407d !important;
            border-color: #15426b !important;
            color: white !important;
            font-weight: 500 !important;
        }

        .tag-btn:hover:not(.selected) {
            background-color: #e0e9ff !important;
            border-color: #afc4ff !important;
        }

        .tag-input-wrapper {
            flex-grow: 1;
            position: relative;
            cursor: pointer;
        }

        #selected-tags {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            padding: 0 10px;
            box-sizing: border-box;
            display: flex;
            align-items: center;
            gap: 6px;
            pointer-events: none;
        }

        #tag-search-input.has-tags {
            text-indent: -9999px;
        }

        #tag-search-input {
            width: 100%;
            border: none;
            outline: none;
            padding: 13px 10px;
            font-size: 16px;
            background-color: transparent;
            box-sizing: border-box;
            pointer-events: none;
        }

        #sh-search-btn {
            flex-shrink: 0;
            margin-left: 8px;
        }

        #selected-tags .tag-badge {
            pointer-events: auto;
        }

        #tag-search-input.has-tags::placeholder {
            color: transparent;
        }

        .tag-badge {
            display: inline-flex;
            align-items: center;
            background-color: #e5f2ff;
            color: #1c407d;
            font-weight: 500;
            border-radius: 16px;
            padding: 5px 12px;
            font-size: 14px;
            white-space: nowrap;
            cursor: default;
        }

        .badge-remove {
            margin-left: 8px;
            cursor: pointer;
            font-size: 12px;
            color: #5a7aab;
        }
        .badge-remove:hover {
            color: #1c407d;
        }

        /* --- 모달 스크롤바 스타일 --- */
        /* Firefox */
        #tagSelectModalOverlay .modal-body {
            scrollbar-width: thin;
            scrollbar-color: #c4c4c4 white;
        }

        /* Webkit (Chrome, Safari, Edge) */
        #tagSelectModalOverlay .modal-body::-webkit-scrollbar {
            width: 10px; /* ✅ 핸들과 여백을 고려해 너비 약간 조정 */
        }
        #tagSelectModalOverlay .modal-body::-webkit-scrollbar-track {
            background: transparent;
        }
        #tagSelectModalOverlay .modal-body::-webkit-scrollbar-thumb {
            background: #c4c4c4;
            border-radius: 10px;
            border: 4px solid transparent; /* ✅ [수정] 투명 여백을 4px로 늘려 핸들이 더 짧아보이게 함 */
            background-clip: content-box;
        }
        #tagSelectModalOverlay .modal-body::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }

    </style>

    <script>
        const ctx = '${pageContext.request.contextPath}';
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main id="sh-wrapper">
    <div class="sh-searchbar">
        <div class="tag-input-wrapper">
            <input type="text" placeholder="ㅤ원하는 조건으로 검색하세요" id="tag-search-input" readonly/>
            <div id="selected-tags" class="selected-tags"></div>
        </div>
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>

        <div id="tagSelectModalOverlay" style="display: none;">
            <div class="modal-sheet">
                <div class="modal-header">
<%--                    <div class="modal-title-text">태그 선택</div>--%>
                    <button type="button" class="modal-close" onclick="closeTagModal()">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <div id="all-tag-list">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="sh-scroll-area">
        <section class="sh-grid">
        </section>
    </div>

</main>

<%-- 챗봇 --%>
<%@ include file="../includes/chatbot.jsp" %>
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

<script>
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;
            window.open(ctx + '/roommate/roommateDetail?userId=' + encodeURIComponent(id), '_blank');
        });
    })();
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<script>
    $(document).ready(function () {
        let page = 1;
        let loading = false;
        let lastPage = false;
        let isSearching = false;
        let currentTagFilter = [];
        const pageSize = 10;
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
                if (isSearching) {
                    loadFilteredPage(page);
                } else {
                    loadPage(page);
                }
            }
        });

        function loadPage(p) {
            loading = true;
            $.ajax({
                url: ctx + "/roommate/list",
                type: "GET",
                data: {page: p},
                dataType: "json",
                success: function (data) {
                    if (!data || !data.items || data.items.length === 0) {
                        lastPage = true;
                        return;
                    }
                    renderUserCards(data.items);
                    if (data.lastPage) {
                        lastPage = true;
                    }
                },
                error: function (xhr, status, err) {
                    console.error("회원 정보 불러오기 실패:", err);
                },
                complete: function () {
                    loading = false;
                }
            });
        }

        function loadFilteredPage(p) {
            loading = true;
            const reqData = {
                tagIds: currentTagFilter,
                page: p,
                pageSize: pageSize
            };
            $.ajax({
                url: '/roommate/searchByTags',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(reqData),
                dataType: 'json',
                success: function (data) {
                    if (!data || !data.users || data.users.length === 0) {
                        lastPage = true;
                        return;
                    }
                    renderUserCards(data.users);
                },
                error: function (err) {
                    console.error('검색 실패', err);
                },
                complete: function () {
                    loading = false;
                }
            });
        }

        $('#sh-search-btn').on('click', function () {
            const selected = getSelectedTagIds();
            isSearching = true;
            currentTagFilter = selected;
            page = 1;
            lastPage = false;
            $('.sh-grid').empty();
            loadFilteredPage(page);
        });

        $('.tag-input-wrapper').on('click', function (e) {
            e.stopPropagation();
            openTagModal();
        });

        function openTagModal() {
            const $modal = $('#tagSelectModalOverlay');
            if ($modal.is(':visible')) return;

            const $searchbar = $('.sh-searchbar');
            const width = $searchbar.outerWidth();

            $modal.css({
                width: width + 'px',
                display: 'block'
            });

            loadAllTags();

            setTimeout(function() {
                $(document).on('click.tagModal', function (e) {
                    if (!$modal.is(e.target) && $modal.has(e.target).length === 0 && !$(e.target).closest('.sh-searchbar').length) {
                        closeTagModal();
                    }
                });
            }, 0);
        }

        window.closeTagModal = function () {
            $('#tagSelectModalOverlay').hide();
            $(document).off('click.tagModal');
        };

        function loadAllTags() {
            $.ajax({
                url: '/roommate/tagAll',
                type: 'GET',
                dataType: 'json',
                success: function (tags) {
                    renderAllTags(tags);
                },
                error: function (err) {
                    console.error('태그 불러오기 실패', err);
                }
            });
        }

        function renderAllTags(tagsFromServer) {
            const $container = $('#all-tag-list');
            $container.empty();
            const tagMap = new Map(tagsFromServer.map(t => [t.tagId, t]));

            // ✅ 위에서 수정한 tagGroups 배열을 여기에 붙여넣거나, 이 함수 바깥에 두시면 됩니다.
            const tagGroups = [
                { title: "생활패턴", icon: "fa-solid fa-sun", tags: [1, 2] }, { title: "활동범위", icon: "fa-solid fa-map-location-dot", tags: [3, 4] },
                { title: "직업", icon: "fa-solid fa-briefcase", tags: [5, 6, 7] }, { title: "퇴근 시간", icon: "fa-solid fa-business-time", tags: [8, 9, 10] },
                { title: "손님초대", icon: "fa-solid fa-door-open", tags: [11, 12] }, { title: "물건공유", icon: "fa-solid fa-handshake", tags: [13, 14] },
                { title: "성격", icon: "fa-solid fa-face-smile", tags: [15, 16] }, { title: "선호하는 성격", icon: "fa-solid fa-heart", tags: [17, 18] },
                { title: "대화", icon: "fa-solid fa-comments", tags: [19, 20] }, { title: "갈등", icon: "fa-solid fa-people-arrows", tags: [21, 22] },
                { title: "요리", icon: "fa-solid fa-utensils", tags: [23, 24, 25] }, { title: "주식", icon: "fa-solid fa-bowl-food", tags: [26, 27, 28] },
                { title: "끼니", icon: "fa-solid fa-calendar-day", tags: [29, 30, 31] }, { title: "음식 냄새", icon: "fa-solid fa-wind", tags: [32, 33] },
                { title: "청결", icon: "fa-solid fa-broom", tags: [34, 35, 36] }, { title: "청소 주기", icon: "fa-solid fa-broom", tags: [37, 38, 39] },
                { title: "쓰레기 배출", icon: "fa-solid fa-trash-can", tags: [40, 41] }, { title: "설거지", icon: "fa-solid fa-sink", tags: [42, 43] }
            ];

            tagGroups.forEach(group => {
                const $groupDiv = $('<div>').addClass('search-tag-group');

                // ✅ [수정] 아이콘(<i>) 태그를 생성하고 제목(<span>)과 함께 추가
                const $groupTitle = $('<div>').addClass('search-tag-group__title');
                const $icon = $('<i>').addClass(group.icon).css({'margin-right': '8px', 'width': '16px'});
                const $titleText = $('<span>').text(group.title);
                $groupTitle.append($icon, $titleText);

                const $groupList = $('<div>').addClass('search-tag-group__list');

                group.tags.forEach(tagId => {
                    if (tagMap.has(tagId)) {
                        const tag = tagMap.get(tagId);
                        const $btn = $('<button>')
                            .addClass('tag-btn')
                            .text(tag.tagName)
                            .attr('data-id', tag.tagId);
                        if (isTagSelected(tag.tagId)) {
                            $btn.addClass('selected');
                        }
                        $btn.on('click', function () {
                            toggleTagSelection(tag.tagId, tag.tagName, $(this));
                        });
                        $groupList.append($btn);
                    }
                });

                if ($groupList.children().length > 0) {
                    $groupDiv.append($groupTitle).append($groupList);
                    $container.append($groupDiv);
                }
            });
        }

        const selectedTags = new Map();

        function isTagSelected(tagId) {
            return selectedTags.has(tagId);
        }

        function toggleTagSelection(tagId, tagName, $btn) {
            if (isTagSelected(tagId)) {
                selectedTags.delete(tagId);
                $btn.removeClass('selected');
            } else {
                selectedTags.set(tagId, tagName);
                $btn.addClass('selected');
            }
            renderSelectedTags();
        }

        function renderSelectedTags() {
            const $wrapper = $('#selected-tags');
            const $input = $('#tag-search-input');
            $wrapper.empty();

            selectedTags.forEach((tagName, tagId) => {
                const $span = $('<span>').addClass('tag-badge').text(tagName);
                const $x = $('<i>').addClass('fa-solid fa-xmark badge-remove').attr('data-id', tagId);
                $span.append($x);
                $wrapper.append($span);
            });

            if (selectedTags.size > 0) {
                $input.addClass('has-tags');
            } else {
                $input.removeClass('has-tags');
            }

            $('.badge-remove').off('click').on('click', function (e) {
                e.stopPropagation();
                const tid = $(this).data('id');
                if (selectedTags.has(tid)) {
                    selectedTags.delete(tid);
                    renderSelectedTags();
                    $('#all-tag-list .tag-btn[data-id="' + tid + '"]').removeClass('selected');
                }
            });
        }

        function getSelectedTagIds() {
            return Array.from(selectedTags.keys());
        }

        function renderUserCards(users) {
            const loginUserId = "${sessionScope.SS_USER_ID}";
            $.each(users, function (i, user) {
                if (user.userId === loginUserId) return true;

                var imgUrl = user.profileImageUrl || (ctx + "/images/noimg.png");
                var nickname = user.userName || "알 수 없음";
                var age = user.age ? user.age + "세" : "";
                var $card = $("<article>").addClass("sh-card").attr("data-id", user.userId);
                var $thumb = $("<div>").addClass("sh-thumb").css("background-image", "url('" + imgUrl + "')");
                var $info = $("<div>").addClass("sh-info").append($("<p>").addClass("sh-sub").text("이름 : " + nickname + (age ? " (" + age + ")" : "")));
                var $tagBox = $("<div>").addClass("tag-box");

                if (user.tag1) $tagBox.append($("<span>").addClass("tag").text(user.tag1));
                if (user.tag2) $tagBox.append($("<span>").addClass("tag").text(user.tag2));

                if (user.gender) {
                    var genderText = user.gender === "M" ? "남" : user.gender === "F" ? "여" : user.gender;
                    var genderClass = (genderText === "남") ? "male" : "female";
                    $tagBox.append($("<span>").addClass("tag gender " + genderClass).text(genderText));
                }
                $info.append($tagBox);
                $card.append($thumb).append($info);
                $grid.append($card);
            });
        }
    });
</script>

</body>
</html>