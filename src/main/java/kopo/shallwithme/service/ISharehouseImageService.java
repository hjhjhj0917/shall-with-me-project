package kopo.shallwithme.service;

import kopo.shallwithme.dto.SharehouseImageDTO;

import java.util.List;

public interface ISharehouseImageService {

    int insertImage(SharehouseImageDTO pDTO) throws Exception;

    int insertImages(List<SharehouseImageDTO> pList) throws Exception;

    List<SharehouseImageDTO> selectByHouseId(SharehouseImageDTO pDTO) throws Exception;

    SharehouseImageDTO selectMainByHouseId(SharehouseImageDTO pDTO) throws Exception;

    int deleteById(SharehouseImageDTO pDTO) throws Exception;

    int deleteByHouseId(SharehouseImageDTO pDTO) throws Exception;
}
