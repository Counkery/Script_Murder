package com.example.scriptmurder.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.scriptmurder.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
