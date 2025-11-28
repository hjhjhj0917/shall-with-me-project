package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseCardDTO;
import kopo.shallwithme.dto.TagDTO;
import kopo.shallwithme.dto.UserTagDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ISharehouseMapper {

    List<SharehouseCardDTO> listCards(Map<String, Object> params);

    SharehouseCardDTO getCardById(Long houseId);

    Map<String, Object> getDetail(Long houseId);

    int insertSharehouse(SharehouseCardDTO dto);

    List<Map<String, Object>> selectSharehouseImages(Long houseId);

    List<UserTagDTO> selectSharehouseTags(Long houseId);

    List<TagDTO> getAllTags();

    int insertSharehouseTags(Map<String, Object> params);

    int deleteSharehouseTags(Long houseId);

    List<SharehouseCardDTO> getSharehouseByUserId(String userId);

    int deleteSharehouse(Long houseId);

    int deleteSharehouseImages(Long houseId);
}