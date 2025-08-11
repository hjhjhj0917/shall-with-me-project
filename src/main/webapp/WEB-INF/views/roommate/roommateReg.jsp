<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        /* 컨테이너 중앙 정렬 및 크기 확대 유지 */
        .roommate-container {
            display: flex;
            flex-direction: row;
            justify-content: center;
            align-items: flex-start;
            gap: 60px;
            padding: 60px;
            width: 90%;
            max-width: 3200px;
            margin: 0 auto;
        }

        /* 좌/우 박스 공통 스타일 */
        .roommate-left,
        .roommate-right {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 48px;
            display: flex;
            flex-direction: column;
        }

        /* 너비 비율: 왼쪽 35%, 오른쪽 50% */
        .roommate-left { flex: 0 0 35%; }
        .roommate-right { flex: 0 0 50%; }

        /* 내부 요소 스타일 */
        .form-group { margin-bottom: 48px; }
        .form-group label {
            display: block;
            font-weight: 500;
            margin-bottom: 20px;
        }
        .form-group input[type="text"] {
            width: 100%;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .image-upload-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 32px;
            margin-bottom: 48px;
        }
        .upload-box {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 2px dashed #bbb;
            border-radius: 8px;
            padding: 48px;
            cursor: pointer;
        }
        .upload-box i { color: #999; margin-bottom: 20px; }
        .upload-box span { font-size: 16px; color: #666; }
        .upload-box input[type="file"] {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            opacity: 0;
            cursor: pointer;
        }

        /* 자기소개 버튼 크기 축소 */
        .intro-btn {
            align-self: flex-start;
            margin-bottom: 32px;
            padding: 10px 20px;
            background-color: #3399ff;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
        }

        /* textarea 높이 조정 */
        textarea#introTextarea {
            flex: 1;
            width: 100%;
            min-height: 370px;
            padding: 32px;
            border: 1px solid #ccc;
            border-radius: 4px;
            resize: vertical;
            font-family: inherit;
            line-height: 1.5;
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
        <!-- 왼쪽 섹션: 이미지 업로드 등 -->
        <section class="roommate-left">
            <div class="form-group name-group">
                <label for="userNameInput">이름 :</label>
                <input type="text"
                       id="userNameInput"
                       name="userName"
                       placeholder="이름을 입력하세요" />
            </div>
            <div class="image-upload-grid">
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file"
                           name="images"
                           accept="image/*" />
                </div>
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file"
                           name="images"
                           accept="image/*" />
                </div>
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file"
                           name="images"
                           accept="image/*" />
                </div>
                <div class="upload-box">
                    <i class="fa-solid fa-cloud-arrow-up fa-2x"></i>
                    <span>이미지 업로드</span>
                    <input type="file"
                           name="images"
                           accept="image/*" />
                </div>
            </div>
            <div class="form-group tag-group">
                <label for="tagInput">보여질 태그 :</label>
                <input type="text"
                       id="tagInput"
                       name="tags"
                       placeholder="#보여질 태그를 등록하세요" />
            </div>
        </section>

        <!-- 오른쪽 섹션: 자기소개 -->
        <section class="roommate-right">
            <button type="button" class="intro-btn">자기 소개</button>
            <textarea id="introTextarea"
                      name="introduction"
                      placeholder="소개글 시작"></textarea>
        </section>
    </form>
</main>

<div id="customAlertOverlay"
     class="modal-overlay"
     style="display: none;">
    <div class="modal">
        <div class="modal-title">
            <i class="fa-solid fa-circle-exclamation fa-shake fa-lg"
               style="color: #3399ff;"></i>
            <h2>살며시</h2>
        </div>
        <p id="customAlertMessage">메시지 내용</p>
        <div class="modal-buttons" style="text-align: right;">
            <button class="deactivate-btn"
                    onclick="closeCustomAlert()">확인</button>
        </div>
    </div>
</div>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>
<script>
    const userName = "<%= ssUserName %>";
</script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
