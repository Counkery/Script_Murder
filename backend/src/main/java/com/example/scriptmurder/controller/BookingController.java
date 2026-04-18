package com.example.scriptmurder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Reservation;
import com.example.scriptmurder.entity.Script;
import com.example.scriptmurder.entity.Session;
import com.example.scriptmurder.entity.User;
import com.example.scriptmurder.mapper.ReservationMapper;
import com.example.scriptmurder.mapper.ScriptMapper;
import com.example.scriptmurder.mapper.SessionMapper;
import com.example.scriptmurder.mapper.UserMapper;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/booking")
public class BookingController {

    @Resource
    private SessionMapper sessionMapper;

    @Resource
    private ReservationMapper reservationMapper;

    @Resource
    private ScriptMapper scriptMapper;

    @Resource
    private UserMapper userMapper;

    // --- 场次接口 ---

    @GetMapping("/session/list")
    public Result<List<Session>> sessionList(@RequestParam(required = false) Long scriptId,
                                             @RequestParam(required = false) Long shopId) {
        LambdaQueryWrapper<Session> query = new LambdaQueryWrapper<>();
        if (scriptId != null) query.eq(Session::getScriptId, scriptId);
        if (shopId != null) query.eq(Session::getShopId, shopId);
        
        // 过滤掉已过期的场次（sessionTime < now）
        query.gt(Session::getSessionTime, LocalDateTime.now());
        
        query.orderByAsc(Session::getSessionTime);
        return Result.success(sessionMapper.selectList(query));
    }

    @PostMapping("/session/save")
    public Result<?> sessionSave(@RequestBody Session session) {
        if (session.getId() == null) {
            session.setRemainNum(session.getTotalNum());
            sessionMapper.insert(session);
        } else {
            sessionMapper.updateById(session);
        }
        return Result.success(null);
    }

    @DeleteMapping("/session/delete/{id}")
    @Transactional
    public Result<?> sessionDelete(@PathVariable Long id) {
        // 检查是否有生效中的预约
        Long count = reservationMapper.selectCount(new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getSessionId, id)
                .in(Reservation::getStatus, 0, 1));
        if (count > 0) {
            return Result.error("该场次已有玩家预约，无法删除");
        }
        sessionMapper.deleteById(id);
        return Result.success(null);
    }

    // --- 预约接口 ---

    @PostMapping("/reserve")
    @Transactional
    public Result<?> reserve(@RequestBody Reservation reservation) {
        // 1. 基础校验
        Session session = sessionMapper.selectById(reservation.getSessionId());
        if (session == null) return Result.error("场次不存在");
        
        if (session.getSessionTime().isBefore(LocalDateTime.now())) {
            return Result.error("该场次已开始或已结束，无法预约");
        }

        if (session.getShopId().equals(reservation.getUserId())) {
            return Result.error("店家无法预约自己的场次");
        }

        // 2. 检查是否重复预约（状态为 0-待确认 或 1-已确认 的记录）
        Long count = reservationMapper.selectCount(new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getSessionId, reservation.getSessionId())
                .eq(Reservation::getUserId, reservation.getUserId())
                .in(Reservation::getStatus, 0, 1));
        if (count > 0) {
            return Result.error("您已预约过该场次，请勿重复操作");
        }

        // 3. 尝试扣减库存 (乐观锁/原子更新)
        // update session set remain_num = remain_num - num where id = sessionId and remain_num >= num
        int updated = sessionMapper.update(null, new LambdaUpdateWrapper<Session>()
                .setSql("remain_num = remain_num - " + reservation.getReserveNum())
                .eq(Session::getId, session.getId())
                .ge(Session::getRemainNum, reservation.getReserveNum()));
        
        if (updated == 0) {
            return Result.error("剩余名额不足");
        }

        // 4. 插入预约记录
        reservation.setCreateTime(LocalDateTime.now());
        reservation.setStatus(1); // 默认直接确认
        reservationMapper.insert(reservation);

        return Result.success(null);
    }

    @GetMapping("/my")
    public Result<List<Reservation>> myBookings(@RequestParam Long userId) {
        List<Reservation> list = reservationMapper.selectList(new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getUserId, userId)
                .orderByDesc(Reservation::getCreateTime));
        return Result.success(enrichReservations(list));
    }

    @GetMapping("/shop/list")
    public Result<List<Reservation>> shopBookings(@RequestParam Long shopId,
                                                  @RequestParam(required = false) Integer status) {
        List<Session> sessions = sessionMapper.selectList(new LambdaQueryWrapper<Session>().eq(Session::getShopId, shopId));
        if (sessions.isEmpty()) return Result.success(new java.util.ArrayList<>());
        
        List<Long> sessionIds = sessions.stream().map(Session::getId).collect(Collectors.toList());

        LambdaQueryWrapper<Reservation> query = new LambdaQueryWrapper<Reservation>()
                .in(Reservation::getSessionId, sessionIds);
        
        if (status != null) {
            query.eq(Reservation::getStatus, status);
        }
        
        query.orderByDesc(Reservation::getCreateTime);
        
        List<Reservation> list = reservationMapper.selectList(query);
        return Result.success(enrichReservations(list));
    }

    private List<Reservation> enrichReservations(List<Reservation> list) {
        for (Reservation res : list) {
            Session session = sessionMapper.selectById(res.getSessionId());
            if (session != null) {
                res.setSessionTime(session.getSessionTime());
                res.setScriptId(session.getScriptId()); // 补充 scriptId 用于评价
                Script script = scriptMapper.selectById(session.getScriptId());
                if (script != null) {
                    res.setScriptName(script.getName());
                }
            }
            User user = userMapper.selectById(res.getUserId());
            if (user != null) {
                res.setUserNickname(user.getNickname());
                res.setUserPhone(user.getPhone());
            }
        }
        return list;
    }

    @PostMapping("/confirm/{id}")
    @Transactional
    public Result<?> confirm(@PathVariable Long id, @RequestParam Integer status) {
        Reservation reservation = reservationMapper.selectById(id);
        if (reservation == null) return Result.error("预约不存在");
        
        // 校验取消预约的限制 (status 2 代表取消)
        if (status == 2 && reservation.getStatus() != 2) {
            Session session = sessionMapper.selectById(reservation.getSessionId());
            
            // 规则修改：只有在开场前 4 小时以上才能取消
            // 如果 sessionTime < now + 4 hours，说明离开始不足 4 小时，不能取消
            if (session.getSessionTime().isBefore(LocalDateTime.now().plusHours(4))) {
                return Result.error("距离开场不足 4 小时，无法取消预约");
            }

            // 原子归还库存
            sessionMapper.update(null, new LambdaUpdateWrapper<Session>()
                    .setSql("remain_num = remain_num + " + reservation.getReserveNum())
                    .eq(Session::getId, session.getId()));
        }

        reservation.setStatus(status);
        reservationMapper.updateById(reservation);
        return Result.success(null);
    }
}
