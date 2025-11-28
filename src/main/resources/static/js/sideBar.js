document.addEventListener("DOMContentLoaded", function() {
    const sidebar = document.querySelector(".sidebar");
    const toggleBtn = document.getElementById("sidebarToggle");
    const pathname = window.location.pathname;

    const passwordCheckPath = "/mypage/myPagePwCheck";

    if (sidebar && pathname.includes(passwordCheckPath)) {

        sidebar.classList.add("collapsed");

        if (toggleBtn) {
            toggleBtn.disabled = true;
        }

        const menuItems = document.querySelectorAll(".sidebar-menu-item");
        menuItems.forEach(item => {
            item.style.pointerEvents = 'none';
            item.style.cursor = 'default';
            item.removeAttribute('onclick');
        });

        const logoLink = document.querySelector(".sidebar-logo");
        if (logoLink) {
            logoLink.style.pointerEvents = 'none';
            logoLink.style.cursor = 'default';
        }

    } else {

        if (toggleBtn && sidebar) {
            toggleBtn.addEventListener("click", () => {
                sidebar.classList.toggle("collapsed");
            });
        }

        $("#sidebar-logout").on("click", function () {
            showCustomConfirm("로그아웃 하시겠습니까?", function () {
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
    }
});

