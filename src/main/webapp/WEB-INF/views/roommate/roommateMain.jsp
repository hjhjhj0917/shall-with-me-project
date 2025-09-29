<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 룸메이트 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <!-- 룸메이트 전용 CSS -->
    <link rel="stylesheet" href="/css/roommate/roommateMain.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <!-- 큰 모달 스타일 + 배경 상호작용 차단 -->
    <style>
        /*이거 제거되면 끝*/
        /* 부모가 relative여야 하므로, .sh-searchbar에 position: relative; 추가 */
        .sh-searchbar {
            display: flex;
            align-items: center;
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 50px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            position: relative;
        }

        /* 태그 선택 모달 floating 스타일 */
        #tagSelectModalOverlay {
            position: absolute;
            top: 100%; /* input 바로 아래 */
            left: 50%; /* 중앙 정렬 시작 */
            transform: translateX(-50%); /* 정확히 가운데 오도록 이동 */
            z-index: 9999;
            width: 100%; /* input 너비 맞춰주려면 JS로 동기화 가능 */
            max-width: 690px; /* 너무 커지지 않게 제한 */
            background: white;
            border-radius: 25px;

        }

        /* 모달 시트 기본 스타일 제거 */
        #tagSelectModalOverlay .modal-sheet {
            border: none;
            box-shadow: none;
            height: auto;
            max-height: none;
            padding: 20px;
        }

        /* 모달 헤더 스타일 */
        #tagSelectModalOverlay .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 8px;
            border-bottom: 1px solid #eee;
            background: none;
        }

        /* 모달 제목 */
        #tagSelectModalOverlay .modal-title-text {
            font-weight: 600;
            color: #1c407d;
            font-size: 1rem;
        }

        /* 닫기 버튼 */
        #tagSelectModalOverlay .modal-close {
            font-size: 1.1rem;
            color: #666;
            background: transparent;
            border: none;
            cursor: pointer;
            transition: color 0.2s;
        }

        #tagSelectModalOverlay .modal-close:hover {
            color: #1c407d;
        }

        /* 모달 본문 */
        #tagSelectModalOverlay .modal-body {
            padding-top: 8px;
        }

        /* 태그 버튼 스타일 */
        .all-tag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .tag-btn {
            background-color: #f0f4ff;
            border: 1px solid #c2d1ff;
            border-radius: 16px;
            padding: 6px 14px;
            font-size: 0.9rem;
            cursor: pointer;
            transition: background-color 0.3s, border-color 0.3s;
            user-select: none;
        }

        .tag-btn.selected {
            background-color: #1c407d;
            border-color: #15426b;
            color: white;
        }

        .tag-btn:hover:not(.selected) {
            background-color: #d0dbff;
            border-color: #9bb3ff;
        }

        /* 2. 🔥핵심: Wrapper를 position의 기준점으로 설정 */
        .tag-input-wrapper {
            flex-grow: 1;
            position: relative;
        }

        #selected-tags {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%; /* 부모 높이에 꽉 채움 */

            padding: 0 10px; /* input의 padding과 맞춤 */
            box-sizing: border-box; /* padding이 크기에 영향을 주지 않도록 설정 */

            display: flex;
            align-items: center; /* 세로 중앙 정렬 */
            gap: 6px;

            pointer-events: none;
        }

        /* 🔥핵심: 태그가 있을 때 placeholder를 숨기기 위해 사용 */
        #tag-search-input.has-tags {
            text-indent: -9999px; /* 텍스트를 화면 밖으로 밀어내서 숨김 */
        }

        #tag-search-input {
            width: 100%;
            border: none;
            outline: none;
            padding: 13px 10px;
            font-size: 16px;
            background-color: transparent;
            box-sizing: border-box;
            caret-color: transparent;
        }

        #sh-search-btn {
            flex-shrink: 0;
            margin-left: 8px;
        }

        /* 4. 🔥핵심: 태그 뱃지는 클릭(삭제)이 되어야 하므로 이벤트 활성화 */
        #selected-tags .tag-badge {
            pointer-events: auto;
        }

        /* 6. 🔥핵심: 태그가 있을 때 placeholder를 투명하게 만드는 클래스 */
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

    </style>

    <script>
        // 전역 컨텍스트 경로
        const ctx = '${pageContext.request.contextPath}';
        //
        // // + 버튼 클릭 → 모달 열기
        // $(document).ready(function () {
        //     $("#roommateAdd").on("click", function () {
        //         openProfileModal(ctx + '/roommate/roommateReg');
        //     });
        // });
        //
        // // ===== 모달 제어 함수 (배경 상호작용 차단: inert + aria-hidden) =====
        // function openProfileModal(url) {
        //     const ov = document.getElementById('profileModalOverlay');
        //     const frame = document.getElementById('profileModalFrame');
        //     if (!ov || !frame) return;
        //
        //     frame.src = url;                 // 등록 페이지 로드
        //     ov.style.display = 'flex';       // 모달 표시
        //     document.body.classList.add('modal-open');
        //
        //     const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
        //     bgEls.forEach(el => {
        //         if (!el) return;
        //         el.setAttribute('inert', '');        // 포커스/탭 이동 차단(지원 브라우저)
        //         el.setAttribute('aria-hidden', 'true'); // 스크린리더 숨김
        //     });
        //
        //     document.getElementById('profileModalClose')?.focus(); // 포커스 이동
        // }
        //
        // function closeProfileModal() {
        //     const ov = document.getElementById('profileModalOverlay');
        //     const frame = document.getElementById('profileModalFrame');
        //     if (!ov || !frame) return;
        //
        //     ov.style.display = 'none';
        //     document.body.classList.remove('modal-open');
        //
        //     const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
        //     bgEls.forEach(el => {
        //         if (!el) return;
        //         el.removeAttribute('inert');
        //         el.removeAttribute('aria-hidden');
        //     });
        //
        //     frame.src = 'about:blank'; // 프레임 리셋
        //     document.getElementById('roommateAdd')?.focus(); // 트리거로 포커스 복귀
        // }
        //
        // // 배경 클릭 닫기
        // document.addEventListener('click', (e) => {
        //     const ov = document.getElementById('profileModalOverlay');
        //     if (!ov || ov.style.display !== 'flex') return;
        //     if (e.target === ov) closeProfileModal();
        // });
        // // ESC 닫기
        // document.addEventListener('keydown', (e) => {
        //     if (e.key === 'Escape') closeProfileModal();
        // });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main id="sh-wrapper">
    <!-- 검색바 -->
    <div class="sh-searchbar">
        <div class="tag-input-wrapper">
            <input type="text" placeholder="ㅤ원하는 조건으로 검색하세요" id="tag-search-input" readonly/>
            <div id="selected-tags" class="selected-tags"></div>
        </div>
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>

    <!-- 태그 선택 모달 -->
    <div id="tagSelectModalOverlay" style="display: none;">
        <div class="modal-sheet">
            <div class="modal-header">
                <div class="modal-title-text">태그 선택</div>
                <button type="button" class="modal-close" onclick="closeTagModal()">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <div class="modal-body">
                <div id="all-tag-list" class="all-tag-list">
                    <!-- 모든 태그 버튼 또는 span으로 들어감 -->
                </div>
            </div>
        </div>
    </div>

    <!-- ✅ 스크롤 전용 박스 추가 -->
    <div class="sh-scroll-area">
        <section class="sh-grid">
            <!-- 카드들이 Ajax로 들어옴 -->
        </section>
    </div>


    <!-- 좌하단 등록 플로팅 버튼 -->
    <%--    <button class="sh-fab" title="등록" id="roommateAdd">--%>
    <%--        <i class="fa-solid fa-plus"></i>--%>
    <%--    </button>--%>
</main>

<!-- 큰 모달 (등록 페이지를 iframe으로 로드) -->
<%--<div id="profileModalOverlay" aria-hidden="true">--%>
<%--    <div class="modal-sheet" role="dialog" aria-modal="true" aria-labelledby="profileModalTitle">--%>
<%--        <div class="modal-header">--%>
<%--            <div id="profileModalTitle" class="modal-title-text">프로필 등록</div>--%>
<%--            <button type="button" class="modal-close" id="profileModalClose" aria-label="닫기"--%>
<%--                    onclick="closeProfileModal()">--%>
<%--                <i class="fa-solid fa-xmark"></i>--%>
<%--            </button>--%>
<%--        </div>--%>
<%--        <div class="modal-body">--%>
<%--            <iframe id="profileModalFrame" title="룸메이트 등록 화면"></iframe>--%>
<%--        </div>--%>
<%--    </div>--%>
<%--</div>--%>

<%-- 챗봇 --%>
<%@ include file="../includes/chatbot.jsp" %>
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

<script>
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;

            // 새 탭으로 열기
            window.open(
                ctx + '/roommate/roommateDetail?userId=' + encodeURIComponent(id),
                '_blank'
            );
        });
    })();
</script>


<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<!-- ✅ 무한 스크롤 스크립트 -->
<script>
    $(document).ready(function () {
        let page = 1;
        let loading = false;
        let lastPage = false;

        let isSearching = false; // 🔥 검색 중 여부
        let currentTagFilter = []; // 🔥 현재 선택된 태그들 기억

        const pageSize = 10;
        const $grid = $(".sh-grid");
        const $scrollArea = $(".sh-scroll-area");

        // 첫 로드
        loadPage(page);

        // 무한 스크롤
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

        // 일반 목록 불러오기
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

        // 검색 결과 불러오기
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

        // 검색 버튼 클릭
        $('#sh-search-btn').on('click', function () {
            const selected = getSelectedTagIds();

            isSearching = true;
            currentTagFilter = selected;
            page = 1;
            lastPage = false;

            $('.sh-grid').empty(); // 기존 목록 제거
            loadFilteredPage(page); // 첫 검색 결과 불러오기
        });

        // 태그 선택 관련 함수들
        $('#tag-search-input').on('click', function () {
            openTagModal();
        });

        function openTagModal() {
            const $modal = $('#tagSelectModalOverlay');
            const $searchbar = $('.sh-searchbar');

            const height = $searchbar.outerHeight();
            const width = $searchbar.outerWidth();

            $modal.css({
                top: height + 220 + 'px',     // 검색바 바로 아래
                width: width + 'px',        // 검색 input 너비와 동일
                display: 'block'
            });

            loadAllTags();
        }

        window.closeTagModal = function () {
            $('#tagSelectModalOverlay').hide();
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

        function renderAllTags(tags) {
            const $container = $('#all-tag-list');
            $container.empty();
            tags.forEach(tag => {
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
                $container.append($btn);
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
            const $input = $('#tag-search-input'); // input 요소를 가져옵니다.

            $wrapper.empty(); // 일단 비우고

            // 선택된 태그가 있으면 태그 뱃지를 다시 그림
            selectedTags.forEach((tagName, tagId) => {
                const $span = $('<span>').addClass('tag-badge').text(tagName);
                const $x = $('<i>').addClass('fa-solid fa-xmark badge-remove').attr('data-id', tagId);
                $span.append($x);
                $wrapper.append($span);
            });

            /*
             * 🔥핵심 로직:
             * 태그 맵(selectedTags)의 크기(size)를 확인해서
             * 0보다 크면(태그가 하나라도 있으면) .has-tags 클래스를 붙이고,
             * 그렇지 않으면(태그가 없으면) .has-tags 클래스를 제거합니다.
             */
            if (selectedTags.size > 0) {
                $input.addClass('has-tags');
            } else {
                $input.removeClass('has-tags');
            }

            // 삭제 버튼 이벤트 다시 연결
            $('.badge-remove').off('click').on('click', function () {
                const tid = $(this).data('id');
                if (selectedTags.has(tid)) { // tid가 숫자인 경우를 대비해 has로 한 번 더 체크
                    selectedTags.delete(tid);
                    renderSelectedTags(); // ★★★ 자신을 다시 호출하여 화면을 갱신 ★★★
                    // 모달의 버튼 상태도 갱신
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
                if (user.userId === loginUserId) {
                    return true;
                }

                var imgUrl = user.profileImageUrl || (ctx + "/images/noimg.png");
                var nickname = user.userName || "알 수 없음";
                var age = user.age ? user.age + "세" : "";

                var $card = $("<article>")
                    .addClass("sh-card")
                    .attr("data-id", user.userId);

                var $thumb = $("<div>")
                    .addClass("sh-thumb")
                    .css("background-image", "url('" + imgUrl + "')");

                var $info = $("<div>").addClass("sh-info")
                    .append($("<p>").addClass("sh-sub").text("이름 : " + nickname + (age ? " (" + age + ")" : "")));

                var $tagBox = $("<div>").addClass("tag-box");

                if (user.tag1) $tagBox.append($("<span>").addClass("tag").text(user.tag1));
                if (user.tag2) $tagBox.append($("<span>").addClass("tag").text(user.tag2));

                if (user.gender) {
                    var genderText = user.gender === "M" ? "남" :
                        user.gender === "F" ? "여" : user.gender;

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
