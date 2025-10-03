<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 일정 확인</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sideBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <!-- FullCalendar 라이브러리 -->
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js'></script>

    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

    <!-- CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <!-- Optional 테마 (예: Material Blue) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">

    <!-- JS -->
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

    <style>

        body {
            background: linear-gradient(to right, white, #f9f9f9);
        }

        /* 메인 컨테이너 */
        .schedule-container {
            display: flex;
            max-width: 1200px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.07);
            overflow: hidden;
            min-height: 700px;
        }

        /* 왼쪽: 일정 정보 패널 */
        .schedule-info {
            width: 350px;
            padding: 32px;
            border-right: 1px solid #eef2f6;
            display: flex;
            flex-direction: column;
        }

        .host-info {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }

        .host-profile-pic {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }

        .host-name {
            font-weight: 500;
            color: #555;
        }

        .event-title h2 {
            font-size: 1.5rem;
            margin: 0 0 16px 0;
            color: #111;
        }

        .event-meta {
            list-style: none;
            padding: 0;
            margin: 0 0 24px 0;
            color: #555;
            font-size: 0.9rem;
        }

        .event-meta li {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }

        .event-meta i {
            color: #888;
            width: 16px;
            text-align: center;
        }

        .event-description {
            font-size: 0.95rem;
            line-height: 1.6;
            color: #333;
            flex-grow: 1;
        }

        .schedule-footer {
            margin-top: auto;
        }

        .confirm-btn {
            width: 100%;
            padding: 14px;
            background-color: #3399ff;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        /* 오른쪽: 날짜 선택 */
        .schedule-picker {
            flex: 1;
            padding: 32px;
            display: flex;
        }

        /* FullCalendar 스타일 */
        #calendar {
            flex-grow: 1;
            --fc-border-color: #eef2f6;
            --fc-today-bg-color: rgba(51, 153, 255, 0.1);
            --fc-button-bg-color: #3399ff;
            --fc-button-border-color: #3399ff;
        }

        .fc .fc-event {
            cursor: pointer;
        }

        /* FullCalendar 툴바 수평 정렬을 위한 스타일 */
        .fc .fc-toolbar.fc-header-toolbar {
            display: flex;
            align-items: center; /* 세로 중앙 정렬 */
            gap: 1em; /* 각 영역(left, center, right) 사이의 최소 간격 */
        }

        .fc .fc-toolbar-chunk {
            display: flex;
            align-items: center;
            gap: 0.5em; /* 버튼들 사이의 간격 */
        }

        /* 중앙 영역(제목, 화살표)이 남은 공간을 모두 차지하도록 설정 */
        .fc .fc-toolbar-chunk:nth-child(2) {
            flex-grow: 1; /* 남은 공간을 모두 차지 */
            justify-content: center; /* 내부 요소들을 중앙에 배치 */

        }

        /* 캘린더의 날짜 숫자 크기를 줄입니다. */
        .fc .fc-daygrid-day-number {
            font-size: 0.8em; /* 기본 크기(1em)보다 작게 설정 */
            padding: 4px;
        }

        /* 토요일(sat) 헤더 및 날짜 색상을 파란색으로 변경 */
        .fc .fc-col-header-cell.fc-day-sat a,
        .fc .fc-day-sat .fc-daygrid-day-number {
            color: #3399ff !important;
        }

        /* 일요일(sun) 헤더 및 날짜 색상을 빨간색으로 변경 */
        .fc .fc-col-header-cell.fc-day-sun a,
        .fc .fc-day-sun .fc-daygrid-day-number {
            color: #dc3545 !important;
        }

        /* 이전/다음 화살표 버튼 스타일 초기화 */
        .fc .fc-prev-button,
        .fc .fc-next-button {
            background: none !important;
            border: none !important;
            box-shadow: none !important;
            color: #333 !important; /* 화살표 아이콘 색상 */
        }

        .fc .fc-toolbar-chunk:first-child .fc-button-primary {
            visibility: hidden;
            pointer-events: none;
            background-color: transparent !important;
            border-color: transparent !important;
            color: transparent !important;
            box-shadow: none !important;
        }

        .fc .fc-day-today {
            box-sizing: border-box !important;
            border: 1px solid transparent; /* 기존 테두리 공간 유지를 위해 투명 처리 */
            box-shadow: 0 0 0 2px #3399ff inset !important; /* 테두리 효과를 안쪽 그림자로 대체 */
            border-radius: 4px;
            background-color: white !important;
            z-index: 1;
            position: relative;
        }

        .fc .fc-scrollgrid {
            padding-right: 2px;
        }

        .fc .fc-daygrid-day.fc-day-today:last-child {
            padding-right: 2px;
        }

        .fc-day-sat.fc-day-today {
            margin-right: 2px;
        }

        /* 날짜 셀 내 "오늘" 텍스트 표시용 */
        .fc .fc-day-today {
            position: relative;
        }

        /* 왼쪽 상단에 "오늘" 표시 */
        .fc .fc-day-today::before {
            content: '오늘';
            position: absolute;
            top: 4px;
            left: 6px;
            font-size: 10px;
            color: #888;
            font-weight: 500;
        }

        .fc-listWeek-view .fc-day-today::before,
        .fc-listDay-view .fc-day-today::before {
            content: none !important;
        }

        .fc-listWeek-view .fc-day-today,
        .fc-listDay-view .fc-day-today {
            border: none !important;
        }

        /* 요일(header) 배경색 변경 */
        .fc .fc-col-header {
            background-color: #f0f4ff;
        }

        /* FullCalendar 일정 텍스트 굵기 줄이기 */
        .fc-event-title {
            font-weight: 500 !important; /* 일반 굵기 */
        }

        .form-group {
            margin-bottom: 15px;
            text-align: left;
            column-gap: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }

        .form-group input, .form-group textarea {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
        }

        /* 반응형 */
        @media (max-width: 1200px) {
            .schedule-container {
                flex-direction: column;
            }

            .schedule-info {
                width: auto;
                border-right: none;
                border-bottom: 1px solid #eef2f6;
            }
        }

        .top-buttons {
            position: absolute;
            width: 65px;
            height: 65px;
            border-radius: 50%;
            left: 100px;
            top: 150px;
            z-index: 10;
            cursor: pointer;
        }

        #step2 {
            display: none;
            flex-direction: column;
            justify-content: space-between;
        }

        #step2 form {
            display: flex;
            flex-direction: column;
            height: 500px;
        }

        #eventMemoInput {
            font-family: inherit; /* 폰트 통일 */
            resize: none;
            margin-top: 20px;
        }

        #eventTimeInput {
            font-family: inherit;
        }

        .form-group input {
            width: 100%;
            /*padding: 12px;*/
            /*margin: 8px 0;*/
            border: none;
            border-bottom: 1px solid #ddd;
            font-size: 14px;
            outline: none;
            /*box-sizing: border-box;*/
        }

        #eventForm > div:first-of-type {
            margin-top: 20px;
        }

        .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            min-height: 150px;
            resize: vertical;
        }

        #eventMemoInput:focus {
            border-color: #3399ff;
            outline: none;
            box-shadow: 0 0 0 2px rgba(51, 153, 255, 0.2);
        }

        .form-group input:focus {
            border-color: #3399ff;
            outline: none;
        }

        #titleErrorMessage,
        #timeErrorMessage,
        #locationErrorMessage {
            color: #3399ff;
            font-size: 14px;
            text-align: left; /* 왼쪽 정렬 */
            height: 3px; /* 고정 높이로 레이아웃 안정 */
            padding-left: 5px;
            visibility: hidden; /* 기본은 숨김, 자리 차지는 유지 */
            margin-bottom: 20px;
        }

        #locationErrorMessage.visible,
        #timeErrorMessage.visible,
        #titleErrorMessage.visible {
            visibility: visible; /* 메시지가 있을 때 표시 */
        }

        .input-with-icon {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-with-icon i {
            position: absolute;
            left: 10px;
            font-size: 16px;
            color: #888;
            pointer-events: none;
            top: 50%;
            transform: translateY(-50%);
            height: 100%;
            display: flex;
            align-items: center;
        }

        .input-with-icon input {
            padding-left: 36px;
            height: 40px;
            font-size: 14px;
            line-height: 1.4;
            box-sizing: border-box;
            border: none;
            border-bottom: 1px solid #ddd;
            outline: none;
        }

        /* input[type="time"] 추가 스타일 */
        .input-with-icon input[type="time"] {
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            height: 40px;
            padding-left: 36px;
        }

        /* flatpickr 팝업 크기를 input과 맞춤 */
        .flatpickr-calendar {
            width: 285px;
        }

        /* 시간 선택 부분 정리 */
        .flatpickr-time {
            display: flex;
            justify-content: center; /* 가운데 정렬 */
            gap: 6px; /* 시/분/AMPM 간격 */
        }

        .schedule-modal-buttons {
            margin-top: 14px;
        }

        .schedule-btn,
        .btn-register,
        .btn-edit {
            display: flex;
            width: 100%;
            padding: 14px;
            background-color: #3399ff;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
            justify-content: center;
            margin-top: 25px;
        }

        /* 이벤트가 없을 때 메시지 배경 흰색으로 변경 */
        .fc-list-empty {
            background-color: white !important;
            color: #555;
            padding: 20px;
            text-align: center;
            font-size: 1rem;
        }

        .btn-update {
            display: flex;
            width: 100%;
            padding: 14px;
            background-color: #3399ff;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
            justify-content: center;
            margin-top: 0; !important;
            margin-bottom: 5px;
        }

        #deleteEventBtn {
            display: none;
            width: 100%;
            padding: 14px;
            background-color: #c2c2c2;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
            margin-bottom: 15px;
        }


    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const timeWrapper = document.getElementById('timeInputWrapper');
            const timeInput = document.getElementById('timePicker');

            timeWrapper.addEventListener('click', function () {
                // flatpickr 인스턴스가 연결되어 있으면 open() 호출
                if (timeInput._flatpickr) {
                    timeInput._flatpickr.open();
                } else {
                    timeInput.focus();
                }
            });
        });
    </script>
</head>
<body>
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<%--사이드바--%>
<%@ include file="../includes/sideBar.jsp" %>

<main class="sidebar-main-content">

    <main class="schedule-container">
        <%-- 왼쪽: 일정 정보 패널 --%>
        <aside id="step1" class="schedule-info">
            <div class="host-info">
                <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") != null ? session.getAttribute("SS_USER_PROFILE_IMG_URL") : "/images/withdraw-profile-img.png" %>"
                     alt="프로필 사진" class="host-profile-pic">
                <div class="host-name" id="hostName"><%= session.getAttribute("SS_USER_NAME")%>님의 일정</div>
            </div>
            <div class="event-title">
                <h2 id="eventTitleDisplay">일정을 선택해주세요</h2>
            </div>
            <ul class="event-meta">
                <li id="eventTimeMeta" style="display: none;"><i class="fa-regular fa-clock"></i><span
                        id="eventTimeDisplay"></span></li>
                <li id="eventLocationMeta" style="display: none;"><i class="fa-solid fa-location-dot"></i><span
                        id="eventLocationDisplay"></span></li>
            </ul>
            <p class="event-description" id="eventDescriptionDisplay">
                달력에서 등록된 일정을 클릭하여 상세 내용을 확인하거나, 비어있는 날짜를 클릭하여 새 일정을 추가할 수 있습니다.
            </p>
            <div class="schedule-footer">
                <button type="button" class="btn-event-action btn-add" style="display:none;">새 일정 등록하기</button>
            </div>
        </aside>


        <aside id="step2" class="schedule-info">

            <div class="host-info">
                <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") != null ? session.getAttribute("SS_USER_PROFILE_IMG_URL") : "/images/noimg.png" %>"
                     alt="프로필 사진" class="host-profile-pic">
                <div class="host-name"><%= session.getAttribute("SS_USER_NAME")%>님의 일정</div>
            </div>

            <div class="event-title">
                <h2 id="regTitleDisplay">일정을 등록하세요</h2>
            </div>
            <form id="eventForm">
                <input type="hidden" id="eventScheduleId">
                <input type="hidden" id="eventStartDate">
                <div class="form-group input-with-icon">
                    <i class="fa-solid fa-bars" style="color: #1c407d;"></i>
                    <input type="text" id="eventTitleInput" class="login-input" placeholder="일정 제목">
                </div>
                <div id="titleErrorMessage" class="error-message"></div>
                <label class="form-group input-with-icon" id="timeInputWrapper">
                    <i class="fa-solid fa-clock" style="color: #1c407d;"></i>
                    <input type="text" id="timePicker" placeholder="시간을 선택하세요" class="form-control"/>
                </label>
                <div id="timeErrorMessage" class="error-message"></div>
                <div class="form-group input-with-icon">
                    <i class="fa-solid fa-location-dot" style="color: #1c407d;"></i>
                    <input type="text" placeholder="위치" id="eventLocationInput" class="login-input">
                </div>
                <div id="locationErrorMessage" class="error-message"></div>
                <div class="form-group">
                    <textarea placeholder="메모" id="eventMemoInput"></textarea>
                </div>
                <div class="schedule-modal-buttons">
                    <button type="submit" class="schedule-btn btn-register">일정 등록하기</button>
                    <button type="button" id="deleteEventBtn" style="display:none;">삭제</button>
                </div>
            </form>
        </aside>

        <%-- 오른쪽: 캘린더 --%>
        <section class="schedule-picker">
            <div id='calendar'></div>
        </section>
    </main>
</main>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserId = (String) session.getAttribute("SS_USER_ID");
    if (ssUserId == null) ssUserId = "";
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) ssUserName = "";

    String targetUserId = request.getParameter("targetUserId");
    if (targetUserId == null || targetUserId.isEmpty()) {
        targetUserId = ssUserId; // 상대방 ID가 없으면 자신의 ID 사용
    }
%>

<script>
    const userName = "<%= ssUserName %>";
    const myUserId = "<%= ssUserId %>";
    const targetUserId = "<%= targetUserId %>";
</script>

<script src="${pageContext.request.contextPath}/js/scheduleCheck.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>
</body>
</html>
