<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {

            function checkLoginAndRedirect(url) {
                $.ajax({
                    url: "/user/loginCheck",
                    type: "GET",
                    dataType: "json",
                    success: function (res) {
                        if (res === 1) {
                            location.href = url;
                        } else {
                            showCustomAlert("로그인이 필요한 서비스입니다.", function () {
                                location.href = "/user/login";
                            });
                        }
                    },
                    error: function () {
                        showCustomAlert("서버 통신 오류가 발생했습니다.");
                    }
                });
            }

            $("#roommateBtn").on("click", function () {
                checkLoginAndRedirect("/roommate/roommateMain");
            });

            $("#sharehouseBtn").on("click", function () {
                checkLoginAndRedirect("/sharehouse/sharehouseMain");
            });
        });
    </script>

</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="main-container">

    <div class="left-panel" id="roommateBtn">
        <div class="left-text">
            자신과 비슷한 성향의 룸메이트를 찾아보세요
        </div>
        <div class="roommate-start">
            룸메이트 찾기
        </div>
        <div class="left">
            <img src="/images/roommate.png" class="left-image" alt="왼쪽 이미지"/>
        </div>
    </div>

    <div class="right-panel" id="sharehouseBtn">
        <div class="right-text">
            자신의 새로운 보금자리를 찾아보세요
        </div>
        <div class="right-start">
            쉐어하우스 찾기
        </div>
        <div class="right">
            <img src="/images/sharehouse.png" class="right-image" alt="오른쪽 이미지"/>
        </div>
    </div>
</div>

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
</script>

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<%-- 모달창 js --%>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>


</body>
</html>


