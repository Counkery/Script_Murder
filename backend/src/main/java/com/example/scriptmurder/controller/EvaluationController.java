package com.example.scriptmurder.controller;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Evaluation;
import com.example.scriptmurder.entity.User;
import com.example.scriptmurder.mapper.EvaluationMapper;
import com.example.scriptmurder.mapper.UserMapper;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/evaluation")
public class EvaluationController {

    @Resource
    private EvaluationMapper evaluationMapper;

    @Resource
    private UserMapper userMapper;

    @Resource
    private com.example.scriptmurder.mapper.ReservationMapper reservationMapper;

    @PostMapping("/add")
    @org.springframework.transaction.annotation.Transactional
    public Result<?> add(@RequestBody Evaluation evaluation) {
        System.out.println("收到评价请求: " + evaluation);
        
        // 1. 检查预约记录是否存在
        com.example.scriptmurder.entity.Reservation reservation = reservationMapper.selectById(evaluation.getBookingId());
        if (reservation == null) {
            return Result.error("预约记录不存在");
        }
        
        // 权限检查：确保只能评价自己的预约
        Long currentUserId = StpUtil.getLoginIdAsLong();
        if (!reservation.getUserId().equals(currentUserId)) {
            return Result.error("无权操作他人的预约");
        }
        
        // 补全 userId (如果前端没传)
        evaluation.setUserId(currentUserId);

        // 2. 双重检查：从评价表直接查询该预约 ID 是否已有评价
        Long count = evaluationMapper.selectCount(new LambdaQueryWrapper<Evaluation>()
                .eq(Evaluation::getBookingId, evaluation.getBookingId()));
        if (count > 0) {
            // 同步更新一下预约表的状态，防止状态不一致
            reservation.setHasEvaluated(1);
            reservationMapper.updateById(reservation);
            return Result.error("该场次已评价过");
        }

        // 3. 检查预约表的状态标志
        if (reservation.getHasEvaluated() != null && reservation.getHasEvaluated() == 1) {
            return Result.error("该场次已评价过");
        }

        // 4. 保存评价
        evaluation.setCreateTime(LocalDateTime.now());
        evaluationMapper.insert(evaluation);

        // 5. 更新预约记录状态
        reservation.setHasEvaluated(1);
        reservationMapper.updateById(reservation);
        
        return Result.success(null);
    }

    @GetMapping("/script/{scriptId}")
    public Result<List<Map<String, Object>>> getByScript(@PathVariable Long scriptId) {
        System.out.println("查询剧本评价, scriptId: " + scriptId);
        List<Evaluation> evaluations = evaluationMapper.selectList(new LambdaQueryWrapper<Evaluation>()
                .eq(Evaluation::getScriptId, scriptId)
                .orderByDesc(Evaluation::getCreateTime));
        
        List<Map<String, Object>> result = evaluations.stream().map(e -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", e.getId());
            map.put("score", e.getScore() != null ? e.getScore() : 5);
            map.put("content", e.getContent() != null ? e.getContent() : "");
            map.put("createTime", e.getCreateTime());
            
            if (e.getUserId() != null) {
                User user = userMapper.selectById(e.getUserId());
                if (user != null) {
                    map.put("nickname", user.getNickname() != null ? user.getNickname() : user.getPhone());
                    map.put("avatar", user.getAvatar());
                } else {
                    map.put("nickname", "未知玩家");
                }
            } else {
                map.put("nickname", "匿名玩家");
            }
            return map;
        }).collect(Collectors.toList());
        
        System.out.println("查询结果数量: " + result.size());
        return Result.success(result);
    }
}
