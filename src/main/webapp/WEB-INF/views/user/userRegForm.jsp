<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>회원가입 화면</title>
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="//code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <script src="//code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
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
    </script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/regform.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>
    <script type="text/javascript">

        // 아이디 중복체크여부 (중복 Y / 중복아님 : N)
        let userIdCheck = "Y";

        // 이메일 중복체크 인증번호 발송 값
        let emailAuthNumber = "";

        // HTML로딩이 완료되고, 실행됨
        $(document).ready(function () {

            $.datepicker.setDefaults($.datepicker.regional['ko']); // 이 줄을 꼭 추가

            let f = document.getElementById("f"); // form 태그

            // 아이디 중복체크
            $("#btnUserId").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
                userIdExists(f)

            })

            // 이메일 중복체크
            $("#btnEmail").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
                emailExists(f)

            })

            // 우편번호 찾기
            $("#btnAddr").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
                kakaoPost(f);
            })

            // 회원가입
            $("#btnSend").on("click", function () { // 버튼 클릭했을때, 발생되는 이벤트 생성함(onclick 이벤트와 동일함)
                doSubmit(f);
            })

            // 생년월일 3칸 중 아무거나 클릭하면 달력 팝업
            $('.birth-input').on('click', function(){
                $('#birth-datepicker').datepicker('show');
            });

            // jQuery UI datepicker 초기화
            $("#birth-datepicker").datepicker({
                changeYear: true,
                changeMonth: true,
                yearRange: "1900:2025",
                dateFormat: "yy-mm-dd",
                onSelect: function(dateText) {
                    let parts = dateText.split('-');
                    $('input[name="birthYear"]').val(parts[0]);
                    $('input[name="birthMonth"]').val(parts[1]);
                    $('input[name="birthDay"]').val(parts[2]);
                },

                beforeShow: function(input, inst) {
                    // 1. 생년월일 input을 감싸는 div의 위치를 구함
                    var $row = $('#birth-row');
                    var offset = $row.offset();
                    // 2. 달력 popup을 해당 div 아래에 맞춰 위치 지정
                    setTimeout(function() {
                        $(inst.dpDiv).css({
                            top: offset.top + $row.outerHeight(), // row의 아래에 딱 붙여줌
                            left: offset.left -25,
                            position: 'absolute',
                            zIndex: 9999
                        });
                    }, 0);
                }
            });
        });

        // 회원아이디 중복 체크
        function userIdExists(f) {

            if (f.userId.value === "") {
                alert("아이디를 입력하세요.");
                f.userId.focus();
                return;
            }

            // Ajax 호출해서 회원가입하기
            $.ajax({
                    url: "/user/getUserIdExists",
                    type: "post", // 전송방식은 Post
                    dataType: "JSON", // 전송 결과는 JSON으로 받기
                    data: $("#f").serialize(), // form 태그 내 input 등 객체를 자동으로 전송할 형태로 변경하기
                    success: function (json) { // 호출이 성공했다면..

                        if (json.existsYn === "Y") {
                            alert("이미 가입된 아이디가 존재합니다.");
                            f.userId.focus();

                        } else { // 회원가입 실패
                            alert("가입 가능한 아이디입니다.");
                            userIdCheck = "N";
                        }

                    }
                }
            )
        }

        // 이메일 중복 체크
        function emailExists(f) {
            if (f.email.value === "") {
                alert("이메일을 입력하세요.");
                f.email.focus();
                return;
            }

            // Ajax 호출해서 회원가입하기
            $.ajax({
                    url: "/user/getEmailExists",
                    type: "post", // 전송방식은 Post
                    dataType: "JSON", // 전송 결과는 JSON으로 받기
                    data: $("#f").serialize(), // form 태그 내 input 등 객체를 자동으로 전송할 형태로 변경하기
                    success: function (json) { // 호출이 성공했다면..

                        if (json.existsYn === "Y") {
                            alert("이미 가입된 이메일 주소가 존재합니다.");
                            f.email.focus();

                        } else {
                            alert("이메일로 인증번호가 발송되었습니다. \n받은 메일의 인증번호를 입력하기 바랍니다.");
                            emailAuthNumber = json.authNumber;

                        }

                    }
                }
            )
        }

        // 카카오 우편번호 조회 API 호출
        function kakaoPost(f) {
            new daum.Postcode({
                oncomplete: function (data) {

                    // Kakao에서 제공하는 data는 JSON구조로 주소 조회 결과값을 전달함
                    // 주요 결과값
                    // 주소 : data.address
                    // 우편번호 : data.zonecode
                    let address = data.address; // 주소
                    let zonecode = data.zonecode; // 우편번호
                    f.addr1.value = "(" + zonecode + ")" + address
                }
            }).open();
        }

        //회원가입 정보의 유효성 체크하기
        function doSubmit(f) {

            if (f.userId.value === "") {
                alert("아이디를 입력하세요.");
                f.userId.focus();
                return;
            }

            if (userIdCheck !== "N") {
                alert("아이디 중복 체크 및 중복되지 않은 아이디로 가입 바랍니다.");
                f.userId.focus();
                return;
            }

            if (f.userName.value === "") {
                alert("이름을 입력하세요.");
                f.userName.focus();
                return;
            }

            if (f.password.value === "") {
                alert("비밀번호를 입력하세요.");
                f.password.focus();
                return;
            }

            if (f.password2.value === "") {
                alert("비밀번호확인을 입력하세요.");
                f.password2.focus();
                return;
            }

            if (f.password.value !== f.password2.value) {
                alert("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                f.password.focus();
                return;
            }

            if (f.email.value === "") {
                alert("이메일을 입력하세요.");
                f.email.focus();
                return;
            }

            if (f.authNumber.value === "") {
                alert("이메일 인증번호를 입력하세요.");
                f.authNumber.focus();
                return;
            }

            if (f.authNumber.value != emailAuthNumber) {
                alert("이메일 인증번호가 일치하지 않습니다.");
                f.authNumber.focus();
                return;
            }

            if (f.addr1.value === "") {
                alert("주소를 입력하세요.");
                f.addr1.focus();
                return;
            }

            if (f.addr2.value === "") {
                alert("상세주소를 입력하세요.");
                f.addr2.focus();
                return;
            }

            if (f.birthYear.value === "") {
                alert("생년월일을 선택해주세요");
                f.birthYear.focus();
                return;
            }

            if (f.birthMonth.value === "") {
                alert("생년월일을 선택해주세요");
                f.birthMonth.focus();
                return;
            }

            if (f.birthDay.value === "") {
                alert("생년월일을 선택해주세요");
                f.birthDay.focus();
                return;
            }

            if (f.gender.value === "") {
                alert("성별을 선택해주세요");
                f.gender.focus();
                return;
            }

            // Ajax 호출해서 회원가입하기
            $.ajax({
                    url: "/user/insertUserInfo",
                    type: "post", // 전송방식은 Post
                    dataType: "JSON", // 전송 결과는 JSON으로 받기
                    data: $("#f").serialize(), // form 태그 내 input 등 객체를 자동으로 전송할 형태로 변경하기
                    success: function (json) { // /notice/noticeUpdate 호출이 성공했다면..

                        if (json.result === 1) { // 회원가입 성공
                            alert(json.msg); // 메시지 띄우기
                            location.href = "/user/userTagSelect"; // 로그인 페이지 이동

                        } else { // 회원가입 실패
                            alert(json.msg); // 메시지 띄우기
                        }

                    }
                }
            )
        }

    </script>
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
            <span class="slide-bg3"></span> <!-- 둥근 반스도 역할 -->
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span> <!-- 둥근 반스도 역할 -->
            <span class="user-name-text" id="userNameText">
        <%= session.getAttribute("SS_USER_NAME") %>님
      </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span> <!-- 둥근 반스도 역할 -->
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>
<div class="header">
    <div class="logo">살며시</div>
    <div class="logo-2">Shall With Me</div>
</div>
<form id="f" style="width:250px;">
    <div class="divTable minimalistBlack">
        <div class="divTableBody">
            <!-- 이름 -->
            <div class="divTableRow">
                <div class="divTableCell">
                </div>
                <div class="divTableCell">
                    <input type="text" name="userName" style="width:95%" placeholder="이름"/>
                </div>
            </div>

            <!-- 아이디 + 중복 확인 버튼 -->
            <div class="divTableRow">
                <div class="divTableCell">
                </div>
                <div class="divTableCell" style="display: flex; gap: 10px; align-items: center;">
                    <input type="text" name="userId" style="flex: 1;" placeholder="아이디"/>
                    <button id="btnUserId" type="button" style="flex-shrink: 0;">중복 확인</button>
                </div>
            </div>

            <!-- 비밀번호 -->
            <div class="divTableRow">
                <div class="divTableCell">
                </div>
                <div class="divTableCell">
                    <input type="password" name="password" style="width:95%" placeholder="비밀번호"/>
                </div>
            </div>

            <!-- 비밀번호 확인 -->
            <div class="divTableRow">
                <div class="divTableCell">
                </div>
                <div class="divTableCell">
                    <input type="password" name="password2" style="width:95%" placeholder="비밀번호 확인"/>
                </div>
            </div>

            <!-- 이메일 + 요청 버튼 (아이디 밑에 한 줄로) -->
            <div class="divTableRow">
                <div class="divTableCell"></div>
                <div class="divTableCell" style="display: flex; gap: 10px; align-items: center;">
                    <input type="email" name="email" style="flex: 1;" placeholder="이메일"/>
                    <button id="btnEmail" type="button" style="flex-shrink: 0;"> 요청 </button>
                </div>
            </div>

            <!-- 인증번호 + 승인 버튼 -->
            <div class="divTableRow">
                <div class="divTableCell"></div>
                <div class="divTableCell" style="display: flex; gap: 10px; align-items: center;">
                    <input type="text" name="authNumber" style="flex: 1;" placeholder="인증번호"/>
                </div>
            </div>

            <!-- 아이디 + 중복 확인 버튼 -->
            <div class="divTableRow">
                <div class="divTableCell">
                </div>
                <div class="divTableCell" style="display: flex; gap: 10px; align-items: center;">
                    <input type="text" name="addr1" style="flex: 1;" placeholder="주소"/>
                    <button id="btnAddr" type="button" style="flex-shrink: 0;">우편번호</button>
                </div>
            </div>

            <!-- 상세주소 -->
            <div class="divTableRow">
                <div class="divTableCell">
                </div>
                <div class="divTableCell">
                    <input type="text" name="addr2" style="width:95%" placeholder="상세주소"/>
                </div>
            </div>
        </div>
    </div>

    <!-- 나이(생년월일) 입력: 연/월/일 3개 입력 -->
    <div class="divTableRow">
        <div class="divTableCell"></div>
        <div class="divTableCell" id="birth-row" style="display:flex; gap:10px;">
            <input type="text" name="birthYear" maxlength="4" style="width:33%;" placeholder="2025" class="birth-input" readonly/>
            <input type="text" name="birthMonth" maxlength="2" style="width:30%;" placeholder="01" class="birth-input" readonly/>
            <input type="text" name="birthDay" maxlength="2" style="width:30%;" placeholder="01" class="birth-input" readonly/>
        </div>
    </div>

    <!-- 성별 라디오 버튼 -->
    <div class="divTableRow">
        <div class="divTableCell"></div>
        <div class="divTableCell gender-select" style="display:flex; align-items:center; gap:20px;">
            <span>성별</span>
            <label for="genderMale" style="display:flex; align-items:center; gap:3px;">
                <input type="radio" id="genderMale" name="gender" value="M"/> 남성
            </label>
            <label for="genderFemale" style="display:flex; align-items:center; gap:3px;">
                <input type="radio" id="genderFemale" name="gender" value="F"/> 여성
            </label>
        </div>
    </div>

    <!-- 회원가입 버튼 -->
    <div>
        <button id="btnSend" type="button">회원가입</button>
    </div>
</form>
<input type="text" id="birth-datepicker" style="position:absolute; left:-9999px; top:-9999px;">

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