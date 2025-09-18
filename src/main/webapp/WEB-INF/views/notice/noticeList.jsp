<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 공지사항</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        .notice-container {
            padding: 60px 250px;
        }

        h2 {
            font-weight: 700;
            font-size: 18px;
            margin-bottom: 20px;
            color: #222;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            color: #222;
        }

        thead tr {
            border-bottom: 1px solid #ccc;
        }

        thead th {
            font-weight: 500;
            padding: 15px 6px;
            text-align: left;
            color: white;
            background-color: #1c407d;
            border-bottom: 1px solid #ccc;
        }

        tbody tr {
            border-bottom: 1px solid #eee;
            background-color: white;
        }

        tbody td {
            padding: 15px 6px;
            vertical-align: middle;
            color: #444;
        }

        tbody td:nth-child(2) {
            width: 60%;
            font-weight: 600;
            white-space: normal;
            word-break: break-word;
        }

        tbody td:nth-child(1),
        tbody td:nth-child(3),
        tbody td:nth-child(4) {
            width: auto;
            color: #666;
        }

        tbody td a {
            color: #222;
            text-decoration: none;
        }

        tbody td a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<%@ include file="../includes/header.jsp" %>

<div class="notice-container">
    <h2>청년정책 알림</h2>

    <!-- JSON 데이터 전달용 div -->
    <div id="policyJsonData" data-json='${policiesJson}' style="display: none;"></div>

    <table>
        <thead>
        <tr>
            <th>정책 No</th>
            <th>제목</th>
            <th>접수기간</th>
            <th>바로가기</th>
        </tr>
        </thead>
        <tbody id="policyTableBody"></tbody>
    </table>
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

    // JSON 데이터 가져오기
    const jsonDataDiv = document.getElementById("policyJsonData");
    const rawJsonString = jsonDataDiv?.dataset?.json || "[]";

    let policies = [];
    try {
        policies = JSON.parse(rawJsonString);
    } catch (e) {
        console.error("JSON 파싱 오류:", e);
    }

    const tableBody = document.getElementById('policyTableBody');

    if (!policies || policies.length === 0) {
        const emptyRow = document.createElement('tr');
        emptyRow.innerHTML = '<td colspan="4">등록된 공지사항이 없습니다.</td>';
        tableBody.appendChild(emptyRow);
    } else {
        policies.forEach(policy => {
            const tr = document.createElement('tr');

            const tdNo = document.createElement('td');
            tdNo.textContent = policy.plcyNo || '정책번호 없음';

            const tdTitle = document.createElement('td');
            tdTitle.textContent = policy.plcyNm || '제목 없음';

            const tdPeriod = document.createElement('td');
            tdPeriod.textContent = `${policy.bizPrdBgngYmd || '-'} ~ ${policy.bizPrdEndYmd || '-'}`;

            const tdLink = document.createElement('td');
            const a = document.createElement('a');
            a.href = policy.aplyUrlAddr || '#';
            a.target = '_blank';
            a.textContent = '바로가기';
            tdLink.appendChild(a);

            tr.appendChild(tdNo);
            tr.appendChild(tdTitle);
            tr.appendChild(tdPeriod);
            tr.appendChild(tdLink);

            tableBody.appendChild(tr);
        });
    }
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>
