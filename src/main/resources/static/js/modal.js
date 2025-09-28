// 콜백 함수를 저장할 변수들
let alertCallback = null;
let confirmOkCallback = null;
let confirmCancelCallback = null;

/**
 * 알림창 (버튼 1개)을 보여주는 함수
 */
function showCustomAlert(message, callback) {
    const overlay = document.getElementById('customAlertOverlay');
    const msgEl = document.getElementById('customAlertMessage');
    const cancelBtn = document.getElementById('customAlertCancel');

    if (overlay && msgEl && cancelBtn) {
        msgEl.innerText = message;
        cancelBtn.style.display = 'none'; // 취소 버튼 숨기기
        overlay.style.display = 'flex';

        alertCallback = callback || null;
    }
}

/**
 * 확인창 (버튼 2개)을 보여주는 함수
 */
function showCustomConfirm(message, onConfirm, onCancel) {
    const overlay = document.getElementById('customAlertOverlay');
    const msgEl = document.getElementById('customAlertMessage');
    const cancelBtn = document.getElementById('customAlertCancel');

    if (overlay && msgEl && cancelBtn) {
        msgEl.innerText = message;
        cancelBtn.style.display = 'inline-block'; // 취소 버튼 보이기
        overlay.style.display = 'flex';

        confirmOkCallback = onConfirm || null;
        confirmCancelCallback = onCancel || null;
    }
}

/**
 * 모달을 닫는 공통 함수
 */
function closeCustomModal() {
    const overlay = document.getElementById('customAlertOverlay');
    if (overlay) {
        overlay.style.display = 'none';
    }
    // 모든 콜백 변수 초기화
    alertCallback = null;
    confirmOkCallback = null;
    confirmCancelCallback = null;
}

// 페이지 로드 시 버튼에 이벤트 리스너 한 번만 설정
document.addEventListener('DOMContentLoaded', function() {
    const okBtn = document.getElementById('customAlertOk');
    const cancelBtn = document.getElementById('customAlertCancel');

    if (okBtn) {
        okBtn.addEventListener('click', function() {
            if (confirmOkCallback) {
                confirmOkCallback();
            }
            if (alertCallback) {
                alertCallback();
            }
            closeCustomModal();
        });
    }

    if (cancelBtn) {
        cancelBtn.addEventListener('click', function() {
            if (confirmCancelCallback) {
                confirmCancelCallback();
            }
            closeCustomModal();
        });
    }
});