package com.example.scriptmurder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Notice;
import com.example.scriptmurder.mapper.NoticeMapper;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/notice")
public class NoticeController {

    @Resource
    private NoticeMapper noticeMapper;

    @PostMapping("/save")
    public Result<?> save(@RequestBody Notice notice) {
        if (notice.getId() == null) {
            notice.setCreateTime(LocalDateTime.now());
            noticeMapper.insert(notice);
        } else {
            noticeMapper.updateById(notice);
        }
        return Result.success(null);
    }

    @GetMapping("/list")
    public Result<List<Notice>> list() {
        return Result.success(noticeMapper.selectList(new LambdaQueryWrapper<Notice>().orderByDesc(Notice::getCreateTime)));
    }

    @DeleteMapping("/delete/{id}")
    public Result<?> delete(@PathVariable Long id) {
        noticeMapper.deleteById(id);
        return Result.success(null);
    }
}
