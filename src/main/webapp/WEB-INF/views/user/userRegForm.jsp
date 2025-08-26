<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>살며시|회원가입</title>
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="//code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <script src="//code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/register.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <script>
        $.datepicker.regional['ko'] = {
            closeText: '닫기',
            prevText: '이전달',
            nextText: '다음달',
            currentText: '오늘',
            monthNames: ['1월','2월','3월','4월','5월','6월',
                '7월','8월','9월','10월','11월','12월'],
            monthNamesShort: ['1월','2월','3월','4월','5월','6월',
                '7월','8월','9월','10월','11월','12월'],
            dayNames: ['일','월','화','수','목','금','토'],
            dayNamesShort: ['일','월','화','수','목','금','토'],
            dayNamesMin: ['일','월','화','수','목','금','토'],
            weekHeader: 'Wk',
            dateFormat: 'yy-mm-dd',
            firstDay: 0,
            isRTL: false,
            showMonthAfterYear: true,
            yearSuffix: '년'
        };
        $.datepicker.setDefaults($.datepicker.regional['ko']);

        $("#birth-datepicker").datepicker({
            changeMonth: true,
            changeYear: true,
            yearRange: "1900:2025",
            dateFormat: "yy-mm-dd",
            beforeShow: function(input, inst) {
                setTimeout(function() {
                    const $container = $('.input-container');
                    const offset = $container.offset();
                    const width = $container.outerWidth();
                    const height = $container.outerHeight();

                    const dpWidth = $(inst.dpDiv).outerWidth();
                    const dpHeight = $(inst.dpDiv).outerHeight();

                    const top = offset.top + (height / 2) - (dpHeight / 2);
                    const left = offset.left + (width / 2) - (dpWidth / 2);

                    $(inst.dpDiv).css({
                        position: 'absolute',
                        top: top + 'px',
                        left: left + 'px',
                        transform: 'none',
                        zIndex: 9999
                    });
                }, 0);
            }
        });
    </script>
    <style>
        body {
            background-image: url("../images/kpaas-background.png");
        }

            /* ✅ 등록 폼 컨테이너 */
        .register-form-wrapper {
            width: 1100px;
            margin: 0 auto;
            padding: 24px 32px;
            background-color: #FFFFFF;
            border-radius: 12px;
            border-top-right-radius: 0;
            box-shadow: -3px -3px 16px rgba(0, 0, 0, 0.1), 6px 5px 16px rgba(0, 0, 0, 0.27);
            position: relative;
            text-align: center;
            box-sizing: border-box;
            overflow: visible; /* 중요 */
        }
        /*/////////////////////////////////////////*/
        /* form-row 내부의 input과 버튼들을 유연하게 배치 */
        .form-row {
            display: flex;
            margin-top: 8px;
            gap: 10px;
            justify-content: center;
            align-items: center;
            height: 40px;
        }

        /* input이 버튼이 있을 때와 없을 때 모두 최대한 공간 활용하도록 */
        .form-row input[type="text"],
        .form-row input[type="email"],
        .form-row input[type="password"],
        .form-row input[type="number"] {
            flex: 1 1 auto;   /* flex-grow:1, flex-shrink:1, flex-basis:auto */
            min-width: 0;     /* 오버플로우 방지 */
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
        }

        /* 버튼은 내용 크기만큼만 */
        .form-row button.form-button {
            flex: 0 0 auto;  /* 크기 고정, 늘어나거나 줄어들지 않음 */
            height: 40px;
            padding: 0 12px;
            font-size: 14px;
            cursor: pointer;
            background-color: #3399ff;
            color: white;
            border: none;
            border-radius: 4px;
            white-space: nowrap;
        }

        /* birth-row 의 input들도 flex 사용 */
        .birth-row input {
            flex: 1 1 auto;
            min-width: 0;
            width: auto; /* width 고정하지 않음 */
            text-align: center;
        }

        /* input-container 너비는 그대로 유지 */
        .input-container {
            width: 500px; /* 필요한 너비 유지 */
            margin: 0 auto;
            box-sizing: border-box;
        }
/*///////////////////////////////////*/


        /* ✅ 버튼 스타일 고정 */
        .form-button {
            height: 40px;
            padding: 8px 12px;
            font-size: 14px;
            vertical-align: middle;
            cursor: pointer;
            background-color: #3399ff;
            color: white;
            border: none;
            border-radius: 4px;
            white-space: nowrap;
        }

        /* ✅ 버튼 hover 효과 */
        .form-button:hover {
            background-color: #2a80d4;
        }

        /* ✅ 생년월일 입력 줄 */
        .birth-row {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 12px;
        }

        /* ✅ 성별 선택 영역 */
        .gender-select {
            display: flex;
            justify-content: center;
            gap: 50px;
            margin: 16px 0;
        }

        /* ✅ 회원가입 버튼 */
        .submit-button {
            width: 100%;  /* 부모(.input-container) 너비에 맞게 꽉 채우기 */
            margin-top: 16px;
        }

        /* ✅ 탭이나 제목 여백 조절 */
        .register-tab, .prefer-tab, .profile-tab {
            margin-bottom: 12px;
        }

        .register-tab {
            position: absolute;
            top: 10.34%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #4da3ff;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;
            box-shadow: 2px 0px 10px rgba(0, 0, 0, 0.25);
            z-index: 2;
        }

        .prefer-tab {
            position: absolute;
            top: 30.5%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #91C4FB;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;
            box-shadow: 2px 0px 10px rgba(0, 0, 0, 0.25);
            z-index: 1;
        }

        .profile-tab {
            position: absolute;
            top: 51%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #B1B1B1;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;
            box-shadow: 2px 0px 10px rgba(0, 0, 0, 0.25);
        }

        /* 현재 활성화된 탭 스타일 */
        .active-tab {
            right: -39px;
            font-size: 20px !important;
            z-index: 3 !important;
        }

        /* 로그인 링크 */
        .signup-link {
            margin-top: 18px;
            font-size: 13px;
            text-align: center;
        }

        .signup-link a {
            color: #3399ff;
            text-decoration: none;
        }

        .error-message {
            color: #3399ff;
            font-size: 14px;
            text-align: left;          /* 왼쪽 정렬 */
            height: 5px;              /* 고정 높이로 레이아웃 안정 */
            padding-left: 275px;
            padding-bottom: 15px;
            visibility: hidden;        /* 기본은 숨김, 자리 차지는 유지 */
        }

        .error-message.visible {
            visibility: visible;       /* 메시지가 있을 때 표시 */
        }

        .register-input {
            border: 1px solid #ddd;
        }

        .register-input:focus {
            outline: none;
            border-color: #3399ff;
            box-shadow: 0 0 0 2px rgba(51, 153, 255, 0.2);
        }


        /* ======================= */
        /* 달력 전체 박스 */
        .ui-datepicker {
            width: 320px;
            padding: 10px;
            background: #ffffff;
            border: 1px solid #ddd;
            border-radius: 12px;
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);



                top: 50% !important;
                left: 50% !important;
                transform: translate(-50%, -50%) !important;
                z-index: 9999 !important;     /* 위로 띄우기 */

        }

        /* ======================= */
        /* 헤더 (연/월 표시 부분) */
        .ui-datepicker-header {
            display: flex;
            justify-content: center;
            align-items: center;
            background: none;
            border: none;
            padding: 10px 0;
            gap: 6px;
            position: relative;
        }

        .ui-datepicker-title {
            font-size: 15px;
            font-weight: bold;
            color: #333;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        /* 연도/월 select 스타일 */
        .ui-datepicker select.ui-datepicker-month,
        .ui-datepicker select.ui-datepicker-year {
            border: none;
            background: transparent;
            font-size: 15px;
            font-weight: bold;
            color: #333;
            padding: 2px 4px;
            cursor: pointer;
            overflow: hidden;         /* ✅ 스크롤 제거 */
            max-height: 30px;         /* ✅ 높이 제한 */
        }

        /* ======================= */
        /* 이전/다음 버튼 - 동그란 스타일 */
        .ui-datepicker-prev,
        .ui-datepicker-next {
            cursor: pointer;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background-color: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            position: absolute;
            top: 8px;
        }

        .ui-datepicker-prev { left: 8px; }
        .ui-datepicker-next { right: 8px; }

        /* 화살표 모양 */
        .ui-datepicker-prev:before,
        .ui-datepicker-next:before {
            content: '';
            display: inline-block;
            width: 8px;
            height: 8px;
            border: solid #333;
            border-width: 0 2px 2px 0;
        }
        .ui-datepicker-prev:before { transform: rotate(135deg); }
        .ui-datepicker-next:before { transform: rotate(-45deg); }

        /* ======================= */
        /* 요일 헤더 */
        .ui-datepicker thead th {
            color: #666;
            font-weight: bold;
            text-align: center;
            padding: 6px 0;
        }

        /* ======================= */
        /* 날짜 스타일 */
        .ui-datepicker td {
            text-align: center;
            padding: 2px;
        }

        .ui-datepicker td a {
            display: inline-block;
            width: 36px;
            height: 36px;
            line-height: 36px;
            text-align: center;
            text-decoration: none;
            color: #333;
            border-radius: 6px;
            transition: background-color 0.2s;
        }

        /* hover 시 */
        .ui-datepicker td a:hover {
            background-color: #e6f2ff;
            color: #3399ff;
        }

        /* 오늘 날짜 */
        .ui-datepicker-today a {
            border: 1px solid #3399ff !important;
            background-color: #fff !important;
            color: #3399ff !important;
            font-weight: bold;
            border-radius: 50%;
        }

        /* 선택된 날짜 */
        .ui-datepicker-current-day a {
            background-color: #3399ff !important;
            color: #fff !important;
            font-weight: bold;
            border-radius: 50%;
        }
        /* 연도 / 월 드롭다운 공통 스타일 */
        .flatpickr-calendar select.flatpickr-monthDropdown-months,
        .flatpickr-calendar select.numInput {
            appearance: none;           /* 브라우저 기본 화살표 제거 */
            -webkit-appearance: none;
            -moz-appearance: none;
            border: 1px solid #ddd;
            border-radius: 6px;         /* 둥글게 */
            padding: 2px 6px;
            background-color: #fff;
            font-size: 14px;
            text-align: center;
            outline: none;
            overflow: hidden;           /* 스크롤 제거 */
        }

        /* 드롭다운 펼쳤을 때 옵션 스타일 */
        .flatpickr-calendar select.flatpickr-monthDropdown-months option,
        .flatpickr-calendar select.numInput option {
            border-radius: 10px;         /* 옵션에도 살짝 둥근 느낌 */
            padding: 4px;
        }

    </style>
</head>
<body>
<%@ include file="../includes/header.jsp"%>

<div class="register-form-wrapper">
    <div class="register-tab active-tab">REGISTER</div>
    <div class="prefer-tab">PREFER</div>
    <div class="profile-tab">PROFILE</div>
    <div class="header">
        <div class="logo">살며시</div>
        <div class="logo-2">Shall With Me</div>
    </div>
    <div id="errorMessage" class="error-message"></div>
    <form id="f">
        <div class="input-container">
            <div class="form-row">
                <input type="text" name="userName" placeholder="이름" class="register-input"/>
            </div>

        <div class="form-row flex-row">
            <input type="text" name="userId" placeholder="아이디" class="register-input"/>
            <button type="button" id="btnUserId" class="form-button">중복확인</button>
        </div>
            <div class="form-row">
        <input type="password" name="password" placeholder="비밀번호" class="register-input"/>
            </div>
            <div class="form-row">
        <input type="password" name="password2" placeholder="비밀번호 확인" class="register-input"/>
            </div>

        <div class="form-row flex-row">
            <input type="email" name="email" placeholder="이메일" class="register-input"/>
            <button type="button" id="btnEmail" class="form-button">요청</button>
        </div>

            <div class="form-row">
        <input type="text" name="authNumber" placeholder="인증번호 입력" class="register-input"/>
            </div>

        <div class="form-row flex-row">
            <input type="text" name="addr1" placeholder="주소" class="register-input"/>
            <button type="button" id="btnAddr" class="form-button">우편번호</button>
        </div>

            <div class="form-row">
        <input type="text" name="addr2" placeholder="상세주소" class="register-input"/>
            </div>

        <div class="form-row birth-row" id="birth-row">
            <input type="text" name="birthYear" placeholder="2025" class="birth-input" readonly class="register-input"/>
            <input type="text" name="birthMonth" placeholder="01" class="birth-input" readonly class="register-input"/>
            <input type="text" name="birthDay" placeholder="01" class="birth-input" readonly class="register-input"/>
        </div>

        <div class="gender-select">
            <label><input type="radio" name="gender" value="M" class="register-input"/> 남성</label>
            <label><input type="radio" name="gender" value="F" class="register-input"/> 여성</label>
        </div>

        <button type="button" id="btnSend" class="form-button submit-button">회원가입</button>
        </div>
    </form>
    <div class="signup-link">
        이미 계정이 있으신가요? <a href="#" id="btnLogin">ㅤ로그인</a>
    </div>

    <input type="text" id="birth-datepicker" style="position:absolute; left:-9999px; top:-9999px;">
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

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>