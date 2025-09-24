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