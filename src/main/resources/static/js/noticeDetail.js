const rawJson = '<%= request.getAttribute("policyJson") %>';
const policy = JSON.parse(rawJson || '{}');

// ✅ 유효하지 않은 값 확인
const isInvalid = (value) => {
    return (
        value === undefined ||
        value === null ||
        value === '' ||
        value === false ||
        value === 'false' ||
        value === '-'     // 추가
    );
};

(function setTitle() {
    const titleText = isInvalid(policy.plcyNm) ? '살며시' : '살며시: ' + policy.plcyNm;
    document.title = titleText;
})();

// ✅ 텍스트 영역 처리: 유효하지 않으면 섹션 제거
const setOrRemove = (id, value) => {
    const element = document.getElementById(id);
    const section = element?.closest('.detail-section');
    if (!element || !section) return;

    if (isInvalid(value)) {
        section.remove();
    } else {
        element.innerHTML = value;
    }
};

// ✅ 제목은 항상 표시 (내용 없으면 기본 텍스트)
const titleElement = document.getElementById("title");
if (titleElement) {
    const titleValue = isInvalid(policy.plcyNm) ? '제목 없음' : policy.plcyNm;
    titleElement.textContent = titleValue;
}

// 일반 텍스트 필드들
setOrRemove("expln", policy.plcyExplnCn);
setOrRemove("support", policy.plcySprtCn);
setOrRemove("applyMethod", policy.plcyAplyMthdCn);
setOrRemove("documents", policy.sbmsnDcmntCn);
setOrRemove("additional", policy.addAplyQlfcCndCn);
setOrRemove("participant", policy.ptcpPrpTrgtCn);
setOrRemove("operator", policy.operInstCdNm);
setOrRemove("supervisor", policy.sprvsnInstCdNm);

// ✅ 연령 섹션: 둘 다 유효할 때만 출력
(function handleAgeRange() {
    const element = document.getElementById("ageRange");
    const section = element?.closest('.detail-section');
    if (!element || !section) return;

    const min = policy.sprtTrgtMinAge;
    const max = policy.sprtTrgtMaxAge;

    const validMin = !isInvalid(min);
    const validMax = !isInvalid(max);

    if ((validMin && validMax) && (min != 0 && max !=0)) {
        element.textContent = min + '세 ~' + max + '세';
    } else {
        section.remove();
    }
})();

// ✅ 소득 조건 처리
(function handleIncome() {
    const element = document.getElementById("income");
    const section = element?.closest('.detail-section');
    if (!element || !section) return;

    const min = policy.earnMinAmt;
    const max = policy.earnMaxAmt;
    const etc = policy.earnEtcCn;

    const validMin = !isInvalid(min);
    const validMax = !isInvalid(max);
    const validEtc = !isInvalid(etc);

    if ((validMin || validMax || validEtc) && (min >0 || max>0)) {
        const lines = [];
        if (validMin) lines.push('최소: ' + min);
        if (validMax) lines.push('최대: ' + max);
        if (validEtc) lines.push('기타: ' + etc);
        element.textContent = lines.join('\n');
    } else {
        section.remove();
    }
})();

// ✅ 사업 기간 처리
(function handlePeriod() {
    const element = document.getElementById("period");
    const section = element?.closest('.detail-section');
    if (!element || !section) return;

    const start = policy.bizPrdBgngYmd;
    const end = policy.bizPrdEndYmd;

    const validStart = !isInvalid(start);
    const validEnd = !isInvalid(end);

    function formatDate(dateStr) {
        if (!dateStr || dateStr.length !== 8) return dateStr;

        const year = dateStr.substring(0, 4);
        const month = dateStr.substring(4, 6);
        const day = dateStr.substring(6, 8);

        return year + '년 ' + parseInt(month, 10) + '월 ' + parseInt(day, 10) + '일';
    }

    if (validStart || validEnd) {
        const startText = validStart ? formatDate(start) : '-';
        const endText = validEnd ? formatDate(end) : '-';
        element.textContent = startText + ' ~ ' + endText;
    } else {
        section.remove();
    }
})();

// ✅ 외부 링크 처리
const linksContainer = document.getElementById('links');
const displayedUrls = new Set();

const createLinkButton = (url, label) => {
    if (isInvalid(url) || displayedUrls.has(url)) return;
    const a = document.createElement('a');
    a.href = url;
    a.target = "_blank";
    a.textContent = label;
    a.className = "go-link";
    linksContainer.appendChild(a);
    displayedUrls.add(url);
};

createLinkButton(policy.aplyUrlAddr, '참고 URL 1');
createLinkButton(policy.refUrlAddr1, '참고 URL 1');
createLinkButton(policy.refUrlAddr2, '참고 URL 2');

if (linksContainer.children.length === 0) {
    linksContainer.remove();
}
