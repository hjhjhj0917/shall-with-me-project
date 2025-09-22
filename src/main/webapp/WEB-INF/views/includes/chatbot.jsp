<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<style>
    /* 챗봇 플로팅 버튼 */
    .chatbot-toggler {
        position: fixed;
        right: 50px;
        bottom: 40px;
        width: 60px;
        height: 60px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.8rem;
        cursor: pointer;
        z-index: 999;
        background-color: white;
        border: 2px solid #E5F2FF;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
    }

    /* 챗봇 창 */
    .chatbot-container {
        position: fixed;
        right: 80px;
        bottom: 130px;
        width: 460px;
        height: 600px;
        background: #fff;
        border-radius: 35px;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        transform: scale(0.5);
        opacity: 0;
        pointer-events: none;
        transition: all 0.3s ease;
        z-index: 998;
    }

    .chatbot-container.active {
        transform: scale(1);
        opacity: 1;
        pointer-events: auto;
    }

    .chatbot-header {
        background: #3399ff;
        color: white;
        padding: 15px;
        text-align: center;
        font-weight: 500;
    }

    .chatbot-messages {
        flex-grow: 1;
        padding: 15px;
        overflow-y: auto;

        /* 스크롤바 숨기기 */
        scrollbar-width: none; /* Firefox */
        -ms-overflow-style: none; /* IE 10+ */

        display: flex; /* 추가: flex 컨테이너 */
        flex-direction: column; /* 추가: 세로 정렬 */
    }


    .chatbot-messages::-webkit-scrollbar {
        display: none; /* Chrome, Safari, Opera */
    }

    .chatbot-message {
        margin-bottom: 16px;
        padding: 8px 12px;
        border-radius: 18px;
        max-width: 80%;
        word-wrap: break-word;
        user-select: text; /* 복사 가능하게 명시 */
        font-size: 15px; /* ✅ 원하는 사이즈로 설정 */
    }

    .user-message {
        background: #E1EBFB;
        align-self: flex-end; /* 오른쪽 정렬 유지 */
        margin-left: auto;
        display: inline-block; /* 텍스트 길이만큼 줄이기 */
        max-width: 80%;
        word-wrap: break-word;
        text-align: left; /* 텍스트는 왼쪽 정렬 유지 */
        margin-bottom: 16px;
    }

    .bot-message {
        background: #F3F3F3;
        align-self: flex-start;
    }

    .chatbot-input-area {
        display: flex;
        padding: 10px;
        margin-bottom: 10px;
    }

    .chatbot-input-area input {
        flex-grow: 1;
        border: 1px solid #ddd;
        border-radius: 20px;
        padding: 13px 15px;
        outline: none;
    }

    .chatbot-input-area button {
        border: none;
        background: none;
        font-size: 1.2rem;
        color: #3399ff;
        cursor: pointer;
        padding: 0 10px;
    }

    .chatbot-toggler img {
        width: 35px;
        height: 35px;
        border-radius: 50%;
        object-fit: cover;
    }

</style>

<!-- 챗봇 플로팅 버튼 -->
<button class="chatbot-toggler">
    <img src="../images/chatbot.png">
</button>

<!-- 챗봇 창 -->
<div class="chatbot-container">
    <div class="chatbot-header">청년 정책 챗봇 '살며시'</div>
    <div class="chatbot-messages" id="chatbotMessages">
        <div class="chatbot-message bot-message">
            안녕하세요!
            <br>
            <br>
            저는 청년 정책을 안내해드리는 챗봇 ‘살며시’예요.
            궁금한 정책이 있다면 편하게 질문해 주세요.
            <br>
            <br>
            예 : "자립하는 청년을 위한 정책은 뭐가 있어?”
        </div>
    </div>
    <div class="chatbot-input-area">
        <input type="text" id="chatbotInput" placeholder="메시지를 입력하세요...">
        <button id="chatbotSendBtn"><i class="fa-solid fa-paper-plane" style="color: #3399ff"></i></button>
    </div>
</div>

<script>
    $(document).ready(function () {
        const toggler = $(".chatbot-toggler");
        const container = $(".chatbot-container");
        const messagesEl = $("#chatbotMessages");
        const inputEl = $("#chatbotInput");
        const sendBtn = $("#chatbotSendBtn");

        // 챗봇 창 열고 닫기
        toggler.on("click", () => container.toggleClass("active"));

        function linkify(text) {
            const urlRegex = /https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)/g;
            return text.replace(urlRegex, function (rawUrl) {
                // URL 끝에 붙은 문장부호 체크
                let url = rawUrl;
                let trailingChar = '';

                // URL 끝에 ) , . ! ? 등이 붙어있으면 떼어내기
                const lastChar = url.charAt(url.length - 1);
                if (/[)\],.!?]/.test(lastChar)) {
                    trailingChar = lastChar;
                    url = url.slice(0, -1);
                }

                return '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + url + '</a>' + trailingChar;
            });
        }

        // \n 줄바꿈을 <br>로 바꾸는 함수
        function formatNewlines(text) {
            return text.replace(/\n/g, "<br>");
        }

        // 메시지 전송
        function sendMessage() {
            const question = inputEl.val().trim();
            if (!question) return;

            // 사용자 메시지는 그냥 텍스트
            appendMessage(question, 'user-message', false);

            // 입력창 비우기
            inputEl.val('');

            // '입력 중...' 메시지 추가 (초기값은 텍스트)
            const typingIndicator = appendMessage('...', 'bot-message', false);

            // 서버에 질문 전송 (AJAX)
            $.ajax({
                url: "/api/chatbot/ask",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({question: question}),
                success: function (response) {
                    // ✅ 줄바꿈 처리 추가!
                    const formatted = formatNewlines(linkify(response.answer));
                    $(typingIndicator).html(formatted);
                    scrollToBottom();
                },
                error: function () {
                    $(typingIndicator).text('죄송합니다. 오류가 발생했어요.');
                }
            });
        }

        sendBtn.on("click", sendMessage);
        inputEl.on("keypress", (e) => {
            if (e.key === 'Enter') sendMessage();
        });

        // 메시지를 채팅창에 추가하는 함수
        function appendMessage(content, className, isHtml = false) {
            const msgDiv = $('<div></div>').addClass('chatbot-message').addClass(className);
            if (isHtml) {
                msgDiv.html(content);
            } else {
                msgDiv.text(content);
            }
            messagesEl.append(msgDiv);
            scrollToBottom();
            return msgDiv[0]; // '입력 중...' 메시지를 수정하기 위해 요소 반환
        }

        // 항상 맨 아래로 스크롤
        function scrollToBottom() {
            messagesEl.scrollTop(messagesEl[0].scrollHeight);
        }
    });
</script>
