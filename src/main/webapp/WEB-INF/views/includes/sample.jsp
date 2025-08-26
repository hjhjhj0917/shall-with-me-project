<%--
  Created by IntelliJ IDEA.
  User: data8320-16
  Date: 2025-08-04
  Time: 오전 11:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
  <title>살며시|"이름"</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
  <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
</head>
<body>
<%@ include file="../includes/header.jsp"%>

<%--여기에 코드 작성--%>

<div id="customAlertOverlay" class="modal-overlay" style="display: none;">
  <div class="modal">
    <div class="modal-title">
      <i class="fa-solid fa-circle-exclamation fa-shake fa-lg" style="color: #3399ff;"></i>
      <h2>살며시</h2>
    </div>
    <p id="customAlertMessage">메시지 내용</p>
    <div class="modal-buttons" style="text-align: right;">
      <button class="deactivate-btn" onclick="closeCustomAlert()">확인</button>
    </div>
  </div>
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

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
