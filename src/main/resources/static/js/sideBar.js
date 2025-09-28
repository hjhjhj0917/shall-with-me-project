document.addEventListener("DOMContentLoaded", function() {
    const sidebar = document.querySelector(".sidebar");
    const toggleBtn = document.getElementById("sidebarToggle");
    const pathname = window.location.pathname;

    // 비밀번호 확인 페이지의 URL 경로
    const passwordCheckPath = "/mypage/myPagePwCheck";

    if (sidebar && pathname.includes(passwordCheckPath)) {
        // ========== 비밀번호 확인 페이지일 경우 ==========

        // 1. 사이드바를 강제로 '접힘' 상태로 만듭니다.
        sidebar.classList.add("collapsed");

        // 2. 토글 버튼을 비활성화합니다.
        if (toggleBtn) {
            toggleBtn.disabled = true;
        }

        // 3. 모든 메뉴 아이템의 클릭 이벤트를 막습니다.
        const menuItems = document.querySelectorAll(".sidebar-menu-item");
        menuItems.forEach(item => {
            item.style.pointerEvents = 'none'; // 클릭 비활성화
            item.style.cursor = 'default';     // 마우스 커서 기본 모양으로
            item.removeAttribute('onclick');
        });

        // 4. 프로필 로고 링크도 비활성화합니다.
        const logoLink = document.querySelector(".sidebar-logo");
        if (logoLink) {
            logoLink.style.pointerEvents = 'none';
            logoLink.style.cursor = 'default';
        }

    } else {
        // ========== 그 외 모든 일반 페이지일 경우 ==========

        // 1. 사이드바 펼침/접힘 기능을 활성화합니다.
        if (toggleBtn && sidebar) {
            toggleBtn.addEventListener("click", () => {
                sidebar.classList.toggle("collapsed");
            });
        }

        // 2. 로그아웃 버튼 기능을 활성화합니다.
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

