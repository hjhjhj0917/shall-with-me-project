let alertCallback = null;
let confirmOkCallback = null;
let confirmCancelCallback = null;

function showCustomAlert(message, callback) {
    const overlay = document.getElementById('customAlertOverlay');
    const msgEl = document.getElementById('customAlertMessage');
    const cancelBtn = document.getElementById('customAlertCancel');

    if (overlay && msgEl && cancelBtn) {
        msgEl.innerText = message;
        cancelBtn.style.display = 'none';
        overlay.style.display = 'flex';

        alertCallback = callback || null;
    }
}

function showCustomConfirm(message, onConfirm, onCancel) {
    const overlay = document.getElementById('customAlertOverlay');
    const msgEl = document.getElementById('customAlertMessage');
    const cancelBtn = document.getElementById('customAlertCancel');

    if (overlay && msgEl && cancelBtn) {
        msgEl.innerText = message;
        cancelBtn.style.display = 'inline-block';
        overlay.style.display = 'flex';

        confirmOkCallback = onConfirm || null;
        confirmCancelCallback = onCancel || null;
    }
}

function closeCustomModal() {
    const overlay = document.getElementById('customAlertOverlay');
    if (overlay) {
        overlay.style.display = 'none';
    }
    alertCallback = null;
    confirmOkCallback = null;
    confirmCancelCallback = null;
}

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