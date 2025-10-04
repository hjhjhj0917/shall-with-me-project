<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String ctx = request.getContextPath();
    String houseId = request.getParameter("houseId"); // 101, 102 ...
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시: 쉐어하우스 상세</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="<%=ctx%>/css/navbar.css"/>
    <link rel="stylesheet" href="<%=ctx%>/css/modal.css"/>
    <link rel="stylesheet" href="<%=ctx%>/css/sharehouse/sharehouseDetail.css"/>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main class="shd-wrapper">
    <!-- 상단 타이틀 + 액션 -->
    <section class="shd-titlebar">
        <h1 id="shd-title">임시 제목</h1>
        <div class="shd-actions">
            <button class="action-btn" type="button"><i class="fa-regular fa-share-from-square"></i> 공유하기</button>
            <button class="action-btn" type="button"><i class="fa-regular fa-heart"></i> 저장</button>
        </div>
    </section>

    <!-- 이미지 갤러리 -->
    <section class="shd-gallery">
        <img id="g0" alt="대표 이미지" onerror="this.src='<%=ctx%>/images/noimg.png'">
        <img id="g1" alt="썸네일 1"   onerror="this.src='<%=ctx%>/images/noimg.png'">
        <img id="g2" alt="썸네일 2"   onerror="this.src='<%=ctx%>/images/noimg.png'">
        <img id="g3" alt="썸네일 3"   onerror="this.src='<%=ctx%>/images/noimg.png'">
        <img id="g4" alt="썸네일 4"   onerror="this.src='<%=ctx%>/images/noimg.png'">
        <button class="see-all" type="button"><i class="fa-solid fa-grip"></i> 사진 모두 보기</button>
    </section>

    <!-- 본문 2컬럼 -->
    <section class="shd-body">
        <div class="col-left">
            <!-- 요약 -->
            <div class="shd-summary card">
                <div class="meta">
                    <span id="meta-type">한국의 공동 주택 전체</span>
                    <span class="dot"></span>
                    <span id="meta-guest">최대 인원 3명</span>
                    <span class="dot"></span>
                    <span id="meta-rooms">침실 1개 · 침대 2개 · 욕실 1개</span>
                </div>
                <div class="tag-row" id="tagRow"></div>
            </div>

            <!-- 소개 -->
            <div class="shd-desc card">
                <h2 class="sec-title"><i class="fa-regular fa-circle-user"></i> 호스트 소개</h2>
                <p id="hostLine">호스트 이름 · 응답 빠름</p>
                <h2 class="sec-title mt"><i class="fa-regular fa-file-lines"></i> 숙소 소개</h2>
                <p id="desc">
                    뷰/교통/편의성 중심의 임시 설명입니다. 실제 데이터 연동 전까지 예시 텍스트가 표시됩니다.
                    좌측 상단 큰 이미지 + 우측 4분할 썸네일 구조는 에어비앤비 스타일과 유사하게 구성되어 있습니다.
                </p>
            </div>

            <!-- 편의시설 -->
            <div class="shd-amenities card">
                <h2 class="sec-title"><i class="fa-solid fa-screwdriver-wrench"></i> 편의시설</h2>
                <ul class="amenity-list" id="amenityList"></ul>
            </div>
        </div>

        <!-- 우측 스티키 카드 -->
        <aside class="col-right">
            <div class="shd-sticky card">
                <div class="price-line">
                    <strong id="price">₩99,000</strong><span>/박 (임시)</span>
                </div>
                <div class="mini-form">
                    <div class="mf-row">
                        <label>체크인</label>
                        <input type="text" placeholder="날짜 선택 (임시)">
                    </div>
                    <div class="mf-row">
                        <label>체크아웃</label>
                        <input type="text" placeholder="날짜 선택 (임시)">
                    </div>
                    <div class="mf-row">
                        <label>인원</label>
                        <select>
                            <option>1명</option><option>2명</option><option>3명</option><option>4명</option>
                        </select>
                    </div>
                    <button class="reserve-btn" type="button">문의하기</button>
                </div>
                <p class="notice"><i class="fa-solid fa-circle-exclamation"></i> 이 페이지는 데이터 연동 전 임시 화면입니다.</p>
            </div>
        </aside>
    </section>
</main>

<%@ include file="../includes/footer.jsp" %>

<script>
    const ctx = '<%=ctx%>';
    const uid = '<%=houseId != null ? houseId : ""%>';
    const STAMP = Date.now(); // 캐시 버스터

    // ✅ 캐시 버스팅 헬퍼 (항상 최신 이미지 로드)
    const bust = (url) => `${url}?v=${Date.now()}`;

    // 👉 억지 캐시 무력화용 타임스탬프
    const imgSet = function(id){
        return [
            ctx + "/images/sample/" + id + "/hero.jpg?v="   + STAMP,
            ctx + "/images/sample/" + id + "/a.jpg?v="      + STAMP,
            ctx + "/images/sample/" + id + "/b.jpg?v="      + STAMP,
            ctx + "/images/sample/" + id + "/gym.jpg?v="    + STAMP,
            ctx + "/images/sample/" + id + "/living.jpg?v=" + STAMP
        ];
    };

    const DUMMY = {
        "101": {
            title: "부산역 KTX 3min, 침보관, 고층, 하프오션뷰 #101",
            host: "김부산",
            type: "한국의 공동 주택 전체",
            guest: "최대 인원 3명",
            rooms: "침실 1개 · 침대 2개 · 욕실 1개",
            price: "₩120,000",
            tags: ["역세권", "오션뷰", "체크인셀프", "금연"],
            amenities: ["와이파이","에어컨","난방","TV","드럼세탁기","건조기","피트니스","주차가능"],
            images: imgSet("101")
        },
        "102": {
            title: "광안리 2min, 오션뷰 라운지, 루프탑 #102",
            host: "박광안",
            type: "한국의 공동 주택 전체",
            guest: "최대 인원 4명",
            rooms: "침실 2개 · 침대 3개 · 욕실 2개",
            price: "₩150,000",
            tags: ["바다근처","루프탑","조용한동네"],
            amenities: ["와이파이","에어컨","주방","식기세척기","엘리베이터","루프탑","주차가능"],
            images: imgSet("102")
        }
    };

    const FALLBACK = {
        title: "임시 쉐어하우스 상세",
        host: "살며시 호스트",
        type: "한국의 공동 주택 전체",
        guest: "최대 인원 3명",
        rooms: "침실 1개 · 침대 2개 · 욕실 1개",
        price: "₩99,000",
        tags: ["임시데이터", "미리보기"],
        amenities: ["와이파이", "에어컨", "주방", "세탁기"],
        images: [
            ctx + "/images/noimg.png",
            ctx + "/images/noimg.png",
            ctx + "/images/noimg.png",
            ctx + "/images/noimg.png",
            ctx + "/images/noimg.png"
        ]
    };

    const data = DUMMY[uid] || FALLBACK;

    // 타이틀/메타 주입
    document.getElementById('shd-title').textContent = data.title;
    document.getElementById('meta-type').textContent = data.type;
    document.getElementById('meta-guest').textContent = data.guest;
    document.getElementById('meta-rooms').textContent = data.rooms;
    document.getElementById('hostLine').textContent = `${data.host} · 응답 빠름`;
    document.getElementById('price').textContent = data.price;

    // 태그 칩
    const tagRow = document.getElementById('tagRow');
    data.tags.forEach(t => {
        const s = document.createElement('span');
        s.className = 'chip';
        s.textContent = `# ${t}`;
        tagRow.appendChild(s);
    });

    // 편의시설
    const amen = document.getElementById('amenityList');
    data.amenities.forEach(a => {
        const li = document.createElement('li');
        li.innerHTML = `<i class="fa-regular fa-circle-check"></i> ${a}`;
        amen.appendChild(li);
    });

    // 이미지 주입
    ['g0','g1','g2','g3','g4'].forEach(function(id, i){
        const el = document.getElementById(id);
        if (el) el.src = data.images[i] || (ctx + "/images/noimg.png");
    });
</script>
</body>
</html>
