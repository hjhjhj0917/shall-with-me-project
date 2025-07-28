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
const selectedTags = {};

function selectButton(button) {
    const group = button.closest('.button-group');
    const groupKey = group.getAttribute('data-group');

    // 한 그룹 내에서 중복 선택 방지
    const buttons = group.querySelectorAll('button');
    buttons.forEach(btn => btn.classList.remove('selected'));

    button.classList.add('selected');
    selectedTags[groupKey] = button.innerText;  // 예: lifestyle → '아침형'
}

document.addEventListener("DOMContentLoaded", function () {
    const saveButton = document.getElementById("saveButton");

    saveButton.addEventListener("click", function () {
        console.log("선택된 태그:", selectedTags);

        fetch("/user/saveTags", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(selectedTags)
        })
            .then(response => response.json())
            .then(data => {
                alert(data.message);
            })
            .catch(error => {
                console.error("에러 발생:", error);
                alert("저장 중 오류가 발생했습니다.");
            });
    });
});

