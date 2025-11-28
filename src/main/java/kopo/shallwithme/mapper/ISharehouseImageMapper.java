package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseImageDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ISharehouseImageMapper {

    int insertImage(SharehouseImageDTO pDTO);

    int insertImages(List<SharehouseImageDTO> pList);

    List<SharehouseImageDTO> selectByHouseId(SharehouseImageDTO pDTO);

    SharehouseImageDTO selectMainByHouseId(SharehouseImageDTO pDTO);

    int deleteById(SharehouseImageDTO pDTO);

    int deleteByHouseId(SharehouseImageDTO pDTO);
}
