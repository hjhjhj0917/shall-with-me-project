<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 쉐어하우스 찾기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseAddBtn.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseMain.css"/>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-3.6.0.min.js"></script>

    <style>
        body.modal-open { overflow: hidden; }
        body.modal-open header,
        body.modal-open #sh-wrapper {
            pointer-events: none; -webkit-user-select: none; user-select: none; touch-action: none;
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
            bgEls.forEach(el => { if (el) { el.setAttribute('inert',''); el.setAttribute('aria-hidden','true'); }});
            document.getElementById('profileModalClose')?.focus();
        }

        function closeProfileModal() {
            const ov = document.getElementById('profileModalOverlay');
            const frame = document.getElementById('profileModalFrame');
            if (!ov || !frame) return;
            ov.style.display = 'none';
            document.body.classList.remove('modal-open');
            const bgEls = [document.querySelector('header'), document.getElementById('sh-wrapper')];
            bgEls.forEach(el => { if (el) { el.removeAttribute('inert'); el.removeAttribute('aria-hidden'); }});
            frame.src = 'about:blank';
            document.getElementById('sharehouseAddBtn')?.focus();
        }

        document.addEventListener('click', (e) => {
            const ov = document.getElementById('profileModalOverlay');
            if (ov && ov.style.display === 'flex' && e.target === ov) closeProfileModal();
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
        <section class="sh-grid"></section>
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
        if (grid) {
            grid.addEventListener('click', (e) => {
                const card = e.target.closest('.sh-card');
                if (card && grid.contains(card)) {
                    const id = card.dataset.id;
                    if (id) {
                        window.open(ctx + '/sharehouse/sharehouseDetail?userId=' + encodeURIComponent(id), '_blank');
                    }
                }
            });
        }
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
                error: function (xhr, status, err) { console.error("목록 불러오기 실패:", err); },
                complete: function () { loading = false; }
            });
        }

        function renderUserCards(items) {
            const loginUserId = "${sessionScope.SS_USER_ID}";
            const stamp = Date.now();                   // 캐시 버스터
            const noimg = ctx + "/images/noimg.png";
            const $grid = $(".sh-grid");

            $.each(items, function (i, it) {
                if (String(it.userId) === String(loginUserId)) return true;

                const nickname = it.name || "알 수 없음";
                const age = it.age ? (it.age + "세") : "";

                // 카드 뼈대
                const $card  = $("<article>").addClass("sh-card").attr("data-id", it.userId);
                const $thumb = $("<div>").addClass("sh-thumb")
                    .css("background-image", "url('" + noimg + "')");  // 회색 방지용 기본값
                const $info  = $("<div>").addClass("sh-info")
                    .append($("<p>").addClass("sh-sub").text("이름 : " + nickname + (age ? " (" + age + ")" : "")));

                // 우선순위: (서버 프로필) → (샘플 hero)
                const sampleHero = ctx + "/images/sample/" + it.userId + "/hero.jpg?v=" + stamp;
                const wanted = (it.profileImgUrl && it.profileImgUrl.trim() !== "")
                    ? (it.profileImgUrl + (it.profileImgUrl.indexOf("?") >= 0 ? "&" : "?") + "v=" + stamp)
                    : sampleHero;

                // 미리 로드해서 성공 시 교체, 실패면 noimg 유지
                const probe = new Image();
                probe.onload  = function(){ $thumb.css("background-image", "url('" + wanted + "')"); };
                probe.onerror = function(){ $thumb.css("background-image", "url('" + noimg + "')"); };
                probe.src = wanted;

                // 태그들
                const $tagBox = $("<div>").addClass("tag-box");
                if (it.tag1) $tagBox.append($("<span>").addClass("tag").text(it.tag1));
                if (it.tag2) $tagBox.append($("<span>").addClass("tag").text(it.tag2));
                if (it.gender) {
                    const genderClass = (it.gender === "남" || it.gender === "M") ? "male" : "female";
                    $tagBox.append($("<span>").addClass("tag gender " + genderClass).text(it.gender));
                }
                $info.append($tagBox);

                $card.append($thumb).append($info);
                $grid.append($card);
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
        const addBtn = document.getElementById('sharehouseAddBtn');
        if (addBtn) {
            addBtn.addEventListener('click', function(){
                openProfileModal(ctx + '/sharehouse/sharehouseReg');
            });
        }
    });
</script>

</body>
</html>