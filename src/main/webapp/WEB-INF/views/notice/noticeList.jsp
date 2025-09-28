<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 공지사항</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/noticeList.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
</head>

<body>

<%@ include file="../includes/header.jsp" %>

<div class="notice-container">
    <div class="notice-header">
        <h2>청년정책 알림</h2>
        <div class="notice-search">
            <input type="text" id="searchInput" placeholder="제목 검색...">
            <button onclick="handleSearch()">
                <i class="fa-solid fa-magnifying-glass"></i>
            </button>
        </div>
    </div>
    <!-- JSON 데이터 전달용 div -->
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <div id="policyJsonData" data-json="<c:out value='${policiesJson}'/>" style="display: none;"></div>

    <table>
        <thead>
        <tr>
            <th>정책 No</th>
            <th>제목</th>
            <th>접수기간</th>
        </tr>
        </thead>
        <tbody id="policyTableBody"></tbody>
    </table>

    <div id="pagination" style="text-align:center; margin-top: 20px;"></div>

</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>

<script src="${pageContext.request.contextPath}/js/noticeList.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>
