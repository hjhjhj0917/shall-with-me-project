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
        showCustomAlert(`${firstMissingLegend} 항목을 선택하세요`);
        return;
    }

    // user_id와 tag_type은 예시로 하드코딩. 실제로는 서버에서 세션 등으로 받아서 처리
    const tagType = 'ME';   // 예: 'ME' 혹은 'PREF'
    console.log(userId)

    fetch('/user/saveUserTags', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ userId, tagType, tagList: selectedTags })
    })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                showCustomAlert("저장 완료!", function() {
                    location.href = "/user/main";
                });
            } else {
                showCustomAlert(data.message, function() {
                    location.href = "/user/main";
                });
            }
        })
        .catch(err => {
            console.error(err);
            showCustomAlert('저장 중 오류 발생');
        });
});

// 태그 선택되면 자동으로 넘어감
window.selectButton = function (button) {
    const group = button.parentNode;
    const buttons = group.querySelectorAll("button");
    buttons.forEach(btn => btn.classList.remove("selected"));
    button.classList.add("selected");

    // 현재 슬라이드 내 모든 fieldset이 선택됐는지 체크
    const slider = document.getElementById('slider');
    const slides = slider.children;
    const currentSlideDiv = slides[currentSlide];
    const fieldsets = currentSlideDiv.querySelectorAll('fieldset');

    let allSelected = true;
    fieldsets.forEach(fs => {
        if (!fs.querySelector('button.selected')) {
            allSelected = false;
        }
    });

    if (allSelected) {
        // 다음 슬라이드로 이동, 마지막 슬라이드면 이동 안 함
        if (currentSlide < slides.length - 1) {
            moveSlide(1);
        }
    }
};




