<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>sample</title>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/modal.css"/>

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
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 32px;
        }
        .upload-box {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 2px dashed #bbb;
            border-radius: 100%;
            width: 200px;
            height: 200px;
            padding: 0;
            overflow: hidden;
            cursor: pointer;
            transition: border-color .2s ease, background-color .2s ease;
            text-align: center;
        }
        .upload-box:hover {
            border-color: #3399ff;
            background-color: #f7fbff;
        }
        .upload-box i { color: #999; margin-bottom: 12px; }
        .upload-box span { font-size: 14px; color: #666; }

        /* 파일 인풋이 박스 전체를 덮도록 */
        .upload-box input[type="file"] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
        }

        /* 미리보기 상태 */
        .upload-box.has-image {
            border-color: #3399ff;
            background: #f7fbff;
        }
        .upload-box.has-image i,
        .upload-box.has-image span {
            display: none;
        }
        .upload-box img.preview {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 100%;
            display: block;
            pointer-events: none;
        }

        .upload-box.has-image input[type="file"] {
            pointer-events: auto;
        }

        /* 자기소개 버튼 */
        .intro-btn {
            align-self: flex-start;
            margin-bottom: 16px;
            padding: 10px 18px;
            background-color: #3399ff;
            color: #fff;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.95rem;
        }

        /* textarea */
        textarea#introTextarea {
            flex: 1;
            width: 500px;
            min-height: 100px;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 6px;
            resize: vertical;
            font-family: inherit;
            line-height: 1.5;
        }

        /* 태그 */
        .tag-chip-wrap { display:flex; flex-wrap:wrap; gap:8px; margin-top:6px; }
        .tag-chip {
            display:inline-flex; align-items:center; gap:4px;
            padding:6px 10px; border-radius:999px; background:#f2f6ff; color:#1c407d;
            font-size:0.9rem; border:1px solid #d9e6ff;
        }
        .tag-type { color:#6b7da6; font-size:0.78rem; }
        .tag-empty { color:#888; margin-left:8px; }

        @media (max-width: 1100px) {
            #roommateForm { flex-direction: column; gap: 30px; }
            .roommate-left, .roommate-right { padding: 24px; }
        }
    </style>
</head>
<body>
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
            <button class="menu-list" onclick="location.href='/chat/userListPage'">메세지</button>
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<main class="roommate-container">
    <form id="roommateForm"
          action="/roommate/register"
          method="post"
          enctype="multipart/form-data">
        <!-- 왼쪽 -->
        <section class="roommate-left">
            <div class="form-group name-group">
                <label>이름 :
                    <span><%= session.getAttribute("SS_USER_NAME") != null ? session.getAttribute("SS_USER_NAME") : "" %></span>
                </label>
            </div>

            <div class="image-upload-grid">
                <c:set var="profileUrl" value="${userProfile.profileImageUrl}" />
                <div class="upload-box ${not empty profileUrl ? 'has-image' : ''}" id="profileUploadBox">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>프로필 사진 업로드</span>

                    <!-- ✅ 파일 name을 컨트롤러와 일치 -->
                    <input type="file" name="profileImage" accept="image/*" />

                    <!-- ✅ 기존 이미지가 있으면 미리보기 표시 -->
                    <c:if test="${not empty profileUrl}">
                        <img class="preview" src="${profileUrl}" alt="profile preview"/>
                    </c:if>
                </div>
            </div>

            <!-- 태그 표시 -->
            <div class="form-group tag-group">
                <label>보여질 태그 :</label>
                <c:choose>
                    <c:when test="${not empty userTags}">
                        <div class="tag-chip-wrap">
                            <c:forEach var="t" items="${userTags}">
                                <span class="tag-chip">
                                    <c:out value="${empty t.tagName ? t.tag_name : t.tagName}"/>
                                </span>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <span class="tag-empty">등록된 태그가 없습니다.</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <!-- /태그 표시 -->

        </section>

        <!-- 오른쪽 -->
        <section class="roommate-right">
            <button type="button" class="intro-btn" id="introBtn">자기 소개</button>

            <!-- ✅ 기존 소개글이 있으면 채워서 보여줌 -->
            <textarea id="introTextarea"
                      name="introduction"
                      placeholder="소개글 시작"><c:out value="${userProfile.introduction}"/></textarea>

            <!-- ✅ 저장 버튼 추가 -->
            <button type="submit" class="intro-btn" style="margin-top:16px;">저장</button>
        </section>
    </form>
</main>

<div id="customAlertOverlay" class="modal-overlay" style="display: none;">
    <div class="modal">
        <div class="modal-title">
            <i class="fa-solid fa-circle-exclamation fa-shake fa-lg" style="color: #3399ff;"></i>
            <h2>살며시</h2>
        </div>
        <p id="customAlertMessage">메시지 내용</p>
        <div class="modal-buttons" style="text-align: right;">
            <button class="deactivate-btn" onclick="closeCustomAlert()">확인</button>
        </div>
    </div>
</div>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>

<!-- JS -->
<script>
    function showCustomAlert(msg) {
        const overlay = document.getElementById('customAlertOverlay');
        document.getElementById('customAlertMessage').textContent = msg;
        overlay.style.display = 'flex';
    }

    document.querySelectorAll('.upload-box input[type="file"]').forEach((input) => {
        const box = input.closest('.upload-box');

        input.addEventListener('change', (e) => {
            const file = e.target.files && e.target.files[0];
            if (!file) return;

            if (!file.type.startsWith('image/')) {
                showCustomAlert('이미지 파일만 업로드할 수 있어요.');
                e.target.value = '';
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                showCustomAlert('파일 용량이 너무 커요. (최대 5MB)');
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
                }
                img.src = reader.result;
            };
            reader.readAsDataURL(file);
        });
    });

    document.getElementById('introBtn')?.addEventListener('click', () => {
        document.getElementById('introTextarea')?.focus();
    });
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
