<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  boolean inModal = "Y".equals(request.getParameter("inModal"));
%>
<!DOCTYPE html>
<html lang="ko">

<head>
  <meta charset="UTF-8"/>
  <title>살며시: 쉐어하우스 정보 등록</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseReg.css?v=20251006"/>
  <style>
    /* UX: 업로더 전체가 버튼처럼 보이게 */
    .uploader { cursor: pointer; }
  </style>
</head>

<body>
<% if (!inModal) { %>
<header>
  <!-- (기존 헤더) -->
  <div class="home-logo" onclick="location.href='/user/main'">
    <div class="header-icon-stack"><i class="fa-solid fa-people-roof fa-xs" style="color:#3399ff;"></i></div>
    <div class="header-logo">살며시</div>
  </div>
  <div class="header-user-area">
    <div class="header-switch-container pinned" id="switchBox">
      <span class="slide-bg3"></span>
      <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
      <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
      <button class="header-dropdown-toggle" id="switchToggle"><i class="fa-solid fa-repeat fa-sm" style="color:#1c407d;"></i></button>
    </div>
    <div class="header-user-name-container pinned" id="userNameBox">
      <span class="slide-bg"></span>
      <span class="user-name-text" id="userNameText"><%= session.getAttribute("SS_USER_NAME") %>님</span>
      <button class="header-dropdown-toggle" id="userIconToggle"><i class="fa-solid fa-circle-user fa-sm" style="color:#1c407d;"></i></button>
    </div>
    <div class="header-menu-container pinned" id="menuBox">
      <span class="slide-bg2"></span>
      <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
      <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
      <button class="header-dropdown-toggle" id="headerDropdownToggle"><i class="fa-solid fa-bars fa-xs" style="color:#1c407d;"></i></button>
    </div>
  </div>
</header>
<% } %>

<main class="roommate-container">
  <form id="roommateForm" action="/sharehouse/register" method="post" enctype="multipart/form-data">

    <section class="roommate-left sh-reg-wrap">
      <c:set var="loginName" value="${sessionScope.SS_USER_NAME}" />
      <div class="form-group name-group">
        <label>
          <span>
            <c:choose>
              <c:when test="${not empty loginName}"><c:out value="${loginName}"/>의 쉐어하우스</c:when>
              <c:otherwise>내 쉐어하우스</c:otherwise>
            </c:choose>
          </span>
        </label>
      </div>

      <!-- ✅ 추가: 쉐어하우스 이름 입력 -->
      <div class="form-group">
        <label>쉐어하우스 이름 <span style="color:#999; font-size:0.9em;">(최대 20자)</span></label>
        <input type="text"
               name="houseName"
               id="houseName"
               maxlength="20"
               placeholder="예: 강남 따뜻한 쉐어하우스 역세권"
               required
               style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; font-size:1rem;">
      </div>

      <div class="sh-modal-body sh-reg">
        <!-- ▼ 업로더 왼쪽 + 태그패널 오른쪽 -->
        <div class="sh-top-row">
          <!-- 업로더 5장 -->
          <section class="sh-uploader-5">
            <label class="uploader thumb">
              <input type="file" name="thumbnail" accept="image/*" hidden>
              <span>대표 이미지(썸네일)</span>
              <img class="preview" alt="" hidden>
            </label>
            <label class="uploader small">
              <input type="file" name="images" accept="image/*" hidden>
              <span>이미지 업로드</span>
              <img class="preview" alt="" hidden>
            </label>
            <label class="uploader small">
              <input type="file" name="images" accept="image/*" hidden>
              <span>이미지 업로드</span>
              <img class="preview" alt="" hidden>
            </label>
            <label class="uploader small">
              <input type="file" name="images" accept="image/*" hidden>
              <span>이미지 업로드</span>
              <img class="preview" alt="" hidden>
            </label>
            <label class="uploader small">
              <input type="file" name="images" accept="image/*" hidden>
              <span>이미지 업로드</span>
              <img class="preview" alt="" hidden>
            </label>
          </section>

          <!-- ✅ 업로더 오른쪽: 보여질 태그 -->
          <aside class="inline-tag-panel inline-right">
            <div class="inline-tag-title">보여질 태그</div>
            <div class="inline-tag-list" id="inlineTagList"></div>
            <p class="inline-tag-empty" id="inlineTagEmpty">등록된 태그가 없습니다.</p>
          </aside>
        </div>
        <!-- ▲ 업로더 + 태그패널 -->

        <!-- 소개글은 아래 -->
        <section class="sh-reg-intro">
          <div class="form-group">
            <label>쉐어하우스 소개</label>
            <textarea id="introTextarea" name="introduction" rows="10" placeholder="소개글 시작"></textarea>
          </div>
        </section>
      </div>

      <div class="sh-reg-actions">
        <button type="button" class="btn btn-cancel" id="shRegCancelBtn">취소</button>
        <button type="submit" class="btn btn-primary" id="btnSave">저장</button>
      </div>
    </section>

    <!-- 오른쪽 외부 박스는 제거 -->
  </form>
</main>

<script>
  // 취소 버튼
  document.addEventListener('DOMContentLoaded', function () {
    const cancelBtn = document.getElementById('shRegCancelBtn');
    if (cancelBtn) {
      cancelBtn.addEventListener('click', function (e) {
        e.preventDefault();
        try {
          if (window.parent && typeof window.parent.closeSharehouseRegModal === 'function') {
            window.parent.closeSharehouseRegModal();
          } else { window.close(); }
        } catch (err) { console.error('모달 닫기 실패:', err); }
      });
    }
  });
</script>

<%@ include file="../includes/customModal.jsp" %>

<!-- 업로더 미리보기 + 태그 복제 표시 -->
<script>
  document.addEventListener('DOMContentLoaded', () => {
    // 업로더 미리보기
    document.querySelectorAll('.sh-uploader-5 .uploader input[type="file"]').forEach(input => {
      const wrap = input.closest('.uploader');
      const span = wrap.querySelector('span');
      const img  = wrap.querySelector('.preview');

      // ✅ programmatic click 제거: 라벨 기본 클릭만 사용
      // 라벨을 누르는 순간(파일창 열리기 직전) 값 초기화 → 같은 파일 재선택도 change 발생
      wrap.addEventListener('mousedown', () => {
        input.value = null;
      });

      // 보조: input 자체를 직접 눌러도 동일 동작
      input.addEventListener('click', () => {
        input.value = null;
      });

      // 파일 선택 후 미리보기
      input.addEventListener('change', () => {
        const f = input.files && input.files[0];
        if (!f){ img.hidden = true; span.hidden = false; return; }
        if (!f.type.startsWith('image/')){ alert('이미지 파일만 업로드 가능합니다.'); input.value=''; return; }
        if (f.size > 5 * 1024 * 1024){ alert('최대 5MB까지만 업로드 가능합니다.'); input.value=''; return; }
        img.src = URL.createObjectURL(f); img.hidden = false; span.hidden = true;
      });
    });

    // 좌측(혹은 서버)에서 선택된 태그를 오른쪽 패널에 복제
    const SRC_SELECTOR = '#displayTags .tag-chip, .left-tags .tag-chip';

    function renderInlineTags(){
      const src   = document.querySelectorAll(SRC_SELECTOR);
      const list  = document.getElementById('inlineTagList');
      const empty = document.getElementById('inlineTagEmpty');
      list.innerHTML = '';
      if (src.length){
        empty.style.display = 'none';
        src.forEach(el=>{
          const pill = document.createElement('span');
          pill.className = 'tag-pill';
          const pure = (el.childNodes[0]?.textContent || el.textContent).trim().replace(/^#/, '');
          pill.textContent = pure;
          list.appendChild(pill);
        });
      } else {
        empty.style.display = '';
      }
    }

    renderInlineTags();
    document.addEventListener('tags:changed', renderInlineTags); // 태그 변경 시 호출
  });
</script>

<script>
  document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('roommateForm');
    const btn  = document.getElementById('btnSave');

    form.addEventListener('submit', async (e) => {
      e.preventDefault();

      const houseName = document.getElementById('houseName')?.value?.trim();
      if (!houseName) {
        alert('쉐어하우스 이름을 입력해 주세요.');
        document.getElementById('houseName')?.focus();
        return;
      }
      if (houseName.length > 20) {
        alert('쉐어하우스 이름은 최대 20자까지 입력 가능합니다.');
        return;
      }

      // ✅ 이름 검증 추가
      const thumb = form.querySelector('input[name="thumbnail"]')?.files?.[0];
      if (!thumb) { alert('대표 이미지를 선택해 주세요.'); return; }
      const imgs = [...form.querySelectorAll('input[name="images"]')]
              .map(i => i.files?.[0]).filter(Boolean);
      if (imgs.length < 1) { alert('추가 이미지를 최소 1장 선택해 주세요.'); return; }

      btn.disabled = true; btn.textContent = '저장중...';

      const fd = new FormData(form); // name="images" 여러개 자동 포함
      // 룸메이트와 동일 구조: thumbnail을 profileImage로도 같이 전송
      fd.append('profileImage', form.querySelector('input[name="thumbnail"]').files[0]);


      try {
        const url = (typeof ctx !== 'undefined' ? ctx : '') + '/sharehouse/register';
        const res = await fetch(url, {
          method: 'POST',
          body: fd,
          credentials: 'include', // 세션 쿠키 포함
        });

        let json = null;
        try { json = await res.clone().json(); } catch (_) { /* ignore */ }

// 리다이렉트/불투명 응답(상태코드 0) 대비
        if (res.status === 0 || res.type === 'opaqueredirect') {
          alert('저장 실패 (redirect/CORS 가능성)\n로그인 리다이렉트 또는 CORS 설정을 확인해 주세요.');
          return;
        }

// 일반 실패 처리
        if (!res.ok) {
          const text =
                  (json && json.msg) ||
                  (await res.text().catch(() => '')) ||
                  '서버 오류';
          alert(`저장 실패 (${res.status})\n${text}`);
          return;
        }

        json = json || {};

        if (json.result === 1 || json.result === 'success') {
          // 부모창에 목록 리로드 신호 (data 없을 수도 있으니 안전 처리)
          const savedId = json?.data?.shId ?? null;
          if (window.parent) {
            window.parent.postMessage({ type: 'SH_SAVED', shId: savedId }, '*');
          }

          // 모달 닫기 (함수가 있으면)
          try {
            if (window.parent && typeof window.parent.closeSharehouseRegModal === 'function') {
              window.parent.closeSharehouseRegModal();
            }
          } catch(_) {}

          // 단독 페이지로 연 경우엔 메인 이동
          if (window === window.parent) location.href = '/sharehouse/main';
        } else {
          alert(json.msg || '저장에 실패했습니다.');
        }
      } catch (err) {
        console.error(err);
        alert('서버 통신 중 오류가 발생했습니다.');
      } finally {
        btn.disabled = false; btn.textContent = '저장';
      }
    });
  });
</script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
