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

    <!-- ⬇⬇ 성별 / 주소 -->
    <p class="user-info">성별: ${user.gender}</p>

    <!-- ⬇⬇ 태그 목록 -->
    <div class="tag-box">
      <c:forEach var="tag" items="${user.tags}">
        <span class="tag">#${tag}</span>
      </c:forEach>
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
