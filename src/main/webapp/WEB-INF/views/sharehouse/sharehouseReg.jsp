<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    boolean inModal = "Y".equals(request.getParameter("inModal"));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>살며시: 쉐어하우스 정보 등록</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/navbar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/modal.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sharehouse/sharehouseReg.css?v=20251006"/>
    <style>
        .uploader {
            cursor: pointer;
        }

        /* 태그 선택 버튼 */
        .tag-select-btn {
            background: linear-gradient(135deg, #3399ff 0%, #0066cc 100%);
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform .2s;
        }

        .tag-select-btn:hover {
            transform: translateY(-2px);
        }

        .tag-select-btn i {
            margin-right: 8px;
        }

        /* 층수 입력 버튼 */
        .floor-input-btn {
            background: linear-gradient(135deg, #3399ff 0%, #0066cc 100%);
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform .2s;
        }

        .floor-input-btn:hover {
            transform: translateY(-2px);
        }

        .floor-input-btn i {
            margin-right: 8px;
        }

        .button-row {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }

        /* 층수 입력 모달 */
        .floor-modal {
            display: none;
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, .5);
            z-index: 10001;
            align-items: center;
            justify-content: center;
        }

        .floor-modal-content {
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            width: 90%;
            max-width: 400px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, .2);
        }

        .floor-modal-title {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 20px;
            color: #1c407d;
        }

        .floor-input-group {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .floor-input-group input {
            flex: 1;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            text-align: center;
        }

        .floor-input-group input:focus {
            outline: none;
            border-color: #3399ff;
        }

        .floor-input-group span {
            font-size: 1rem;
            color: #666;
            font-weight: 600;
        }

        .floor-modal-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        .floor-modal-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            transition: .2s;
        }

        .floor-modal-btn.cancel {
            background: #f0f0f0;
            color: #666;
        }

        .floor-modal-btn.cancel:hover {
            background: #e0e0e0;
        }

        .floor-modal-btn.confirm {
            background: #3399ff;
            color: #fff;
        }

        .floor-modal-btn.confirm:hover {
            background: #2288ee;
        }

        /* 모달 여백 제거 */
        #sharehouseRegOverlay .modal-sheet {
            max-height: 95vh !important;
            margin: 0 !important;
        }

        #sharehouseRegOverlay .modal-body {
            padding: 0 !important;
            overflow-y: auto;
        }

        /* 우편번호 입력 필드 스타일 */
        .address-group {
            margin-bottom: 20px;
        }

        .address-row {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
        }

        .address-row input[readonly] {
            background-color: #f5f5f5;
            cursor: not-allowed;
        }

        .address-row button {
            padding: 10px 20px;
            background: linear-gradient(135deg, #3399ff 0%, #0066cc 100%);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: transform .2s;
            white-space: nowrap;
        }

        .address-row button:hover {
            transform: translateY(-2px);
        }

        .address-input-full {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
        }

        .address-input-full:focus {
            outline: none;
            border-color: #3399ff;
        }
    </style>
    <!-- 다음 우편번호 서비스 -->
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>

<body>
<% if (!inModal) { %>
<header>
    <div class="home-logo" onclick="location.href='/user/main'">
        <div class="header-icon-stack"><i class="fa-solid fa-people-roof fa-xs" style="color:#3399ff;"></i></div>
        <div class="header-logo">살며시</div>
    </div>
    <div class="header-user-area">
        <div class="header-switch-container pinned" id="switchBox">
            <span class="slide-bg3"></span>
            <button class="switch-list" onclick="location.href='/profile.html'">룸메이트</button>
            <button class="switch-list" onclick="location.href='/logout.html'">쉐어하우스</button>
            <button class="header-dropdown-toggle" id="switchToggle"><i class="fa-solid fa-repeat fa-sm"
                                                                        style="color:#1c407d;"></i></button>
        </div>
        <div class="header-user-name-container pinned" id="userNameBox">
            <span class="slide-bg"></span>
            <span class="user-name-text" id="userNameText"><%= session.getAttribute("SS_USER_NAME") %>님</span>
            <button class="header-dropdown-toggle" id="userIconToggle"><i class="fa-solid fa-circle-user fa-sm"
                                                                          style="color:#1c407d;"></i></button>
        </div>
        <div class="header-menu-container pinned" id="menuBox">
            <span class="slide-bg2"></span>
            <button class="menu-list" onclick="location.href='/profile.html'">마이페이지</button>
            <button class="menu-list" onclick="location.href='/logout.html'">로그아웃</button>
            <button class="header-dropdown-toggle" id="headerDropdownToggle"><i class="fa-solid fa-bars fa-xs"
                                                                                style="color:#1c407d;"></i></button>
        </div>
    </div>
</header>
<% } %>

<main class="roommate-container">
    <form id="roommateForm" action="/sharehouse/register" method="post" enctype="multipart/form-data">
        <section class="roommate-left sh-reg-wrap">
            <c:set var="loginName" value="${sessionScope.SS_USER_NAME}"/>
            <div class="form-group name-group">
                <label>
          <span>
            <c:choose>
                <c:when test="${not empty loginName}">
                    <c:out value="${loginName}"/>의 쉐어하우스
                </c:when>
                <c:otherwise>내 쉐어하우스</c:otherwise>
            </c:choose>
          </span>
                </label>
            </div>

            <!-- 쉐어하우스 이름 -->
            <div class="form-group">
                <label>쉐어하우스 이름 <span style="color:#999; font-size:.9em;">(최대 20자)</span></label>
                <input type="text" name="houseName" id="houseName" maxlength="20"
                       placeholder="예: 강남 따뜻한 쉐어하우스 역세권" required
                       style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; font-size:1rem;">
            </div>

            <!-- 태그 선택 + 층수 입력 -->
            <div class="form-group">
                <div class="button-row">
                    <button type="button" id="btnTagSelect" class="tag-select-btn">
                        <i class="fa-solid fa-tags"></i> 태그 6개 선택 (필수)
                    </button>
                    <button type="button" id="btnFloorOpen" class="floor-input-btn">
                        <i class="fa-solid fa-building"></i> 층수 입력 (필수)
                    </button>
                </div>
                <div id="selectedTagsDisplay" style="margin-top:8px; color:#666; font-size:.9rem;">태그 6개와 층수를 선택해주세요.
                </div>
                <input type="hidden" id="selectedTagIds" name="tagListJson" value="[]">
                <input type="hidden" id="floorNumber" name="floorNumber" value="">
            </div>

            <!-- 우편번호 및 주소 입력 -->
            <div class="form-group address-group">
                <label>주소 <span style="color:#999; font-size:.9em;">(필수)</span></label>
                <div class="address-row">
                    <input type="text" id="addr1" name="addr1" placeholder="주소" readonly required
                           style="flex:1; padding:10px; border:1px solid #ddd; border-radius:8px; font-size:1rem;">
                    <button type="button" id="btnAddr">
                        <i class="fa-solid fa-magnifying-glass"></i> 우편번호 찾기
                    </button>
                </div>
                <input type="text" id="addr2" name="addr2" placeholder="상세주소를 입력하세요" required
                       class="address-input-full">
            </div>

            <div class="sh-modal-body sh-reg">
                <div class="sh-top-row">
                    <!-- 업로더 5장 -->
                    <section class="sh-uploader-5">
                        <label class="uploader thumb">
                            <input type="file" name="thumbnail" accept="image/*" hidden>
                            <span>대표 이미지(썸네일)</span>
                            <img class="preview" alt="" hidden>
                        </label>
                        <label class="uploader small">
                            <input type="file" name="images" accept="image/*" hidden>
                            <span>이미지 업로드</span>
                            <img class="preview" alt="" hidden>
                        </label>
                        <label class="uploader small">
                            <input type="file" name="images" accept="image/*" hidden>
                            <span>이미지 업로드</span>
                            <img class="preview" alt="" hidden>
                        </label>
                        <label class="uploader small">
                            <input type="file" name="images" accept="image/*" hidden>
                            <span>이미지 업로드</span>
                            <img class="preview" alt="" hidden>
                        </label>
                        <!-- ✅ 안내 영역 (업로드 불가) -->
                        <div class="upload-notice-box">
                            <div class="notice-icon">
                                <i class="fa-solid fa-images"></i>
                            </div>
                            <div class="notice-title">최대 4장까지<br>업로드 가능</div>
                            <div class="notice-subtitle">대표 이미지 1장 +<br>추가 이미지 3장</div>
                        </div>
                    </section>


                    <!-- 태그 패널 -->
                    <aside class="inline-tag-panel inline-right">
                        <div class="inline-tag-title">쉐어하우스 태그</div>
                        <div class="inline-tag-list" id="inlineTagList"></div>
                        <p class="inline-tag-empty" id="inlineTagEmpty">등록된 태그가 없습니다.</p>
                    </aside>
                </div>

                <!-- 소개글 -->
                <section class="sh-reg-intro">
                    <div class="form-group">
                        <label>쉐어하우스 소개</label>
                        <textarea id="introTextarea" name="introduction" rows="10" placeholder="소개글 시작"></textarea>
                    </div>
                </section>
            </div>

            <div class="sh-reg-actions">
                <button type="button" class="btn btn-cancel" id="shRegCancelBtn">취소</button>
                <button type="submit" class="btn btn-primary" id="btnSave">저장</button>
            </div>
        </section>
    </form>
</main>

<!-- 층수 입력 모달 -->
<div class="floor-modal" id="floorModal">
    <div class="floor-modal-content">
        <div class="floor-modal-title">
            <i class="fa-solid fa-building" style="color:#667eea; margin-right:8px;"></i> 층수 입력
        </div>
        <div class="floor-input-group">
            <input type="number" id="floorInput" min="1" max="99" placeholder="숫자 입력">
            <span>층</span>
        </div>
        <div class="floor-modal-actions">
            <button type="button" class="floor-modal-btn cancel" id="btnFloorCancel">취소</button>
            <button type="button" class="floor-modal-btn confirm" id="btnFloorConfirm">확인</button>
        </div>
    </div>
</div>

<!-- ✅ 1. jQuery (가장 먼저!) -->
<script src="${pageContext.request.contextPath}/js/jquery-3.6.0.min.js"></script>

<!-- ✅ 2. customModal 포함 (jQuery 다음) -->
<%@ include file="../includes/customModal.jsp" %>

<!-- ✅ 3. 다음 우편번호 서비스 스크립트 -->
<script>
    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function (data) {
                let addr = '';
                if (data.userSelectedType === 'R') {
                    addr = data.roadAddress;
                } else {
                    addr = data.jibunAddress;
                }
                document.getElementById('addr1').value = addr;
                document.getElementById('addr2').focus();
            }
        }).open();
    }

    document.addEventListener('DOMContentLoaded', function () {
        const btnAddr = document.getElementById('btnAddr');
        if (btnAddr) {
            btnAddr.addEventListener('click', function (e) {
                e.preventDefault();
                execDaumPostcode();
            });
        }
    });
</script>

<!-- ✅ 4. 취소 버튼 -->
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const cancelBtn = document.getElementById('shRegCancelBtn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', function (e) {
                e.preventDefault();
                try {
                    if (window.parent && typeof window.parent.closeSharehouseRegModal === 'function') {
                        window.parent.closeSharehouseRegModal();
                    } else {
                        window.close();
                    }
                } catch (err) {
                    console.error('모달 닫기 실패:', err);
                }
            });
        }
    });
</script>

<!-- ✅ 5. 업로더 미리보기 및 태그/층수 표시 -->
<script>
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.sh-uploader-5 .uploader input[type="file"]').forEach(input => {
            const wrap = input.closest('.uploader');
            const span = wrap.querySelector('span');
            const img = wrap.querySelector('.preview');

            wrap.addEventListener('mousedown', () => {
                input.value = null;
            });
            input.addEventListener('click', () => {
                input.value = null;
            });

            input.addEventListener('change', () => {
                const f = input.files && input.files[0];
                if (!f) {
                    img.hidden = true;
                    span.hidden = false;
                    return;
                }
                if (!f.type.startsWith('image/')) {
                    showCustomAlert('이미지 파일만 업로드 가능합니다.');
                    input.value = '';
                    return;
                }
                if (f.size > 10 * 1024 * 1024) {
                    showCustomAlert('최대 10MB까지만 업로드 가능합니다.');
                    input.value = '';
                    return;
                }
                img.src = URL.createObjectURL(f);
                img.hidden = false;
                span.hidden = true;
            });
        });
        renderInlineTags();
    });

    function renderInlineTags() {
        const list = document.getElementById('inlineTagList');
        const empty = document.getElementById('inlineTagEmpty');
        const tagIds = JSON.parse(document.getElementById('selectedTagIds').value || '[]');
        const floorNum = document.getElementById('floorNumber').value;
        list.innerHTML = '';
        let hasContent = false;

        if (tagIds.length > 0) {
            hasContent = true;
            tagIds.forEach(tagId => {
                const tagName = window.tagMap && window.tagMap[tagId] ? window.tagMap[tagId] : `태그${tagId}`;
                const pill = document.createElement('span');
                pill.className = 'tag-pill';
                pill.textContent = tagName;
                list.appendChild(pill);
            });
        }
        if (floorNum && floorNum !== '') {
            hasContent = true;
            const floorPill = document.createElement('span');
            floorPill.className = 'tag-pill';
            floorPill.textContent = floorNum + '층';
            list.appendChild(floorPill);
        }
        empty.style.display = hasContent ? 'none' : '';
    }

    window.tagMap = {};

    function updateDisplayText() {
        const display = document.getElementById('selectedTagsDisplay');
        const tagIds = JSON.parse(document.getElementById('selectedTagIds').value || '[]');
        const floorNum = document.getElementById('floorNumber').value;

        let parts = [];
        if (tagIds.length > 0) {
            const tagNames = tagIds.map(id => window.tagMap[id] || `태그${id}`);
            parts.push(...tagNames);
        }
        if (floorNum && floorNum !== '' && floorNum !== 'undefined') {
            parts.push(floorNum + '층');
        }

        if (parts.length > 0) {
            display.textContent = '선택됨: ' + parts.join(', ');
            display.style.color = '#3399ff';
        } else {
            display.textContent = '태그 6개와 층수를 선택해주세요.';
            display.style.color = '#666';
        }
    }
</script>

<!-- ✅ 6. 층수 입력 모달 스크립트 -->
<script>
    function openFloorModal() {
        const modal = document.getElementById('floorModal');
        const input = document.getElementById('floorInput');
        const currentFloor = document.getElementById('floorNumber').value;
        input.value = currentFloor || '';
        modal.style.display = 'flex';
        input.focus();
    }

    function closeFloorModal() {
        document.getElementById('floorModal').style.display = 'none';
    }

    function saveFloorNumber() {
        const input = document.getElementById('floorInput');
        const floorNum = parseInt(input.value);
        if (isNaN(floorNum) || floorNum < 1 || floorNum > 99) {
            showCustomAlert('1층부터 99층까지 입력 가능합니다.');
            return;
        }
        document.getElementById('floorNumber').value = floorNum;
        updateDisplayText();
        renderInlineTags();
        closeFloorModal();
    }

    document.addEventListener('DOMContentLoaded', () => {
        const floorInput = document.getElementById('floorInput');
        if (floorInput) floorInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') saveFloorNumber();
        });
    });
</script>

<!-- ✅ 7. 저장 제출 -->
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const form = document.getElementById('roommateForm');
        const btn = document.getElementById('btnSave');

        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            const houseName = document.getElementById('houseName')?.value?.trim();
            if (!houseName) {
                showCustomAlert('쉐어하우스 이름을 입력해 주세요.');
                document.getElementById('houseName')?.focus();
                return;
            }
            if (houseName.length > 20) {
                showCustomAlert('쉐어하우스 이름은 최대 20자까지 입력 가능합니다.');
                return;
            }

            const tagIds = JSON.parse(document.getElementById('selectedTagIds').value || '[]');
            if (tagIds.length !== 6) {
                showCustomAlert('태그를 정확히 6개 선택해주세요.');
                return;
            }

            const floorNum = document.getElementById('floorNumber').value;
            if (!floorNum || floorNum === '') {
                showCustomAlert('층수를 입력해주세요.');
                return;
            }

            const addr1 = document.getElementById('addr1').value.trim();
            const addr2 = document.getElementById('addr2').value.trim();

            if (!addr1) {
                showCustomAlert('주소를 입력해주세요. "우편번호 찾기" 버튼을 클릭하세요.');
                return;
            }

            if (!addr2) {
                showCustomAlert('상세주소를 입력해주세요.');
                document.getElementById('addr2').focus();
                return;
            }

            const thumb = form.querySelector('input[name="thumbnail"]')?.files?.[0];
            if (!thumb) {
                showCustomAlert('대표 이미지를 선택해 주세요.');
                return;
            }

            const imgs = [...form.querySelectorAll('input[name="images"]')].map(i => i.files?.[0]).filter(Boolean);
            if (imgs.length < 1) {
                showCustomAlert('추가 이미지를 최소 1장 선택해 주세요.');
                return;
            }

            btn.disabled = true;
            btn.textContent = '저장중...';
            const fd = new FormData();

            const thumbnailFile = form.querySelector('input[name="thumbnail"]').files[0];
            if (thumbnailFile) {
                fd.append('thumbnail', thumbnailFile);
            }

            // ✅ 추가 이미지 (파일이 있을 때만!)
            const imageInputs = form.querySelectorAll('input[name="images"]');
            imageInputs.forEach(input => {
                if (input.files && input.files[0]) {  // ✅ 파일 있을 때만!
                    fd.append('images', input.files[0]);
                }
            });

            // ✅ 나머지 필드들
            fd.append('houseName', document.getElementById('houseName').value);
            fd.append('introduction', document.getElementById('introTextarea').value || '');
            fd.append('tagListJson', document.getElementById('selectedTagIds').value);
            fd.append('floorNumber', document.getElementById('floorNumber').value);
            fd.append('addr1', document.getElementById('addr1').value);
            fd.append('addr2', document.getElementById('addr2').value);

            try {
                const url = (typeof ctx !== 'undefined' ? ctx : '') + '/sharehouse/register';
                const res = await fetch(url, {method: 'POST', body: fd, credentials: 'include'});
                let json = null;
                try {
                    json = await res.clone().json();
                } catch (_) {
                }

                if (res.status === 0 || res.type === 'opaqueredirect') {
                    showCustomAlert('저장 실패 (redirect/CORS 가능성)\n로그인 리다이렉트 또는 CORS 설정을 확인해 주세요.');
                    return;
                }
                if (!res.ok) {
                    const text = (json && json.msg) || (await res.text().catch(() => '')) || '서버 오류';
                    showCustomAlert(`저장 실패 (${res.status})\n${text}`);
                    return;
                }

                json = json || {};
                if (json.result === 1 || json.result === 'success') {
                    const savedId = json?.data?.shId ?? null;
                    if (window.parent) window.parent.postMessage({type: 'SH_SAVED', shId: savedId}, '*');
                    try {
                        if (window.parent && typeof window.parent.closeSharehouseRegModal === 'function') {
                            window.parent.closeSharehouseRegModal();
                        }
                    } catch (_) {
                    }
                    if (window === window.parent) location.href = '/sharehouse/main';
                } else {
                    showCustomAlert(json.msg || '저장에 실패했습니다.');
                }
            } catch (err) {
                console.error(err);
                showCustomAlert('서버 통신 중 오류가 발생했습니다.');
            } finally {
                btn.disabled = false;
                btn.textContent = '저장';
            }
        });
    });
</script>

<!-- ✅ 8. 태그 선택 모달 포함 -->
<jsp:include page="/WEB-INF/views/sharehouse/sharehouseTagSelect.jsp"/>

<!-- ✅ 9. 페이지 전용 바인딩 -->
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const tagBtn = document.getElementById('btnTagSelect');
        if (tagBtn) {
            tagBtn.addEventListener('click', function () {
                if (typeof window.openTagSelectPopup === 'function') {
                    window.openTagSelectPopup();
                    return;
                }
                const openImpl = window.openTagSelectModal || window.openTagModal;
                if (typeof openImpl === 'function') {
                    const hidden = document.getElementById('selectedTagIds');
                    const current = JSON.parse(hidden.value || '[]');
                    openImpl(current, function (ids) {
                        hidden.value = JSON.stringify(ids);

                        window.tagMap = window.tagMap || {};
                        ids.forEach(function (id) {
                            const btn = document.querySelector('.tag-btn[data-id="' + id + '"]');
                            if (btn) window.tagMap[id] = btn.getAttribute('data-name') || btn.textContent || ('태그' + id);
                        });

                        updateDisplayText();
                        renderInlineTags();
                    });
                } else if (typeof $ !== 'undefined' && $('#tagSelectModalOverlay').length) {
                    $('#tagSelectModalOverlay').show();
                } else {
                    showCustomAlert('태그 선택 모달 스크립트를 찾지 못했습니다. sharehouseTagSelect.jsp를 확인하세요.');
                }
            });
        }

        const btnFloorOpen = document.getElementById('btnFloorOpen');
        const btnFloorCancel = document.getElementById('btnFloorCancel');
        const btnFloorConfirm = document.getElementById('btnFloorConfirm');

        if (btnFloorOpen) btnFloorOpen.addEventListener('click', openFloorModal);
        if (btnFloorCancel) btnFloorCancel.addEventListener('click', closeFloorModal);
        if (btnFloorConfirm) btnFloorConfirm.addEventListener('click', saveFloorNumber);
    });
</script>

<script>
    window.userName = '<c:out value="${sessionScope.SS_USER_NAME}" default=""/>';
</script>

<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/navbar.js"></script>

<style id="tagModalStyles">
    :root {
        --sh-primary: #1c407d;
        --sh-border: #e5e7eb;
        --sh-bg: #f5f7fb;
        --radius: 14px;
        --shadow: 0 6px 18px rgba(0, 0, 0, .06);
    }

    html body #tagSelectModalOverlay.modal-overlay {
        position: fixed;
        inset: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, .4);
        backdrop-filter: blur(1px);
        z-index: 10020;
    }

    html body #tagSelectModalOverlay .modal-sheet {
        width: 100%;
        max-width: 450px;
        max-height: 80vh;
        background: #fff;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: var(--shadow);
        animation: fadeIn .3s;
        display: flex;
        flex-direction: column;
    }

    html body #tagSelectModalOverlay .modal-header {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 16px 20px;
        border-bottom: 1px solid #eee;
        background: #fff;
    }

    html body #tagSelectModalOverlay .modal-title-text {
        font-weight: 700;
        font-size: 1.05rem;
        color: #1f2937;
    }

    html body #tagSelectModalOverlay .modal-close {
        position: absolute;
        right: 12px;
        top: 12px;
        width: 36px;
        height: 36px;
        border: 0;
        border-radius: 999px;
        background: #f6f7f8;
        display: grid;
        place-items: center;
        cursor: pointer;
    }

    html body #tagSelectModalOverlay .modal-close:hover {
        background: #eceff3;
    }

    html body #tagSelectModalOverlay .modal-body {
        padding: 14px 16px;
        overflow: auto;
        flex: 1;
        background: #fafbfc;
    }

    html body #tagSelectModalOverlay .all-tag-list {
        display: grid;
        grid-template-columns:repeat(3, minmax(0, 1fr));
        gap: 8px;
    }

    @media (max-width: 640px) {
        html body #tagSelectModalOverlay .all-tag-list {
            grid-template-columns:repeat(2, minmax(0, 1fr));
        }
    }

    html body #tagSelectModalOverlay .tag-btn {
        padding: 10px 12px;
        border: 1px solid #e5e8ef;
        background: #fff;
        color: #334155;
        border-radius: 999px;
        font-size: .95rem;
        cursor: pointer;
        transition: .18s;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    html body #tagSelectModalOverlay .tag-btn:hover {
        border-color: #cfd7e6;
        transform: translateY(-1px);
    }

    html body #tagSelectModalOverlay .tag-btn.selected {
        background: #485fe7;
        border-color: #485fe7;
        color: #fff;
    }

    @keyframes fadeIn {
        0% {
            opacity: 0;
            transform: scale(.95)
        }
        100% {
            opacity: 1;
            transform: scale(1)
        }
    }
</style>

</body>
</html>