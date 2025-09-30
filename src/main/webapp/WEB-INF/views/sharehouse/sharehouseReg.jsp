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
    <%-- 필요하면 전용 CSS 연결
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseReg.css"/>
    --%>

    <style>
        * { box-sizing: border-box; }

        /* 바깥 컨테이너: 가운데 정렬 */
        .roommate-container {
            padding: 60px 20px;
            width: 90%;
            max-width: 1600px;
            margin: 0 auto;
        }

        /* 폼을 가로 플렉스로 만들어 좌/우 수평 정렬 */
        #roommateForm {
            display: flex;
            flex-direction: row;
            justify-content: center;
            align-items: stretch;
            gap: 60px;
            width: 100%;
        }

        /* 좌/우 박스 */
        .roommate-right,
        .roommate-left {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 48px;
            display: flex;
            flex-direction: column;
            min-height: 600px;
        }

        /* 내부 요소 */
        .form-group { margin-bottom: 32px; }
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 12px;
        }
        .form-group input[type="text"] {
            width: 100%;
            padding: 16px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }

        /* 이미지 업로드 */
        .image-upload-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 32px;
        }
        .upload-box {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 2px dashed #bbb;
            border-radius: 8px;
            width: 180px;
            height: 180px;
            padding: 0;
            overflow: hidden;
            cursor: pointer;
            transition: border-color .2s ease, background-color .2s ease;
            text-align: center;
        }
        .upload-box:hover { border-color: #3399ff; background-color: #f7fbff; }
        .upload-box i { color: #999; margin-bottom: 12px; }
        .upload-box span { font-size: 14px; color: #666; }
        .upload-box input[type="file"] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer;
        }
        .upload-box.has-image { border-color: #3399ff; background: #f7fbff; }
        .upload-box.has-image i,
        .upload-box.has-image span { display: none; }
        .upload-box img.preview {
            width: 100%; height: 100%; object-fit: cover; border-radius: 6px; display: block;
        }
        .upload-box .remove-btn {
            position: absolute; top: 8px; right: 8px; z-index: 3;
            border: 1px solid #ddd; padding: 6px 10px; border-radius: 6px;
            cursor: pointer; background: #fff; font-size: 0.85rem;
        }
        .upload-box.has-image input[type="file"] { pointer-events: none; }

        /* 자기소개 */
        .intro-btn {
            align-self: flex-start;
            margin-bottom: 16px;
            padding: 10px 18px;
            background-color: #3399ff;
            color: #fff;
            border: none; border-radius: 6px;
            cursor: pointer; font-size: 0.95rem;
        }
        textarea#introTextarea {
            flex: 1; width: 500px; min-height: 100px;
            padding: 20px; border: 1px solid #ccc; border-radius: 6px;
            resize: vertical; font-family: inherit; line-height: 1.5;
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
                            <c:otherwise>
                                내 쉐어하우스
                            </c:otherwise>
                        </c:choose>
                    </span>
                </label>
            </div>

            <div class="image-upload-grid">
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file" name="images" accept="image/*"/>
                </div>
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file" name="images" accept="image/*"/>
                </div>
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file" name="images" accept="image/*"/>
                </div>
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file" name="images" accept="image/*"/>
                </div>
            </div>

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

        <!-- 오른쪽 -->
        <section class="roommate-right">
            <button type="button" class="intro-btn">쉐어하우스 소개</button>
            <textarea id="introTextarea"
                      name="introduction"
                      placeholder="소개글 시작"></textarea>
        </section>
    </form>
</main>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) { ssUserName = ""; }
%>

<!-- JS: 미리보기 + 삭제 기능 -->
<script>
  document.querySelectorAll('.upload-box input[type="file"]').forEach((input) => {
    input.addEventListener('change', (e) => {
      const file = e.target.files && e.target.files[0];
      const box = e.target.closest('.upload-box');
      if (!file) return;

      if (!file.type.startsWith('image/')) {
        alert('이미지 파일만 업로드할 수 있어요.');
        e.target.value = '';
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        alert('파일 용량이 너무 커요. (최대 5MB)');
        e.target.value = '';
        return;
      }

      const reader = new FileReader();
      reader.onload = () => {
        box.classList.add('has-image');

        let img = box.querySelector('img.preview');
        if (!img) {
          img = document.createElement('img');
          img.className = 'preview';
          box.appendChild(img);

          const btn = document.createElement('button');
          btn.type = 'button';
          btn.className = 'remove-btn';
          btn.textContent = '이미지 삭제';
          btn.addEventListener('click', () => {
            input.value = '';
            img.remove();
            btn.remove();
            box.classList.remove('has-image');
          });
          box.appendChild(btn);
        }
        img.src = reader.result;
      };
      reader.readAsDataURL(file);
    });
  });

  // 백업: 만약 파라미터 누락되어도 iframe 안에서 열렸다면 헤더 제거
  if (window.self !== window.top) {
    document.querySelector('header')?.remove();
    document.querySelector('.roommate-container')?.style.setProperty('padding-top', '24px');
    document.body.style.background = '#fff';
  }
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
