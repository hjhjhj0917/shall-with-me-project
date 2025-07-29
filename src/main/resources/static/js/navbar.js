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