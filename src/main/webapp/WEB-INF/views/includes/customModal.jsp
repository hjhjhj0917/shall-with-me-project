<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
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
