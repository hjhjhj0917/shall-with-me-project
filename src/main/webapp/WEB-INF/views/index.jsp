<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시</title>
    <link rel="stylesheet" href="/css/index.css"/>
</head>
<body>

<div class="main-container">
    <!-- 왼쪽 텍스트 -->
    <div class="left-panel">
        <div class="text-box">
            <div id="textContainer" class="slide-text"></div>
        </div>
    </div>

    <!-- 오른쪽 비스듬한 영역 -->
    <div class="right-panel">
        <div class="right-inner">
            <div class="logo">살며시</div>
            <div class="logo-2">Shall With Me</div>
            <form action="${pageContext.request.contextPath}/start" method="get">
                <button type="submit" class="start-button">시작하기</button>
            </form>
        </div>
    </div>

    <!-- 도시 배경 이미지 -->
    <img src="${pageContext.request.contextPath}/static/images/city-bg.png" alt="city" class="city-img">
</div>

<script>
    const texts = [
        "자신과 비슷한 성향의 룸메이트를 찾아보세요",
        "살며시는 당신의 새로운 동거를 응원합니다",
        "당신의 라이프스타일에 맞는 사람을 매칭해보세요"
    ];

    let idx = 0;
    const textContainer = document.getElementById("textContainer");

    function showText(index) {
        textContainer.style.opacity = 0;
        textContainer.style.transform = "translateY(10px)";
        setTimeout(() => {
            textContainer.innerText = texts[index];
            textContainer.style.opacity = 1;
            textContainer.style.transform = "translateY(0)";
        }, 300);
    }

    showText(idx);
    setInterval(() => {
        idx = (idx + 1) % texts.length;
        showText(idx);
    }, 3000);
</script>

</body>
</html>
