<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<div id="tagSelectModalOverlay" class="modal-overlay" style="display:none;">
  <div class="modal-sheet">
    <div class="modal-header">
      <div class="modal-title-text">태그 선택</div>
      <button type="button" class="modal-close" id="tagSelectCloseBtn">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <div class="modal-body">
      <div id="all-tag-list" class="all-tag-list"><!-- 태그 버튼 랜더링 영역 --></div>
    </div>

    <div class="modal-footer" style="display:flex;justify-content:space-between;gap:8px;padding:12px 16px;border-top:1px solid #eee;">
      <div><span id="tagCount">0</span>/3 선택</div>
      <div>
        <button type="button" class="btn ghost" id="tagSelectCancelBtn">취소</button>
        <button type="button" class="btn primary" id="tagSelectOkBtn">선택 완료</button>
      </div>
    </div>
  </div>
</div>

<script>
  (function(){
    // 내부 상태
    const MAX = 3;
    const $overlay = $('#tagSelectModalOverlay');
    const $list = $('#all-tag-list');
    const $count = $('#tagCount');

    // 선택 상태 (숫자 id -> 이름)
    const selectedTags = new Map();

    // === 공개 API: 등록 폼에서 호출 ===
    window.openTagSelectModal = function(initialSelectedIds = [], onDone){
      // 초기 상태 세팅
      selectedTags.clear();
      // 데이터 로딩 후 초기 선택 적용 → 모달 오픈
      loadAllTags().then(tags => {
        renderAllTags(tags);
        // 초기 선택들 활성화
        initialSelectedIds.map(Number).forEach(id=>{
          const btn = $list.find(`.tag-btn[data-id="${id}"]`);
          if (btn.length) {
            selectedTags.set(id, btn.data('name'));
            btn.addClass('selected');
          }
        });
        updateCount();
        $overlay.show();

        // 완료/닫기 바인딩(중복바인딩 방지 위해 먼저 off)
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
        url: '/sharehouse/tagAll',   // ✅ 쉐어하우스용 엔드포인트
        type: 'GET',
        dataType: 'json'
      });
    }

    function renderAllTags(tags){
      $list.empty();
      tags.forEach(tag => {
        const $btn = $('<button>')
                .addClass('tag-btn')           // 기존 스타일 재사용
                .text(tag.tagName)
                .attr('data-id', tag.tagId)
                .attr('data-name', tag.tagName);

        // 선택 토글
        $btn.on('click', function(){
          const id = Number($(this).data('id'));
          const name = $(this).data('name');

          if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
            selectedTags.delete(id);
          } else {
            if (selectedTags.size >= MAX) return; // ✅ 최대 3개 제한
            $(this).addClass('selected');
            selectedTags.set(id, name);
          }
          updateCount();
        });

        $list.append($btn);
      });
    }

    function updateCount(){
      $count.text(selectedTags.size);
    }
  })();
</script>
