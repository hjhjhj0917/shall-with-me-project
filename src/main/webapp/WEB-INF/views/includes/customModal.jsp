<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 2025-08-02
  Time: 오후 7:11
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
  <head>
    <title>Title</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  </head>
  <body>

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

  <script src="${pageContext.request.contextPath}/js/modal.js"></script>
  
  </body>
</html>
