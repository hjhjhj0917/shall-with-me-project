package kopo.shallwithme.mapper;


import kopo.shallwithme.dto.UserInfoDTO;
import kopo.shallwithme.dto.UserProfileDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface IUserInfoMapper {

    int updatePassword(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserId(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getLogin(UserInfoDTO pDTO) throws Exception;

    int insertUserInfo(UserInfoDTO pDTO) throws Exception;



    UserInfoDTO getUserIdExists(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getEmailExists(UserInfoDTO pDTO) throws Exception;

    // 아이디 찾기 메일 전송
    UserInfoDTO emailAuthNumber(UserInfoDTO pDTO) throws Exception;

    // 비밀번호 찾기 메일 전송
    UserInfoDTO emailAuthNumberPw(UserInfoDTO pDTO) throws Exception;

    UserInfoDTO getUserForPassword(UserInfoDTO pDTO) throws Exception;

    // 태그 삽입
    int insertUserTags(UserTagDTO dto);

    // DB에 저장된 태그 개수 확인
    int countUserTags(UserTagDTO dto);

    // userId가 담긴 UserInfoDTO를 파라미터로 받음
    List<UserTagDTO> findByUserId(UserInfoDTO pDTO);

    //룸메이트 프로필 저장
    int upsertUserProfile(UserProfileDTO pDTO);

    UserProfileDTO getUserProfile(String userId);

    String selectProfileImageUrlByUserId(String userId);

    List<Map<String, Object>> getRoommateList(@Param("offset") int offset,
                                              @Param("limit") int limit);

    List<UserInfoDTO> getAllUsersWithProfile();

    // userId로 태그 이름 목록 조회
    List<String> getUserTags(String userId);

    // userId로 회원 성별 가져오기
    UserInfoDTO getUserById(String userId);

    // userId로 태그 목록 조회
    List<UserTagDTO> selectUserTags(String userId);


    // ✅ 프로필 조회: DTO로 받고 DTO로 반환 (void 금지, @Param 금지)
    UserProfileDTO findUserProfileByUserId(UserProfileDTO pDTO);


}
