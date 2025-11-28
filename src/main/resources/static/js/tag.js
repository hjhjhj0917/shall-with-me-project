let currentSlide = 0;

window.moveSlide = function (direction) {
    const slider = document.getElementById('slider');
    const totalSlides = slider.children.length;
    currentSlide = (currentSlide + direction + totalSlides) % totalSlides;
    slider.style.transform = `translateX(-${currentSlide * 100}vw)`;
    updateStepIndicator(currentSlide);
};

window.selectButton = function (button) {
    const group = button.parentElement;
    const buttons = group.querySelectorAll('button');
    buttons.forEach(btn => btn.classList.remove('selected'));
    button.classList.add('selected');
};


function selectButton(button) {
    const group = button.parentNode;
    const buttons = group.querySelectorAll("button");
    buttons.forEach(btn => btn.classList.remove("selected"));
    button.classList.add("selected");
}

document.getElementById('saveButton').addEventListener('click', () => {
    const selectedTags = [];
    let firstMissingLegend = null;

    document.querySelectorAll('fieldset').forEach(fieldset => {
        const selectedBtn = fieldset.querySelector('button.selected');
        const legendText = fieldset.querySelector('legend')?.textContent || '항목';
        if (selectedBtn) {
            selectedTags.push(parseInt(selectedBtn.getAttribute('data-tag'), 10));
        } else if (!firstMissingLegend) {
            firstMissingLegend = legendText;
        }
    });

    if (firstMissingLegend) {
        const lastChar = firstMissingLegend.charAt(firstMissingLegend.length - 1);
        const isBatchim = (lastChar.charCodeAt(0) - 44032) % 28 !== 0;
        showCustomAlert(`${firstMissingLegend} 항목을 선택하세요`);
        return;
    }

    fetch('/user/saveUserTags', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ userId, tagList: selectedTags })
    })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                showCustomAlert("저장되었습니다.", function () {
                    location.href = "/user/userProfile";
                });
            } else {
                showCustomAlert(data.message, function () {
                    location.href = "/user/main";
                });
            }
        })
        .catch(err => {
            console.error(err);
            showCustomAlert('저장 중 오류 발생');
        });
});


window.selectButton = function (button) {
    const group = button.parentNode;
    const buttons = group.querySelectorAll("button");
    buttons.forEach(btn => btn.classList.remove("selected"));
    button.classList.add("selected");

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
        if (currentSlide < slides.length - 1) {
            moveSlide(1);
        }
    }

    updateProgressIndicator();
};

function updateStepIndicator(index) {
    const steps = document.querySelectorAll('.progress-indicator .step');
    steps.forEach((step, i) => {
        if (i === index) {
            step.classList.add('active');
        } else {
            step.classList.remove('active');
        }
    });
}

window.goToSlide = function (index) {
    const slider = document.getElementById('slider');
    const totalSlides = slider.children.length;
    if (index >= 0 && index < totalSlides) {
        currentSlide = index;
        slider.style.transform = `translateX(-${currentSlide * 100}vw)`;
        updateProgressIndicator();
    }
};

function updateProgressIndicator() {
    const steps = document.querySelectorAll('.step');

    steps.forEach((step, idx) => {
        step.classList.remove('active', 'completed');

        if (idx === currentSlide) {
            step.classList.add('active');
        } else if (isSlideComplete(idx)) {
            step.classList.add('completed');
        }
    });
}

function isSlideComplete(slideIndex) {
    const slider = document.getElementById('slider');
    const slide = slider.children[slideIndex];
    const fieldsets = slide.querySelectorAll('fieldset');

    for (let fs of fieldsets) {
        if (!fs.querySelector('button.selected')) {
            return false;
        }
    }
    return true;
}





