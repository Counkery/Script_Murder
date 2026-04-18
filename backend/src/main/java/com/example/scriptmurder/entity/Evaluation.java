package com.example.scriptmurder.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("evaluation")
public class Evaluation {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @com.baomidou.mybatisplus.annotation.TableField("script_id")
    private Long scriptId;
    
    @com.baomidou.mybatisplus.annotation.TableField("user_id")
    private Long userId;
    
    @com.baomidou.mybatisplus.annotation.TableField("booking_id")
    private Long bookingId;
    
    private Integer score;
    private String content;
    
    @com.baomidou.mybatisplus.annotation.TableField("create_time")
    private LocalDateTime createTime;
}
