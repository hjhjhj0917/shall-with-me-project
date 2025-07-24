<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>살며시</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body, html {
            width: 100%;
            height: 100%;
            font-family: 'Noto Sans KR', sans-serif;
        }

        .container {
            position: relative;
            width: 100%;
            height: 100vh;
            background: #fff;
            overflow: hidden;
        }

        .background {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 200px;
            /*background: url('/mnt/data/3cd2464c-c857-4492-99d0-4a18f660e670.png') no-repeat center bottom;*/
            background-size: cover;
            z-index: 1;
        }

        .angled-shadow {
            position: absolute;
            top: 0;
            right: 0;
            width: 50%;
            height: 100%;
            background: #e6eef6;
            clip-path: polygon(30% 0%, 100% 0%, 100% 100%, 0% 100%);
            transition: all 0.5s ease;
            z-index: 3;             /* 수정됨 */
            pointer-events: auto;
        }

        .angled-shadow.enlarged {
            clip-path: polygon(20% 0%, 100% 0%, 100% 100%, 0% 100%);
        }

        .content {
            position: relative;
            z-index: 2;
            display: flex;
            height: 100%;
            align-items: center;
            justify-content: space-between;
            padding: 0 5%;
            /*background-image: url("kpaas-background.png");*/
        }

        .left-text {
            text-align: center;
            font-size: 30px;
            margin-left: 250px;
            margin-bottom: 30px;
        }

        .right-box {
            text-align: center;
        }

        .title {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .subtitle {
            font-size: 14px;
            color: #555;
            margin-bottom: 20px;
        }

        .start-button {
            padding: 12px 24px;
            font-size: 18px;
            background-color: #2e73f2;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .start-button:hover {
            background-color: #1d55c5;
        }
    </style>
</head>
<body>
<div class="container" id="mainContainer">
    <div class="angled-shadow" id="angledShadow"></div>

    <div class="content">
        <div class="left-text-container">
            <div class="left-text">자신과 비슷한 성향의 룸메이트를<br>찾아보세요</div>
            <!-- <div class="left-text">자신의 주변 쉐어하우스를<br>찾아보세요</div> -->
        </div>
    </div>

    <div class="right-box">
        <div class="title">살며시</div>
        <div class="subtitle">Shall With Me</div>
        <button class="start-button">시작하기</button>
    </div>

    <div class="background"></div>
</div>

<script>
    const shadow = document.getElementById('angledShadow');
    const container = document.getElementById('mainContainer');

    shadow.addEventListener('mouseenter', () => {
        shadow.classList.add('enlarged');
    });

    container.addEventListener('mousemove', (e) => {
        const shadowRect = shadow.getBoundingClientRect();
        if (
            e.clientX < shadowRect.left ||
            e.clientY < shadowRect.top ||
            e.clientX > shadowRect.right ||
            e.clientY > shadowRect.bottom
        ) {
            shadow.classList.remove('enlarged');
        }
    });
</script>
</body>
</html>

