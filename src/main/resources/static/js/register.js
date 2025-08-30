// 아이디 중복체크여부 (중복 Y / 중복아님 : N)
let userIdCheck = "Y";

// 이메일 중복체크 인증번호 발송 값
let emailAuthNumber = "";

// HTML 로딩 완료 후 실행
$(document).ready(function () {

    $.datepicker.setDefaults($.datepicker.regional['ko']);

    let f = document.getElementById("f");

    $("#btnUserId").on("click", function () {
        userIdExists(f);
    });

    $("#btnLogin").on("click", function () {
        location.href = "/user/login";
    });

    $("#btnEmail").on("click", function () {
        emailExists(f);
    });

    $("#btnAuthCheck").on("click", function () {
        doAuthCheck(f);
    });

    $("#btnAddr").on("click", function () {
        kakaoPost(f);
    });

    $("#btnSend").on("click", function () {
        doSubmit(f);
    });

    $(".birth-input").on("click", function () {
        $("#birth-datepicker").datepicker("show");
    });

    $("#birth-datepicker").datepicker({
        changeYear: true,
        changeMonth: true,
        yearRange: "1900:2025",
        dateFormat: "yy-mm-dd",
        onSelect: function (dateText) {
            let parts = dateText.split("-");
            $('input[name="birthYear"]').val(parts[0]);
            $('input[name="birthMonth"]').val(parts[1]);
            $('input[name="birthDay"]').val(parts[2]);
        },
        beforeShow: function (input, inst) {
            var $row = $("#birth-row");
            var offset = $row.offset();
            setTimeout(function () {
                $(inst.dpDiv).css({
                    top: offset.top + $row.outerHeight(),
                    left: offset.left - 25,
                    position: "absolute",
                    zIndex: 9999
                });
            }, 0);
        }
    });

    // 폼 외 클릭 시 오류 스타일 제거
    $(document).on("click", function (e) {
        const $target = $(e.target);
        if (!$target.closest("form").length) {
            $(".form-row input").removeClass("input-error");
            $("#errorMessage").removeClass("visible");
        }
    });
});

function showError(message, input) {
    $("#errorMessage").text(message).addClass("visible");

    if (input) {
        $(input).addClass("input-error");
        input.focus();
    }

    setTimeout(() => {
        $("#errorMessage").removeClass("visible");
    }, 2000);
}

// 아이디 중복체크
function userIdExists(f) {
    if (f.userId.value === "") {
        showError("아이디를 입력하세요.", f.userId);
        return;
    }

    $.ajax({
        url: "/user/getUserIdExists",
        type: "post",
        dataType: "JSON",
        data: $("#f").serialize(),
        success: function (json) {
            if (json.existsYn === "Y") {
                showError("이미 가입된 아이디가 존재합니다.", f.userId);
            } else {
                showError("가입 가능한 아이디입니다.");
                f.userId.readOnly = true;

                const btnUserId = document.getElementById("btnUserId");

                if (btnUserId) btnUserId.disabled = true;
                userIdCheck = "N";
            }
        }
    });
}

// 이메일 중복 체크 및 인증번호 전송
function emailExists(f) {
    if (f.email.value === "") {
        showError("이메일을 입력하세요.", f.email);
        return;
    }

    $.ajax({
        url: "/user/getEmailExists",
        type: "post",
        dataType: "JSON",
        data: $("#f").serialize(),
        success: function (json) {
            if (json.existsYn === "Y") {
                showError("이미 가입된 이메일 주소가 존재합니다", f.email);
            } else {
                showCustomAlert("이메일로 인증번호가 발송되었습니다");
                emailAuthNumber = json.authNumber;
            }
        }
    });
}

// 인증번호 확인 처리
function doAuthCheck(f) {
    if (f.authNumber.value === "") {
        showError("인증번호를 입력하세요", f.authNumber);
        return;
    }

    if (parseInt(f.authNumber.value) !== emailAuthNumber) {
        showError("잘못된 인증번호 입니다", f.authNumber);
        return;
    } else {
        showError("인증번호 확인");
        f.email.readOnly = true;               // 이메일 input readonly
        f.authNumber.readOnly = true;          // 인증번호 input readonly

        const btnEmail = document.getElementById("btnEmail");
        const btnAuthCheck = document.getElementById("btnAuthCheck");

        if (btnEmail) btnEmail.disabled = true;       // 이메일 요청 버튼 비활성화
        if (btnAuthCheck) btnAuthCheck.disabled = true; // 인증 확인 버튼 비활성화
    }
}

// 카카오 우편번호 API
function kakaoPost(f) {
    new daum.Postcode({
        oncomplete: function (data) {
            let address = data.address;
            let zonecode = data.zonecode;
            f.addr1.value = "(" + zonecode + ")" + address;
        }
    }).open();
}

// 회원가입 유효성 체크 및 전송
function doSubmit(f) {
    $(".form-row input").removeClass("input-error");
    $("#errorMessage").removeClass("visible");

    if (f.userName.value === "") {
        showError("이름을 입력하세요.", f.userName);
        return;
    }

    if (f.userId.value === "") {
        showError("아이디를 입력하세요.", f.userId);
        return;
    }

    if (userIdCheck !== "N") {
        showError("아이디 중복 체크 후 가입하세요.", f.userId);
        return;
    }

    if (f.password.value === "") {
        showError("비밀번호를 입력하세요.", f.password);
        return;
    }

    if (f.password2.value === "") {
        showError("비밀번호 확인을 입력하세요.", f.password2);
        return;
    }

    if (f.password.value !== f.password2.value) {
        showError("비밀번호가 일치하지 않습니다.", f.password);
        return;
    }

    if (f.email.value === "") {
        showError("이메일을 입력하세요.", f.email);
        return;
    }

    if (f.authNumber.value === "") {
        showError("이메일 인증번호를 입력하세요.", f.authNumber);
        return;
    }

    if (f.authNumber.value === "") {
        showError("인증번호를 입력하세요.", f.authNumber);
        return;
    }

    if (parseInt(f.authNumber.value) !== emailAuthNumber) {
        showError("이메일 인증번호가 일치하지 않습니다.", f.authNumber);
        return;
    }

    if (f.addr1.value === "") {
        showError("주소를 입력하세요.", f.addr1);
        return;
    }

    if (f.addr2.value === "") {
        showError("상세주소를 입력하세요.", f.addr2);
        return;
    }

    if (f.birthYear.value === "" || f.birthMonth.value === "" || f.birthDay.value === "") {
        showError("생년월일을 선택해주세요.", f.birthYear);
        return;
    }

    if (!$("input[name='gender']:checked").val()) {
        showError("성별을 선택해주세요.");
        return;
    }

    // 모든 유효성 통과 → 서버로 전송
    $.ajax({
        url: "/user/insertUserInfo",
        type: "post",
        dataType: "JSON",
        data: $("#f").serialize(),
        success: function (json) {
            if (json.result === 1) {
                showCustomAlert(json.msg, function () {
                    location.href = "/user/userTagSelect";
                });
            } else {
                showCustomAlert(json.msg);
            }
        }
    }); // readonly 처리
}
