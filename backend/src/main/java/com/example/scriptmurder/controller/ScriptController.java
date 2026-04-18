package com.example.scriptmurder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Script;
import com.example.scriptmurder.entity.Session;
import com.example.scriptmurder.mapper.ScriptMapper;
import com.example.scriptmurder.mapper.SessionMapper;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/script")
public class ScriptController {

    @Resource
    private ScriptMapper scriptMapper;

    @Resource
    private SessionMapper sessionMapper;

    @GetMapping("/list")
    public Result<List<Script>> list(@RequestParam(required = false) String type,
                                     @RequestParam(required = false) String name,
                                     @RequestParam(required = false) Integer peopleNum,
                                     @RequestParam(required = false) String sortField,
                                     @RequestParam(required = false) String sortOrder) {
        LambdaQueryWrapper<Script> query = new LambdaQueryWrapper<>();
        
        // 1. 类型筛选
        if (type != null && !type.isEmpty()) {
            query.eq(Script::getType, type);
        }
        
        // 2. 名称模糊搜索
        if (name != null && !name.isEmpty()) {
            query.like(Script::getName, name);
        }
        
        // 3. 人数筛选
        if (peopleNum != null) {
            // 优化逻辑：如果 min/max 都有值，则查范围；
            // 如果 min/max 为空，则认为该剧本的人数是固定的 peopleNum
            query.and(q -> q
                .nested(n -> n.le(Script::getMinPeople, peopleNum).ge(Script::getMaxPeople, peopleNum))
                .or()
                .nested(n -> n.isNull(Script::getMinPeople).eq(Script::getPeopleNum, peopleNum))
            );
        }
        
        // 4. 排序逻辑
        if ("price".equals(sortField)) {
            if ("asc".equals(sortOrder)) {
                query.orderByAsc(Script::getPrice);
            } else {
                query.orderByDesc(Script::getPrice);
            }
        } else {
            // 默认按创建时间降序
            query.orderByDesc(Script::getCreateTime);
        }
        
        List<Script> list = scriptMapper.selectList(query);
        // 对已有数据的兜底处理：如果 min/maxPeople 为 null，则使用 peopleNum
        for (Script script : list) {
            if (script.getMinPeople() == null) script.setMinPeople(script.getPeopleNum());
            if (script.getMaxPeople() == null) script.setMaxPeople(script.getPeopleNum());
            if (script.getDuration() == null) script.setDuration(0);
        }
        return Result.success(list);
    }

    @PostMapping("/save")
    @Transactional
    public Result<?> save(@RequestBody Script script) {
        if (script.getId() == null) {
            script.setCreateTime(LocalDateTime.now());
            scriptMapper.insert(script);
        } else {
            scriptMapper.updateById(script);
            
            // 同步更新该剧本下所有未开始场次的价格和人数限制
            List<Session> futureSessions = sessionMapper.selectList(new LambdaQueryWrapper<Session>()
                    .eq(Session::getScriptId, script.getId())
                    .gt(Session::getSessionTime, LocalDateTime.now()));
            
            for (Session session : futureSessions) {
                // 同步价格
                session.setPrice(script.getPrice());
                
                // 同步人数限制：保持已预约人数不变，调整剩余名额
                int bookedCount = session.getTotalNum() - session.getRemainNum();
                session.setTotalNum(script.getPeopleNum());
                session.setRemainNum(Math.max(0, script.getPeopleNum() - bookedCount));
                
                sessionMapper.updateById(session);
            }
        }
        return Result.success(null);
    }

    @DeleteMapping("/delete/{id}")
    @Transactional
    public Result<?> delete(@PathVariable Long id) {
        // 1. 检查是否有尚未结束的场次
        Long sessionCount = sessionMapper.selectCount(new LambdaQueryWrapper<Session>()
                .eq(Session::getScriptId, id));
        if (sessionCount > 0) {
            // 严格模式：只要有历史场次数据，就不允许物理删除，防止破坏历史订单
            return Result.error("该剧本存在关联的场次数据（含历史场次），无法删除");
        }
        
        scriptMapper.deleteById(id);
        return Result.success(null);
    }

    @GetMapping("/detail/{id}")
    public Result<Script> detail(@PathVariable Long id) {
        Script script = scriptMapper.selectById(id);
        if (script != null) {
            // 对已有老数据的兼容处理：如果 min/maxPeople 为空，则取建议人数
            if (script.getMinPeople() == null) script.setMinPeople(script.getPeopleNum());
            if (script.getMaxPeople() == null) script.setMaxPeople(script.getPeopleNum());
            if (script.getDuration() == null) script.setDuration(0);
        }
        return Result.success(script);
    }

    @GetMapping("/shop/{shopId}")
    public Result<List<Script>> getByShop(@PathVariable Long shopId) {
        List<Script> list = scriptMapper.selectList(new LambdaQueryWrapper<Script>().eq(Script::getShopId, shopId));
        for (Script script : list) {
            // 对已有老数据的兼容处理：如果 min/maxPeople 为空，则取建议人数
            if (script.getMinPeople() == null) script.setMinPeople(script.getPeopleNum());
            if (script.getMaxPeople() == null) script.setMaxPeople(script.getPeopleNum());
            if (script.getDuration() == null) script.setDuration(0);
        }
        return Result.success(list);
    }
}
