package kopo.shallwithme.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserInfoMapper {

    Integer findTagIdByName(@Param("tagName") String tagName);

    void insertUserTag(@Param("userId") String userId,
                       @Param("tagId") int tagId,
                       @Param("tagType") String tagType);
}
