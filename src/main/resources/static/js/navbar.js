document.addEventListener('DOMContentLoaded', function () {

    $("#logout").on("click", function () {
        showCustomAlert("로그아웃 하시겠습니까?", function () {
            $.ajax({
                url: "/user/logout",
                type: "Post",
                dataType: "json",
                success: function (res) {
                    if (res.result === 1) {
                        location.href = "/user/main";

                    } else {
                        showCustomAlert("실패: " + res.msg);
                    }
                },
                error: function () {
                    showCustomAlert("서버 통신 중 오류가 발생했습니다.");
                }
            });
        });
    });

    // ✅ 초기화 (접힘 상태 유지)
    const ids = ['menuBox', 'headerDropdownToggle'];
    ids.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.remove('pinned');
    });

    ['userNameBox', 'menuBox', 'switchBox'].forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener('click', function (e) {
                e.stopPropagation();
                el.classList.toggle('pinned');
            });
        }
    });

// toggle 대상 요소만 클릭 시 pinned 토글
    ['switchToggle', 'userIconToggle', 'headerDropdownToggle'].forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener('click', function () {
                el.classList.toggle('pinned');
            });
        }
    });

    // ✅ 숨겨야 할 페이지들 처리
    const path = window.location.pathname;
    const pageName = path.split('/').pop();

    const hideBoxByPage = {
        main: ['switchBox'],
        userTagSelect: ['switchBox', 'menuBox'],
        preTagSelect: ['switchBox', 'menuBox'],
        userRegForm: ['switchBox', 'menuBox', 'userNameBox'],
        login: ['userNameBox', 'switchBox', 'menuBox'],
        searchUserId: ['userNameBox', 'switchBox', 'menuBox'],
        searchPassword: ['userNameBox', 'switchBox', 'menuBox'],
        chatRoom: ['switchBox'],
    };

    if (hideBoxByPage[pageName]) {
        hideBoxByPage[pageName].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.style.display = 'none';
        });
    }

    // ✅ 로그인 안 돼 있으면 이름 박스 및 메뉴 수정
    if (!userName || userName.trim() === "") {
        const userNameBox = document.getElementById("userNameBox");
        if (userNameBox) userNameBox.style.display = "none";

        const menuButtons = document.querySelectorAll("#menuBox .menu-list");

        if (menuButtons.length >= 2) {
            menuButtons[0].textContent = "회원가입";
            menuButtons[0].setAttribute("onclick", "location.href='/user/userRegForm'");

            menuButtons[1].textContent = "ㅤ로그인ㅤ";
            menuButtons[1].setAttribute("id", "loginBtn");
            menuButtons[1].setAttribute("onclick", "location.href='/user/login'");
        }

        if (menuButtons.length >= 3) {
            menuButtons[2].style.display = "none";
        }

        const style = document.createElement('style');
        style.innerHTML = `
            .header-menu-container:hover:not(.pinned),
            .header-menu-container.pinned {
                width: 250px !important;
            }
            #headerDropdownToggle {
                margin-top: 2px;
                margin-right: 176px;
            }
        `;
        document.head.appendChild(style);
    }
});
