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
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=218d70914021664c1d8e3dc194489251&libraries=services"></script>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <style>
        /* 작성자 프로필 스타일 */
        .host-profile {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 30px 0;
            gap: 16px;
        }

        .host-avatar {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            overflow: hidden;
            border: 4px solid #3399ff;
            box-shadow: 0 6px 16px rgba(51, 153, 255, 0.3);
        }

        .host-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .host-info {
            text-align: center;
        }

        .host-info .host-label {
            display: block;
            font-size: 0.85rem;
            color: #666;
            margin-bottom: 4px;
            font-weight: 500;
        }

        .host-info strong {
            font-size: 1.3rem;
            color: #222;
            display: block;
        }

        .reserve-btn {
            margin-top: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 24px;
            font-size: 1rem;
        }

        .reserve-btn i {
            font-size: 1.2rem;
        }

        .map-section {
            margin-top: 30px;
        }

        .map-container {
            width: 100%;
            height: 400px;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #e0e0e0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .address-info {
            margin-top: 16px;
            padding: 16px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #3399ff;
        }

        .address-info i {
            color: #3399ff;
            margin-right: 8px;
        }

        .address-info p {
            margin: 8px 0;
            color: #333;
            font-size: 0.95rem;
        }

        .address-info .postcode {
            color: #666;
            font-size: 0.9rem;
        }


        .shd-two-cols {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            align-items: start;
        }

        .shd-two-cols > .card {
            height: 100%;
        }

        /* 소개 섹션 */
        .shd-desc {
            display: flex;
            flex-direction: column;
        }

        .shd-desc p {
            flex: 1;
        }


        .map-section {
            margin-top: 40px;
        }

        .address-info {
            margin-bottom: 24px;
        }
    </style>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main class="shd-wrapper">
    <section class="shd-titlebar">
        <h1 id="shd-title">${user.title}</h1>
    </section>

    <!-- 이미지 갤러리 -->
    <section class="shd-gallery">
        <c:choose>
            <c:when test="${not empty user.images}">
                <c:forEach var="img" items="${user.images}" varStatus="status" end="3">
                    <img id="g${status.index}"
                         src="${img.url}"
                         alt="쉐어하우스 이미지 ${status.index + 1}"
                         onerror="this.src='${pageContext.request.contextPath}/images/noimg.png'">
                </c:forEach>

                <c:forEach begin="${fn:length(user.images)}" end="3" var="i">
                    <img id="g${i}"
                         src="${pageContext.request.contextPath}/images/noimg.png"
                         alt="이미지 없음">
                </c:forEach>
            </c:when>
            <c:otherwise>
                <c:forEach begin="0" end="3" var="i">
                    <img id="g${i}"
                         src="${pageContext.request.contextPath}/images/noimg.png"
                         alt="이미지 없음">
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <div class="photo-notice-box">
            <div class="notice-icon">
                <i class="fa-solid fa-camera"></i>
            </div>
            <div class="notice-title">실제 거주<br/>사진입니다</div>
            <div class="notice-subtitle">Real Photos<br/>Verified</div>
        </div>
    </section>

    <section class="shd-body">
        <div class="shd-summary-full card">
            <div class="meta">
                <span id="meta-type">쉐어하우스</span>
                <span class="dot"></span>
                <span id="meta-guest">설명 태그</span>
            </div>

            <div class="tag-row" id="tagRow">
                <c:forEach var="tag" items="${user.tags}">
                    <span class="chip"># ${tag.tagName}</span>
                </c:forEach>

                <c:if test="${not empty user.floorNumber}">
                    <span class="chip"># ${user.floorNumber}층</span>
                </c:if>
            </div>
        </div>

        <div class="shd-two-cols">
            <div class="shd-desc card">
                <h2 class="sec-title"><i class="fa-regular fa-file-lines"></i> 소개</h2>
                <p>${user.subText}</p>
            </div>

            <div class="shd-contact card">
                <div class="host-profile">
                    <div class="host-avatar">
                        <c:choose>
                            <c:when test="${not empty user.hostProfileUrl}">
                                <img src="${user.hostProfileUrl}"
                                     alt="작성자 프로필"
                                     onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${fn:escapeXml(not empty user.hostName ? user.hostName : 'User')}&background=3399ff&color=fff&size=140'">
                            </c:when>
                            <c:otherwise>
                                <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(not empty user.hostName ? user.hostName : 'User')}&background=3399ff&color=fff&size=140"
                                     alt="기본 프로필">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="host-info">
                        <span class="host-label">작성자</span>
                        <strong>${not empty user.hostName ? user.hostName : '알 수 없음'}</strong>
                    </div>
                </div>

                <!-- 문의하기 버튼 (채팅으로 연결) -->
                <button class="reserve-btn" type="button" onclick="openChatWithHost()">
                    <i class="fa-regular fa-comment-dots"></i> 문의하기
                </button>
            </div>
        </div>

        <div class="shd-desc card map-section">
            <h2 class="sec-title"><i class="fa-solid fa-map-location-dot"></i> 위치</h2>

            <div class="address-info">
                <p>
                    <i class="fa-solid fa-location-dot"></i>
                    <strong>${not empty user.address ? user.address : '주소 정보 없음'}</strong>
                </p>
                <c:if test="${not empty user.detailAddress}">
                    <p style="color:#666; font-size:0.9rem; margin-left:24px;">
                        ${user.detailAddress}
                    </p>
                </c:if>
            </div>

            <!-- 카카오맵 컨테이너 -->
            <div id="map" class="map-container"></div>
        </div>
    </section>
</main>

<%@ include file="../includes/customModal.jsp" %>
<%@ include file="../includes/footer.jsp" %>

<script>
    // 채팅 열기 함수 (기존 시스템 활용)
    function openChatWithHost() {
        const hostId = '${user.regId}';
        const hostName = '${user.hostName}';

        // null 체크 강화
        if (!hostId || hostId === 'null' || hostId === '' || hostId === 'undefined') {
            showCustomAlert('작성자 정보를 찾을 수 없습니다.');
            return;
        }

        console.log('채팅 열기:', hostId, hostName);

        fetch('/chat/createOrGetRoom?user2Id=' + encodeURIComponent(hostId))
            .then(res => {
                if (!res.ok) throw new Error('HTTP error! status: ' + res.status);
                return res.json();
            })
            .then(data => {
                if (data.roomId) {
                    window.location.href = '/chat/chatRoom?roomId=' + Number(data.roomId);
                } else {
                    showCustomAlert('채팅방 생성에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('채팅방 생성 중 오류:', error);
                showCustomAlert('채팅 연결에 실패했습니다.');
            });
    }

    document.addEventListener('DOMContentLoaded', function() {
        const address = '${user.address}';

        if (!address || address === '' || address === 'null') {
            console.warn('주소 정보가 없습니다.');
            document.getElementById('map').innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#999;"><p>주소 정보가 없어 지도를 표시할 수 없습니다.</p></div>';
            return;
        }

        if (typeof kakao === 'undefined' || !kakao.maps) {
            console.error('카카오맵 API가 로드되지 않았습니다.');
            return;
        }

        const mapContainer = document.getElementById('map');
        const mapOption = {
            center: new kakao.maps.LatLng(37.5665, 126.9780),
            level: 3
        };

        const map = new kakao.maps.Map(mapContainer, mapOption);
        const geocoder = new kakao.maps.services.Geocoder();

        geocoder.addressSearch(address, function(result, status) {
            if (status === kakao.maps.services.Status.OK) {
                const coords = new kakao.maps.LatLng(result[0].y, result[0].x);

                // 마커 생성
                const marker = new kakao.maps.Marker({
                    map: map,
                    position: coords
                });

                // 인포윈도우 생성
                const infowindow = new kakao.maps.InfoWindow({
                    content: '<div style="padding:5px 10px;font-size:12px;font-weight:600;">${user.title}</div>'
                });
                infowindow.open(map, marker);

                // 지도 중심을 마커 위치로 이동
                map.setCenter(coords);
            } else {
                console.error('주소 검색 실패:', status, 'address:', address);
                mapContainer.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#999;"><p>주소를 찾을 수 없습니다.</p></div>';
            }
        });
    });


    document.addEventListener('DOMContentLoaded', function() {
        const profileImg = document.querySelector('.host-avatar img');
        if (profileImg) {

            if (!profileImg.dataset.errorHandled) {
                profileImg.dataset.errorHandled = 'true';
                profileImg.addEventListener('error', function(e) {

                    e.target.removeEventListener('error', arguments.callee);
                    console.log('프로필 이미지 로드 실패, 기본 이미지로 대체');


                    const hostName = '${fn:escapeXml(not empty user.hostName ? user.hostName : "User")}';
                    this.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(hostName) + '&background=3399ff&color=fff&size=140';
                }, {once: true}); // once 옵션으로 한 번만 실행
            }
        }
    });
</script>
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