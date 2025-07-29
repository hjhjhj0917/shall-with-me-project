// 이름 보여주는 js
const userNameBox = document.getElementById('userNameBox');

userNameBox.addEventListener('click', function (e) {
    e.stopPropagation(); // 외부 클릭 방지
    userNameBox.classList.toggle('pinned'); // toggle 고정
});

const userMenuBox = document.getElementById('menuBox');

userMenuBox.addEventListener('click', function (e) {
    e.stopPropagation(); // 외부 클릭 방지
    userMenuBox.classList.toggle('pinned'); // toggle 고정
});

const userSwitchBox = document.getElementById('switchBox');

userSwitchBox.addEventListener('click', function (e) {
    e.stopPropagation(); // 외부 클릭 방지
    userSwitchBox.classList.toggle('pinned'); // toggle 고정
});

document.getElementById('switchToggle').addEventListener('click', function () {
    this.classList.toggle('pinned');
});

document.getElementById('userIconToggle').addEventListener('click', function () {
    this.classList.toggle('pinned');
});

document.getElementById('headerDropdownToggle').addEventListener('click', function () {
    this.classList.toggle('pinned');
});

// 룸메이트 쉐어하우스 전환하는 navbar 안보이게 설정
document.addEventListener('DOMContentLoaded', function () {
    const path = window.location.pathname;
    const pageName = path.split('/').pop(); // ex: 'main'

    if (pageName === 'main') {
        const switchBox = document.getElementById('switchBox');
        if (switchBox) {
            switchBox.style.display = 'none';
        }
    }
});