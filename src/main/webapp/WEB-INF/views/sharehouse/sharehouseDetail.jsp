<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시: 쉐어하우스 상세</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseDetail.css"/>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main class="shd-wrapper">
    <section class="shd-titlebar">
        <h1 id="shd-title">${user.title}</h1>
<%--        <div class="shd-actions">--%>
<%--            <button class="action-btn" type="button"><i class="fa-regular fa-share-from-square"></i> 공유하기</button>--%>
<%--            <button class="action-btn" type="button"><i class="fa-regular fa-heart"></i> 저장</button>--%>
<%--        </div>--%>
    </section>

    <!-- 이미지 갤러리 -->
    <section class="shd-gallery">
        <c:choose>
            <c:when test="${not empty user.images}">
                <c:forEach var="img" items="${user.images}" varStatus="status" end="4">
                    <img id="g${status.index}"
                         src="${img.url}"
                         alt="쉐어하우스 이미지 ${status.index + 1}"
                         onerror="this.src='${pageContext.request.contextPath}/images/noimg.png'">
                </c:forEach>

                <!-- 5개 미만일 경우 noimg로 채우기 -->
                <c:forEach begin="${fn:length(user.images)}" end="4" var="i">
                    <img id="g${i}"
                         src="${pageContext.request.contextPath}/images/noimg.png"
                         alt="이미지 없음">
                </c:forEach>
            </c:when>
            <c:otherwise>
                <!-- 이미지가 없을 경우 -->
                <c:forEach begin="0" end="4" var="i">
                    <img id="g${i}"
                         src="${pageContext.request.contextPath}/images/noimg.png"
                         alt="이미지 없음">
                </c:forEach>
            </c:otherwise>
        </c:choose>

<%--        <button class="see-all" type="button">--%>
<%--            <i class="fa-solid fa-grip"></i> 사진 모두 보기--%>
<%--        </button>--%>
    </section>

    <section class="shd-body">
            <div class="shd-summary-full card">
                <div class="meta">
                    <span id="meta-type">쉐어하우스</span>
                    <span class="dot"></span>
                    <span id="meta-guest">공동 주택</span>
                </div>
                <div class="tag-row" id="tagRow">
                    <c:forEach var="tag" items="${user.tags}">
                        <span class="chip"># ${tag.tagName}</span>
                    </c:forEach>

                    <!-- ✅ 층수 추가 (6개 태그 + 층수 = 총 7개) -->
                    <c:if test="${not empty user.floorNumber}">
                        <span class="chip"># ${user.floorNumber}층</span>
                    </c:if>
                </div>
            </div>

        <!-- 하단: 2단 레이아웃 -->
        <div class="shd-two-cols">
            <!-- 왼쪽: 소개 -->
            <div class="shd-desc card">
                <h2 class="sec-title"><i class="fa-regular fa-file-lines"></i> 소개</h2>
                <p>${user.subText}</p>
            </div>

            <!-- 오른쪽: 문의하기 -->
            <div class="shd-contact card">
                <div class="price-line">
                    <strong>문의하기</strong>
                </div>
                <button class="reserve-btn" type="button">문의하기</button>
            </div>
        </div>
    </section>
</main>

<%@ include file="../includes/footer.jsp" %>
</body>
</html>