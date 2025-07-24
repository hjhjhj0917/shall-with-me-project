<%--
  Created by IntelliJ IDEA.
  User: data8320-16
  Date: 2025-07-24
  Time: 오후 4:00
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>살며시</title>
    <link rel="stylesheet" href="/css/tag.css"/>
    <script src="${pageContext.request.contextPath}/js/tag.js"></script>
</head>
<body>

<!-- 슬라이드 화살표 -->
<div class="arrow left" onclick="moveSlide(-1)">&#10094;</div>
<div class="arrow right" onclick="moveSlide(1)">&#10095;</div>

<div class="header">
    <h1>살며시</h1>
    <h2>Shall With Me</h2>
    <div class="subtitle">홍길동님의 라이프 스타일을 한가지 씩 선택하여 주세요</div>
</div>

<div class="slider-container" id="slider">
    <!-- 슬라이드 1 -->
    <div class="slide">

        <div class="section">
            <fieldset class="box">
                <legend>생활패턴</legend>
                <div class="button-group" data-group="lifestyle">
                    <button onclick="selectButton(this)">아침형</button>
                    <button onclick="selectButton(this)">저녁형</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>활동범위</legend>
                <div class="button-group" data-group="activity">
                    <button onclick="selectButton(this)">집콕</button>
                    <button onclick="selectButton(this)">활동형</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>직업</legend>
                <div class="button-group" data-group="job">
                    <button onclick="selectButton(this)">학생</button>
                    <button onclick="selectButton(this)">직장인</button>
                    <button onclick="selectButton(this)">프리랜서/무직</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>퇴근 시간</legend>
                <div class="button-group" data-group="worktime">
                    <button onclick="selectButton(this)">일정함</button>
                    <button onclick="selectButton(this)">변동적</button>
                    <button onclick="selectButton(this)">야근 잦음</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>손님초대</legend>
                <div class="button-group" data-group="guest">
                    <button onclick="selectButton(this)">자주</button>
                    <button onclick="selectButton(this)">거의 안함</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>물건공유</legend>
                <div class="button-group" data-group="share">
                    <button onclick="selectButton(this)">가능</button>
                    <button onclick="selectButton(this)">불가능</button>
                </div>
            </fieldset>
        </div>
    </div>

    <!-- 슬라이드 2 -->
    <div class="slide">

        <div class="section">
            <fieldset class="box">
                <legend>성격</legend>
                <div class="button-group" data-group="personality">
                    <button onclick="selectButton(this)">내향적</button>
                    <button onclick="selectButton(this)">중간</button>
                    <button onclick="selectButton(this)">외향적</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>선호하는 성격</legend>
                <div class="button-group" data-group="preferred-personality">
                    <button onclick="selectButton(this)">조용한 사람</button>
                    <button onclick="selectButton(this)">활발한 사람</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>대화</legend>
                <div class="button-group" data-group="talk">
                    <button onclick="selectButton(this)">자주</button>
                    <button onclick="selectButton(this)">필요할 때</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>갈등</legend>
                <div class="button-group" data-group="conflict">
                    <button onclick="selectButton(this)">회피형</button>
                    <button onclick="selectButton(this)">해결형</button>
                </div>
            </fieldset>
        </div>
    </div>

    <!-- 슬라이드 3-->
    <div class="slide">

        <div class="section">
            <fieldset class="box">
                <legend>요리</legend>
                <div class="button-group" data-group="cook">
                    <button onclick="selectButton(this)">요리</button>
                    <button onclick="selectButton(this)">배달</button>
                    <button onclick="selectButton(this)">외식</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>주식</legend>
                <div class="button-group" data-group="diet">
                    <button onclick="selectButton(this)">채식</button>
                    <button onclick="selectButton(this)">육식</button>
                    <button onclick="selectButton(this)">둘 다</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>끼니</legend>
                <div class="button-group" data-group="meal">
                    <button onclick="selectButton(this)">한 끼</button>
                    <button onclick="selectButton(this)">두 끼</button>
                    <button onclick="selectButton(this)">세 끼</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>음식 냄새</legend>
                <div class="button-group" data-group="cook-semll">
                    <button onclick="selectButton(this)">예민</button>
                    <button onclick="selectButton(this)">상관없음</button>
                </div>
            </fieldset>
        </div>
    </div>

    <!-- 슬라이드 4-->
    <div class="slide">

        <div class="section">
            <fieldset class="box">
                <legend>청결</legend>
                <div class="button-group" data-group="clean">
                    <button onclick="selectButton(this)">깔끔이</button>
                    <button onclick="selectButton(this)">중간이</button>
                    <button onclick="selectButton(this)">대충이</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>청소 주기</legend>
                <div class="button-group" data-group="clean-circle">
                    <button onclick="selectButton(this)">주 1회</button>
                    <button onclick="selectButton(this)">주 2회</button>
                    <button onclick="selectButton(this)">주 3회 이상</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>쓰레기 배출</legend>
                <div class="button-group" data-group="trash">
                    <button onclick="selectButton(this)">바로바로</button>
                    <button onclick="selectButton(this)">쌓아두기</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>설거지</legend>
                <div class="button-group" data-group="wash-dish">
                    <button onclick="selectButton(this)">바로바로</button>
                    <button onclick="selectButton(this)">쌓아두기</button>
                </div>
            </fieldset>
        </div>
    </div>
</div>

<div class="restore">
    <button id="saveButton">저장</button>
</div>
</body>
</html>

