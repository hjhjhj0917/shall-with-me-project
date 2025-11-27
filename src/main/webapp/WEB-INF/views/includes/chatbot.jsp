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
        display: none;
        flex-direction: column;
        overflow: hidden;
        transform: scale(0.5);
        opacity: 0;
        pointer-events: none;
        transition: all 0.3s ease;
        z-index: 998;
    }

    .chatbot-container.active {
        display: flex;
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

        display: flex;
        flex-direction: column;
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
        user-select: text;
        font-size: 15px;
    }

    .chatbot-message a {
        color: #3399ff;
        text-decoration: underline;
        cursor: pointer;
    }
    .chatbot-message a:hover {
        color: #0056b3;
    }

    .user-message {
        background: #E1EBFB;
        align-self: flex-end;
        margin-left: auto;
        display: inline-block;
        max-width: 80%;
        word-wrap: break-word;
        text-align: left;
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

<button class="chatbot-toggler">
    <img src="../images/chatbot.png">
</button>

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

        // 텍스트 내 URL을 클릭 가능한 a 태그로 변환하는 함수
        function linkify(text) {
            const urlRegex = /https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)/g;
            return text.replace(urlRegex, function (rawUrl) {
                let url = rawUrl;
                let trailingChar = '';
                const lastChar = url.charAt(url.length - 1);
                if (/[)\],.!?]/.test(lastChar)) {
                    trailingChar = lastChar;
                    url = url.slice(0, -1);
                }
                // target="_blank"를 추가하여 새 탭에서 열리도록 설정
                return '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + url + '</a>' + trailingChar;
            });
        }

        // --- 🎨 수정된 typeWriter 함수: HTML 태그(특히 링크)를 깨뜨리지 않고 출력 ---
        function typeWriter(element, text) {
            // 1. URL을 링크 태그로 변환하고 줄바꿈 처리
            const processedHtml = linkify(text).replace(/\n/g, '<br>');

            let i = 0;
            $(element).html(''); // '입력 중...' 메시지 초기화

            function typing() {
                if (i < processedHtml.length) {
                    const char = processedHtml[i];

                    // 2. 태그 시작 감지 ('<')
                    if (char === '<') {
                        // 3. 링크 태그인지 확인 ('<a')
                        if (processedHtml.substring(i, i + 2).toLowerCase() === '<a') {
                            // 링크의 닫는 태그(</a>) 위치를 찾음
                            const closingTag = '</a>';
                            const closingIndex = processedHtml.indexOf(closingTag, i);

                            if (closingIndex !== -1) {
                                // <a>부터 </a>까지 전체를 잘라서 한 번에 추가 (링크 깨짐 방지)
                                const fullLinkTag = processedHtml.substring(i, closingIndex + closingTag.length);
                                $(element).append(fullLinkTag);
                                i = closingIndex + closingTag.length; // 인덱스를 </a> 뒤로 이동
                            } else {
                                // 닫는 태그 못 찾으면 일반 태그처럼 처리
                                const closingTagIndex = processedHtml.indexOf('>', i);
                                const tag = processedHtml.substring(i, closingTagIndex + 1);
                                $(element).append(tag);
                                i = closingTagIndex + 1;
                            }
                        } else {
                            // 4. 링크가 아닌 다른 태그 (<br>, <strong> 등) 처리
                            const closingTagIndex = processedHtml.indexOf('>', i);
                            if (closingTagIndex !== -1) {
                                const tag = processedHtml.substring(i, closingTagIndex + 1);
                                $(element).append(tag);
                                i = closingTagIndex + 1;
                            } else {
                                $(element).append(char);
                                i++;
                            }
                        }
                    } else {
                        // 5. 일반 텍스트는 한 글자씩 타이핑
                        $(element).append(char);
                        i++;
                    }

                    scrollToBottom();
                    setTimeout(typing, 30); // 타이핑 속도 (ms)
                }
            }
            typing();
        }

        function sendMessage() {
            const question = inputEl.val().trim();
            if (!question) return;

            appendMessage(question, 'user-message', false);
            inputEl.val('');

            const typingIndicator = appendMessage('...', 'bot-message', false);

            $.ajax({
                url: "/api/chatbot/ask",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({question: question}),
                success: function (response) {
                    // 응답이 오면 타이핑 효과 시작
                    typeWriter(typingIndicator, response.answer);
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
            return msgDiv[0];
        }

        // 항상 맨 아래로 스크롤
        function scrollToBottom() {
            messagesEl.scrollTop(messagesEl[0].scrollHeight);
        }
    });
</script>