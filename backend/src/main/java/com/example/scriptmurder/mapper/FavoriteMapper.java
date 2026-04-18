package com.example.scriptmurder.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.scriptmurder.entity.Favorite;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface FavoriteMapper extends BaseMapper<Favorite> {
}
