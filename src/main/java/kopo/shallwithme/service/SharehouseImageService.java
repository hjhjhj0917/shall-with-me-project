package kopo.shallwithme.service;

import kopo.shallwithme.dto.SharehouseImageDTO;
import kopo.shallwithme.mapper.ISharehouseImageMapper;
import kopo.shallwithme.service.ISharehouseImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SharehouseImageService implements ISharehouseImageService {

    private final ISharehouseImageMapper imageMapper;

    @Override
    public int insertImage(SharehouseImageDTO pDTO) throws Exception {
        if (pDTO == null) return 0;
        return imageMapper.insertImage(pDTO);
    }

    @Override
    @Transactional
    public int insertImages(List<SharehouseImageDTO> pList) throws Exception {
        if (pList == null || pList.isEmpty()) return 0;
        // 필요 시 검증/보정 로직 추가 (isMain 하나만 1인지 등)
        return imageMapper.insertImages(pList);
    }

    @Override
    public List<SharehouseImageDTO> selectByHouseId(SharehouseImageDTO pDTO) throws Exception {
        if (pDTO == null || pDTO.getHouseId() == null) return Collections.emptyList();
        return imageMapper.selectByHouseId(pDTO);
    }

    @Override
    public SharehouseImageDTO selectMainByHouseId(SharehouseImageDTO pDTO) throws Exception {
        if (pDTO == null || pDTO.getHouseId() == null) return null;
        return imageMapper.selectMainByHouseId(pDTO);
    }

    @Override
    public int deleteById(SharehouseImageDTO pDTO) throws Exception {
        if (pDTO == null || pDTO.getImgId() == null) return 0;
        return imageMapper.deleteById(pDTO);
    }

    @Override
    @Transactional
    public int deleteByHouseId(SharehouseImageDTO pDTO) throws Exception {
        if (pDTO == null || pDTO.getHouseId() == null) return 0;
        return imageMapper.deleteByHouseId(pDTO);
    }
}
