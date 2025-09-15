<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 일정 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <!-- FullCalendar 라이브러리 -->
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js'></script>

    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

    <style>
        /* 페이지 전체 배경 */
        body {
            background-image: url("../images/test1.png");
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

        /* 모달 스타일 */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal {
            width: 450px;
        }

        .form-group {
            margin-bottom: 15px;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }

        .form-group input, .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .form-group textarea {
            min-height: 80px;
            resize: vertical;
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
    </style>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main class="schedule-container">
    <%-- 왼쪽: 일정 정보 패널 --%>
    <aside class="schedule-info">
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

    <%-- 오른쪽: 캘린더 --%>
    <section class="schedule-picker">
        <div id='calendar'></div>
    </section>
</main>

<!-- 일정 추가/수정/삭제를 위한 모달 -->
<div id="eventModal" class="modal-overlay" style="display:none;">
    <div class="modal">
        <h3 id="modalTitle">새 일정 추가</h3>
        <form id="eventForm">
            <input type="hidden" id="eventScheduleId">
            <input type="hidden" id="eventStartDate">
            <div class="form-group">
                <label for="eventTitleInput">일정 제목</label>
                <input type="text" id="eventTitleInput" required>
            </div>
            <div class="form-group">
                <label for="eventTimeInput">시간</label>
                <input type="time" id="eventTimeInput" required>
            </div>
            <div class="form-group">
                <label for="eventParticipantInput">상대방 ID</label>
                <input type="text" id="eventParticipantInput" required>
            </div>
            <div class="form-group">
                <label for="eventLocationInput">위치</label>
                <input type="text" id="eventLocationInput">
            </div>
            <div class="form-group">
                <label for="eventMemoInput">메모</label>
                <textarea id="eventMemoInput"></textarea>
            </div>
            <div class="modal-buttons">
                <button type="button" id="deleteEventBtn" style="display:none;">삭제</button>
                <button type="button" onclick="$('#eventModal').hide()">취소</button>
                <button type="submit">저장</button>
            </div>
        </form>
    </div>
</div>

<%@ include file="../includes/customModal.jsp" %>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const calendarEl = document.getElementById('calendar');
        const eventTitleDisplay = document.getElementById('eventTitleDisplay');
        const eventTimeMeta = document.getElementById('eventTimeMeta');
        const eventTimeDisplay = document.getElementById('eventTimeDisplay');
        const eventLocationMeta = document.getElementById('eventLocationMeta');
        const eventLocationDisplay = document.getElementById('eventLocationDisplay');
        const eventDescriptionDisplay = document.getElementById('eventDescriptionDisplay');

        let f = document.getElementById("eventForm");

        $("#eventLocationInput").on("click", function () {
            kakaoPost(f);
        });

        const calendar = new FullCalendar.Calendar(calendarEl, {
            locale: 'ko',
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'today',
                center: 'prev title next',
                right: 'dayGridMonth,listWeek'
            },
            displayEventTime: false,
            height: '100%',
            fixedWeekCount: false,  // 해당 월에 필요한 주(week)만 표시
            dayMaxEvents: true,
            buttonText: {
                today: '오늘',
                dayGridMonth: '달력',
                listWeek: '일정'
            },

            // events를 URL이 아닌 함수로 변경하여, 서버 데이터를 FullCalendar 형식으로 변환합니다.
            events: function (fetchInfo, successCallback, failureCallback) {
                $.ajax({
                    url: '/schedule/api/events',
                    type: 'GET',
                    dataType: 'json',
                    success: function (data) {
                        // 서버에서 받은 데이터를 FullCalendar가 이해하는 형식으로 가공(map)
                        const transformedEvents = data.map(function (event) {
                            return {
                                id: event.scheduleId,    // scheduleId는 FullCalendar의 id로
                                title: event.title,
                                start: event.scheduleDt, // scheduleDt는 start로
                                end: event.end,
                                extendedProps: { // 나머지 데이터는 extendedProps에 보관
                                    location: event.location,
                                    memo: event.memo,
                                    creatorId: event.creatorId,
                                    participantId: event.participantId,
                                    // 원본 데이터도 보관하여 eventClick에서 사용
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
                $('#modalTitle').text('새 일정 추가');
                $('#eventForm')[0].reset();
                $('#eventStartDate').val(info.startStr);
                $('#deleteEventBtn').hide();
                $('#eventModal').show();
            },

            eventClick: function (info) {
                const props = info.event.extendedProps;
                const original = props.originalEvent; // 원본 데이터 사용

                eventTitleDisplay.textContent = original.title;

                const eventDate = new Date(original.scheduleDt);
                const options = {year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'};
                eventTimeDisplay.textContent = new Intl.DateTimeFormat('ko-KR', options).format(eventDate);
                eventTimeMeta.style.display = 'flex';

                if (original.location) {
                    eventLocationDisplay.textContent = original.location;
                    eventLocationMeta.style.display = 'flex';
                } else {
                    eventLocationMeta.style.display = 'none';
                }

                if (original.memo) {
                    eventDescriptionDisplay.textContent = original.memo;
                } else {
                    eventDescriptionDisplay.textContent = '등록된 메모가 없습니다.';
                }
            }
        });

        // 카카오 우편번호 API
        function kakaoPost(f) {
            new daum.Postcode({
                oncomplete: function (data) {
                    let address = data.address;
                    let zonecode = data.zonecode;
                    f.eventLocationInput.value = "(" + zonecode + ")" + address;
                }
            }).open();
        }

        calendar.render();

        $('#eventForm').on('submit', function (e) {
            e.preventDefault();

            const title = $('#eventTitleInput').val().trim();
            const participantId = $('#eventParticipantInput').val().trim();

            if (!title) {
                alert('일정 제목을 입력해주세요.');
                $('#eventTitle').focus();
                return; // 전송 중단
            }
            if (!participantId) {
                alert('상대방 ID를 입력해주세요.');
                $('#eventParticipant').focus();
                return; // 전송 중단
            }

            let startDate = $('#eventStartDate').val();
            // 날짜만 있는 경우 (YYYY-MM-DD), 시간을 00:00:00으로 추가
            if (startDate && startDate.length === 10) {
                startDate += 'T00:00:00';
            }

            const eventData = {
                title: $('#eventTitleInput').val(),
                scheduleDt: startDate,
                participantId: $('#eventParticipantInput').val(),
                location: $('#eventLocationInput').val(),
                memo: $('#eventMemoInput').val()
            };

            $.ajax({
                url: '/schedule/api/events',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(eventData),
                success: function () {
                    $('#eventModal').hide();
                    calendar.refetchEvents();
                },
                error: function () {
                    alert('일정 저장에 실패했습니다.');
                }
            });
        });

        $('#addNewEventBtn').on('click', function () {
            $('#modalTitle').text('새 일정 추가');
            $('#eventForm')[0].reset();
            const today = new Date().toISOString().split('T')[0];
            $('#eventStartDate').val(today);
            $('#deleteEventBtn').hide();
            $('#eventModal').show();
        });
    });
</script>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) ssUserName = "";
%>
<script>
    const userName = "<%= ssUserName %>";
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>

