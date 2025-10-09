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
    <style>
        /* 작성자 프로필 스타일 */
        .host-profile {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 30px 0;  /* ✅ 패딩 증가 */
            gap: 16px;  /* ✅ 간격 증가 */
        }

        .host-avatar {
            width: 140px;  /* ✅ 100px → 140px */
            height: 140px;  /* ✅ 100px → 140px */
            border-radius: 50%;
            overflow: hidden;
            border: 4px solid #3399ff;  /* ✅ 3px → 4px */
            box-shadow: 0 6px 16px rgba(51, 153, 255, 0.3);  /* ✅ 그림자 강화 */
        }

        .host-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .host-info {
            text-align: center;
        }

        /* ✅ "작성자" 라벨 스타일 추가 */
        .host-info .host-label {
            display: block;
            font-size: 0.85rem;
            color: #666;
            margin-bottom: 4px;
            font-weight: 500;
        }

        .host-info strong {
            font-size: 1.3rem;  /* ✅ 1.1rem → 1.3rem */
            color: #222;
            display: block;
        }

        .reserve-btn {
            margin-top: 20px;  /* ✅ 16px → 20px */
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 24px;  /* ✅ 패딩 추가 */
            font-size: 1rem;  /* ✅ 폰트 크기 명시 */
        }

        .reserve-btn i {
            font-size: 1.2rem;  /* ✅ 1.1rem → 1.2rem */
        }
    </style>
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
                <span id="meta-guest">설명 태그</span>
            </div>

            <!-- ✅ 태그 6개 + 층수 = 총 7개 표시 -->
            <div class="tag-row" id="tagRow">
                <c:forEach var="tag" items="${user.tags}">
                    <span class="chip"># ${tag.tagName}</span>
                </c:forEach>

                <!-- ✅ 층수 추가 (일반 태그와 동일한 스타일) -->
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

            <!-- 오른쪽: 작성자 프로필 + 문의하기 -->
            <div class="shd-contact card">
                <!-- ✅ 작성자 프로필 이미지 추가 -->
                <div class="host-profile">
                    <div class="host-avatar">
                        <c:choose>
                            <c:when test="${not empty user.hostProfileUrl}">
                                <img src="${user.hostProfileUrl}"
                                     alt="작성자 프로필"
                                     onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${fn:escapeXml(not empty user.hostName ? user.hostName : 'User')}&background=3399ff&color=fff&size=140'">
                            </c:when>
                            <c:otherwise>
                                <%-- ✅ 사용자 이름의 첫 글자를 아바타에 표시, 크기 140으로 변경 --%>
                                <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(not empty user.hostName ? user.hostName : 'User')}&background=3399ff&color=fff&size=140"
                                     alt="기본 프로필">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="host-info">
                        <%-- ✅ "작성자" 라벨 추가 --%>
                        <span class="host-label">작성자</span>
                        <strong>${not empty user.hostName ? user.hostName : '알 수 없음'}</strong>
                    </div>
                </div>

                <!-- ✅ 문의하기 버튼 (채팅으로 연결) -->
                <button class="reserve-btn" type="button" onclick="openChatWithHost()">
                    <i class="fa-regular fa-comment-dots"></i> 문의하기
                </button>
            </div>
        </div>
    </section>
</main>

<%@ include file="../includes/footer.jsp" %>

<script>
    // ✅ 채팅 열기 함수 (기존 시스템 활용)
    function openChatWithHost() {
        const hostId = '${user.regId}';
        const hostName = '${user.hostName}';

        // ✅ null 체크 강화
        if (!hostId || hostId === 'null' || hostId === '' || hostId === 'undefined') {
            alert('작성자 정보를 찾을 수 없습니다.');
            return;
        }

        console.log('채팅 열기:', hostId, hostName);

        // 기존 채팅 시스템 활용: createOrGetRoom API 사용
        fetch('/chat/createOrGetRoom?user2Id=' + encodeURIComponent(hostId))
            .then(res => {
                if (!res.ok) throw new Error('HTTP error! status: ' + res.status);
                return res.json();
            })
            .then(data => {
                if (data.roomId) {
                    window.location.href = '/chat/chatRoom?roomId=' + Number(data.roomId);
                } else {
                    alert('채팅방 생성에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('채팅방 생성 중 오류:', error);
                alert('채팅 연결에 실패했습니다.');
            });
    }

    // ✅ 이미지 로드 오류 방지 - 한 번만 실행되도록 개선
    document.addEventListener('DOMContentLoaded', function() {
        const profileImg = document.querySelector('.host-avatar img');
        if (profileImg) {
            // ✅ 이미 에러 핸들러가 설정되어 있으면 중복 방지
            if (!profileImg.dataset.errorHandled) {
                profileImg.dataset.errorHandled = 'true';
                profileImg.addEventListener('error', function(e) {
                    // ✅ 한 번만 실행되도록 이벤트 리스너 제거
                    e.target.removeEventListener('error', arguments.callee);
                    console.log('프로필 이미지 로드 실패, 기본 이미지로 대체');

                    // ✅ 사용자 이름을 포함한 기본 이미지로 대체 (크기 140)
                    const hostName = '${fn:escapeXml(not empty user.hostName ? user.hostName : "User")}';
                    this.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(hostName) + '&background=3399ff&color=fff&size=140';
                }, {once: true}); // ✅ once 옵션으로 한 번만 실행
            }
        }
    });
</script>

<script>
    // ✅ 페이지 로드 시 디버깅 정보 출력
    console.log('=== JSP 디버깅 정보 ===');
    console.log('user.regId:', '${user.regId}');
    console.log('user.hostName:', '${user.hostName}');
    console.log('user.hostProfileUrl:', '${user.hostProfileUrl}');
    console.log('regId 타입:', typeof '${user.regId}');
    console.log('regId 길이:', '${user.regId}'.length);

    // ✅ 채팅 열기 함수
    function openChatWithHost() {
        const hostId = '${user.regId}';
        const hostName = '${user.hostName}';

        console.log('=== openChatWithHost 호출 ===');
        console.log('hostId:', hostId);
        console.log('hostId 타입:', typeof hostId);
        console.log('hostId 길이:', hostId.length);
        console.log('hostName:', hostName);

        // ✅ null 체크 강화 (공백 제거 후 체크)
        const trimmedHostId = hostId.trim();

        if (!trimmedHostId ||
            trimmedHostId === 'null' ||
            trimmedHostId === '' ||
            trimmedHostId === 'undefined') {
            console.error('❌ hostId가 유효하지 않음:', trimmedHostId);
            alert('작성자 정보를 찾을 수 없습니다.');
            return;
        }

        console.log('✅ 채팅방 생성 요청 시작');
        console.log('요청 URL:', '/chat/createOrGetRoom?user2Id=' + encodeURIComponent(trimmedHostId));

        fetch('/chat/createOrGetRoom?user2Id=' + encodeURIComponent(trimmedHostId))
            .then(res => {
                console.log('응답 상태:', res.status);
                if (!res.ok) {
                    throw new Error('HTTP error! status: ' + res.status);
                }
                return res.json();
            })
            .then(data => {
                console.log('응답 데이터:', data);
                if (data.roomId) {
                    console.log('✅ 채팅방 생성 성공, roomId:', data.roomId);
                    window.location.href = '/chat/chatRoom?roomId=' + Number(data.roomId);
                } else {
                    console.error('❌ roomId가 없음:', data);
                    alert('채팅방 생성에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('❌ 채팅방 생성 중 오류:', error);
                alert('채팅 연결에 실패했습니다: ' + error.message);
            });
    }

    // ✅ 이미지 로드 오류 방지
    document.addEventListener('DOMContentLoaded', function() {
        const profileImg = document.querySelector('.host-avatar img');
        if (profileImg) {
            console.log('프로필 이미지 src:', profileImg.src);

            if (!profileImg.dataset.errorHandled) {
                profileImg.dataset.errorHandled = 'true';
                profileImg.addEventListener('error', function(e) {
                    console.log('❌ 프로필 이미지 로드 실패, 기본 이미지로 대체');
                    e.target.removeEventListener('error', arguments.callee);
                    this.src = '${pageContext.request.contextPath}/images/default-profile.png';
                }, {once: true});
            }
        }
    });
</script>

<script>
    // ✅ 페이지 로드 시 이미지 URL 확인
    document.addEventListener('DOMContentLoaded', function() {
        console.log('=== 프로필 이미지 디버깅 ===');
        console.log('hostProfileUrl:', '${user.hostProfileUrl}');
        console.log('hostProfileUrl 타입:', typeof '${user.hostProfileUrl}');
        console.log('hostProfileUrl 길이:', '${user.hostProfileUrl}'.length);

        const profileImg = document.querySelector('.host-avatar img');
        if (profileImg) {
            console.log('실제 img src:', profileImg.src);
            console.log('img complete:', profileImg.complete);
            console.log('img naturalWidth:', profileImg.naturalWidth);

            // ✅ 이미지 로드 성공
            profileImg.addEventListener('load', function() {
                console.log('✅ 프로필 이미지 로드 성공!');
            });

            // ✅ 이미지 로드 실패
            profileImg.addEventListener('error', function(e) {
                console.error('❌ 프로필 이미지 로드 실패');
                console.error('시도한 URL:', this.src);
                console.error('오류:', e);

                // 기본 이미지로 대체
                this.src = '${pageContext.request.contextPath}/images/default-profile.png';
            }, {once: true});
        } else {
            console.error('❌ .host-avatar img 요소를 찾을 수 없음');
        }
    });
</script>

</body>
</html>