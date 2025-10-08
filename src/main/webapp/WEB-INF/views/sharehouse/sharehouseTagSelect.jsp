<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>살며시: 쉐어하우스 태그 선택</title>

  <link rel="stylesheet" href="/css/tag.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>

  <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>

  <style>
    body {
      margin: 0;
      padding: 20px;
      font-family: 'Noto Sans KR', sans-serif;
      background-color: #f8faff;
    }

    .tag-select-header {
      text-align: center;
      margin-bottom: 30px;
    }

    .tag-select-header h1 {
      color: #1c407d;
      font-size: 2rem;
      margin-bottom: 8px;
    }

    .tag-select-header p {
      color: #666;
      font-size: 1rem;
    }

    .floating-save {
      position: fixed;
      right: 40px;
      bottom: 40px;
      z-index: 999;
      display: inline-flex;
      align-items: center;
      gap: 10px;
      background: #3399FF;
      color: #fff;
      border: none;
      border-radius: 999px;
      padding: 14px 22px;
      font-size: 1rem;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(51, 153, 255, 0.4);
      transition: transform 0.2s ease;
    }

    .floating-save:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(51, 153, 255, 0.5);
    }
  </style>
</head>
<body>

<div class="tag-select-header">
  <h1>쉐어하우스 태그 선택</h1>
  <p>쉐어하우스의 특성을 나타내는 태그를 선택해주세요 (최대 3개)</p>
</div>

<div class="tag-content-wrapper">
  <div class="progress-indicator">
    <div class="step-wrapper" onclick="goToSlide(0)">
      <div class="step" data-index="0">
        <i class="fa-solid fa-check"></i>
      </div>
      <div>생활</div>
    </div>
    <div class="line"></div>
    <div class="step-wrapper" onclick="goToSlide(1)">
      <div class="step" data-index="1">
        <i class="fa-solid fa-check"></i>
      </div>
      <div>성격</div>
    </div>
    <div class="line"></div>
    <div class="step-wrapper" onclick="goToSlide(2)">
      <div class="step" data-index="2">
        <i class="fa-solid fa-check"></i>
      </div>
      <div>식습관</div>
    </div>
    <div class="line"></div>
    <div class="step-wrapper" onclick="goToSlide(3)">
      <div class="step" data-index="3">
        <i class="fa-solid fa-check"></i>
      </div>
      <div>청결</div>
    </div>
  </div>

  <div class="slider-container" id="slider">
    <div class="slide">
      <div class="section">
        <fieldset class="box">
          <legend>생활패턴</legend>
          <div class="button-group" data-group="lifestyle">
            <button onclick="selectButton(this)" data-tag="1">아침형</button>
            <button onclick="selectButton(this)" data-tag="2">저녁형</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>활동범위</legend>
          <div class="button-group" data-group="activity">
            <button onclick="selectButton(this)" data-tag="3">집콕</button>
            <button onclick="selectButton(this)" data-tag="4">활동형</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>직업</legend>
          <div class="button-group" data-group="job">
            <button onclick="selectButton(this)" data-tag="5">학생</button>
            <button onclick="selectButton(this)" data-tag="6">직장인</button>
            <button onclick="selectButton(this)" data-tag="7">프리랜서/무직</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>퇴근 시간</legend>
          <div class="button-group" data-group="worktime">
            <button onclick="selectButton(this)" data-tag="8">일정함</button>
            <button onclick="selectButton(this)" data-tag="9">변동적</button>
            <button onclick="selectButton(this)" data-tag="10">야근 잦음</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>손님초대</legend>
          <div class="button-group" data-group="guest">
            <button onclick="selectButton(this)" data-tag="11">자주</button>
            <button onclick="selectButton(this)" data-tag="12">거의 안함</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>물건공유</legend>
          <div class="button-group" data-group="share">
            <button onclick="selectButton(this)" data-tag="13">가능</button>
            <button onclick="selectButton(this)" data-tag="14">불가능</button>
          </div>
        </fieldset>
      </div>
    </div>

    <div class="slide four-boxes">
      <div class="section">
        <fieldset class="box">
          <legend>성격</legend>
          <div class="button-group" data-group="personality">
            <button onclick="selectButton(this)" data-tag="15">내향적</button>
            <button onclick="selectButton(this)" data-tag="16">외향적</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>선호하는 성격</legend>
          <div class="button-group" data-group="preferred-personality">
            <button onclick="selectButton(this)" data-tag="17">조용한 사람</button>
            <button onclick="selectButton(this)" data-tag="18">활발한 사람</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>대화</legend>
          <div class="button-group" data-group="talk">
            <button onclick="selectButton(this)" data-tag="19">자주</button>
            <button onclick="selectButton(this)" data-tag="20">필요할 때</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>갈등</legend>
          <div class="button-group" data-group="conflict">
            <button onclick="selectButton(this)" data-tag="21">회피형</button>
            <button onclick="selectButton(this)" data-tag="22">해결형</button>
          </div>
        </fieldset>
      </div>
    </div>

    <div class="slide four-boxes">
      <div class="section">
        <fieldset class="box">
          <legend>요리</legend>
          <div class="button-group" data-group="cook">
            <button onclick="selectButton(this)" data-tag="23">요리</button>
            <button onclick="selectButton(this)" data-tag="24">배달</button>
            <button onclick="selectButton(this)" data-tag="25">외식</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>주식</legend>
          <div class="button-group" data-group="diet">
            <button onclick="selectButton(this)" data-tag="26">채식</button>
            <button onclick="selectButton(this)" data-tag="27">육식</button>
            <button onclick="selectButton(this)" data-tag="28">둘 다</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>라니</legend>
          <div class="button-group" data-group="meal">
            <button onclick="selectButton(this)" data-tag="29">한 라</button>
            <button onclick="selectButton(this)" data-tag="30">두 라</button>
            <button onclick="selectButton(this)" data-tag="31">세 라</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>음식 냄새</legend>
          <div class="button-group" data-group="cook-smell">
            <button onclick="selectButton(this)" data-tag="32">예민</button>
            <button onclick="selectButton(this)" data-tag="33">상관없음</button>
          </div>
        </fieldset>
      </div>
    </div>

    <div class="slide four-boxes">
      <div class="section">
        <fieldset class="box">
          <legend>청결</legend>
          <div class="button-group" data-group="clean">
            <button onclick="selectButton(this)" data-tag="34">깔끔이</button>
            <button onclick="selectButton(this)" data-tag="35">중간이</button>
            <button onclick="selectButton(this)" data-tag="36">대충이</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>청소 주기</legend>
          <div class="button-group" data-group="clean-circle">
            <button onclick="selectButton(this)" data-tag="37">주 1회</button>
            <button onclick="selectButton(this)" data-tag="38">주 2회</button>
            <button onclick="selectButton(this)" data-tag="39">주 3회 이상</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>쓰레기 배출</legend>
          <div class="button-group" data-group="trash">
            <button onclick="selectButton(this)" data-tag="40">바로바로</button>
            <button onclick="selectButton(this)" data-tag="41">쌓아두기</button>
          </div>
        </fieldset>
        <fieldset class="box">
          <legend>설거지</legend>
          <div class="button-group" data-group="wash-dish">
            <button onclick="selectButton(this)" data-tag="42">바로바로</button>
            <button onclick="selectButton(this)" data-tag="43">쌓아두기</button>
          </div>
        </fieldset>
      </div>
    </div>
  </div>

  <!-- 저장 버튼 -->
  <button type="button" id="saveButton" class="floating-save">
    <i class="fa-solid fa-floppy-disk"></i><span>선택 완료</span>
  </button>

</div>

<script>
  const ctx = '${pageContext.request.contextPath}';
  let currentSlide = 0;
  const selectedTags = new Set(); // 최대 3개만 선택
  const tagNames = {}; // 태그 ID -> 이름 매핑

  // 태그 이름 매핑 초기화
  document.querySelectorAll('button[data-tag]').forEach(btn => {
    const tagId = parseInt(btn.getAttribute('data-tag'));
    tagNames[tagId] = btn.textContent.trim();
  });

  // 슬라이드 이동
  window.moveSlide = function (direction) {
    const slider = document.getElementById('slider');
    const totalSlides = slider.children.length;
    currentSlide = (currentSlide + direction + totalSlides) % totalSlides;
    slider.style.transform = `translateX(-${currentSlide * 100}vw)`;
    updateStepIndicator(currentSlide);
  };

  // 버튼 선택
  window.selectButton = function (button) {
    const tagId = parseInt(button.getAttribute('data-tag'));
    const group = button.parentNode;
    const buttons = group.querySelectorAll('button');

    // 같은 그룹의 다른 버튼 선택 해제
    buttons.forEach(btn => {
      const btnTagId = parseInt(btn.getAttribute('data-tag'));
      if (btn.classList.contains('selected')) {
        selectedTags.delete(btnTagId);
      }
      btn.classList.remove('selected');
    });

    // 현재 버튼 선택
    if (selectedTags.size < 3 || button.classList.contains('selected')) {
      button.classList.add('selected');
      selectedTags.add(tagId);
    } else {
      alert('최대 3개까지만 선택할 수 있습니다.');
      return;
    }

    updateStepIndicator();
  };

  function updateStepIndicator(index) {
    const steps = document.querySelectorAll('.progress-indicator .step');
    steps.forEach((step, i) => {
      if (i === currentSlide) {
        step.classList.add('active');
      } else {
        step.classList.remove('active');
      }

      // 완료된 슬라이드 표시
      if (isSlideComplete(i)) {
        step.classList.add('completed');
      } else {
        step.classList.remove('completed');
      }
    });
  }

  window.goToSlide = function (index) {
    const slider = document.getElementById('slider');
    const totalSlides = slider.children.length;
    if (index >= 0 && index < totalSlides) {
      currentSlide = index;
      slider.style.transform = `translateX(-${currentSlide * 100}vw)`;
      updateStepIndicator();
    }
  };

  function isSlideComplete(slideIndex) {
    const slider = document.getElementById('slider');
    const slide = slider.children[slideIndex];
    const fieldsets = slide.querySelectorAll('fieldset');

    for (let fs of fieldsets) {
      if (!fs.querySelector('button.selected')) {
        return false;
      }
    }
    return true;
  }

  // 저장 버튼 클릭
  document.getElementById('saveButton').addEventListener('click', () => {
    if (selectedTags.size === 0) {
      alert('최소 1개 이상의 태그를 선택해주세요.');
      return;
    }

    if (selectedTags.size > 3) {
      alert('최대 3개까지만 선택할 수 있습니다.');
      return;
    }

    const tagList = Array.from(selectedTags);
    const tagNameList = tagList.map(id => tagNames[id]);

    console.log('선택된 태그:', tagList, tagNameList);

    // 부모 창에 선택된 태그 전달
    if (window.opener && typeof window.opener.receiveSelectedTags === 'function') {
      window.opener.receiveSelectedTags(tagList, tagNameList);
      window.close();
    } else {
      alert('부모 창을 찾을 수 없습니다.');
    }
  });

  // 초기화
  updateStepIndicator();
</script>

</body>
</html>