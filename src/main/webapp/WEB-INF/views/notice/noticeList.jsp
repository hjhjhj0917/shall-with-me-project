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

    <div id="pagination" style="text-align:center; margin-top: 20px;"></div>

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
    const pageSize = 10; // 한 페이지에 보여줄 아이템 수
    let currentPage = 1;  // 현재 페이지 번호
    let totalCount = 0;   // 전체 아이템 수

    const tableBody = document.getElementById('policyTableBody');
    const paginationDiv = document.getElementById('pagination');
    console.log("paginationDiv.innerHTML : ", paginationDiv.innerHTML);
    console.log("totalCount:", totalCount, "pageSize:", pageSize);

    // 페이지 데이터 가져오기 함수 (AJAX 요청)
    function loadPolicies(page) {
        fetch(window.location.origin + '/notice/api?page=' + page + '&size=' + pageSize)
            .then(res => res.json())
            .then(data => {
                const policies = data.policies || [];
                totalCount = data.totalCount || 0;
                currentPage = page;

                renderTable(policies);
                renderPagination();
            })
            .catch(err => {
                console.error('데이터 로드 실패:', err);
                tableBody.innerHTML = '<tr><td colspan="4">데이터를 불러오는데 실패했습니다.</td></tr>';
                paginationDiv.innerHTML = '';
            });
    }

    // 테이블 내용 렌더링 함수
    function renderTable(policies) {
        tableBody.innerHTML = '';
        if (policies.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="4">등록된 공지사항이 없습니다.</td></tr>';
            return;
        }

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

    // 페이징 버튼 렌더링 함수
    function renderPagination() {
        paginationDiv.innerHTML = '';

        const totalPages = Math.ceil(totalCount / pageSize);
        if (totalPages <= 1) return; // 페이지가 1개 이하이면 페이징 표시 안함

        // 이전 버튼
        const prevBtn = document.createElement('button');
        prevBtn.textContent = '<';
        prevBtn.disabled = currentPage === 1;
        prevBtn.onclick = () => {
            if (currentPage > 1) loadPolicies(currentPage - 1);
        };
        paginationDiv.appendChild(prevBtn);

        // 페이지 번호 버튼들 (최대 6개 표시)
        const maxPageButtons = 6;
        let startPage = Math.max(1, currentPage - Math.floor(maxPageButtons / 2));
        let endPage = startPage + maxPageButtons - 1;

        if (endPage > totalPages) {
            endPage = totalPages;
            startPage = Math.max(1, endPage - maxPageButtons + 1);
        }

        for (let i = startPage; i <= endPage; i++) {
            const pageBtn = document.createElement('button');
            pageBtn.textContent = i;
            pageBtn.disabled = (i === currentPage);
            pageBtn.onclick = () => loadPolicies(i);
            paginationDiv.appendChild(pageBtn);
        }

        // 다음 버튼
        const nextBtn = document.createElement('button');
        nextBtn.textContent = '>';
        nextBtn.disabled = currentPage === totalPages;
        nextBtn.onclick = () => {
            if (currentPage < totalPages) loadPolicies(currentPage + 1);
        };
        paginationDiv.appendChild(nextBtn);
    }

    // 초기 로드
    loadPolicies(1);
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

</body>
</html>
