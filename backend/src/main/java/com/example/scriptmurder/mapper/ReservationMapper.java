package com.example.scriptmurder.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.scriptmurder.entity.Reservation;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ReservationMapper extends BaseMapper<Reservation> {
}
