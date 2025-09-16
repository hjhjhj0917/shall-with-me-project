<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
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
    <!-- 프로필 사진 (동그라미) -->
    <div class="profile-photo"></div>

    <!-- 자기소개 -->
    <div class="self-intro">
      <h3>자기소개</h3>
      <p>
        안녕하세요! 저는 홍길동입니다. <br>
        조용한 분위기를 좋아하고 성실하게 지내고 싶습니다.
      </p>
    </div>
  </div>

  <!-- 오른쪽 영역 -->
  <div class="detail-right">
    <h2 class="user-name">홍길동 (25세)</h2>
    <p class="user-info">성별: 남</p>
    <p class="user-info">주소: 부산광역시 동래구</p>

    <!-- 태그 목록 -->
    <div class="tag-box">
      <span class="tag">#청결</span>
      <span class="tag">#조용한</span>
      <span class="tag">#비흡연</span>
    </div>
  </div>
</main>

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

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
