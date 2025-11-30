<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    footer {
        background-color: #f8f9fa;
        color: #6c757d;
        padding: 50px 0;
        font-size: 14px;
        border-top: 1px solid #e9ecef;
        margin-top: 100px;
    }

    .footer-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
    }

    .footer-content {
        flex-grow: 1;
    }

    .footer-logo {
        font-size: 22px;
        font-weight: 700;
        color: #495057;
        margin-bottom: 20px;
    }

    .footer-links {
        margin-bottom: 15px;
    }

    .footer-links a {
        color: #495057;
        text-decoration: none;
        margin-right: 20px;
        transition: color 0.2s;
    }

    .footer-links a:hover {
        color: #3399ff;
    }

    .footer-links a.privacy {
        font-weight: 600;
    }

    .footer-info {
        margin-bottom: 15px;
        line-height: 1.8;
    }

    .footer-info span {
        margin-right: 15px;
        display: inline-block;
    }

    .footer-copyright {
        font-size: 13px;
        color: #adb5bd;
    }

    .footer-social {
        flex-shrink: 0;
        padding-top: 10px;
    }

    .footer-social a {
        color: #adb5bd;
        font-size: 22px;
        text-decoration: none;
        margin-left: 20px;
        transition: color 0.2s;
    }

    .footer-social a:hover {
        color: #3399ff;
    }
</style>
<footer>
    <div class="footer-container">
        <div class="footer-content">
            <div class="footer-logo">살며시</div>
            <div class="footer-links">
                <a href="https://kopo.ac.kr/kangseo/index.do" target="_blank" rel="noopener noreferrer">학교홈페이지</a>
                <a href="/notice/noticeList" class="privacy">청년정책</a>
                <a href="/mypage/withdraw">회원탈퇴</a>
            </div>
            <div class="footer-info">
                <span>(주)살며시</span>
                <span>팀장: 양준모</span>
                <span>메일: yjmo0309@gmail.com</span>
                <br>
                <span>주소: 서울 강서구 우장산로10길 112 한국폴리텍대학서울강서캠퍼스</span>
                <span>학과: 빅데이터학과</span>
            </div>
            <div class="footer-copyright">
                &copy; 2025 SahllWithMe. All Rights Reserved.
            </div>
        </div>
        <div class="footer-social">
            <a href="https://github.com/hjhjhj0917/shall-with-me-project" target="_blank" rel="noopener noreferrer" aria-label="깃허브">
                <i class="fa-brands fa-github"></i>
            </a>
            <a href="https://www.instagram.com/poly_kangseo/" target="_blank" rel="noopener noreferrer" aria-label="인스타그램">
                <i class="fa-brands fa-instagram"></i>
            </a>
            <a href="https://www.youtube.com/channel/UCmzyR9BA0gHRM58o8SjdYjw" target="_blank" rel="noopener noreferrer" aria-label="유튜브">
                <i class="fa-brands fa-youtube"></i>
            </a>
        </div>
    </div>
</footer>