<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<div id="tagSelectModalOverlay" class="modal-overlay" style="display:none;">
  <div class="modal-sheet">
    <div class="modal-header">
      <button type="button" class="modal-close" id="tagSelectCloseBtn">
        <i class="fa-solid fa-xmark"></i>
      </button>
      <div class="modal-title-text">태그 선택</div>
    </div>

    <div class="modal-body">
      <div id="all-tag-list"><!-- 태그 그룹 랜더링 영역 --></div>
    </div>

    <div class="modal-footer" style="display:flex;justify-content:space-between;align-items:center;gap:8px;padding:12px 16px;border-top:1px solid #eee;background:#fff;">
      <div style="font-size:0.95rem;color:#495057;">
        <span id="tagCount" style="font-weight:600;color:#3399ff;">0</span>/3 선택
      </div>
      <div style="display:flex;gap:8px;">
        <button type="button" class="btn ghost" id="tagSelectCancelBtn"
                style="padding:8px 16px;border:1px solid #ddd;border-radius:8px;background:#fff;cursor:pointer;font-size:0.9rem;">취소</button>
        <button type="button" class="btn primary" id="tagSelectOkBtn"
                style="padding:8px 16px;border:none;border-radius:8px;background:#3399ff;color:#fff;font-weight:600;cursor:pointer;font-size:0.9rem;">선택 완료</button>
      </div>
    </div>
  </div>
</div>

<style>
  /* 메인 화면과 동일한 태그 그룹 스타일 */
  #tagSelectModalOverlay .search-tag-group {
    display: flex;
    align-items: center;
    padding: 16px 0;
  }

  #tagSelectModalOverlay .search-tag-group + .search-tag-group {
    border-top: 1px solid #f0f0f0;
  }

  #tagSelectModalOverlay .search-tag-group__icon-wrapper {
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

  #tagSelectModalOverlay .search-tag-group__icon-wrapper i {
    font-size: 30px;
    color: #495057;
  }

  #tagSelectModalOverlay .search-tag-group__content-wrapper {
    flex-grow: 1;
    padding-left: 24px;
    min-width: 0; /* 추가: 텍스트 오버플로우 방지 */
  }

  #tagSelectModalOverlay .search-tag-group__title {
    font-weight: 600;
    font-size: 1rem;
    color: #343a40;
    margin-bottom: 12px;
  }

  #tagSelectModalOverlay .search-tag-group__list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    width: 100%; /* 추가 */
  }

  #tagSelectModalOverlay .tag-btn {
    background-color: #fff;
    border: 1px solid #dee2e6;
    border-radius: 20px;
    padding: 8px 16px;
    font-size: 0.9rem;
    color: #495057;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  #tagSelectModalOverlay .tag-btn.selected {
    background-color: #3399ff;
    border-color: #3399ff;
    color: white;
    font-weight: 600;
  }

  #tagSelectModalOverlay .tag-btn:hover:not(.selected) {
    border-color: #495057;
  }

  #tagSelectModalOverlay .modal-body {
    max-height: 500px;
    overflow-y: auto;
    padding: 20px;
  }
</style>

<script>
  (function(){
    const MAX = 6; // 6개 필수 선택으로 변경
    const $overlay = $('#tagSelectModalOverlay');
    const $list = $('#all-tag-list');
    const $count = $('#tagCount');
    const selectedTags = new Map();

    // 쉐어하우스 전용 태그 그룹 (DB에 실제 존재하는 ID 사용)
    const sharehouseTagGroups = [
      {key: "bathroom", title: "화장실", icon: "fa-solid fa-bath", tags: [1, 2]},
      {key: "fridge", title: "냉장고 공유", icon: "fa-solid fa-temperature-low", tags: [3, 4]},
      {key: "washer", title: "세탁기 공유", icon: "fa-solid fa-soap", tags: [5, 6]},
      {key: "elevator", title: "엘리베이터", icon: "fa-solid fa-elevator", tags: [7, 8]},
      {key: "nearby", title: "근처", icon: "fa-solid fa-location-dot", tags: [9, 10, 11]},
      {key: "parking", title: "주차", icon: "fa-solid fa-car", tags: [12, 13]},
    ];

    window.openTagSelectModal = function(initialSelectedIds = [], onDone){
      selectedTags.clear();

      loadAllTags().then(tags => {
        renderSharehouseTagsGrouped(tags);

        // 초기 선택 활성화
        initialSelectedIds.map(Number).forEach(id=>{
          const btn = $list.find(`.tag-btn[data-id="${id}"]`);
          if (btn.length) {
            selectedTags.set(id, btn.data('name'));
            btn.addClass('selected');
          }
        });

        updateCount();
        $overlay.show();

        // 이벤트 바인딩
        $('#tagSelectOkBtn').off('click').on('click', function(){
          const ids = Array.from(selectedTags.keys());
          if (onDone) onDone(ids);
          $overlay.hide();
        });

        $('#tagSelectCancelBtn, #tagSelectCloseBtn').off('click').on('click', function(){
          $overlay.hide();
        });
      });
    };

    function loadAllTags(){
      return $.ajax({
        url: '/sharehouse/tagAll',
        type: 'GET',
        dataType: 'json'
      });
    }

    function renderSharehouseTagsGrouped(tags){
      $list.empty();
      const tagMap = new Map(tags.map(t => [t.tagId, t]));

      sharehouseTagGroups.forEach(group => {
        const $groupDiv = $('<div>').addClass('search-tag-group');

        // 아이콘
        const $iconWrapper = $('<div>')
                .addClass('search-tag-group__icon-wrapper')
                .append($('<i>').addClass(group.icon));

        // 콘텐츠
        const $contentWrapper = $('<div>').addClass('search-tag-group__content-wrapper');
        const $groupTitle = $('<div>').addClass('search-tag-group__title').text(group.title);
        const $groupList = $('<div>').addClass('search-tag-group__list');

        // 태그 버튼들
        let hasVisibleTags = false;
        group.tags.forEach(tagId => {
          if (tagMap.has(tagId)) {
            hasVisibleTags = true;
            const tag = tagMap.get(tagId);
            const $btn = $('<button>')
                    .addClass('tag-btn')
                    .text(tag.tagName)
                    .attr('data-id', tag.tagId)
                    .attr('data-name', tag.tagName)
                    .attr('type', 'button');

            if (selectedTags.has(tag.tagId)) {
              $btn.addClass('selected');
            }

            $btn.on('click', function(e){
              e.preventDefault();
              e.stopPropagation();

              const id = Number($(this).data('id'));
              const name = $(this).data('name');

              if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                selectedTags.delete(id);
              } else {
                if (selectedTags.size >= MAX) {
                  alert('최대 3개까지만 선택할 수 있습니다.');
                  return;
                }
                $(this).addClass('selected');
                selectedTags.set(id, name);
              }
              updateCount();
            });

            $groupList.append($btn);
          }
        });

        // 태그가 있는 그룹만 추가
        if (hasVisibleTags) {
          $contentWrapper.append($groupTitle, $groupList);
          $groupDiv.append($iconWrapper, $contentWrapper);
          $list.append($groupDiv);
        }
      });
    }

    function updateCount(){
      $count.text(selectedTags.size);
    }
  })();
</script>