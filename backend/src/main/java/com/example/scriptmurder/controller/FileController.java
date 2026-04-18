package com.example.scriptmurder.controller;

import com.example.scriptmurder.common.MinioUtils;
import com.example.scriptmurder.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import java.io.IOException;

@Slf4j
@RestController
@RequestMapping("/api/file")
public class FileController {

    @Resource
    private MinioUtils minioUtils;

    @PostMapping("/upload")
    public Result<String> upload(@RequestParam("file") MultipartFile file) throws IOException {
        log.info("接收到文件上传请求: name={}, size={}", file.getOriginalFilename(), file.getSize());
        
        if (file == null || file.isEmpty()) {
            return Result.error("文件不能为空");
        }
        
        // 校验文件大小 (限制 20MB)
        if (file.getSize() > 20 * 1024 * 1024) {
            log.warn("文件大小超出限制: {} bytes", file.getSize());
            return Result.error("文件大小不能超过 20MB");
        }

        String originalFilename = file.getOriginalFilename();
        String ext = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        }
        
        // 校验文件后缀
        if (!ext.matches(".(jpg|jpeg|png|gif|webp)")) {
            log.warn("不支持的文件格式: {}", ext);
            return Result.error("不支持的文件格式，仅支持 jpg, jpeg, png, gif, webp");
        }

        try {
            String url = minioUtils.upload(file);
            log.info("文件上传成功: {}", url);
            return Result.success(url);
        } catch (Exception e) {
            log.error("文件上传异常", e);
            return Result.error("文件上传失败");
        }
    }
}

