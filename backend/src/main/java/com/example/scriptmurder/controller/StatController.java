package com.example.scriptmurder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Reservation;
import com.example.scriptmurder.entity.Script;
import com.example.scriptmurder.entity.Session;
import com.example.scriptmurder.mapper.ReservationMapper;
import com.example.scriptmurder.mapper.ScriptMapper;
import com.example.scriptmurder.mapper.SessionMapper;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/stat")
public class StatController {

    @Resource
    private ReservationMapper reservationMapper;

    @Resource
    private ScriptMapper scriptMapper;

    @Resource
    private SessionMapper sessionMapper;

    @GetMapping("/shop/{shopId}")
    public Result<Map<String, Object>> shopStat(@PathVariable Long shopId) {
        Map<String, Object> map = new HashMap<>();
        
        // 1. 基础统计
        Long scriptCount = scriptMapper.selectCount(new LambdaQueryWrapper<Script>().eq(Script::getShopId, shopId));
        map.put("scriptCount", scriptCount);
        
        Long sessionCount = sessionMapper.selectCount(new LambdaQueryWrapper<Session>().eq(Session::getShopId, shopId));
        map.put("sessionCount", sessionCount);
        
        List<Session> sessions = sessionMapper.selectList(new LambdaQueryWrapper<Session>().eq(Session::getShopId, shopId));
        if (sessions.isEmpty()) {
            map.put("bookingCount", 0);
            map.put("totalRevenue", 0);
            map.put("revenueTrend", new ArrayList<>());
            map.put("typeDistribution", new ArrayList<>());
            map.put("scriptRank", new ArrayList<>());
            return Result.success(map);
        }

        List<Long> sessionIds = sessions.stream().map(Session::getId).collect(Collectors.toList());
        List<Reservation> reservations = reservationMapper.selectList(new LambdaQueryWrapper<Reservation>()
                .in(Reservation::getSessionId, sessionIds)
                .eq(Reservation::getStatus, 1)); // 仅统计已确认的
        
        map.put("bookingCount", reservations.size());
        
        // 2. 营业额计算与趋势统计 (近7天)
        double totalRevenue = 0;
        Map<String, Double> trendMap = new HashMap<>();
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("MM-dd");
        
        // 初始化近7天数据
        for (int i = 6; i >= 0; i--) {
            trendMap.put(LocalDate.now().minusDays(i).format(dtf), 0.0);
        }

        for (Reservation res : reservations) {
            Session s = sessionMapper.selectById(res.getSessionId());
            if (s != null && s.getPrice() != null) {
                double amount = s.getPrice().doubleValue() * res.getReserveNum();
                totalRevenue += amount;
                
                // 统计趋势
                String dateKey = res.getCreateTime().toLocalDate().format(dtf);
                if (trendMap.containsKey(dateKey)) {
                    trendMap.put(dateKey, trendMap.get(dateKey) + amount);
                }
            }
        }
        map.put("totalRevenue", totalRevenue);
        
        List<Map<String, Object>> trendList = new ArrayList<>();
        trendMap.keySet().stream().sorted().forEach(date -> {
            Map<String, Object> item = new HashMap<>();
            item.put("date", date);
            item.put("amount", trendMap.get(date));
            trendList.add(item);
        });
        map.put("revenueTrend", trendList);

        // 3. 剧本类型分布
        List<Script> scripts = scriptMapper.selectList(new LambdaQueryWrapper<Script>().eq(Script::getShopId, shopId));
        Map<String, Long> typeMap = scripts.stream()
                .collect(Collectors.groupingBy(Script::getType, Collectors.counting()));
        
        List<Map<String, Object>> typeDist = new ArrayList<>();
        typeMap.forEach((type, count) -> {
            Map<String, Object> item = new HashMap<>();
            item.put("name", type);
            item.put("value", count);
            typeDist.add(item);
        });
        map.put("typeDistribution", typeDist);

        // 4. 剧本预约排行 (Top 5)
        Map<Long, Integer> scriptBookingMap = new HashMap<>();
        for (Reservation res : reservations) {
            Session s = sessionMapper.selectById(res.getSessionId());
            if (s != null) {
                scriptBookingMap.put(s.getScriptId(), scriptBookingMap.getOrDefault(s.getScriptId(), 0) + res.getReserveNum());
            }
        }
        
        List<Map<String, Object>> scriptRank = scriptBookingMap.entrySet().stream()
                .sorted((a, b) -> b.getValue() - a.getValue())
                .limit(5)
                .map(entry -> {
                    Map<String, Object> item = new HashMap<>();
                    Script script = scriptMapper.selectById(entry.getKey());
                    item.put("name", script != null ? script.getName() : "未知剧本");
                    item.put("value", entry.getValue());
                    return item;
                }).collect(Collectors.toList());
        map.put("scriptRank", scriptRank);
        
        return Result.success(map);
    }
}
