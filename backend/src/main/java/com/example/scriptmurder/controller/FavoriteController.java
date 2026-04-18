package com.example.scriptmurder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Favorite;
import com.example.scriptmurder.entity.Script;
import com.example.scriptmurder.mapper.FavoriteMapper;
import com.example.scriptmurder.mapper.ScriptMapper;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    @Resource
    private FavoriteMapper favoriteMapper;

    @Resource
    private ScriptMapper scriptMapper;

    @PostMapping("/add")
    public Result<?> add(@RequestBody Favorite favorite) {
        Favorite dbFavorite = favoriteMapper.selectOne(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, favorite.getUserId())
                .eq(Favorite::getScriptId, favorite.getScriptId()));
        if (dbFavorite != null) {
            return Result.success(null); // 幂等性处理
        }
        favorite.setCreateTime(LocalDateTime.now());
        favoriteMapper.insert(favorite);
        return Result.success(null);
    }

    @DeleteMapping("/remove")
    public Result<?> remove(@RequestParam Long userId, @RequestParam Long scriptId) {
        favoriteMapper.delete(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .eq(Favorite::getScriptId, scriptId));
        return Result.success(null);
    }

    @GetMapping("/check")
    public Result<Boolean> check(@RequestParam Long userId, @RequestParam Long scriptId) {
        Favorite dbFavorite = favoriteMapper.selectOne(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .eq(Favorite::getScriptId, scriptId));
        return Result.success(dbFavorite != null);
    }

    @GetMapping("/my")
    public Result<List<Script>> my(@RequestParam Long userId) {
        List<Favorite> favorites = favoriteMapper.selectList(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId));
        List<Long> scriptIds = favorites.stream().map(Favorite::getScriptId).collect(Collectors.toList());
        if (scriptIds.isEmpty()) {
            return Result.success(new java.util.ArrayList<>());
        }
        List<Script> list = scriptMapper.selectBatchIds(scriptIds);
        return Result.success(list);
    }
}
