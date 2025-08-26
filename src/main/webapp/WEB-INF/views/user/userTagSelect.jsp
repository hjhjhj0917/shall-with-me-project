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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <style>
        .progress-indicator {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 50px;
            gap: 10px;
        }

        .step-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            cursor: pointer;
        }

        .step {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: 2px solid #3a7bff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            background-color: white;
            color: #3a7bff;
            transition: all 0.3s ease;
            text-align: center;
        }

        .step.active {
            background-color: #3399ff;
            color: white;
            border-color: #3399ff;
        }

        .step.completed {
            background-color: #3399ff;
            color: white;
            border-color: #3399ff;
        }

        .line {
            flex: none;
            width: 130px;
            height: 2px;
            background-color: #3a7bff;
            margin: 0 5px;
        }

    </style>
</head>
<body>

<header>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack">
            <i class="fa-solid fa-people-roof fa-xs" style="color: #3399ff;"></i>
        </div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span> <!-- 둥근 반스도 역할 -->
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle">
                <i class="fa-solid fa-repeat fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span> <!-- 둥근 반스도 역할 -->
            <span class="user-name-text" id="userNameText">
                <%= session.getAttribute("SS_USER_NAME") %>님
            </span>
            <button class="header-dropdown-toggle" id="userIconToggle">
                <i class="fa-solid fa-circle-user fa-sm" style="color: #1c407d;"></i>
            </button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span> <!-- 둥근 반스도 역할 -->
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle">
                <i class="fa-solid fa-bars fa-xs" style="color: #1c407d;"></i>
            </button>
        </div>
    </div>
</header>

<!-- 슬라이드 화살표 -->
<%--<div class="arrow left" onclick="moveSlide(-1)">&#10092;</div>--%>
<%--<div class="arrow right" onclick="moveSlide(1)">&#10093;</div>--%>

<div class="header">
    <div class="logo">살며시</div>
    <div class="logo-2">Shall With Me</div>
    <div class="subtitle">
        <%= session.getAttribute("SS_USER_NAME") %>님의 라이프 스타일을 한가지 씩 선택하여 주세요
    </div>
</div>

<%--<div class="progress-indicator">--%>
<%--    <div class="step-wrapper" onclick="goToSlide(0)">--%>
<%--        <div class="step" data-index="0">1</div>--%>
<%--    </div>--%>
<%--    <div class="line"></div>--%>
<%--    <div class="step-wrapper" onclick="goToSlide(1)">--%>
<%--        <div class="step" data-index="1">2</div>--%>
<%--    </div>--%>
<%--    <div class="line"></div>--%>
<%--    <div class="step-wrapper" onclick="goToSlide(2)">--%>
<%--        <div class="step" data-index="2">3</div>--%>
<%--    </div>--%>
<%--    <div class="line"></div>--%>
<%--    <div class="step-wrapper" onclick="goToSlide(3)">--%>
<%--        <div class="step" data-index="3">4</div>--%>
<%--    </div>--%>
<%--</div>--%>

<div class="slider-container" id="slider">
    <!-- 슬라이드 1 -->
    <div class="slide">

        <div class="section">
            <fieldset class="box">
                <legend>생활패턴</legend>
                <div class="button-group" data-group="lifestyle">
                    <button onclick="selectButton(this)" data-tag="1">아침형</button>
                    <button onclick="selectButton(this)" data-tag="2">저녁형</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>활동범위</legend>
                <div class="button-group" data-group="activity">
                    <button onclick="selectButton(this)" data-tag="3">집콕</button>
                    <button onclick="selectButton(this)" data-tag="4">활동형</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>직업</legend>
                <div class="button-group" data-group="job">
                    <button onclick="selectButton(this)" data-tag="5">학생</button>
                    <button onclick="selectButton(this)" data-tag="6">직장인</button>
                    <button onclick="selectButton(this)" data-tag="7">프리랜서/무직</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>퇴근 시간</legend>
                <div class="button-group" data-group="worktime">
                    <button onclick="selectButton(this)" data-tag="8">일정함</button>
                    <button onclick="selectButton(this)" data-tag="9">변동적</button>
                    <button onclick="selectButton(this)" data-tag="10">야근 잦음</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>손님초대</legend>
                <div class="button-group" data-group="guest">
                    <button onclick="selectButton(this)" data-tag="11">자주</button>
                    <button onclick="selectButton(this)" data-tag="12">거의 안함</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>물건공유</legend>
                <div class="button-group" data-group="share">
                    <button onclick="selectButton(this)" data-tag="13">가능</button>
                    <button onclick="selectButton(this)" data-tag="14">불가능</button>
                </div>
            </fieldset>
        </div>
    </div>

    <!-- 슬라이드 2 -->
    <div class="slide four-boxes">

        <div class="section">
            <fieldset class="box">
                <legend>성격</legend>
                <div class="button-group" data-group="personality">
                    <button onclick="selectButton(this)" data-tag="15">내향적</button>
                    <button onclick="selectButton(this)" data-tag="16">중간</button>
                    <button onclick="selectButton(this)" data-tag="17">외향적</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>선호하는 성격</legend>
                <div class="button-group" data-group="preferred-personality">
                    <button onclick="selectButton(this)" data-tag="18">조용한 사람</button>
                    <button onclick="selectButton(this)" data-tag="19">활발한 사람</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>대화</legend>
                <div class="button-group" data-group="talk">
                    <button onclick="selectButton(this)" data-tag="20">자주</button>
                    <button onclick="selectButton(this)" data-tag="21">필요할 때</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>갈등</legend>
                <div class="button-group" data-group="conflict">
                    <button onclick="selectButton(this)" data-tag="22">회피형</button>
                    <button onclick="selectButton(this)" data-tag="23">해결형</button>
                </div>
            </fieldset>
        </div>
    </div>

    <!-- 슬라이드 3-->
    <div class="slide four-boxes">

        <div class="section">
            <fieldset class="box">
                <legend>요리</legend>
                <div class="button-group" data-group="cook">
                    <button onclick="selectButton(this)" data-tag="24">요리</button>
                    <button onclick="selectButton(this)" data-tag="25">배달</button>
                    <button onclick="selectButton(this)" data-tag="26">외식</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>주식</legend>
                <div class="button-group" data-group="diet">
                    <button onclick="selectButton(this)" data-tag="27">채식</button>
                    <button onclick="selectButton(this)" data-tag="28">육식</button>
                    <button onclick="selectButton(this)" data-tag="29">둘 다</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>끼니</legend>
                <div class="button-group" data-group="meal">
                    <button onclick="selectButton(this)" data-tag="30">한 끼</button>
                    <button onclick="selectButton(this)" data-tag="31">두 끼</button>
                    <button onclick="selectButton(this)" data-tag="32">세 끼</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>음식 냄새</legend>
                <div class="button-group" data-group="cook-semll">
                    <button onclick="selectButton(this)" data-tag="33">예민</button>
                    <button onclick="selectButton(this)" data-tag="34">상관없음</button>
                </div>
            </fieldset>
        </div>
    </div>

    <!-- 슬라이드 4-->
    <div class="slide four-boxes">

        <div class="section">
            <fieldset class="box">
                <legend>청결</legend>
                <div class="button-group" data-group="clean">
                    <button onclick="selectButton(this)" data-tag="35">깔끔이</button>
                    <button onclick="selectButton(this)" data-tag="36">중간이</button>
                    <button onclick="selectButton(this)" data-tag="37">대충이</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>청소 주기</legend>
                <div class="button-group" data-group="clean-circle">
                    <button onclick="selectButton(this)" data-tag="38">주 1회</button>
                    <button onclick="selectButton(this)" data-tag="39">주 2회</button>
                    <button onclick="selectButton(this)" data-tag="40">주 3회 이상</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>쓰레기 배출</legend>
                <div class="button-group" data-group="trash">
                    <button onclick="selectButton(this)" data-tag="41">바로바로</button>
                    <button onclick="selectButton(this)" data-tag="42">쌓아두기</button>
                </div>
            </fieldset>

            <fieldset class="box">
                <legend>설거지</legend>
                <div class="button-group" data-group="wash-dish">
                    <button onclick="selectButton(this)" data-tag="43">바로바로</button>
                    <button onclick="selectButton(this)" data-tag="44">쌓아두기</button>
                </div>
            </fieldset>
        </div>
    </div>
</div>

<div class="restore">
    <button id="saveButton">저장</button>
</div>

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

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>
<script>
    const userName = "<%= ssUserName %>";
</script>
<%
    String ssUserId = (String) session.getAttribute("SS_USER_ID");
    if (ssUserId == null) {
        ssUserId = "";
    }
%>
<script>
    const userId = "<%= ssUserId %>";
    console.log(userId);
</script>

<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/tag.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>

</body>
</html>

