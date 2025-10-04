<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <%-- 이거 추가 --%>

<html>
<head>
    <title>살며시: "이름"</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/roommate/roommateDetail.css"/>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<%--여기에 코드 작성--%>
<main class="detail-wrapper">
    <!-- 왼쪽 영역 -->
    <div class="detail-left">
        <div class="profile-photo"
             style="background-image:url('${user.profileImageUrl}')">
        </div>

        <!-- ⬇⬇ 자기소개도 DB 값으로 교체 -->
        <div class="self-intro">
            <h3>자기소개</h3>
            <p>${user.introduction}</p>
        </div>
    </div>

    <!-- 오른쪽 영역 -->
    <div class="detail-right">
        <!-- ⬇⬇ 이름 + 나이 -->
        <h2 class="user-name">${user.userName} (${user.age}세)</h2>

        <!-- ⬇⬇ 성별 / 주소 / 생일-->
        <p class="user-info" id="genderArea"></p>
        <p class="user-info" id="regionArea"></p>
        <p class="user-info" id="birthArea"></p>

        <!-- ⬇⬇ 태그 목록 -->
        <div class="tag-box">
            <c:forEach var="tag" items="${user.tags}">
                <span class="tag"><i class="fa-solid fa-tag"></i> ${tag}</span>
            </c:forEach>
        </div>

        <div id="chatButtonContainer">
            <div class="detail-msg-btn" onclick="openChat('${user.userId}')">메시지</div>
        </div>

    </div>
</main>

<%-- 챗봇 --%>
<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/footer.jsp" %>
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

    function openChat(otherUserId) {
        console.log("openChat 호출됨:", otherUserId);
        fetch("/chat/createOrGetRoom?user2Id=" + otherUserId)
            .then(res => {
                if (!res.ok) {
                    throw new Error(`HTTP error! status: ${res.status}`);
                }
                return res.json();
            })
            .then(data => {
                console.log("서버에서 받은 데이터:", data);
                if (data.roomId) {
                    const cleanedRoomId = Number(data.roomId);
                    console.log("➡️ 이동할 채팅방 ID:", cleanedRoomId);
                    const targetUrl = "/chat/chatRoom?roomId=" + cleanedRoomId;
                    console.log("이동할 URL:", targetUrl);
                    window.location.href = targetUrl;
                } else {
                    alert("채팅방 생성 실패");
                }
            })
            .catch(err => {
                console.error("채팅방 생성 중 오류:", err);
                alert("오류가 발생했습니다.");
            });
    }

    window.onload = function() {
        const fullAddr = "${user.addr1}";
        const gender = "${user.gender}";
        const birthDate = "${user.birthDate}"; // "2001-09-12"
        // 괄호 안 우편번호 제거
        const noZip = fullAddr.replace(/\(.*?\)/, "").trim();
        // 공백 기준으로 분리하여 첫번째 요소만 추출
        const bigRegion = noZip.split(" ")[0];

        let genderName = ""

        if (gender === 'M') {
            genderName = "남성"
        } else {
            genderName = "여성"
        }

        // ⬇ 생일 포맷 변경
        let formattedBirthDate = birthDate;
        if (birthDate.includes('-')) {
            const parts = birthDate.split("-");
            if (parts.length === 3) {
                formattedBirthDate = parts[0] + '년 ' + parts[1] + '월    ' + parts[2] + '일';
            }
        }

        document.getElementById("genderArea").textContent = "성별: " + genderName;
        document.getElementById("regionArea").textContent = "지역: " + bigRegion;
        document.getElementById("birthArea").textContent = "생일: " + formattedBirthDate;
    };

</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
