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
            background-color: white !important;
            border: 2px solid #3399ff !important;
            box-sizing: border-box;
            border-radius: 4px;
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
            height: 100%;
        }

        #eventMemoInput {
            font-family: inherit; /* 폰트 통일 */
            resize: none;
            margin-top: 20px;
        }

        #eventTimeInput {
            font-family: inherit;
        }

        .modal-buttons {
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

    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const timeWrapper = document.getElementById('timeInputWrapper');
            const timeInput = document.getElementById('eventTimeInput');

            timeWrapper.addEventListener('click', function () {
                // 브라우저에서 지원할 경우 강제로 picker 띄우기
                if (typeof timeInput.showPicker === "function") {
                    timeInput.showPicker();
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
                <img src="<%= session.getAttribute("SS_USER_PROFILE_IMG_URL") != null ? session.getAttribute("SS_USER_PROFILE_IMG_URL") : "/images/noimg.png" %>"
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
                <button class="confirm-btn" id="addNewEventBtn">새 일정 등록하기</button>
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
                <div class="modal-buttons">
                    <button type="button" id="deleteEventBtn" style="display:none;">삭제</button>
                    <button type="button" onclick="cancelRegister()">취소</button>
                    <button type="submit">저장</button>
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
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const calendarEl = document.getElementById('calendar');
        let f = document.getElementById("eventForm");

        $("#eventLocationInput").on("click", function () {
            kakaoPost(f);
        });

        const calendar = new FullCalendar.Calendar(calendarEl, {
            locale: 'ko',
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: ' ',
                center: 'prev title next',
                right: 'dayGridMonth,listWeek'
            },
            displayEventTime: false,
            height: '100%',
            fixedWeekCount: false,
            dayMaxEvents: true,
            // buttonText: {
            //     today: '오늘'
            // },
            datesSet: function () {
                $('.fc-dayGridMonth-button').html('<i class="fa-solid fa-calendar-days"></i>');
                $('.fc-listWeek-button').html('<i class="fa-solid fa-list-ul"></i>');
            },
            events: function (fetchInfo, successCallback, failureCallback) {
                $.ajax({
                    url: '/schedule/api/events',
                    type: 'GET',
                    dataType: 'json',
                    success: function (data) {
                        const transformedEvents = data.map(function (event) {
                            // 자기 자신의 ID와 participantId가 같으면 개인 일정
                            const isPersonal = event.participantId === myUserId;

                            return {
                                id: event.scheduleId,
                                title: event.title,
                                start: event.scheduleDt,
                                end: event.end,
                                backgroundColor: isPersonal ? '#ff9933' : '#3399ff',  // 개인: 주황, 상대방: 파랑
                                borderColor: isPersonal ? '#ff9933' : '#3399ff',
                                textColor: '#fff',
                                extendedProps: {
                                    location: event.location,
                                    memo: event.memo,
                                    creatorId: event.creatorId,
                                    participantId: event.participantId,
                                    originalEvent: event
                                }
                            };
                        });
                        successCallback(transformedEvents);
                    },
                    error: function (error) {
                        console.error("일정 로딩 중 에러 발생", error);
                        failureCallback(error);
                    }
                });
            },
            editable: true,
            selectable: true,

            select: function (info) {
                $('#step1').hide();
                $('#step2').show();
                $('#eventForm')[0].reset();
                $('#eventStartDate').val(info.startStr);
                $('#deleteEventBtn').hide();
            },

            eventClick: function (info) {
                const props = info.event.extendedProps;
                const original = props.originalEvent;

                $('#eventTitleDisplay').text(original.title);

                const eventDate = new Date(original.scheduleDt);
                const options = {year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'};
                $('#eventTimeDisplay').text(new Intl.DateTimeFormat('ko-KR', options).format(eventDate));
                $('#eventTimeMeta').show();

                if (original.location) {
                    $('#eventLocationDisplay').text(original.location);
                    $('#eventLocationMeta').show();
                } else {
                    $('#eventLocationMeta').hide();
                }

                $('#eventDescriptionDisplay').text(original.memo || '등록된 메모가 없습니다.');

                $('#step2').hide();
                $('#step1').show();
            }
        });

        calendar.render();

        $('#addNewEventBtn').on('click', function () {
            $('#step1').hide();
            $('#step2').show();
            $('#eventForm')[0].reset();
            const today = new Date().toISOString().split('T')[0];
            $('#eventStartDate').val(today);
            $('#deleteEventBtn').hide();
        });

        $(document).on("click", function (e) { // 나중에 추가
            const $target = $(e.target);

            // 클릭한 요소가 input이나 로그인 버튼이 아니면 에러 스타일 제거
            if (
                !$target.is("#eventTitleInput") &&
                !$target.is("#eventTimeInput") &&
                !$target.is("#eventLocationInput")
            ) {
                $(".login-input").removeClass("input-error");
                $("#loginErrorMessage").removeClass("visible");
            }
        });

        $('#eventForm').on('submit', function (e) {
            e.preventDefault();

            const title = $('#eventTitleInput').val().trim();
            const time = $('#timePicker').val().trim();
            const participantId = targetUserId;
            const location = $('#eventLocationInput').val().trim();

            $(".login-input").removeClass("input-error");
            $("#titleErrorMessage").removeClass("visible").text("");
            $("#timeErrorMessage").removeClass("visible").text("");
            $("#locationErrorMessage").removeClass("visible").text("");

            if (!title) {
                $("#eventTitleInput").addClass("input-error");
                $("#titleErrorMessage")
                    .text("일정 제목을 입력하세요.")
                    .addClass("visible");

                // 2초 후 메시지 자동 숨김
                setTimeout(function () {
                    $("#titleErrorMessage").removeClass("visible");
                }, 2000);

                $("#eventTitleInput").focus();
                return;
            }

            if (!time) {
                $("#timePicker").addClass("input-error");
                $("#timeErrorMessage")
                    .text("시간을 입력하세요.")
                    .addClass("visible");

                // 2초 후 메시지 자동 숨김
                setTimeout(function () {
                    $("#timeErrorMessage").removeClass("visible");
                }, 2000);

                $("#timePicker").focus();
                return;
            }

            if (!location) {
                $("#eventLocationInput").addClass("input-error");
                $("#locationErrorMessage")
                    .text("위치 정보를 입력하세요.")
                    .addClass("visible");

                // 2초 후 메시지 자동 숨김
                setTimeout(function () {
                    $("#locationErrorMessage").removeClass("visible");
                }, 2000);

                $("#eventLocationInput").focus();
                return;
            }

            let startDate = $('#eventStartDate').val(); // 예: '2025-09-15'
            if (startDate && time) {
                startDate += 'T' + time + ':00'; // => '2025-09-15T14:30:00'
            }

            const eventData = {
                title: title,
                scheduleDt: startDate,
                participantId: participantId,
                location: $('#eventLocationInput').val(),
                memo: $('#eventMemoInput').val()
            };

            $.ajax({
                url: '/schedule/api/events',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(eventData),
                success: function () {
                    $('#step2').hide();
                    $('#step1').show();
                    calendar.refetchEvents();
                },
                error: function () {
                    alert('일정 저장에 실패했습니다.');
                }
            });
        });

        window.cancelRegister = function () {
            $('#step2').hide();
            $('#step1').show();
        }

        function kakaoPost(f) {
            new daum.Postcode({
                oncomplete: function (data) {
                    let address = data.address;
                    let zonecode = data.zonecode;
                    f.eventLocationInput.value = "(" + zonecode + ")" + address;
                }
            }).open();
        }
    });

    flatpickr("#timePicker", {
        enableTime: true,
        noCalendar: true,
        dateFormat: "h:i", // 12시간제 (오전/오후)
        time_24hr: false,    // true면 24시간제
        minuteIncrement: 5   // 분 단위 간격
    });

</script>

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

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>
</body>
</html>
