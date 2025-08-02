let customAlertCallback = null;

function showCustomAlert(message, callback) {
    document.getElementById("customAlertMessage").innerText = message;
    document.getElementById("customAlertOverlay").style.display = "flex";
    customAlertCallback = callback || null;
}

function closeCustomAlert() {
    document.getElementById("customAlertOverlay").style.display = "none";
    if (customAlertCallback) {
        customAlertCallback(); // 확인 후 실행
        customAlertCallback = null; // 재사용 방지
    }
}