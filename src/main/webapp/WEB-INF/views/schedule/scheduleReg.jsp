<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 스케쥴</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        /* --- schedule.css --- */

        /* 전체 페이지 배경 */
        body {
            background-color: #f4f7f9;
        }

        /* 메인 컨테이너 */
        .schedule-container {
            display: flex;
            width: 1500px;
            height: 700px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.07);
            overflow: hidden;
        }

        /* 왼쪽: 일정 정보 패널 */
        .schedule-details {
            width: 320px;
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
        }
        .event-description {
            font-size: 0.95rem;
            line-height: 1.6;
            color: #333;
            flex-grow: 1; /* 남은 공간을 모두 차지 */
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
        .confirm-btn:disabled {
            background-color: #dbe7f5;
            cursor: not-allowed;
        }
        .confirm-btn:not(:disabled):hover {
            background-color: #1c84ff;
        }

        /* 오른쪽: 날짜 및 시간 선택 */
        .schedule-picker {
            flex: 1;
            padding: 32px;
            display: flex;
            flex-direction: column;
        }
        .picker-header h3 {
            margin: 0;
            font-size: 1.25rem;
        }
        .selected-date-display {
            color: #555;
            margin-top: 4px;
            font-size: 0.9rem;
            min-height: 1.2em; /* 높이 고정 */
        }
        .calendar-wrapper {
            margin-top: 24px;
            display: flex;
            gap: 24px;
        }

        /* 달력 */
        .calendar-container {
            width: 800px;
        }
        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }
        .month-display {
            font-weight: 600;
        }
        .nav-btn {
            background: none;
            border: none;
            cursor: pointer;
            padding: 8px;
            color: #888;
        }
        .calendar-weekdays, .calendar-dates {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            text-align: center;
        }
        .calendar-weekdays {
            font-size: 0.8rem;
            color: #888;
            margin-bottom: 8px;
        }
        .calendar-dates .date-item {
            padding: 8px;
            background: none;
            border: none;
            border-radius: 50%;
            width: 36px;
            height: 36px;
            margin: 2px auto;
            cursor: pointer;
            transition: background-color 0.2s, color 0.2s;
        }
        .calendar-dates .date-item:not(.disabled):hover {
            background-color: #eef2f6;
        }
        .calendar-dates .date-item.selected {
            background-color: #3399ff;
            color: white;
        }
        .calendar-dates .date-item.disabled {
            color: #ccc;
            cursor: not-allowed;
        }

        /* 시간 슬롯 */
        .timeslot-container {
            flex: 1;
            overflow-y: auto;
            max-height: 300px; /* 스크롤 생성을 위한 최대 높이 */
        }
        .timeslot-placeholder {
            color: #aaa;
            text-align: center;
            margin-top: 40px;
        }
        .time-slot {
            display: block;
            width: 100%;
            padding: 12px;
            margin-bottom: 8px;
            border: 1px solid #ddd;
            border-radius: 6px;
            background-color: #fff;
            cursor: pointer;
            text-align: center;
            font-size: 0.95rem;
            transition: border-color 0.2s, color 0.2s;
        }
        .time-slot:hover {
            border-color: #3399ff;
            color: #3399ff;
        }
        .time-slot.selected {
            background-color: #3399ff;
            color: white;
            border-color: #3399ff;
        }

        /* 반응형: 화면이 좁아지면 세로로 쌓임 */
        @media (max-width: 992px) {
            .schedule-container, .calendar-wrapper {
                flex-direction: column;
            }
            .schedule-details {
                width: auto;
                border-right: none;
                border-bottom: 1px solid #eef2f6;
            }
            .calendar-container {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<%-- 여기에 코드 작성 --%>
<div class="schedule-page-wrapper">
    <main class="schedule-container">

        <%-- 왼쪽: 일정 정보 패널 --%>
        <aside class="schedule-details">
            <div class="host-info">
                <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") %>" alt="주최자 프로필 사진" class="host-profile-pic">
                <div class="host-name"><%= session.getAttribute("SS_USER_NAME") %>님의 일정</div>
            </div>
            <div class="event-title">
                <h2>룸메이트 인터뷰 요청</h2>
            </div>
            <ul class="event-meta">
                <li>
                    <i class="fa-regular fa-clock"></i>
                    <span>30분</span>
                </li>
                <li>
                    <i class="fa-solid fa-location-dot"></i>
                    <span>서울 강남구 테헤란로 507</span>
                </li>
            </ul>
            <p class="event-description">
                안녕하세요. 편하게 가능한 시간을 선택하여 알려주세요. 감사합니다 :)
            </p>

            <div class="schedule-footer">
                <button class="confirm-btn" disabled>시간을 선택하세요</button>
            </div>
        </aside>

        <%-- 오른쪽: 날짜 및 시간 선택 --%>
        <section class="schedule-picker">
            <div class="picker-header">
                <h3>날짜를 선택해주세요.</h3>
                <div class="selected-date-display" id="selectedDateDisplay"></div>
            </div>

            <div class="calendar-wrapper">
                <%-- 달력 --%>
                <div class="calendar-container">
                    <div class="calendar-header">
                        <button class="nav-btn" id="prevMonthBtn"><i class="fa-solid fa-chevron-left"></i></button>
                        <div class="month-display" id="monthDisplay">2025년 9월</div>
                        <button class="nav-btn" id="nextMonthBtn"><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                    <div class="calendar-weekdays">
                        <div>일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div>토</div>
                    </div>
                    <div class="calendar-dates" id="calendarDates">
                        <%-- 날짜는 JavaScript로 동적으로 채워집니다. --%>
                    </div>
                </div>

                <%-- 시간 슬롯 --%>
                <div class="timeslot-container" id="timeslotContainer">
                    <%-- 시간은 날짜 선택 시 JavaScript로 동적으로 채워집니다. --%>
                    <div class="timeslot-placeholder">날짜를 먼저 선택해주세요.</div>
                </div>
            </div>
        </section>

    </main>
</div>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp" %>
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
