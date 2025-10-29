<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css"/>
    <style>
        /* 오른쪽 영역 클릭 가능하도록 cursor 추가 */
        .right-panel {
            cursor: pointer;
        }
    </style>
</head>
<body>

<div class="main-container">
    <!-- 왼쪽 텍스트 -->
    <div class="left-panel">
        <div class="text-box">
            <div id="textContainer" class="slide-text"></div>
        </div>
    </div>

    <div class="wave-left">
        <svg viewBox="0 0 800 800" preserveAspectRatio="none">
            <path d="M0,0 C150,200 150,600 0,800 L0,0 Z" fill="#f4f9fe"/>
        </svg>
    </div>

    <!-- 오른쪽 비스듬한 영역 (클릭 시 이동) -->
    <div class="right-panel" id="rightPanel">
        <div class="wave-left">
            <svg viewBox="0 0 800 800" preserveAspectRatio="none">
                <path d="M0,0 C150,200 150,600 0,800 L0,0 Z" fill="#ffffff"/>
            </svg>
        </div>
        <div class="right-inner">
            <div class="logo">살며시</div>
            <div class="logo-2">Shall With Me</div>
        </div>
    </div>

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
    const interval = setInterval(() => {
        idx = (idx + 1) % texts.length;
        showText(idx);
    }, 4000);

    // 오른쪽 영역 클릭 시 메인으로 이동
    const rightPanel = document.getElementById("rightPanel");
    rightPanel.addEventListener("click", () => {
        window.location.href = "/user/main";
    });

    // 특정 시간 후(예: 12초) 자동 이동
    setTimeout(() => {
        window.location.href = "/user/main";
    }, 12000);
</script>

</body>
</html>
