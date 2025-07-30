// /webapp/js/tag.js 또는 /src/main/webapp/js/tag.js 에 위치

let currentSlide = 0;

window.moveSlide = function (direction) {
    const slider = document.getElementById('slider');
    const totalSlides = slider.children.length;
    currentSlide = (currentSlide + direction + totalSlides) % totalSlides;
    slider.style.transform = `translateX(-${currentSlide * 100}vw)`;
};

window.selectButton = function (button) {
    const group = button.parentElement;
    const buttons = group.querySelectorAll('button');
    buttons.forEach(btn => btn.classList.remove('selected'));
    button.classList.add('selected');
};


// 버튼 선택 토글 로직
function selectButton(button) {
    const group = button.parentNode;
    const buttons = group.querySelectorAll("button");
    buttons.forEach(btn => btn.classList.remove("selected"));
    button.classList.add("selected");
}


// 태그 선택

document.getElementById('saveButton').addEventListener('click', () => {
    const selectedTags = [];
    let firstMissingLegend = null;

    document.querySelectorAll('fieldset').forEach(fieldset => {
        const selectedBtn = fieldset.querySelector('button.selected');
        const legendText = fieldset.querySelector('legend')?.textContent || '항목';
        if (selectedBtn) {
            selectedTags.push(parseInt(selectedBtn.getAttribute('data-tag'), 10));
        } else if (!firstMissingLegend) {
            // 처음 발견된 누락 항목만 저장
            firstMissingLegend = legendText;
        }
    });

    if (firstMissingLegend) {
        // 을/를 조사 자동 처리
        const lastChar = firstMissingLegend.charAt(firstMissingLegend.length - 1);
        const isBatchim = (lastChar.charCodeAt(0) - 44032) % 28 !== 0;
        alert(`${firstMissingLegend} 항목을 선택하세요`);
        return;
    }

    // user_id와 tag_type은 예시로 하드코딩. 실제로는 서버에서 세션 등으로 받아서 처리
    const userId = 'test';  // 예: 세션에서 로그인한 user_id
    const tagType = 'ME';   // 예: 'ME' 혹은 'PREF'

    fetch('/user/saveUserTags', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ userId, tagType, tags: selectedTags })
    })
        .then(res => res.json())
        .then(data => {
            if (data.success) alert('저장 완료!');
            else alert('저장 실패');
        })
        .catch(err => {
            console.error(err);
            alert('저장 중 오류 발생');
        });
});



