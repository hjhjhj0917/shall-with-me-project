const userName = "<%= ssUserName %>";

const pageSize = 10;
let currentPage = 1;
let allPolicies = [];
let filteredPolicies = [];

const tableBody = document.getElementById('policyTableBody');
const paginationDiv = document.getElementById('pagination');
const searchInput = document.getElementById('searchInput');

// ▶️ JSON 파싱
const policyJson = document.getElementById('policyJsonData').dataset.json;
if (policyJson) {
    try {
        allPolicies = JSON.parse(policyJson);
    } catch (e) {
        console.error('정책 데이터 파싱 오류:', e);
    }
}

// ✅ 페이지 로드 시 URL에 따라 초기 페이지 설정
const params = new URLSearchParams(window.location.search);
currentPage = parseInt(params.get("page")) || 1;

window.addEventListener("popstate", () => {
    const newParams = new URLSearchParams(window.location.search);
    currentPage = parseInt(newParams.get("page")) || 1;
    render(currentPage);
});

// ▶️ 메인 렌더링 함수
function render(page) {
    currentPage = page;
    const data = filteredPolicies.length ? filteredPolicies : allPolicies;
    const startIdx = (page - 1) * pageSize;
    const endIdx = startIdx + pageSize;

    renderTable(data.slice(startIdx, endIdx));
    renderPagination(data.length);
}

// ▶️ 테이블 렌더링
function renderTable(policies) {
    tableBody.innerHTML = '';

    if (policies.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="3">등록된 정책이 없습니다.</td></tr>';
        return;
    }

    function formatDate(dateStr) {
        if (!dateStr || dateStr.length !== 8) return dateStr || '-';
        const y = dateStr.substring(0, 4);
        const m = parseInt(dateStr.substring(4, 6), 10);
        const d = parseInt(dateStr.substring(6, 8), 10);
        return `${y}년 ${m}월 ${d}일`;
    }

    policies.forEach(policy => {
        const tr = document.createElement('tr');

        const tdNo = document.createElement('td');
        tdNo.textContent = policy.plcyNo || '정책번호 없음';

        const tdTitle = document.createElement('td');
        const detailLink = document.createElement('a');
        detailLink.href = `/notice/noticeDetail?plcyNo=${policy.plcyNo}&page=${currentPage}`;
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

// ▶️ 페이지네이션 렌더링
function renderPagination(totalItems) {
    paginationDiv.innerHTML = '';

    const totalPages = Math.ceil(totalItems / pageSize);
    if (totalPages <= 1) return;

    const makeBtn = (label, page, disabled = false) => {
        const btn = document.createElement('button');
        btn.textContent = label;
        btn.disabled = disabled;
        btn.classList.toggle('active', page === currentPage);
        btn.onclick = () => changePage(page);
        paginationDiv.appendChild(btn);
    };

    makeBtn('<<', 1, currentPage === 1);
    makeBtn('<', currentPage - 1, currentPage === 1);

    const maxBtns = 6;
    let start = Math.max(1, currentPage - Math.floor(maxBtns / 2));
    let end = Math.min(start + maxBtns - 1, totalPages);
    if (end - start < maxBtns - 1) {
        start = Math.max(1, end - maxBtns + 1);
    }

    for (let i = start; i <= end; i++) {
        makeBtn(i, i);
    }

    makeBtn('>', currentPage + 1, currentPage === totalPages);
    makeBtn('>>', totalPages, currentPage === totalPages);
}

// ▶️ 페이지 변경 시 URL 반영
function changePage(page) {
    const url = new URL(window.location);
    url.searchParams.set('page', page);
    window.history.pushState({}, '', url);
    render(page);
}

// ▶️ 검색 처리
function handleSearch() {
    const keyword = searchInput.value.trim().toLowerCase();
    filteredPolicies = allPolicies.filter(policy =>
        policy.plcyNm && policy.plcyNm.toLowerCase().includes(keyword)
    );
    currentPage = 1;
    changePage(1);
}

// ▶️ 초기 렌더링
render(currentPage);

// ▶️ Enter 검색
searchInput.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') {
        handleSearch();
    }
});
