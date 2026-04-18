package com.example.scriptmurder.controller;

import cn.dev33.satoken.secure.SaSecureUtil;
import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.User;
import com.example.scriptmurder.mapper.UserMapper;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Resource
    private UserMapper userMapper;

    @PostMapping("/login")
    public Result<?> login(@RequestBody User user) {
        System.out.println("收到登录请求: phone=" + user.getPhone() + ", password=" + user.getPassword());
        
        // 1. 先只查手机号，确认用户是否存在
        User dbUser = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getPhone, user.getPhone()));
                
        if (dbUser == null) {
            System.out.println("手机号不存在: " + user.getPhone());
            return Result.error("手机号或密码错误");
        }
        
        System.out.println("数据库中密码: " + dbUser.getPassword());
        
        // 2. 比对密码 (使用 Sa-Token 的 MD5 加密工具)
        String inputMd5 = SaSecureUtil.md5(user.getPassword());
        if (!dbUser.getPassword().equals(inputMd5)) {
            // 兼容旧的明文密码（过渡期逻辑）
            if (!dbUser.getPassword().equals(user.getPassword())) {
                System.out.println("密码不匹配");
                return Result.error("手机号或密码错误");
            } else {
                // 如果是旧明文密码登录成功，自动升级为 MD5
                dbUser.setPassword(inputMd5);
                userMapper.updateById(dbUser);
            }
        }

        // Sa-Token 登录
        StpUtil.login(dbUser.getId());
        
        // 获取 Token 信息
        String token = StpUtil.getTokenValue();
        
        Map<String, Object> map = new HashMap<>();
        map.put("token", token);
        map.put("user", dbUser);
        return Result.success(map);
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody User user) {
        User dbUser = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getPhone, user.getPhone()));
        if (dbUser != null) {
            return Result.error("该手机号已注册");
        }
        // 所有通过前台注册的账号强制为玩家角色
        user.setRole("PLAYER");
        user.setCreateTime(LocalDateTime.now());
        if (user.getNickname() == null || user.getNickname().isEmpty()) {
            String phone = user.getPhone();
            String suffix;
            if (phone == null || phone.isEmpty()) {
                suffix = "用户";
            } else if (phone.length() > 4) {
                suffix = phone.substring(phone.length() - 4);
            } else {
                suffix = phone;
            }
            user.setNickname("玩家_" + suffix);
        }
        // 密码加密存储
        user.setPassword(SaSecureUtil.md5(user.getPassword()));
        userMapper.insert(user);
        return Result.success(null);
    }

    @GetMapping("/info/{id}")
    public Result<User> getInfo(@PathVariable Long id) {
        return Result.success(userMapper.selectById(id));
    }

    @PutMapping("/update")
    public Result<?> update(@RequestBody User user) {
        userMapper.updateById(user);
        return Result.success(null);
    }
}
