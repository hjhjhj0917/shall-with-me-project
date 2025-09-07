document.addEventListener("DOMContentLoaded", function() {
    const sidebar = document.querySelector(".sidebar");
    const toggleBtn = document.getElementById("sidebarToggle");

    // 사이드바 펼침/접힘
    if (toggleBtn) {
        toggleBtn.addEventListener("click", () => {
            sidebar.classList.toggle("collapsed");
        });
    }

    $("#sidebar-logout").on("click", function () {
        if (this.id === "sidebar-logout") {
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
        }
    });
});