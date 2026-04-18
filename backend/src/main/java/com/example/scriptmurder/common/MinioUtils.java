package com.example.scriptmurder.common;

import com.example.scriptmurder.config.MinioConfig;
import io.minio.*;
import io.minio.PutObjectArgs;
import io.minio.SetBucketPolicyArgs;
import lombok.extern.slf4j.Slf4j;
import net.coobird.thumbnailator.Thumbnails;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
public class MinioUtils {

    @Resource
    private MinioClient minioClient;

    @Resource
    private MinioConfig minioConfig;

    @PostConstruct
    public void init() {
        createBucket();
    }

    /**
     * 检查存储桶是否存在，不存在则创建
     */
    public void createBucket() {
        try {
            boolean found = minioClient.bucketExists(BucketExistsArgs.builder().bucket(minioConfig.getBucketName()).build());
            if (!found) {
                log.info("MinIO 存储桶 {} 不存在，尝试创建...", minioConfig.getBucketName());
                minioClient.makeBucket(MakeBucketArgs.builder().bucket(minioConfig.getBucketName()).build());
                log.info("创建 MinIO 存储桶成功: {}", minioConfig.getBucketName());
            } else {
                log.info("MinIO 存储桶 {} 已存在", minioConfig.getBucketName());
            }
            
            // 无论新建还是已存在，都强制更新策略为公共读 (解决 AccessDenied 问题)
            String policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":[\"s3:GetBucketLocation\",\"s3:ListBucket\",\"s3:ListBucketMultipartUploads\"],\"Resource\":[\"arn:aws:s3:::" + minioConfig.getBucketName() + "\"]},{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::" + minioConfig.getBucketName() + "/*\"]}]}";
            minioClient.setBucketPolicy(SetBucketPolicyArgs.builder().bucket(minioConfig.getBucketName()).config(policy).build());
            log.info("MinIO 存储桶策略已更新为公共读");

        } catch (Exception e) {
            log.error("检查或创建 MinIO 存储桶失败: endpoint={}, bucket={}", minioConfig.getEndpoint(), minioConfig.getBucketName(), e);
            // 这里不抛出异常，避免阻塞启动，但会打印错误日志
        }
    }

    /**
     * 上传文件 (带压缩功能)
     */
    public String upload(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();
        String ext = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        }
        
        String fileName = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "/" +
                UUID.randomUUID().toString().replace("-", "") + ext;

        try {
            createBucket(); // 确保桶存在
            
            InputStream uploadStream;
            long uploadSize;
            String contentType = file.getContentType();
            
            // 如果是图片且大小超过 500KB，则进行压缩
            if (file.getSize() > 500 * 1024 && contentType != null && contentType.startsWith("image/")) {
                log.info("图片较大 ({} KB)，正在进行压缩...", file.getSize() / 1024);
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                
                // 压缩至最大宽度 1280px，质量 0.8
                Thumbnails.of(file.getInputStream())
                        .size(1280, 1280) // 限制最大尺寸，保持比例
                        .outputQuality(0.8f) // 压缩质量
                        .toOutputStream(outputStream);
                
                byte[] bytes = outputStream.toByteArray();
                uploadStream = new ByteArrayInputStream(bytes);
                uploadSize = bytes.length;
                log.info("压缩完成，新大小: {} KB", uploadSize / 1024);
            } else {
                uploadStream = file.getInputStream();
                uploadSize = file.getSize();
            }

            try (InputStream is = uploadStream) {
                log.info("开始上传文件至 MinIO: bucket={}, object={}", minioConfig.getBucketName(), fileName);
                minioClient.putObject(PutObjectArgs.builder()
                        .bucket(minioConfig.getBucketName())
                        .object(fileName)
                        .stream(is, uploadSize, -1)
                        .contentType(contentType)
                        .build());
                log.info("文件上传完成");
            }
            
            // 返回访问 URL
            return minioConfig.getEndpoint() + "/" + minioConfig.getBucketName() + "/" + fileName;
            
        } catch (Exception e) {
            log.error("MinIO 上传失败: {}", e.getMessage(), e);
            throw new RuntimeException("文件上传失败: " + e.getMessage());
        }
    }
}
