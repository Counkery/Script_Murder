package com.example.scriptmurder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.scriptmurder.common.Result;
import com.example.scriptmurder.entity.Evaluation;
import com.example.scriptmurder.entity.Reservation;
import com.example.scriptmurder.entity.Script;
import com.example.scriptmurder.entity.Session;
import com.example.scriptmurder.entity.User;
import com.example.scriptmurder.mapper.EvaluationMapper;
import com.example.scriptmurder.mapper.ReservationMapper;
import com.example.scriptmurder.mapper.ScriptMapper;
import com.example.scriptmurder.mapper.SessionMapper;
import com.example.scriptmurder.mapper.UserMapper;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/recommend")
public class RecommendController {

    @Resource
    private UserMapper userMapper;

    @Resource
    private ScriptMapper scriptMapper;

    @Resource
    private EvaluationMapper evaluationMapper;

    @Resource
    private ReservationMapper reservationMapper;

    @Resource
    private SessionMapper sessionMapper;

    /**
     * Get recommended scripts for a user
     * Strategy:
     * 1. Content-based: Match user hobbies to Script Types AND Tags
     * 2. History-based: Match types/tags of highly rated scripts (score >= 4)
     * 3. Filter out played scripts
     * 4. Fallback to popular/latest scripts if not enough recommendations
     */
    @GetMapping("/user/{userId}")
    public Result<List<Script>> recommend(@PathVariable Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }

        Set<String> preferredKeywords = new HashSet<>();

        // 1. Collect keywords from user hobbies
        if (user.getHobbies() != null && !user.getHobbies().isEmpty()) {
            String[] hobbies = user.getHobbies().split("[,，]"); // Handle both English and Chinese commas
            for (String hobby : hobbies) {
                preferredKeywords.add(hobby.trim());
            }
        }

        // 2. Collect keywords (type + tags) from highly rated scripts
        List<Evaluation> highRatedEvals = evaluationMapper.selectList(new LambdaQueryWrapper<Evaluation>()
                .eq(Evaluation::getUserId, userId)
                .ge(Evaluation::getScore, 4));
        
        if (!highRatedEvals.isEmpty()) {
            List<Long> likedScriptIds = highRatedEvals.stream()
                    .map(Evaluation::getScriptId)
                    .collect(Collectors.toList());
            
            if (!likedScriptIds.isEmpty()) {
                List<Script> likedScripts = scriptMapper.selectBatchIds(likedScriptIds);
                for (Script s : likedScripts) {
                    // Add Type
                    if (s.getType() != null) {
                        preferredKeywords.add(s.getType());
                    }
                    // Add Tags
                    if (s.getTags() != null && !s.getTags().isEmpty()) {
                        String[] tags = s.getTags().split("[,，]");
                        for (String tag : tags) {
                            preferredKeywords.add(tag.trim());
                        }
                    }
                }
            }
        }

        // 3. Get played script IDs to exclude
        List<Reservation> userReservations = reservationMapper.selectList(new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getUserId, userId)
                .ne(Reservation::getStatus, 2)); // Exclude cancelled
        
        Set<Long> playedScriptIds = new HashSet<>();
        if (!userReservations.isEmpty()) {
            List<Long> sessionIds = userReservations.stream()
                    .map(Reservation::getSessionId)
                    .collect(Collectors.toList());
            
            if (!sessionIds.isEmpty()) {
                List<Session> sessions = sessionMapper.selectBatchIds(sessionIds);
                for (Session s : sessions) {
                    playedScriptIds.add(s.getScriptId());
                }
            }
        }

        // 4. Query for recommendations
        List<Script> recommendations = new ArrayList<>();
        
        if (!preferredKeywords.isEmpty()) {
            // Because MyBatis-Plus doesn't support "OR LIKE" easily in a loop within a standard wrapper without query structure complexity,
            // we will fetch candidate scripts first (e.g. recent ones or all if volume is low) and filter in memory, 
            // OR use a custom query. For simplicity and performance on small dataset, we fetch unplayed scripts and score them.
            
            LambdaQueryWrapper<Script> query = new LambdaQueryWrapper<>();
            if (!playedScriptIds.isEmpty()) {
                query.notIn(Script::getId, playedScriptIds);
            }
            List<Script> candidates = scriptMapper.selectList(query);
            
            // Score candidates
            List<Map.Entry<Script, Integer>> scoredScripts = new ArrayList<>();
            for (Script script : candidates) {
                int score = 0;
                // Match Type
                if (script.getType() != null && preferredKeywords.contains(script.getType())) {
                    score += 5;
                }
                // Match Tags
                if (script.getTags() != null) {
                    String[] tags = script.getTags().split("[,，]");
                    for (String tag : tags) {
                        if (preferredKeywords.contains(tag.trim())) {
                            score += 3;
                        }
                    }
                }
                if (score > 0) {
                    scoredScripts.add(new AbstractMap.SimpleEntry<>(script, score));
                }
            }
            
            // Sort by score desc, then create time desc
            scoredScripts.sort((a, b) -> {
                int scoreCompare = b.getValue().compareTo(a.getValue());
                if (scoreCompare != 0) return scoreCompare;
                return b.getKey().getCreateTime().compareTo(a.getKey().getCreateTime());
            });
            
            recommendations = scoredScripts.stream()
                    .map(Map.Entry::getKey)
                    .limit(5)
                    .collect(Collectors.toList());
        }

        // 5. Fill with popular/latest if not enough
        if (recommendations.size() < 5) {
            int needed = 5 - recommendations.size();
            Set<Long> existingIds = recommendations.stream().map(Script::getId).collect(Collectors.toSet());
            existingIds.addAll(playedScriptIds);
            
            LambdaQueryWrapper<Script> fallbackQuery = new LambdaQueryWrapper<>();
            if (!existingIds.isEmpty()) {
                fallbackQuery.notIn(Script::getId, existingIds);
            }
            fallbackQuery.orderByDesc(Script::getCreateTime);
            fallbackQuery.last("LIMIT " + needed);
            
            List<Script> fallbackScripts = scriptMapper.selectList(fallbackQuery);
            recommendations.addAll(fallbackScripts);
        }

        return Result.success(recommendations);
    }
}
