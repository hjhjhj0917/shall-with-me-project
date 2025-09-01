<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>살며시: 성향태그 선택</title>

    <link rel="stylesheet" href="/css/tag.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/loginNavBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/userform.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/logo.css"/>

    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        /* userRegForm의 폼 Wrapper 디자인 적용 */
        .register-form-wrapper {
            width: 1100px;
            margin: 0 auto;
            padding: 24px 32px;
            background-color: #FFFFFF;
            height: 820px;
            border-radius: 12px;
            border-top-right-radius: 0;
            box-shadow: -3px -3px 16px rgba(0, 0, 0, 0.1), 6px 5px 16px rgba(0, 0, 0, 0.27);
            position: relative;
            text-align: center;
            box-sizing: border-box;
            overflow: visible;
        }

        /* 탭 디자인 */
        .register-tab, .prefer-tab, .profile-tab {
            margin-bottom: 12px;
        }

        .register-tab {
            position: absolute;
            top: 10.34%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #4da3ff;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;
            box-shadow: 2px 0px 10px rgba(0, 0, 0, 0.25);
            z-index: 2;
        }

        .prefer-tab {
            position: absolute;
            top: 30.5%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #91C4FB;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;
            box-shadow: 2px 0px 10px rgba(0, 0, 0, 0.25);
            z-index: 1;
        }

        .profile-tab {
            position: absolute;
            top: 51%;
            right: -30px;
            transform: translateY(-50%);
            background-color: #B1B1B1;
            color: white;
            font-weight: bold;
            font-size: 14px;
            padding: 10px 5px;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            cursor: default;
            height: 150px;
            border-bottom-right-radius: 30px;
            border-top-right-radius: 12px;
            box-shadow: 2px 0px 10px rgba(0, 0, 0, 0.25);
        }

        .active-tab {
            right: -39px;
            font-size: 20px !important;
            z-index: 3 !important;
        }

        .header {
            padding-bottom: 0;
        }

    </style>
</head>
<body>

<%@ include file="../includes/header.jsp" %>

<div class="register-form-wrapper">
    <div class="register-tab">REGISTER</div>
    <div class="prefer-tab active-tab">PREFER</div>
    <div class="profile-tab">PROFILE</div>

    <div class="header">
        <div class="logo">PREFER</div>
        <div class="logo-2">살며시</div>
    </div>

    <div class="tag-content-wrapper">
        <div class="header">
            <div class="subtitle">
                <%= session.getAttribute("SS_USER_NAME") %>님의 라이프 스타일을 한가지 씩 선택하여 주세요
            </div>
        </div>

        <div class="progress-indicator">
            <div class="step-wrapper" onclick="goToSlide(0)">
                <div class="step" data-index="0">
                    <i class="fa-solid fa-check"></i>
                </div>
                <div>생활</div>
            </div>
            <div class="line"></div>
            <div class="step-wrapper" onclick="goToSlide(1)">
                <div class="step" data-index="1">
                    <i class="fa-solid fa-check"></i>
                </div>
                <div>성격</div>
            </div>
            <div class="line"></div>
            <div class="step-wrapper" onclick="goToSlide(2)">
                <div class="step" data-index="2">
                    <i class="fa-solid fa-check"></i>
                </div>
                <div>식습관</div>
            </div>
            <div class="line"></div>
            <div class="step-wrapper" onclick="goToSlide(3)">
                <div class="step" data-index="3">
                    <i class="fa-solid fa-check"></i>
                </div>
                <div>청결</div>
            </div>
        </div>

        <div class="slider-container" id="slider">
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

        <!-- 저장 버튼 -->
        <button type="button" id="saveButton" class="floating-save">
            <i class="fa-solid fa-floppy-disk"></i><span>저장</span>
        </button>

    </div>
</div>

<%@ include file="../includes/customModal.jsp" %>

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