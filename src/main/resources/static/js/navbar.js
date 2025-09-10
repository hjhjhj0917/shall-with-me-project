document.addEventListener('DOMContentLoaded', function () {

    $("#logout").on("click", function () {
        if (this.id === "logout") {
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

    // 숨겨야 할 페이지들 처리
    const path = window.location.pathname;
    const pageName = path.split('/').pop();

    const hideBoxByPage = {
        main: ['switchBox'],
        userProfile: ['switchBox', 'menuBox', 'userNameBox', 'messageBox'],
        userTagSelect: ['switchBox', 'menuBox', 'userNameBox', 'messageBox'],
        userRegForm: ['switchBox', 'menuBox', 'userNameBox', 'messageBox'],
        login: ['userNameBox', 'switchBox', 'menuBox', 'messageBox'],
        searchUserId: ['userNameBox', 'switchBox', 'menuBox', 'messageBox'],
        searchPassword: ['userNameBox', 'switchBox', 'menuBox', 'messageBox'],
        chatRoom: ['switchBox'],
        scheduleReg: ['switchBox']
    };

    if (hideBoxByPage[pageName]) {
        hideBoxByPage[pageName].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.style.display = 'none';
        });
    }

    // 초기화 (접힘 상태 유지)
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

    // 로그인 안 돼 있으면 이름 박스 및 메뉴 수정
    if (!userName || userName.trim() === "") {
        const userNameBox = document.getElementById("userNameBox");
        const messageBox = document.getElementById("messageBox");
        if (userNameBox) {
            userNameBox.style.display = "none";
            messageBox.style.display = "none";
        }
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

        const hideBoxes = hideBoxByPage[pageName] || [];

        ['menuBox'].forEach(id => {
            if (hideBoxes.includes(id)) return;  // 숨겨야 할 박스는 무시

            const el = document.getElementById(id);
            if (el) {
                el.classList.add('pinned');
                el.style.display = '';  // 보이게
            }
        });
    }

    // 메세지 리스트 보기 ================================================== //

    /**
     * ===================================================================
     * 메시지 모달 제어 스크립트
     * ===================================================================
     */

    // 모달을 열었던 버튼(트리거) 요소를 저장하기 위한 변수
    let messageModalTrigger = null;

    // [수정] #messageBox 버튼 클릭 시 모달 열기
    const messageBox = document.getElementById('messageBox');
    if (messageBox) {
        messageBox.addEventListener('click', function(e) {
            e.stopPropagation();

            const ov = document.getElementById('messageModalOverlay');
            if (!ov) return; // 모달이 없으면 중단

            // 모달이 현재 열려있는지 상태를 확인
            const isModalOpen = ov.style.display === 'flex';

            if (isModalOpen) {
                // 모달이 열려있으면 닫는 함수를 호출
                closeMessageModal();
            } else {
                // 모달이 닫혀있으면 여는 함수를 호출
                messageModalTrigger = this; // 포커스 관리를 위해 현재 버튼을 트리거로 저장
                this.classList.add('pinned'); // 버튼을 활성화 상태로 만듦
                openMessageModal('/chat/userListPage');
            }
        });
    }

    // [추가] 닫기 버튼(#messageModalClose)에 클릭 이벤트 연결
    document.getElementById('messageModalClose')?.addEventListener('click', closeMessageModal);

    /**
     * 메시지 모달을 여는 함수
     * @param {string} url - iframe에 로드할 페이지 주소
     */
    function openMessageModal(url) {
        const ov = document.getElementById('messageModalOverlay');
        const frame = document.getElementById('messageModalFrame');
        if (!ov || !frame) return;

        frame.src = url;
        ov.style.display = 'flex';
        ov.setAttribute('aria-hidden', 'false');
        document.body.classList.add('modal-open');

        const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
        bgEls.forEach(el => {
            if (el) {
                el.setAttribute('inert', '');
                el.setAttribute('aria-hidden', 'true');
            }
        });

        document.getElementById('messageModalClose')?.focus();
    }

    /**
     * 메시지 모달을 닫는 함수
     */
    function closeMessageModal() {
        const ov = document.getElementById('messageModalOverlay');
        const frame = document.getElementById('messageModalFrame');
        if (!ov || !frame) return;

        ov.style.display = 'none';
        ov.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('modal-open');

        const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
        bgEls.forEach(el => {
            if (el) {
                el.removeAttribute('inert');
                el.removeAttribute('aria-hidden');
            }
        });

        frame.src = 'about:blank';

        if (messageModalTrigger) {
            messageModalTrigger.focus();

            // [추가] 모달을 닫을 때 버튼의 활성화(.pinned) 상태도 함께 제거
            messageModalTrigger.classList.remove('pinned');
        }
    }

    // 배경 클릭 시 모달 닫기 (이 기능은 사용자 편의성을 높여주므로 유지하는 것이 좋습니다)
    document.addEventListener('click', (e) => {
        const ov = document.getElementById('messageModalOverlay');
        if (ov && e.target === ov) {
            closeMessageModal();
        }
    });

    // ESC 키 입력 시 모달 닫기 (이 기능은 접근성을 위해 필수적이므로 유지하는 것이 좋습니다)
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            const ov = document.getElementById('messageModalOverlay');
            if (ov && ov.style.display === 'flex') {
                closeMessageModal();
            }
        }
    });

    // =================================================================== //
});

// + 버튼 클릭 → 모달 열기
$(document).ready(function () {
    $("#userNameBox").on("click", function () {
        openProfileModal('/user/userInfo');
    });
});

// ===== 모달 제어 함수 (배경 상호작용 차단: inert + aria-hidden) =====
function openProfileModal(url) {
    const ov = document.getElementById('profileModalOverlay');
    const frame = document.getElementById('profileModalFrame');
    if (!ov || !frame) return;

    frame.src = url;                 // 등록 페이지 로드
    ov.style.display = 'flex';       // 모달 표시
    document.body.classList.add('modal-open');

    const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
    bgEls.forEach(el => {
        if (!el) return;
        el.setAttribute('inert', '');        // 포커스/탭 이동 차단(지원 브라우저)
        el.setAttribute('aria-hidden', 'true'); // 스크린리더 숨김
    });

    document.getElementById('profileModalClose')?.focus(); // 포커스 이동
}

function closeProfileModal() {
    const ov = document.getElementById('profileModalOverlay');
    const frame = document.getElementById('profileModalFrame');
    if (!ov || !frame) return;

    ov.style.display = 'none';
    document.body.classList.remove('modal-open');

    const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
    bgEls.forEach(el => {
        if (!el) return;
        el.removeAttribute('inert');
        el.removeAttribute('aria-hidden');
    });

    frame.src = 'about:blank'; // 프레임 리셋
    document.getElementById('roommateAdd')?.focus(); // 트리거로 포커스 복귀
}

// 배경 클릭 닫기
document.addEventListener('click', (e) => {
    const ov = document.getElementById('profileModalOverlay');
    if (!ov || ov.style.display !== 'flex') return;
    if (e.target === ov) closeProfileModal();
});
// ESC 닫기
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeProfileModal();
});

