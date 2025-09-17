<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 룸메이트 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <!-- 룸메이트 전용 CSS -->
    <link rel="stylesheet" href="/css/roommate/roommateMain.css"/>
    <link rel="icon" href="${pageContext.request.contextPath}/images/noimg.png">
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <!-- 큰 모달 스타일 + 배경 상호작용 차단 -->
    <style>
        /* 모달 열릴 때 바디 스크롤 잠금 */
        body.modal-open {
            overflow: hidden;
        }

        /* 모달 열릴 때 배경(헤더+메인) 상호작용 완전 차단 */
        body.modal-open header,
        body.modal-open #sh-wrapper {
            pointer-events: none;
            -webkit-user-select: none;
            user-select: none;
            touch-action: none;
        }

        /* 큰 모달 오버레이 */
        #profileModalOverlay {
            position: fixed;
            inset: 0;
            display: none; /* open 시 flex */
            align-items: center;
            justify-content: center;
            background: rgba(0, 0, 0, 0.45);
            z-index: 10000; /* 알림 모달이 9999라면 이게 위 */
            pointer-events: auto;
        }

        #profileModalOverlay .modal-sheet {
            width: min(1200px, 95vw);
            height: min(90vh, 100svh - 40px);
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.25);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        #profileModalOverlay .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 14px 18px;
            border-bottom: 1px solid #eee;
            background: #f7faff;
        }

        #profileModalOverlay .modal-title-text {
            font-size: 1.1rem;
            font-weight: 700;
            color: #1c407d;
        }

        #profileModalOverlay .modal-close {
            border: none;
            background: transparent;
            cursor: pointer;
            padding: 6px;
            font-size: 1.1rem;
        }

        #profileModalOverlay .modal-body {
            flex: 1 1 auto;
            padding: 0; /* iframe이 꽉 차도록 */
            overflow: hidden;
        }

        /* 등록 화면을 로드하는 프레임 */
        #profileModalFrame {
            width: 100%;
            height: 100%;
            display: block;
            border: 0;
        }
    </style>

    <script>
        // 전역 컨텍스트 경로
        const ctx = '${pageContext.request.contextPath}';

        // + 버튼 클릭 → 모달 열기
        $(document).ready(function () {
            $("#roommateAdd").on("click", function () {
                openProfileModal(ctx + '/roommate/roommateReg');
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
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main id="sh-wrapper">
    <!-- 검색바 -->
    <div class="sh-searchbar">
        <input type="text" placeholder="원하는 지역, 조건 검색" id="sh-q">
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>

    <!-- ✅ 스크롤 전용 박스 추가 -->
    <div class="sh-scroll-area">
        <section class="sh-grid">
            <!-- 카드들이 Ajax로 들어옴 -->
        </section>
    </div>


    <!-- 좌하단 등록 플로팅 버튼 -->
    <button class="sh-fab" title="등록" id="roommateAdd">
        <i class="fa-solid fa-plus"></i>
    </button>
</main>

<!-- 큰 모달 (등록 페이지를 iframe으로 로드) -->
<div id="profileModalOverlay" aria-hidden="true">
    <div class="modal-sheet" role="dialog" aria-modal="true" aria-labelledby="profileModalTitle">
        <div class="modal-header">
            <div id="profileModalTitle" class="modal-title-text">프로필 등록</div>
            <button type="button" class="modal-close" id="profileModalClose" aria-label="닫기"
                    onclick="closeProfileModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <iframe id="profileModalFrame" title="룸메이트 등록 화면"></iframe>
        </div>
    </div>
</div>

<!-- 커스텀 알림창 -->
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) {
        ssUserName = "";
    }
%>

<script>
    const userName = "<%= ssUserName %>";
</script>

<script>
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;

            // 새 탭으로 열기
            window.open(
                ctx + '/roommate/roommateDetail?userId=' + encodeURIComponent(id),
                '_blank'
            );
        });
    })();
</script>


<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<!-- ✅ 무한 스크롤 스크립트 -->
<script>
    $(document).ready(function () {
        let page = 1;
        let loading = false;
        let lastPage = false;

        const $grid = $(".sh-grid");

        // 첫 로드
        loadPage(page);

        // ✅ 카드 리스트 전용 스크롤 이벤트
        const $scrollArea = $(".sh-scroll-area");

        $scrollArea.on("scroll", function () {
            if (loading || lastPage) return;

            let scrollTop = $scrollArea.scrollTop();
            let innerHeight = $scrollArea.innerHeight();
            let scrollHeight = $scrollArea[0].scrollHeight;

            // 바닥 근처 도달 시 다음 페이지 로드
            if (scrollTop + innerHeight + 100 >= scrollHeight) {
                page++;
                loadPage(page);
            }
        });


        function loadPage(p) {
            loading = true;
            $.ajax({
                url: ctx + "/roommate/list",
                type: "GET",
                data: { page: p },
                dataType: "json",
                success: function (data) {
                    if (!data || !data.items || data.items.length === 0) {
                        lastPage = true;
                        return;
                    }
                    renderUserCards(data.items);

                    if (data.lastPage) {
                        lastPage = true;
                    }
                },
                error: function (xhr, status, err) {
                    console.error("회원 정보 불러오기 실패:", err);
                },
                complete: function () {
                    loading = false;
                }
            });
        }

        function renderUserCards(users) {
            const loginUserId = "${sessionScope.SS_USER_ID}";

            $.each(users, function (i, user) {
                if (user.userId === loginUserId) {
                    return true;
                }

                var imgUrl = user.profileImageUrl || (ctx + "/images/noimg.png");
                var nickname = user.userName || "알 수 없음";
                var age = user.age ? user.age + "세" : "";

                var $card = $("<article>")
                    .addClass("sh-card")
                    .attr("data-id", user.userId);

                var $thumb = $("<div>")
                    .addClass("sh-thumb")
                    .css("background-image", "url('" + imgUrl + "')");

                var $info = $("<div>").addClass("sh-info")
                    .append($("<p>").addClass("sh-sub").text("이름 : " + nickname + (age ? " (" + age + ")" : "")));

                var $tagBox = $("<div>").addClass("tag-box");

                if (user.tag1) $tagBox.append($("<span>").addClass("tag").text(user.tag1));
                if (user.tag2) $tagBox.append($("<span>").addClass("tag").text(user.tag2));

                if (user.gender) {
                    var genderClass = (user.gender === "남" || user.gender === "M") ? "male" : "female";
                    $tagBox.append($("<span>").addClass("tag gender " + genderClass).text(user.gender));
                }

                $info.append($tagBox);
                $card.append($thumb).append($info);
                $grid.append($card);
            });
        }
    });
</script>
</body>
</html>
