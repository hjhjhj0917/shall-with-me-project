document.addEventListener('DOMContentLoaded', function () {
    const calendarEl = document.getElementById('calendar');
    const $eventForm = $("#eventForm");

    $("#eventLocationInput").on("click", function () {
        kakaoPost($eventForm[0]);
    });

    const calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'ko',
        initialView: 'dayGridMonth',
        noEventsText: '등록된 일정이 없습니다.',  // 이 부분만 추가!
        headerToolbar: {
            left: ' ',
            center: 'prev title next',
            right: 'dayGridMonth,listWeek'
        },
        displayEventTime: false,
        height: '100%',
        fixedWeekCount: false,
        dayMaxEvents: true,
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
                    const transformedEvents = data.map(event => {
                        const isPersonal = event.creatorId === event.participantId;
                        return {
                            id: event.scheduleId,
                            title: event.title,
                            start: event.scheduleDt,
                            end: event.end,
                            backgroundColor: isPersonal ? '#ff9933' : '#3399ff',
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
            $eventForm[0].reset();
            $('#eventStartDate').val(info.startStr);
            $('.btn-event-action')
                .text('새 일정 등록하기')
                .removeClass('btn-edit')
                .addClass('btn-add');
            $('#deleteEventBtn').hide();
        },

        eventClick: function (info) {
            const original = info.event.extendedProps.originalEvent;
            const isMyScreen = targetUserId === myUserId;
            const isMyOwnEvent = original.creatorId === myUserId && original.participantId === myUserId;

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

            if (isMyScreen && isMyOwnEvent) {
                $('.btn-event-action')
                    .text('일정 수정하기')
                    .removeClass('btn-add')
                    .addClass('btn-edit')
                    .show();
            } else {
                $('.btn-event-action')
                    .text('새 일정 등록하기')
                    .removeClass('btn-edit')
                    .addClass('btn-add')
                    .hide();
            }

            // 마지막 클릭한 이벤트 저장 (수정 시 사용)
            window.lastClickedEvent = info.event;

            $('#step2').hide();
            $('#step1').show();
        }
    });

    calendar.render();

    // 새 일정 등록/수정 버튼 공통 이벤트 (클래스 구분)
    $(document).on('click', '.btn-add', function () {
        $('#step1').hide();
        $('#step2').show();
        $eventForm[0].reset();
        const today = new Date().toISOString().split('T')[0];
        $('#eventStartDate').val(today);
        $('#deleteEventBtn').hide();

        $('.schedule-btn')
            .text('일정 등록하기')
            .removeClass('btn-update')
            .addClass('btn-register');
    });

    $(document).on('click', '.btn-edit', function () {
        $('#step1').hide();
        $('#step2').show();

        const selectedEvent = window.lastClickedEvent;
        if (!selectedEvent) return showCustomAlert("수정할 이벤트가 없습니다.");

        const original = selectedEvent.extendedProps.originalEvent;

        $('#eventScheduleId').val(original.scheduleId);
        $('#eventTitleInput').val(original.title);

        const dt = new Date(original.scheduleDt);
        const hours = dt.getHours().toString().padStart(2, '0');
        const minutes = dt.getMinutes().toString().padStart(2, '0');
        $('#timePicker').val(`${hours}:${minutes}`);

        $('#eventLocationInput').val(original.location || '');
        $('#eventMemoInput').val(original.memo || '');
        $('#eventStartDate').val(original.scheduleDt.split('T')[0]);

        $('.schedule-btn')
            .text('일정 수정하기')
            .removeClass('btn-register')
            .addClass('btn-update');

        $('#deleteEventBtn').show();
    });

    // 등록 및 수정 구분해서 처리
    $eventForm.on('submit', function (e) {
        e.preventDefault();

        const title = $('#eventTitleInput').val().trim();
        const time = $('#timePicker').val().trim();
        const location = $('#eventLocationInput').val().trim();

        $(".login-input").removeClass("input-error");
        $("#titleErrorMessage").removeClass("visible").text("");
        $("#timeErrorMessage").removeClass("visible").text("");
        $("#locationErrorMessage").removeClass("visible").text("");

        if (!title) {
            $("#eventTitleInput").addClass("input-error");
            $("#titleErrorMessage").text("일정 제목을 입력하세요.").addClass("visible");
            setTimeout(() => $("#titleErrorMessage").removeClass("visible"), 2000);
            $("#eventTitleInput").focus();
            return;
        }

        if (!time) {
            $("#timePicker").addClass("input-error");
            $("#timeErrorMessage").text("시간을 입력하세요.").addClass("visible");
            setTimeout(() => $("#timeErrorMessage").removeClass("visible"), 2000);
            $("#timePicker").focus();
            return;
        }

        if (!location) {
            $("#eventLocationInput").addClass("input-error");
            $("#locationErrorMessage").text("위치 정보를 입력하세요.").addClass("visible");
            setTimeout(() => $("#locationErrorMessage").removeClass("visible"), 2000);
            $("#eventLocationInput").focus();
            return;
        }

        let startDate = $('#eventStartDate').val(); // 예: '2025-09-15'
        if (startDate && time) {
            startDate += 'T' + time + ':00'; // => '2025-09-15T14:30:00'
        }

        const participantId = targetUserId;

        const eventData = {
            title: title,
            scheduleDt: startDate,
            participantId: participantId,
            location: location,
            memo: $('#eventMemoInput').val()
        };

        const isUpdate = $('.schedule-btn').hasClass('btn-update');
        let url = '/schedule/api/events';
        let method = 'POST';

        if (isUpdate) {
            url += `/${$('#eventScheduleId').val()}`; // PUT 주소 예시
            method = 'POST';
            eventData.scheduleId = $('#eventScheduleId').val();
        }

        $.ajax({
            url: url,
            type: method,
            contentType: 'application/json',
            data: JSON.stringify(eventData),
            success: function () {
                showCustomAlert(isUpdate ? '일정이 수정되었습니다.' : '일정이 저장되었습니다.');
                $('#step2').hide();
                $('#step1').show();
                calendar.refetchEvents();
            },
            error: function () {
                showCustomAlert(isUpdate ? '일정 수정에 실패했습니다.' : '일정 저장에 실패했습니다.');
            }
        });
    });

    // 삭제 버튼 이벤트
    $('#deleteEventBtn').on('click', function () {
        showCustomConfirm("일정을 삭제 하시겠습니까?", function () {
            const scheduleId = $('#eventScheduleId').val();
            if (!scheduleId) return showCustomAlert("삭제할 일정이 없습니다.");

            $.ajax({
                url: '/schedule/scheduleDelete',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({scheduleId: scheduleId}),
                success: function (msg) {
                    $('#step2').hide();
                    $('#step1').show();
                    calendar.refetchEvents();
                    showCustomAlert(msg);
                },
                error: function () {
                    showCustomAlert(msg);
                }
            });
        });

    });

    window.cancelRegister = function () {
        $('#step2').hide();
        $('#step1').show();
    };

    function kakaoPost(f) {
        new daum.Postcode({
            oncomplete: function (data) {
                let address = data.address;
                let zonecode = data.zonecode;
                f.eventLocationInput.value = "(" + zonecode + ") " + address;
            }
        }).open();
    }
});

flatpickr("#timePicker", {
    enableTime: true,
    noCalendar: true,
    dateFormat: "h:i",
    time_24hr: false,
    minuteIncrement: 5
});
