package com.example.scriptmurder.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String phone;
    private String password;
    private String nickname;
    private String avatar;
    /**
     * 性别：MALE / FEMALE / UNKNOWN
     */
    private String gender;
    /**
     * 年龄
     */
    private Integer age;
    /**
     * 兴趣爱好，使用逗号分隔的简单字符串
     */
    private String hobbies;
    private String role; // PLAYER, SHOP
    private LocalDateTime createTime;
}
