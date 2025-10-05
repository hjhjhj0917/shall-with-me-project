<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  // 모달(iframe)로 열릴 때는 ?inModal=Y 로 호출
  boolean inModal = "Y".equals(request.getParameter("inModal"));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>살며시: 쉐어하우스 정보 등록</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <!-- ▼ 이번 작업에서 사용하는 전용 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseReg.css"/>

    <style>
        * { box-sizing: border-box; }

        /* 바깥 컨테이너: 가운데 정렬 */
        .roommate-container {
            padding: 60px 20px;
            width: 90%;
            max-width: 1600px;
            margin: 0 auto;
        }

        /* 폼 레이아웃: 좌/우 2열 */
        #roommateForm {
            display: flex;
            flex-direction: row;
            justify-content: center;
            align-items: stretch;
            gap: 60px;
            width: 100%;
        }

        /* 좌/우 박스 */
        .roommate-left,
        .roommate-right {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 48px;
            display: flex;
            flex-direction: column;
            min-height: 600px;
        }

        /* 공통 폼 요소 */
        .form-group { margin-bottom: 32px; }
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 12px;
        }

        /* 태그 표시 */
        .tag-chip-wrap { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 6px; }
        .tag-chip {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 6px 10px; border-radius: 999px;
            background: #f2f6ff; color: #1c407d; font-size: 0.9rem;
            border: 1px solid #d9e6ff;
        }
        .tag-type { color: #6b7da6; font-size: 0.78rem; }
        .tag-empty { color: #888; margin-left: 8px; }

        /* 반응형 */
        @media (max-width: 1100px) {
            #roommateForm { flex-direction: column; }
            .roommate-left, .roommate-right { flex: 1 1 auto; min-height: 520px; }
        }

        /* 모달로 열릴 때 헤더/여백 보정 */
        <% if (inModal) { %>
        header { display: none; }
        .roommate-container { padding-top: 24px; }
        body { background: #fff; }
        <% } %>
    </style>
</head>
<body>

<% if (!inModal) { %>
<header>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <i class="fa-solid fa-people-roof fa-xs" style="color: #3399ff;"></i>
        </div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span>
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span>
            <span class="user-name-text" id="userNameText">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span>
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>
<% } %>

<main class="roommate-container">
    <!-- 절대: form 속성 사이에 주석 넣지 말 것 -->
    <form id="roommateForm"
          action="/sharehouse/register"
          method="post"
          enctype="multipart/form-data">

        <!-- 왼쪽 -->
        <section class="roommate-left">

            <%-- 로그인 이름을 JSTL 변수로 보관 --%>
            <c:set var="loginName" value="${sessionScope.SS_USER_NAME}" />

            <div class="form-group name-group">
                <label>
                    <span>
                        <c:choose>
                            <c:when test="${not empty loginName}">
                                <c:out value="${loginName}"/> 의 쉐어하우스
                            </c:when>
                            <c:otherwise>내 쉐어하우스</c:otherwise>
                        </c:choose>
                    </span>
                </label>
            </div>

            <!-- ▼ 사진 5장 + 소개글 (새 레이아웃) ▼ -->
            <div class="sh-modal-body sh-reg">
                <!-- 사진 5장 -->
                <section class="sh-uploader-5">
                    <!-- 큰 썸네일(메인 카드 썸네일 전용) -->
                    <label class="uploader thumb">
                        <input type="file" name="thumbnail" accept="image/*" hidden>
                        <span>대표 이미지(썸네일)</span>
                        <img class="preview" alt="" hidden>
                    </label>

                    <!-- 추가 이미지 4장 -->
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

                <!-- 소개글: 사진 영역 아래 -->
                <section class="sh-reg-intro">
                    <div class="form-group">
                        <label>쉐어하우스 소개</label>
                        <textarea id="introTextarea" name="introduction" rows="10" placeholder="소개글 시작"></textarea>
                    </div>
                </section>
            </div>
            <!-- ▲ 사진 5장 + 소개글 (새 레이아웃) ▲ -->

            <!-- 보여질 태그 -->
            <div class="form-group tag-group">
                <label>보여질 태그 :</label>
                <c:choose>
                    <c:when test="${not empty userTags}">
                        <div class="tag-chip-wrap">
                            <c:forEach var="t" items="${userTags}">
                                <span class="tag-chip">
                                  #<c:out value="${t.tagName != null ? t.tagName : t.tag_name}"/>
                                  <small class="tag-type">
                                    <c:choose>
                                      <c:when test="${(t.tagType != null ? t.tagType : t.tag_type) == 'ME'}">· 나</c:when>
                                      <c:when test="${(t.tagType != null ? t.tagType : t.tag_type) == 'PREF'}">· 선호</c:when>
                                    </c:choose>
                                  </small>
                                </span>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <span class="tag-empty">등록된 태그가 없습니다.</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <!-- /보여질 태그 -->
        </section>

        <!-- 오른쪽: 여기는 추후 가격/주소 등 다른 필드 넣을 자리 -->
        <section class="roommate-right">
            <div class="form-group">
                <label>추가 정보</label>
                <p style="color:#6b7280; margin:0;">향후 보증금/월세, 주소, 옵션 등을 배치할 공간입니다.</p>
            </div>
        </section>
    </form>
</main>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) { ssUserName = ""; }
%>

<!-- JS: 업로더 클릭/미리보기(대표+4장) -->
<script>
  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.sh-uploader-5 .uploader input[type="file"]').forEach(input => {
      const wrap = input.closest('.uploader');
      const span = wrap.querySelector('span');
      const img  = wrap.querySelector('.preview');

      // 클릭으로 파일 선택 열기
      wrap.addEventListener('click', () => input.click());

      // 파일 선택 시 미리보기
      input.addEventListener('change', () => {
        const file = input.files && input.files[0];
        if (!file) { img.hidden = true; span.hidden = false; return; }

        if (!file.type.startsWith('image/')) { alert('이미지 파일만 업로드 가능합니다.'); input.value = ''; return; }
        if (file.size > 5 * 1024 * 1024) { alert('최대 5MB까지만 업로드 가능합니다.'); input.value = ''; return; }

        const url = URL.createObjectURL(file);
        img.src = url; img.hidden = false; span.hidden = true;
      });
    });

    // 백업: 만약 파라미터 누락되어도 iframe 안에서 열렸다면 헤더 제거
    if (window.self !== window.top) {
      document.querySelector('header')?.remove();
      document.querySelector('.roommate-container')?.style.setProperty('padding-top', '24px');
      document.body.style.background = '#fff';
    }
  });
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
