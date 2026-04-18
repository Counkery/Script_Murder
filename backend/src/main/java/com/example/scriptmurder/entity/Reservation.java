package com.example.scriptmurder.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("reservation")
public class Reservation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long sessionId;
    private Long userId;
    private Integer reserveNum;
    private Integer status; // 0-待确认, 1-已确认, 2-已取消
    private Integer paymentStatus; // 0-未支付, 1-已支付, 2-已退款
    private String orderNo;
    private LocalDateTime createTime;
    private Integer hasEvaluated; // 0-未评价 1-已评价

    // 扩展字段
    @TableField(exist = false)
    private Long scriptId;
    @TableField(exist = false)
    private String scriptName;
    @TableField(exist = false)
    private LocalDateTime sessionTime;
    @TableField(exist = false)
    private String userNickname;
    @TableField(exist = false)
    private String userPhone;
}
