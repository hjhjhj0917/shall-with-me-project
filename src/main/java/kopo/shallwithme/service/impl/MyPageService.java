package kopo.shallwithme.service.impl;

import kopo.shallwithme.dto.*;
import kopo.shallwithme.mapper.IMyPageMapper;
import kopo.shallwithme.service.IMailService;
import kopo.shallwithme.service.IMyPageService;
import kopo.shallwithme.util.CmmUtil;
import kopo.shallwithme.util.EncryptUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserTagDTO;
import kopo.shallwithme.dto.UserInfoDTO;


@Slf4j
@RequiredArgsConstructor
@Service
public class MyPageService implements IMyPageService {

    private final IMyPageMapper myPageMapper;
    private final IMailService mailService;

    @Override
    public int deactivateProfile(UserProfileDTO pDTO) throws Exception {
        log.info("{}.deactivateProfile Start!", this.getClass().getName());

        int res = myPageMapper.deactivateProfile(pDTO);

        log.info("{}.deactivateProfile End!", this.getClass().getName());

        return res;
    }

    @Override
    public UserInfoDTO pwCheck(UserInfoDTO pDTO) throws Exception {

        log.info("{}.pwCheck Start", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(myPageMapper.pwCheck(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("{}.pwCheck End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    public UserInfoDTO emailCheck(UserInfoDTO pDTO) throws Exception {

        log.info("{}.emailCheck Start!", this.getClass().getName());

        UserInfoDTO rDTO = Optional.ofNullable(myPageMapper.emailCheck(pDTO)).orElseGet(UserInfoDTO::new);

        log.info("rDTO : {}", rDTO);
        log.info("rDTO.getExistsYn() : {}", rDTO.getExistsYn());

        log.info("{}.emailCheck End!", this.getClass().getName());

        return rDTO;
    }

    @Override
    @Transactional
    public int deactivateUser(UserInfoDTO pDTO) throws Exception{
        log.info("{}.deactivateUser Start!", this.getClass().getName());

        int res = myPageMapper.softDeleteUser(pDTO);

        if (res > 0) {
            log.info("{} 회원 탈퇴 메일 전송 시작!", this.getClass().getName());

            MailDTO dto = new MailDTO();

            dto.setTitle("[살며시] " + pDTO.getUserName() + "님, 회원 탈퇴 신청이 정상적으로 처리되었습니다.");
            dto.setContents(pDTO.getUserName() + "님, '살며시'와의 동행을 마무리하시는군요.\n" +
                    "\n" +
                    "회원님의 탈퇴 신청이 정상적으로 처리되었습니다.\n" +
                    "지금부터 회원님의 계정은 비활성화 상태로 전환되며, 더 이상 로그인하실 수 없습니다.\n" +
                    "\n" +
                    "그동안 '살며시(shall with me)'와 함께 새로운 인연과 공간을 찾아주셔서 진심으로 감사했습니다.\n" +
                    "회원님께서 남겨주신 소중한 흔적들이 저희 서비스를 더욱 따뜻한 공간으로 만들어 주었습니다.");
            dto.setToMail(EncryptUtil.decAES128BCBC(pDTO.getEmail()));

            mailService.doSendMail(dto);

            dto = null;

            log.info("{} 회원 탈퇴 메일 전송 종료!", this.getClass().getName());
        }

        log.info("{}.deactivateUser End!", this.getClass().getName());

        return res;
    }

    @Override
    @Transactional
    public int hardDeleteDeactivatedUsers() {
        log.info("{}.hardDeleteDeactivatedUsers Start!", this.getClass().getName());

        int res = myPageMapper.deleteOldDeactivatedUsers();

        log.info("{}.hardDeleteDeactivatedUsers End!", this.getClass().getName());

        return res;
    }



    @Override
    public UserInfoDTO myPageUserInfo(UserInfoDTO pDTO) throws Exception {
        log.info("{}.myPageUserInfo Start!", this.getClass().getName());
        UserInfoDTO rDTO = myPageMapper.myPageUserInfo(pDTO);
        log.info("{}.myPageUserInfo End!", this.getClass().getName());
        return rDTO;
    }

    @Override
    public List<UserTagDTO> myPageUserTag(UserInfoDTO pDTO) throws Exception {
        log.info("{}.myPageUserTag Start!", this.getClass().getName());
        List<UserTagDTO> rList = myPageMapper.myPageUserTag(pDTO);
        log.info("{}.myPageUserTag End!", this.getClass().getName());
        return rList;
    }

    @Override
    public int updateIntroduction(UserProfileDTO pDTO) throws Exception {
        log.info("{}.updateIntroduction Start!", this.getClass().getName());

        if (pDTO == null || CmmUtil.nvl(pDTO.getUserId()).isEmpty()) {
            log.warn("updateIntroduction: userId가 비어있음");
            return 0;
        }

        int res = myPageMapper.updateIntroduction(pDTO);

        log.info("{}.updateIntroduction End! res={}", this.getClass().getName(), res);
        return res;
    }

    @Override
    public int updateProfileImage(UserProfileDTO pDTO) {
        log.info("{}.updateProfileImage Start!", this.getClass().getName());

        if (pDTO == null) {
            log.warn("updateProfileImage: pDTO is null");
            log.info("{}.updateProfileImage End! res=0 (pDTO null)", this.getClass().getName());
            return 0;
        }
        if (pDTO.getUserId() == null || pDTO.getUserId().isBlank()) {
            log.warn("updateProfileImage: userId is blank");
            log.info("{}.updateProfileImage End! res=0 (userId blank)", this.getClass().getName());
            return 0;
        }
        // URL은 로그에 직접 노출해도 되는 퍼블릭 경로지만, 길면 줄여 찍자
        String shortUrl = Optional.ofNullable(pDTO.getProfileImageUrl())
                .map(u -> u.length() > 120 ? u.substring(0,120) + "..." : u)
                .orElse(null);

        log.info("updateProfileImage param => userId={}, url={}", pDTO.getUserId(), shortUrl);

        int res = myPageMapper.updateProfileImage(pDTO);

        log.info("updateProfileImage DB result => res={}", res);
        log.info("{}.updateProfileImage End!", this.getClass().getName());
        return res;
    }

    @Override
    public List<UserTagDTO> getAllTagsWithType() {
        log.info("{}.getAllTagsWithType Start!", this.getClass().getName());
        List<UserTagDTO> list = myPageMapper.selectAllTagsWithType();
        log.info("{}.getAllTagsWithType End! size={}", this.getClass().getName(), list.size());
        return list;
    }

    @Override
    public List<UserTagDTO> getMyTagSelections(UserInfoDTO p) {
        log.info("{}.getMyTagSelections Start! userId={}", this.getClass().getName(), p.getUserId());
        List<UserTagDTO> list = myPageMapper.selectMyTagSelectionsByUser(p);
        log.info("{}.getMyTagSelections End! size={}", this.getClass().getName(), list.size());
        return list;
    }

    @Override
    public int updateMyTagsByGroup(UserTagDTO p) {
        log.info("{}.updateMyTagsByGroup Start! userId={}, tagList={}", this.getClass().getName(), p.getUserId(), p.getTagList());
        if (p == null || p.getUserId() == null || p.getTagList() == null || p.getTagList().isEmpty()) {
            log.warn("updateMyTagsByGroup invalid param");
            return 0;
        }
        // 1) 전달된 tag_id들의 소속 tag_type만 추출해 해당 그룹만 삭제
        myPageMapper.deleteUserTagsByTagTypesOfTagIds(p); // DTO만 사용

        // 2) INSERT ... SELECT 로 태그타입까지 조인해 일괄 삽입
        int inserted = myPageMapper.insertUserTagsFromIds(p); // DTO만 사용
        log.info("{}.updateMyTagsByGroup End! inserted={}", this.getClass().getName(), inserted);
        return inserted;
    }

    @Override
    public List<TagDTO> getMyTagChips(UserInfoDTO p) {
        log.info("{}.getMyTagChips Start! userId={}", this.getClass().getName(), p.getUserId());
        List<TagDTO> list = myPageMapper.selectMyTagNames(p);
        log.info("{}.getMyTagChips End! size={}", this.getClass().getName(), list.size());
        return list;
    }

    @Override
    public boolean verifyPassword(UserInfoDTO pDTO) throws Exception {
        // DB의 해시값을 가져와 비교
        UserInfoDTO rDTO = myPageMapper.getPasswordHashByUserId(pDTO); // PASSWORD 컬럼만 세팅해서 리턴
        if (rDTO == null || rDTO.getPassword() == null) {
            return false;
        }
        // pDTO.password 는 이미 EncryptUtil로 해시된 값
        return rDTO.getPassword().equals(pDTO.getPassword());
    }


    @Override
    @Transactional
    public int updateAddress(UserProfileDTO pDTO) {
        return myPageMapper.updateAddress(pDTO);
    }




}
