<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>회원 리스트 - 로그인 유저 확인</title>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
</head>
<body>

<h2>회원 목록</h2>

<%
    String ssUserId = (String) session.getAttribute("SS_USER_ID");
    if (ssUserId == null) {
        ssUserId = "로그인 정보가 없습니다";
    }
%>

<p>로그인한 유저 ID: <strong><%= ssUserId %></strong></p>

<table border="1" id="userTable">
    <thead>
    <tr>
        <th>회원ID</th>
        <th>이름</th>
        <th>채팅하기</th>
    </tr>
    </thead>
    <tbody>
    </tbody>
</table>

<script>
    const loggedInUserId = "<%= ssUserId %>";
    console.log("로그인한 유저 ID (JS):", loggedInUserId);

    function openChat(otherUserId) {
        console.log("openChat 호출됨:", otherUserId);
        fetch("/chat/createOrGetRoom?otherUserId=" + encodeURIComponent(otherUserId))
            .then(res => {
                if (!res.ok) {
                    throw new Error(`HTTP error! status: ${res.status}`);
                }
                return res.json();
            })
            .then(data => {
                console.log("서버에서 받은 데이터:", data);
                if (data.roomId) {
                    const cleanedRoomId = Number(data.roomId);
                    console.log("➡️ 이동할 채팅방 ID:", cleanedRoomId);
                    const targetUrl = "/chat/chatRoom?roomId=" + cleanedRoomId;
                    console.log("이동할 URL:", targetUrl);
                    window.location.href = targetUrl;
                } else {
                    alert("채팅방 생성 실패");
                }
            })
            .catch(err => {
                console.error("채팅방 생성 중 오류:", err);
                alert("오류가 발생했습니다.");
            });
    }

    $(document).ready(function() {
        $.ajax({
            url: "/chat/userList",
            method: "GET",
            dataType: "json",
            success: function(userList) {
                console.log("userList 데이터:", userList);
                const tbody = $("#userTable tbody");
                tbody.empty();

                userList.forEach(function(user) {
                    if (user.userId === loggedInUserId) return; // 본인은 제외

                    const row = $('<tr></tr>');
                    row.append('<td>' + user.userId + '</td>');
                    row.append('<td>' + user.userName + '</td>');

                    const chatBtn = $('<button>채팅하기</button>');
                    chatBtn.on('click', function() {
                        openChat(user.userId);
                    });

                    row.append($('<td></td>').append(chatBtn));
                    tbody.append(row);
                });
            },
            error: function(xhr, status, error) {
                console.error("유저 목록 불러오기 실패:", error);
                alert("회원 목록을 불러오는 중 오류가 발생했습니다.");
            }
        });
    });
</script>

</body>
</html>
