package kopo.shallwithme.mapper;

import kopo.shallwithme.dto.SharehouseImageDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ISharehouseImageMapper {

    // 단건 저장
    int insertImage(SharehouseImageDTO pDTO);

    // 여러 장 저장 (리스트 반복 insert)
    int insertImages(List<SharehouseImageDTO> pList);

    // 하우스의 모든 이미지 조회 (대표/정렬순으로 보기 좋게)
    List<SharehouseImageDTO> selectByHouseId(SharehouseImageDTO pDTO);

    // 대표 이미지 1장 조회
    SharehouseImageDTO selectMainByHouseId(SharehouseImageDTO pDTO);

    // 단건 삭제
    int deleteById(SharehouseImageDTO pDTO);

    // 하우스의 이미지 전체 삭제 (하우스 삭제 시 등)
    int deleteByHouseId(SharehouseImageDTO pDTO);
}
