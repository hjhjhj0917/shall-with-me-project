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

// 룸메이트 쉐어하우스 전환하는 navbar 안보이게 설정
document.addEventListener('DOMContentLoaded', function () {
    const path = window.location.pathname;
    const pageName = path.split('/').pop(); // ex: 'main'

    if (pageName === 'userTagSelect') {
        const switchBox = document.getElementById('switchBox');
        if (switchBox) {
            switchBox.style.display = 'none';
        }
    }
});

document.addEventListener('DOMContentLoaded', function () {
    const path = window.location.pathname;
    const pageName = path.split('/').pop(); // ex: 'main'

    if (pageName === 'userTagSelect') {
        const switchBox = document.getElementById('menuBox');
        if (switchBox) {
            switchBox.style.display = 'none';
        }
    }
});

// 로그인 정보가 없으면 회원 이름정보 안보이게 설정
document.addEventListener("DOMContentLoaded", function () {
    if (!userName || userName.trim() === "") {
        const userNameBox = document.getElementById("userNameBox");
        if (userNameBox) {
            userNameBox.style.display = "none";
        }
    }
});

// 로그인 정보가 없으면 메뉴에 로그인 회원가입이 뜨게 설정
document.addEventListener("DOMContentLoaded", function () {
    if (!userName || userName.trim() === "") {
        // 로그인 안 된 경우
        const menuButtons = document.querySelectorAll("#menuBox .menu-list");

        if (menuButtons.length >= 2) {
            // 첫 번째 버튼: 회원가입
            menuButtons[0].textContent = "회원가입";
            menuButtons[0].setAttribute("onclick", "location.href='/user/userRegForm'");

            // 두 번째 버튼: 로그인
            menuButtons[1].textContent = "ㅤ로그인ㅤ";
            menuButtons[1].setAttribute("onclick", "location.href='/user/login'");
        }
    }
});