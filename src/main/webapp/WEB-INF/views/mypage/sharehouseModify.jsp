<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>살며시: 쉐어하우스 정보 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sideBar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

    <style>
        body {
            font-size: 15px;
            line-height: 1.5;
            background: linear-gradient(to right, white, #f9f9f9);
        }

        /* 전체 메인 콘텐츠 영역 */
        .sidebar-main-content {
            padding: 40px;
        }

        .mypage-wrapper {
            max-width: 1200px;
            margin: 80px auto;
        }

        .mypage-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 20px;
            text-align: left;
        }

        /* 카드 컨테이너 - 그리드로 변경 */
        .sharehouse-card-container {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
            margin-top: 20px;
        }

        @media (max-width: 1200px) {
            .sharehouse-card-container {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .sharehouse-card-container {
                grid-template-columns: 1fr;
            }
        }

        /* 카드 스타일 */
        .sh-card {
            position: relative;
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 6px 18px rgba(0,0,0,.06);
            transition: transform .15s ease, box-shadow .15s ease;
        }

        .sh-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(0,0,0,.08);
        }

        /* 썸네일 */
        .sh-thumb {
            height: 200px;
            background: #e9eef7 no-repeat center 15%;
            background-size: cover;
        }

        /* X 버튼 스타일 */
        .delete-btn {
            position: absolute;
            top: 12px;
            right: 12px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(to right, #66B2FF, #3399ff);
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.3);
            transition: transform 0.2s, box-shadow 0.2s;
            z-index: 10;
        }

        .delete-btn:hover {
            transform: scale(1.15);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.4);
        }

        .delete-btn:active {
            transform: scale(0.95);
        }

        .delete-btn i {
            pointer-events: none;
        }

        /* 텍스트 영역 */
        .sh-info {
            padding: 14px;
        }

        .sh-title {
            margin: 0 0 8px 0;
            font-weight: 600;
            font-size: 16px;
            color: #1f2a37;
        }

        /* 태그 박스 */
        .tag-box {
            margin-top: 10px;
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .tag {
            display: inline-block;
            background-color: #f0f0f0;
            color: #333;
            font-size: 12px;
            padding: 4px 9px;
            border-radius: 12px;
        }

        .tag.floor-tag {
            background-color: #dce6ff;
            color: #1c407d;
            font-weight: 600;
        }

        /* 안내 메시지 - userModify 스타일과 동일하게 */
        .no-data-message {
            text-align: center;
            padding: 60px 20px;
            color: #6e7b8b;
            font-size: 15px;
            grid-column: 1 / -1; /* 전체 그리드 영역 차지 */
        }

        .no-data-message i {
            font-size: 48px;
            margin-bottom: 16px;
            color: #d1d5db;
            display: block;
        }
    </style>
</head>
<body>
<%--헤더--%>
<%@ include file="../includes/header.jsp" %>

<div class="main-container">
    <%--사이드바--%>
    <%@ include file="../includes/sideBar.jsp" %>

    <main class="sidebar-main-content">
        <div class="mypage-wrapper">
            <h1 class="mypage-title">쉐어하우스 정보 수정</h1>

            <!-- 카드가 표시될 영역 (그리드) -->
            <div class="sharehouse-card-container" id="sharehouse-card-area"></div>
        </div>
    </main>
</div>

<%@ include file="../includes/chatbot.jsp" %>
<%@ include file="../includes/footer.jsp" %>

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
    const ctx = "${pageContext.request.contextPath}";
    const loginUserId = "${sessionScope.SS_USER_ID}";
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>
<script src="${pageContext.request.contextPath}/js/sideBar.js"></script>

<script>
    $(document).ready(function() {
        loadMySharehouse();
    });

    // 본인의 쉐어하우스 정보 불러오기
    function loadMySharehouse() {
        $.ajax({
            url: ctx + '/sharehouse/getMySharehouse',
            type: 'GET',
            dataType: 'json',
            success: function(response) {
                if (response.houses && response.houses.length > 0) {
                    renderSharehouseCards(response.houses);
                } else {
                    showNoData();
                }
            },
            error: function(xhr, status, error) {
                console.error('쉐어하우스 정보 불러오기 실패', error);
                if (xhr.status === 401) {
                    showCustomAlert('로그인이 필요합니다.', function() {
                        location.href = ctx + '/user/login';
                    });
                } else {
                    showCustomAlert('쉐어하우스 정보를 불러오는데 실패했습니다.');
                }
            }
        });
    }

    // 여러 카드 렌더링 (X 버튼 포함)
    function renderSharehouseCards(houses) {
        const $container = $('#sharehouse-card-area');
        $container.empty();

        houses.forEach(function(house) {
            const houseId = house.houseId;
            const imgUrl = house.profileImgUrl || (ctx + "/images/noimg.png");
            const houseName = house.name || "알 수 없음";

            const $card = $("<article>").addClass("sh-card");

            // X 버튼 추가
            const $deleteBtn = $("<button>")
                .addClass("delete-btn")
                .attr("aria-label", "삭제")
                .html('<i class="fa-solid fa-xmark"></i>')
                .on('click', function(e) {
                    e.stopPropagation();
                    confirmDeleteSharehouse(houseId);
                });

            const $thumb = $("<div>")
                .addClass("sh-thumb")
                .css("background-image", "url('" + imgUrl + "')");

            const $info = $("<div>").addClass("sh-info");
            const $title = $("<p>").addClass("sh-title").text(houseName);
            $info.append($title);

            const $tagBox = $("<div>").addClass("tag-box");

            // 태그 3개 표시
            if (house.tag1) {
                $tagBox.append($("<span>").addClass("tag").text(house.tag1));
            }
            if (house.tag2) {
                $tagBox.append($("<span>").addClass("tag").text(house.tag2));
            }
            if (house.tag3) {
                $tagBox.append($("<span>").addClass("tag").text(house.tag3));
            }

            // 층수 표시
            if (house.floorNumber != null && house.floorNumber !== '' && house.floorNumber !== 'null') {
                const floorTag = $("<span>")
                    .addClass("tag floor-tag")
                    .text(house.floorNumber + "층");
                $tagBox.append(floorTag);
            }

            $info.append($tagBox);
            $card.append($deleteBtn, $thumb, $info);
            $container.append($card);
        });
    }

    // 데이터 없을 때 표시 (userModify 스타일)
    function showNoData() {
        const $container = $('#sharehouse-card-area');
        $container.empty();

        const $message = $('<div>')
            .addClass('no-data-message')
            .html('<i class="fa-solid fa-house-circle-xmark"></i>등록된 쉐어하우스가 없습니다.');

        $container.append($message);
    }

    // 삭제 확인 모달 표시
    function confirmDeleteSharehouse(houseId) {
        showCustomConfirm(
            '쉐어하우스 작성 글을 삭제하시겠습니까?',
            function() {
                // 확인 버튼 클릭 시
                deleteSharehouse(houseId);
            },
            function() {
                // 취소 버튼 클릭 시
                console.log('삭제 취소됨');
            }
        );
    }

    // 실제 삭제 요청
    function deleteSharehouse(houseId) {
        $.ajax({
            url: ctx + '/sharehouse/delete',
            type: 'POST',
            data: { houseId: houseId },
            success: function(response) {
                if (response.success) {
                    showCustomAlert('쉐어하우스가 삭제되었습니다.', function() {
                        // 삭제 후 현재 페이지 새로고침
                        location.reload();
                    });
                } else {
                    showCustomAlert(response.message || '삭제에 실패했습니다.');
                }
            },
            error: function(xhr, status, error) {
                console.error('삭제 실패', error);
                if (xhr.status === 401) {
                    showCustomAlert('로그인이 필요합니다.', function() {
                        location.href = ctx + '/user/login';
                    });
                } else if (xhr.status === 403) {
                    showCustomAlert('본인의 쉐어하우스만 삭제할 수 있습니다.');
                } else {
                    showCustomAlert('삭제 중 오류가 발생했습니다. 다시 시도해주세요.');
                }
            }
        });
    }
</script>

</body>
</html>
