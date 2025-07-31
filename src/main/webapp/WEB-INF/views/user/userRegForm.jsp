<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>회원가입 화면</title>
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script type="text/javascript">

        // 아이디 중복체크여부 (중복 Y / 중복아님 : N)
        let userIdCheck = "Y";

        // 이메일 중복체크 인증번호 발송 값
        let emailAuthNumber = "";

        // HTML로딩이 완료되고, 실행됨
        $(document).ready(function () {

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

        })

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

            // Ajax 호출해서 회원가입하기
            $.ajax({
                    url: "/user/insertUserInfo",
                    type: "post", // 전송방식은 Post
                    dataType: "JSON", // 전송 결과는 JSON으로 받기
                    data: $("#f").serialize(), // form 태그 내 input 등 객체를 자동으로 전송할 형태로 변경하기
                    success: function (json) { // /notice/noticeUpdate 호출이 성공했다면..

                        if (json.result === 1) { // 회원가입 성공
                            alert(json.msg); // 메시지 띄우기
                            location.href = "/user/login"; // 로그인 페이지 이동

                        } else { // 회원가입 실패
                            alert(json.msg); // 메시지 띄우기
                        }

                    }
                }
            )
        }

    </script>
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: white;
            font-family: 'Noto Sans KR', sans-serif;
            text-align: center;
            background-repeat: no-repeat;
            background-position: bottom;
            background-size: cover;
            height: 100vh;
        }

        .logo {
            font-size: 48px;
            font-weight: 700;
            margin-top: 40px;
            color: black;
            user-select: none;
        }

        .logo-2 {
            font-size: 18px;
            color: #555;
            margin-bottom: 20px;
            user-select: none;
        }

        /* ✅ 파란색 큰 네모는 크기 그대로 유지 */
        #f {
            width: 350px;
            margin: 0 auto;
            background-color: #A4CCF4;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.1);
        }

        .form-logo {
            width: 70px;
            height: 70px;
            margin: 0 auto 20px auto;
        }

        /* ✅ 입력칸 간격만 줄임 */
        input[type="text"],
        input[type="email"],
        input[type="password"],
        select {
            width: 100%;
            padding: 6px 8px;     /* 패딩 줄임 */
            margin: 3px 0;        /* 위아래 간격 줄임 */
            border: none;
            border-radius: 5px;
            font-size: 13.5px;
        }

        .divTable {
            display: table;
            width: 100%;
        }

        .divTableBody {
            display: table-row-group;
        }

        .divTableRow {
            display: table-row;
            margin-bottom: 2px; /* 🔽 줄 사이 간격 최소화 */
        }

        .divTableCell {
            display: table-cell;
            padding: 4px 4px;     /* 셀 내부 여백도 최소화 */
            vertical-align: middle;
            font-weight: bold;
            text-align: left;
        }

        .divTableCell input,
        .divTableCell select {
            margin-top: 1px;
            margin-bottom: 1px;
        }

        button {
            padding: 6px 10px;
            background-color: #316B95;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12.5px;
            margin-left: 3px;
        }

        button:hover {
            background-color: #25587a;
        }

        #btnSend {
            width: 100%;
            margin-top: 12px;
            padding: 10px;
            font-size: 15px;
            font-weight: bold;
        }
    </style>


</head>
<body>
<div class="logo">살며시</div>
<div class="logo-2">Shall With Me</div>
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

<%--            <!-- 주소 -->--%>
<%--            <div class="divTableRow">--%>
<%--                <div class="divTableCell">--%>
<%--                </div>--%>
<%--                <div class="divTableCell">--%>
<%--                    <input type="text" name="addr1" style="width:85%" placeholder="주소"/>--%>
<%--                    <button id="btnAddr" type="button">우편번호</button>--%>
<%--                </div>--%>
<%--            </div>--%>

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

    <!-- 회원가입 버튼 -->
    <div>
        <button id="btnSend" type="button">회원가입</button>
    </div>
</form>
</body>
</html>