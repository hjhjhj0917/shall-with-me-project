<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

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

<script>
    $(document).ready(function () {

        // 초기값
        let currentPage = 1;
        const pageSize = 10;

        $('#tag-search-input').on('click', function () {
            openTagModal();
        });

        $('#sh-search-btn').on('click', function () {
            const selected = getSelectedTagIds();
            currentPage = 1; // 검색 버튼 클릭 시 페이지 초기화
            doSearchWithTags(selected, currentPage, pageSize);
        });

        // 페이징 버튼 예시 (필요하면 UI에 페이징 버튼 추가 후 바인딩)
        // $('#next-page-btn').on('click', function() {
        //     currentPage++;
        //     doSearchWithTags(getSelectedTagIds(), currentPage, pageSize);
        // });
    });

    function openTagModal() {
        $('#tagSelectModalOverlay').show();
        loadAllTags();
    }

    function closeTagModal() {
        $('#tagSelectModalOverlay').hide();
    }

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
        $wrapper.empty();
        selectedTags.forEach((tagName, tagId) => {
            const $span = $('<span>').addClass('tag-badge').text(tagName);
            const $x = $('<i>').addClass('fa-solid fa-xmark badge-remove').attr('data-id', tagId);
            $span.append($x);
            $wrapper.append($span);
        });
        $('.badge-remove').off('click').on('click', function () {
            const tid = $(this).data('id');
            selectedTags.delete(tid);
            renderSelectedTags();
            $('#all-tag-list .tag-btn[data-id="' + tid + '"]').removeClass('selected');
        });
    }

    function doSearchWithTags(tagIdArray, page, pageSize) {
        // 빈 배열일 때도 전송해서 백엔드에서 처리하도록
        const reqData = {
            tagIds: tagIdArray || [],
            page: page,
            pageSize: pageSize
        };

        $.ajax({
            url: '/roommate/searchByTags',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(reqData),
            dataType: 'json',
            success: function (data) {
                console.log("✅ AJAX 응답 데이터: ", data);
                // data는 TagDTO 구조. users 리스트는 data.users 또는 data.items 이름 확인 필요
                $('.sh-grid').empty();
                renderUserCards(data.users || data.items || []);

                // 페이징 UI 있으면 여기서 totalCount, pageSize, page 정보로 갱신 가능
                // ex) updatePagination(data.totalCount, data.page, data.pageSize);
            },
            error: function (err) {
                console.error('검색 실패', err);
            }
        });
    }

    function getSelectedTagIds() {
        return Array.from(selectedTags.keys());
    }

    function renderUserCards(users) {
        const $grid = $(".sh-grid");
        $grid.empty();

        const loginUserId = "${sessionScope.SS_USER_ID}";

        $.each(users, function (i, user) {
            if (user.userId === loginUserId) return true;

            const imgUrl = user.profileImageUrl || (ctx + "/images/noimg.png");
            const nickname = user.userName || "알 수 없음";
            const age = user.age ? user.age + "세" : "";

            const $card = $("<article>").addClass("sh-card").attr("data-id", user.userId);
            const $thumb = $("<div>").addClass("sh-thumb").css("background-image", "url('" + imgUrl + "')");
            const $info = $("<div>").addClass("sh-info")
                .append($("<p>").addClass("sh-sub").text("이름 : " + nickname + (age ? " (" + age + ")" : "")));

            const $tagBox = $("<div>").addClass("tag-box");

            if (user.tag1) $tagBox.append($("<span>").addClass("tag").text(user.tag1));
            if (user.tag2) $tagBox.append($("<span>").addClass("tag").text(user.tag2));

            if (user.gender) {
                const genderClass = (user.gender === "남" || user.gender === "M") ? "male" : "female";
                $tagBox.append($("<span>").addClass("tag gender " + genderClass).text(user.gender));
            }

            $info.append($tagBox);
            $card.append($thumb).append($info);
            $grid.append($card);
        });
    }


</script>
