package com.example.scriptmurder.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("script")
public class Script {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long shopId;
    private String name;
    private String type;
    private Integer peopleNum; // 默认展示人数
    @TableField("min_people")
    private Integer minPeople; // 最低开局人数
    @TableField("max_people")
    private Integer maxPeople; // 最多开局人数
    private Integer duration;
    private BigDecimal price;
    private String cover;
    private String intro;
    private String tags; // 标签
    private LocalDateTime createTime;
}
