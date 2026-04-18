package com.example.scriptmurder.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.entity.Reservation;
import com.example.scriptmurder.entity.Script;
import com.example.scriptmurder.entity.Session;
import com.example.scriptmurder.mapper.ReservationMapper;
import com.example.scriptmurder.mapper.ScriptMapper;
import com.example.scriptmurder.mapper.SessionMapper;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;

@Component
public class SessionTask {

    @Resource
    private SessionMapper sessionMapper;

    @Resource
    private ReservationMapper reservationMapper;

    @Resource
    private ScriptMapper scriptMapper;

    /**
     * 每分钟执行一次，检查 15 分钟内即将开局的场次
     */
    @Scheduled(cron = "0 * * * * ?")
    @Transactional
    public void checkSessions() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime fifteenMinutesLater = now.plusMinutes(15);

        // 查询 15 分钟内即将开局，且状态正常的场次
        // 注意：这里需要给 Session 增加一个状态字段，或者通过 logic 判断
        // 假设目前没有状态字段，我们通过时间范围来处理
        List<Session> upcomingSessions = sessionMapper.selectList(new LambdaQueryWrapper<Session>()
                .gt(Session::getSessionTime, now)
                .le(Session::getSessionTime, fifteenMinutesLater));

        for (Session session : upcomingSessions) {
            Script script = scriptMapper.selectById(session.getScriptId());
            if (script == null) continue;

            // 获取最低人数要求 (minPeople 为空则取 peopleNum)
            Integer minPeople = script.getMinPeople() != null ? script.getMinPeople() : script.getPeopleNum();
            if (minPeople == null) minPeople = 0;

            // 计算已预约的总人数 (状态为 1-已确认)
            List<Reservation> reservations = reservationMapper.selectList(new LambdaQueryWrapper<Reservation>()
                    .eq(Reservation::getSessionId, session.getId())
                    .eq(Reservation::getStatus, 1));
            
            int bookedTotal = reservations.stream().mapToInt(Reservation::getReserveNum).sum();

            // 如果人数小于最低人数，取消开局
            if (bookedTotal < minPeople) {
                cancelSession(session, reservations);
            }
        }
    }

    private void cancelSession(Session session, List<Reservation> reservations) {
        // 1. 将预约状态改为 3 (假设 3 代表“因人数不足自动取消”)
        for (Reservation res : reservations) {
            res.setStatus(3);
            reservationMapper.updateById(res);
        }

        // 2. 将场次时间设为一个过去的时间，或者增加状态位标记已取消
        // 这里暂时通过设置 remainNum 为 -1 来表示场次已失效/取消
        session.setRemainNum(-1);
        sessionMapper.updateById(session);
        
        System.out.println("场次 [" + session.getId() + "] 因人数不足自动取消，已通知 " + reservations.size() + " 条预约");
    }
}
