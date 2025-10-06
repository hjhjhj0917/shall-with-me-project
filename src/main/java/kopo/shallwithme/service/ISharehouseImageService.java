package kopo.shallwithme.service;

import kopo.shallwithme.dto.SharehouseImageDTO;

import java.util.List;

public interface ISharehouseImageService {

    /** 이미지 1장 저장 */
    int insertImage(SharehouseImageDTO pDTO) throws Exception;

    /** 이미지 여러 장 저장 (배치) */
    int insertImages(List<SharehouseImageDTO> pList) throws Exception;

    /** 특정 하우스의 모든 이미지 조회 (대표/정렬순 반영은 Mapper 정렬 기준에 따름) */
    List<SharehouseImageDTO> selectByHouseId(SharehouseImageDTO pDTO) throws Exception;

    /** 특정 하우스의 대표 이미지 1장 조회 */
    SharehouseImageDTO selectMainByHouseId(SharehouseImageDTO pDTO) throws Exception;

    /** 이미지 1장 삭제 (imgId 기준) */
    int deleteById(SharehouseImageDTO pDTO) throws Exception;

    /** 특정 하우스의 모든 이미지 삭제 (houseId 기준) */
    int deleteByHouseId(SharehouseImageDTO pDTO) throws Exception;
}
