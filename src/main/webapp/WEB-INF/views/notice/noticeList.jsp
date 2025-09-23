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
            width: 70%;
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

        #pagination button {
            background-color: transparent; /* 배경 투명 */
            border: none;                  /* 테두리 제거 */
            color: #1c407d;                /* 버튼 글자색 (원하는 색으로 변경 가능) */
            font-weight: 600;              /* 글자 굵기 */
            margin: 0 4px;                 /* 버튼 사이 간격 */
            padding: 6px 12px;             /* 클릭 영역 여유 */
            cursor: pointer;               /* 마우스 커서 포인터 */
            border-radius: 4px;            /* 약간 둥근 모서리, 필요 없으면 제거 가능 */
            font-size: 14px;               /* 글자 크기 */
            transition: background-color 0.3s ease;
        }

        #pagination button:disabled {
            color: #999;                  /* 비활성화 시 회색 */
            cursor: default;              /* 비활성화 시 커서 변경 */
        }

        #pagination button:hover:not(:disabled) {
            background-color: #e0e0e0;   /* 마우스 올렸을 때 배경 */
        }

        .notice-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: -5px;
        }

        .notice-search input[type="text"] {
            padding: 6px 10px;
            width: 250px;
            font-size: 15px;
            border: none;
            border-bottom: 1px solid #ccc;
            outline: none;
        }

        .notice-search button {
            padding: 6px 12px;
            margin-left: 6px;
            background-color: #1c407d;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
        }

        .notice-search button:hover {
            background-color: #16345f; /* 버튼 hover 색상 (선택 사항) */
        }

    </style>
</head>
<body>

<%@ include file="../includes/header.jsp" %>

<div class="notice-container">
    <div class="notice-header">
        <h2>청년정책 알림</h2>
        <div class="notice-search">
            <input type="text" id="searchInput" placeholder="제목 검색...">
            <button onclick="handleSearch()">
                <i class="fa-solid fa-magnifying-glass"></i>
            </button>
        </div>
    </div>
    <!-- JSON 데이터 전달용 div -->
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <div id="policyJsonData" data-json="<c:out value='${policiesJson}'/>" style="display: none;"></div>

    <table>
        <thead>
        <tr>
            <th>정책 No</th>
            <th>제목</th>
            <th>접수기간</th>
        </tr>
        </thead>
        <tbody id="policyTableBody"></tbody>
    </table>

    <div id="pagination" style="text-align:center; margin-top: 20px;"></div>

</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>

<script>
    const userName = "<%= ssUserName %>";

    const pageSize = 10; // 한 페이지에 보여줄 아이템 수
    let currentPage = 1;  // 현재 페이지 번호
    let totalCount = 0;   // 전체 아이템 수
    let allPolicies = []; // 전체 정책 데이터
    let filteredPolicies = []; // 🔍 검색된 데이터 저장용

    const tableBody = document.getElementById('policyTableBody');
    const paginationDiv = document.getElementById('pagination');

    // 1. JSON 데이터 파싱
    const policyJson = document.getElementById('policyJsonData').dataset.json;
    if (policyJson) {
        try {
            allPolicies = JSON.parse(policyJson);
            totalCount = allPolicies.length;
        } catch (e) {
            console.error('정책 데이터 파싱 오류:', e);
        }
    }

    // 2. 특정 페이지의 데이터 로드
    function loadPolicies(page) {
        currentPage = page;
        const data = filteredPolicies.length ? filteredPolicies : allPolicies;
        const startIdx = (page - 1) * pageSize;
        const endIdx = startIdx + pageSize;

        renderTable(data.slice(startIdx, endIdx));
        renderPagination();
    }

    // 3. 테이블 렌더링
    function renderTable(policies) {
        tableBody.innerHTML = '';
        if (policies.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="3">등록된 정책이 없습니다.</td></tr>';
            return;
        }

        function formatDate(dateStr) {
            if (!dateStr || dateStr.length !== 8) return dateStr || '-';

            const year = dateStr.substring(0, 4);
            const month = parseInt(dateStr.substring(4, 6), 10);
            const day = parseInt(dateStr.substring(6, 8), 10);

            return year + '년 ' + month + '월 ' + day + '일';
        }

        policies.forEach(policy => {
            const tr = document.createElement('tr');

            const tdNo = document.createElement('td');
            tdNo.textContent = policy.plcyNo || '정책번호 없음';

            const tdTitle = document.createElement('td');
            // 상세보기 새탭 링크 추가
            const detailLink = document.createElement('a');
            detailLink.href = `/notice/noticeDetail?plcyNo=` + policy.plcyNo;
            detailLink.textContent = policy.plcyNm || '제목 없음';
            tdTitle.appendChild(detailLink);

            const tdPeriod = document.createElement('td');
            const start = formatDate(policy.bizPrdBgngYmd);
            const end = formatDate(policy.bizPrdEndYmd);
            tdPeriod.textContent = start + ' ~ ' + end;

            tr.appendChild(tdNo);
            tr.appendChild(tdTitle);
            tr.appendChild(tdPeriod);

            tableBody.appendChild(tr);
        });
    }

    function handleSearch() {
        const keyword = document.getElementById('searchInput').value.trim().toLowerCase();

        // 제목 필터링
        filteredPolicies = allPolicies.filter(policy =>
            policy.plcyNm && policy.plcyNm.toLowerCase().includes(keyword)
        );

        totalCount = filteredPolicies.length;
        currentPage = 1;
        renderTable(filteredPolicies.slice(0, pageSize));
        renderPagination();
    }

    // 4. 페이징 버튼 렌더링
    function renderPagination() {
        paginationDiv.innerHTML = '';

        const data = filteredPolicies.length ? filteredPolicies : allPolicies;
        const totalPages = Math.ceil(data.length / pageSize);
        if (totalPages <= 1) return;

        const makeBtn = (text, page, disabled = false) => {
            const btn = document.createElement('button');
            btn.textContent = text;
            btn.disabled = disabled;
            btn.onclick = () => {
                currentPage = page;
                const startIdx = (page - 1) * pageSize;
                const endIdx = startIdx + pageSize;
                renderTable(data.slice(startIdx, endIdx));
                renderPagination();
            };
            paginationDiv.appendChild(btn);
        };

        makeBtn('<<', 1, currentPage === 1);
        makeBtn('<', currentPage - 1, currentPage === 1);

        const maxPageButtons = 6;
        let startPage = Math.max(1, currentPage - Math.floor(maxPageButtons / 2));
        let endPage = startPage + maxPageButtons - 1;
        if (endPage > totalPages) {
            endPage = totalPages;
            startPage = Math.max(1, endPage - maxPageButtons + 1);
        }

        for (let i = startPage; i <= endPage; i++) {
            makeBtn(i, i, i === currentPage);
        }

        makeBtn('>', currentPage + 1, currentPage === totalPages);
        makeBtn('>>', totalPages, currentPage === totalPages);
    }

    // 5. 초기 로드
    loadPolicies(1);
    renderPagination(allPolicies);

    // Enter 키 입력 시 검색 실행
    document.getElementById('searchInput').addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            handleSearch();
        }
    });


</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>
