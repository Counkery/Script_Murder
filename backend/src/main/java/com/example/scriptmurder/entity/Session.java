package com.example.scriptmurder.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("session")
public class Session {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long scriptId;
    private Long shopId;
    private LocalDateTime sessionTime;
    private Integer totalNum;
    private Integer remainNum;
    private BigDecimal price;
}
