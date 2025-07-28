package kopo.shallwithme.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserInfoMapper {
    void insertUserTag(@Param("userId") String userId,
                       @Param("tagiD") String tagType,
                       @Param("tagType") String tagValue);
}
