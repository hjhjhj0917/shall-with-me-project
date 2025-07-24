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

function getSelectedTags() {
    const selected = {};
    document.querySelectorAll('.button-group').forEach(group => {
        const groupName = group.getAttribute('data-group');
        const selectedBtn = group.querySelector('.selected');
        if (selectedBtn) {
            selected[groupName] = selectedBtn.textContent;
        }
    });
    return selected;
}

function restorButton() {
    const tags = getSelectedTags();
    fetch('<c:url value="/user/saveTags"/>', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(tags)
    })
        .then(res => res.json())
        .then(data => {
            alert(data.message);
        })
        .catch(err => {
            console.error('저장 실패:', err);
            alert('태그 저장 중 오류가 발생했습니다.');
        });
}

document.addEventListener("DOMContentLoaded", function () {
    const saveButton = document.getElementById("saveButton");
    if (saveButton) {
        saveButton.addEventListener("click", function () {
            const selectedTags = {};

            // 모든 버튼 그룹을 순회하면서 선택된 버튼을 찾기
            document.querySelectorAll(".button-group").forEach(group => {
                const groupName = group.getAttribute("data-group");
                const selectedButton = group.querySelector("button.selected");

                if (selectedButton) {
                    selectedTags[groupName] = selectedButton.textContent;
                }
            });

            // fetch 요청
            fetch("/user/saveTags", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(selectedTags)
            })
                .then(res => res.json())
                .then(data => {
                    alert(data.message);
                })
                .catch(err => {
                    alert("에러 발생: " + err);
                });
        });
    }
});

// 버튼 선택 토글 로직
function selectButton(button) {
    const group = button.parentNode;
    const buttons = group.querySelectorAll("button");
    buttons.forEach(btn => btn.classList.remove("selected"));
    button.classList.add("selected");
}
