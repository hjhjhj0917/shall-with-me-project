<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 쉐어하우스 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseAddBtn.css"/>

    <%-- ✅ [수정] 일관성을 위해 sharehouseMain.css를 사용하고, contextPath를 적용했습니다. --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseMain.css"/>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-3.6.0.min.js"></script>

    <style>
        body.modal-open { overflow: hidden; }
        body.modal-open header,
        body.modal-open #sh-wrapper {
            pointer-events: none;
            -webkit-user-select: none;
            user-select: none;
            touch-action: none;
        }
        #profileModalOverlay {
            position: fixed; inset: 0; display: none; align-items: center; justify-content: center;
            background: rgba(0,0,0,.45); z-index: 10000; pointer-events: auto;
        }
        #profileModalOverlay .modal-sheet {
            width: min(1200px,95vw); height: min(90vh,100svh - 40px);
            background:#fff; border-radius:16px; box-shadow:0 20px 60px rgba(0,0,0,.25);
            display:flex; flex-direction:column; overflow:hidden;
        }
        #profileModalOverlay .modal-header {
            display:flex; align-items:center; justify-content:space-between; gap:12px;
            padding:14px 18px; border-bottom:1px solid #eee; background:#f7faff;
        }
        #profileModalOverlay .modal-title-text { font-size:1.1rem; font-weight:700; color:#1c407d; }
        #profileModalOverlay .modal-close { border:0; background:transparent; cursor:pointer; padding:6px; font-size:1.1rem; }
        #profileModalOverlay .modal-body { flex:1 1 auto; padding:0; overflow:hidden; }
        #profileModalFrame { width:100%; height:100%; display:block; border:0; }
    </style>

    <script>
        const ctx = '${pageContext.request.contextPath}';

        function openProfileModal(url) {
            const ov = document.getElementById('profileModalOverlay');
            const frame = document.getElementById('profileModalFrame');
            if (!ov || !frame) return;

            frame.src = url;
            ov.style.display = 'flex';
            document.body.classList.add('modal-open');

            const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
            bgEls.forEach(el => { if (!el) return; el.setAttribute('inert',''); el.setAttribute('aria-hidden','true'); });

            document.getElementById('profileModalClose')?.focus();
        }

        function closeProfileModal() {
            const ov = document.getElementById('profileModalOverlay');
            const frame = document.getElementById('profileModalFrame');
            if (!ov || !frame) return;

            ov.style.display = 'none';
            document.body.classList.remove('modal-open');

            const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
            bgEls.forEach(el => { if (!el) return; el.removeAttribute('inert'); el.removeAttribute('aria-hidden'); });

            frame.src = 'about:blank';
            document.getElementById('sharehouseAddBtn')?.focus(); // 포커스 복귀 대상
        }

        document.addEventListener('click', (e) => {
            const ov = document.getElementById('profileModalOverlay');
            if (!ov || ov.style.display !== 'flex') return;
            if (e.target === ov) closeProfileModal();
        });
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') closeProfileModal();
        });
    </script>
</head>
<body>
<%@ include file="../includes/header.jsp" %>

<main id="sh-wrapper">
    <div class="sh-searchbar">
        <input type="text" placeholder="원하는 지역, 조건 검색" id="sh-q">
        <button type="button" id="sh-search-btn" aria-label="검색">
            <i class="fa-solid fa-magnifying-glass"></i>
        </button>
    </div>

    <div class="sh-scroll-area">
        <section class="sh-grid">
        </section>
    </div>
</main>

<div id="profileModalOverlay" aria-hidden="true">
    <div class="modal-sheet" role="dialog" aria-modal="true" aria-labelledby="profileModalTitle">
        <div class="modal-header">
            <div id="profileModalTitle" class="modal-title-text">쉐어하우스 등록</div>
            <button type="button" class="modal-close" id="profileModalClose" aria-label="닫기" onclick="closeProfileModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <iframe id="profileModalFrame" title="쉐어하우스 등록 화면"></iframe>
        </div>
    </div>
</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/customModal.jsp" %>

<%
    String ssUserName = (String) session.getAttribute("SS_USER_NAME");
    if (ssUserName == null) { ssUserName = ""; }
%>
<script> const userName = "<%= ssUserName %>"; </script>

<script>
    (function () {
        const grid = document.querySelector('.sh-grid');
        if (!grid) return;

        grid.addEventListener('click', (e) => {
            const card = e.target.closest('.sh-card');
            if (!card || !grid.contains(card)) return;
            const id = card.dataset.id;
            if (!id) return;

            window.open(
                ctx + '/sharehouse/sharehouseDetail?userId=' + encodeURIComponent(id),
                '_blank'
            );
        });
    })();
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<script>
    $(document).ready(function () {
        let page = 1;
        let loading = false;
        let lastPage = false;

        const $grid = $(".sh-grid");
        const $scrollArea = $(".sh-scroll-area");

        loadPage(page);

        $scrollArea.on("scroll", function () {
            if (loading || lastPage) return;

            const scrollTop = $scrollArea.scrollTop();
            const innerHeight = $scrollArea.innerHeight();
            const scrollHeight = $scrollArea[0].scrollHeight;

            if (scrollTop + innerHeight + 100 >= scrollHeight) {
                page++;
                loadPage(page);
            }
        });

        function loadPage(p) {
            loading = true;
            $.ajax({
                url: ctx + "/sharehouse/list",
                type: "GET",
                data: { page: p },
                dataType: "json",
                success: function (data) {
                    if (!data || !data.items || data.items.length === 0) {
                        lastPage = true;
                        return;
                    }
                    renderUserCards(data.items);
                    if (data.lastPage) lastPage = true;
                },
                error: function (xhr, status, err) {
                    console.error("목록 불러오기 실패:", err);
                },
                complete: function () { loading = false; }
            });
        }

        // ✅ [수정] 이미지 로딩 로직을 안정적으로 개선했습니다.
        function renderUserCards(items) {
            const loginUserId = "${sessionScope.SS_USER_ID}";
            const noimgUrl = ctx + "/images/noimg.png";

            $.each(items, function (i, it) {
                if (it.userId === loginUserId) return true;

                // ================== 👇 여기 디버깅 코드를 추가! 👇 ==================
                console.log("--- 카드 데이터 확인 ---");
                console.log("서버에서 받은 it 객체:", it);
                console.log("it 객체 안의 userId 값:", it.userId);
                // =================================================================

                // --- HTML 요소 생성 ---
                const nickname = it.name || "알 수 없음";
                const age = it.age ? it.age + "세" : "";

                const $card  = $("<article>").addClass("sh-card").attr("data-id", it.userId);
                const $thumb = $("<div>").addClass("sh-thumb");
                const $info  = $("<div>").addClass("sh-info")
                    .append($("<p>").addClass("sh-sub").text("이름 : " + nickname + (age ? " (" + age + ")" : "")));

                // --- 이미지 URL 결정 및 로딩 로직 ---
                let finalImageUrl = noimgUrl; // 기본값은 noimg

                // 1. 서버에서 받은 프로필 이미지가 유효한지 확인
                if (it.profileImgUrl && it.profileImgUrl.trim() !== "") {
                    // 2. 경로가 http로 시작하지 않으면(외부 이미지가 아니면) ctx를 붙여줌
                    if (it.profileImgUrl.startsWith('http')) {
                        finalImageUrl = it.profileImgUrl;
                    } else {
                        finalImageUrl = ctx + "/" + it.profileImgUrl;
                    }
                }
                // 3. 프로필 이미지가 없으면 샘플 hero 이미지 사용
                else {
                    finalImageUrl = `${ctx}/images/sample/${it.userId}/hero.jpg`;
                }

                // 4. 로딩 중 빈칸이 보이지 않도록 먼저 기본 이미지를 설정
                $thumb.css("background-image", `url('${noimgUrl}')`);

                // 5. 최종 결정된 이미지를 미리 로드(probe) 시도
                const probe = new Image();
                probe.onload = () => {
                    // 6. 로딩 성공 시 썸네일 배경을 해당 이미지로 교체
                    $thumb.css("background-image", `url('${finalImageUrl}')`);
                };
                probe.onerror = () => {
                    // 7. 로딩 실패 시 아무것도 하지 않음 (기본 noimg가 유지됨)
                };
                probe.src = finalImageUrl;


                // --- 태그 생성 (기존과 동일) ---
                const $tagBox = $("<div>").addClass("tag-box");
                if (it.tag1) $tagBox.append($("<span>").addClass("tag").text(it.tag1));
                if (it.tag2) $tagBox.append($("<span>").addClass("tag").text(it.tag2));
                if (it.gender) {
                    const genderClass = (it.gender === "남" || it.gender === "M") ? "male" : "female";
                    $tagBox.append($("<span>").addClass("tag gender " + genderClass).text(it.gender));
                }
                $info.append($tagBox);

                $card.append($thumb).append($info);
                $(".sh-grid").append($card);
            });
        }
    });
</script>

<button type="button" class="sh-fab-left" id="sharehouseAddBtn" aria-label="쉐어하우스 등록">
    <span class="icon-plus">+</span>
</button>
<div class="sh-tooltip">쉐어하우스 등록</div>


<script>
    document.addEventListener('DOMContentLoaded', function () {
        document.getElementById('sharehouseAddBtn')?.addEventListener('click', function(){
            openProfileModal(ctx + '/sharehouse/sharehouseReg');
        });
    });
</script>

</body>
</html>