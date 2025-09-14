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
        }

        /* FullCalendar 스타일 */
        #calendar {
            --fc-border-color: #eef2f6;
            --fc-today-bg-color: rgba(51, 153, 255, 0.1);
            --fc-button-bg-color: #3399ff;
            --fc-button-border-color: #3399ff;
        }

        .fc .fc-event {
            cursor: pointer;
        }

        /* 모달 스타일 */
        .modal-overlay {
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
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<%--사이드바--%>
<%@ include file="../includes/sideBar.jsp" %>

<main class="sidebar-main-content">
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
</main>

<!-- 커스텀 알림창 -->
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

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek,listWeek'},

            // [핵심 수정] events를 URL이 아닌 함수로 변경하여, 서버 데이터를 FullCalendar 형식으로 변환합니다.
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

        calendar.render();

        $('#eventForm').on('submit', function (e) {
            e.preventDefault();
            const eventData = {
                title: $('#eventTitleInput').val(),
                scheduleDt: $('#eventStartDate').val(), // DTO에 맞는 'scheduleDt'로 전송
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
    if (ssUserName == null) {
        ssUserName = "";
    }
%>
<script>
    const userName = "<%= ssUserName %>";
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>

</body>
</html>
