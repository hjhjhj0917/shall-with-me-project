<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: "이름"</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        .detail-container {
            padding: 60px 250px;
            font-family: 'Noto Sans KR', sans-serif;
            color: #222;
        }

        .detail-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 20px;
        }

        .detail-section {
            margin-bottom: 30px;
        }

        .detail-section h3 {
            font-size: 16px;
            color: #1c407d;
            margin-bottom: 10px;
            border-bottom: 1px solid #ddd;
            padding-bottom: 6px;
        }

        .detail-section p {
            font-size: 14px;
            line-height: 1.6;
            white-space: pre-wrap;
        }

        .go-link {
            display: inline-block;
            margin-top: 10px;
            background-color: #1c407d;
            color: white;
            padding: 10px 16px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
        }

        .go-link:hover {
            background-color: #163666;
        }
    </style>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<div class="detail-container">
    <div class="detail-title" id="title"></div>

    <div class="detail-section">
        <h3>정책 설명</h3>
        <p id="expln"></p>
    </div>

    <div class="detail-section">
        <h3>지원 내용</h3>
        <p id="support"></p>
    </div>

    <div class="detail-section">
        <h3>신청 방법</h3>
        <p id="applyMethod"></p>
    </div>

    <div class="detail-section">
        <h3>제출 서류</h3>
        <p id="documents"></p>
    </div>

    <div class="detail-section">
        <h3>지원 대상 연령</h3>
        <p id="ageRange"></p>
    </div>

    <div class="detail-section">
        <h3>소득 조건</h3>
        <p id="income"></p>
    </div>

    <div class="detail-section">
        <h3>추가 자격 조건</h3>
        <p id="additional"></p>
    </div>

    <div class="detail-section">
        <h3>참여 대상</h3>
        <p id="participant"></p>
    </div>

    <div class="detail-section">
        <h3>운영기관</h3>
        <p id="operator"></p>
    </div>

    <div class="detail-section">
        <h3>주관기관</h3>
        <p id="supervisor"></p>
    </div>

    <div class="detail-section">
        <h3>사업 기간</h3>
        <p id="period"></p>
    </div>

    <div id="links"></div>
</div>

<!-- 챗봇 -->
<%@ include file="../includes/chatbot.jsp" %>
<!-- 커스텀 알림창 -->
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

<script>
    // 정책 JSON 데이터를 JavaScript 객체로 파싱
    const rawJson = '<%= request.getAttribute("policyJson") %>';
    const policy = JSON.parse(rawJson || '{}');

    // 텍스트 출력 함수
    const setText = (id, value, fallback = '-') => {
        document.getElementById(id).textContent = value || fallback;
    };

    // 데이터 채우기
    setText("title", policy.plcyNm);
    setText("expln", policy.plcyExplnCn);
    setText("support", policy.plcySprtCn);
    setText("applyMethod", policy.plcyAplyMthdCn);
    setText("documents", policy.sbmsnDcmntCn);
    setText("ageRange", (policy.sprtTrgtMinAge || '-') + '세 ~ ' + (policy.sprtTrgtMaxAge || '-') + '세');
    setText("income", `최소: ${policy.earnMinAmt || '-'}\n최대: ${policy.earnMaxAmt || '-'}\n기타: ${policy.earnEtcCn || '-'}`);
    setText("additional", policy.addAplyQlfcCndCn);
    setText("participant", policy.ptcpPrpTrgtCn);
    setText("operator", policy.operInstCdNm);
    setText("supervisor", policy.sprvsnInstCdNm);
    setText("period", `${policy.bizPrdBgngYmd || '-'} ~ ${policy.bizPrdEndYmd || '-'}`);

    // 외부 링크 버튼
    const linksContainer = document.getElementById('links');
    const createLinkButton = (url, label) => {
        if (!url) return;
        const a = document.createElement('a');
        a.href = url;
        a.target = "_blank";
        a.textContent = label;
        a.className = "go-link";
        linksContainer.appendChild(a);
    };

    createLinkButton(policy.aplyUrlAddr, '신청 바로가기');
    createLinkButton(policy.refUrlAddr1, '참고 URL 1');
    createLinkButton(policy.refUrlAddr2, '참고 URL 2');
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
</body>
</html>
