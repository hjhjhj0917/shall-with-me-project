<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>  <%-- 이거 추가 --%>

<html>
<head>
    <title>살며시: 회원정보</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/roommate/roommateDetail.css"/>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main class="detail-wrapper">
    <div class="detail-left">
        <div class="profile-photo"
             style="background-image:url('${user.profileImageUrl}')">
        </div>

        <div class="self-intro">
            <h3>자기소개</h3>
            <p>${user.introduction}</p>
        </div>
    </div>


    <div class="detail-right">
        <h2 class="user-name">${user.userName} (${user.age}세)</h2>

        <p class="user-info" id="genderArea"></p>
        <p class="user-info" id="regionArea"></p>
        <p class="user-info" id="birthArea"></p>

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
                    console.log("이동할 채팅방 ID:", cleanedRoomId);
                    const targetUrl = "/chat/chatRoom?roomId=" + cleanedRoomId;
                    console.log("이동할 URL:", targetUrl);
                    window.location.href = targetUrl;
                } else {
                    showCustomAlert("채팅방 생성 실패");
                }
            })
            .catch(err => {
                console.error("채팅방 생성 중 오류:", err);
                showCustomAlert("오류가 발생했습니다.");
            });
    }

    window.onload = function() {
        const fullAddr = "${user.addr1}";
        const gender = "${user.gender}";
        const birthDate = "${user.birthDate}";
        const noZip = fullAddr.replace(/\(.*?\)/, "").trim();
        const bigRegion = noZip.split(" ")[0];

        let genderName = ""

        if (gender === 'M') {
            genderName = "남성"
        } else {
            genderName = "여성"
        }


        let formattedBirthDate = birthDate;
        if (birthDate.includes('-')) {
            const parts = birthDate.split("-");
            if (parts.length === 3) {
                formattedBirthDate = parts[0] + '년 ' + parts[1] + '월    ' + parts[2] + '일';
            }
        }

        document.getElementById("genderArea").innerHTML = '<i class="fa-solid fa-venus-mars" style="color: #1c407d;"></i> ' + genderName;
        document.getElementById("regionArea").innerHTML = ' <i class="fa-solid fa-location-dot" style="color: #1c407d;"></i> ' + bigRegion;
        document.getElementById("birthArea").innerHTML = ' <i class="fa-solid fa-cake-candles" style="color: #1c407d;"></i> ' + formattedBirthDate;
    };

</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
