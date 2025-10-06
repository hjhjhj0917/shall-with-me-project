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
              <c:when test="${not empty loginName}"><c:out value="${loginName}"/> 의 쉐어하우스</c:when>
              <c:otherwise>내 쉐어하우스</c:otherwise>
            </c:choose>
          </span>
        </label>
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

      wrap.addEventListener('click', () => input.click());
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

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
