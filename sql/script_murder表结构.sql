/*
 Navicat Premium Dump SQL

 Source Server         : 内网MariaDB
 Source Server Type    : MariaDB
 Source Server Version : 110806 (11.8.6-MariaDB-ubu2404)
 Source Host           : 192.168.1.109:3306
 Source Schema         : script_murder

 Target Server Type    : MariaDB
 Target Server Version : 110806 (11.8.6-MariaDB-ubu2404)
 File Encoding         : 65001

 Date: 09/04/2026 16:04:50
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for evaluation
-- ----------------------------
DROP TABLE IF EXISTS `evaluation`;
CREATE TABLE `evaluation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `script_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `booking_id` bigint(20) NOT NULL COMMENT '关联预约ID (防止重复评价)',
  `score` int(11) NOT NULL COMMENT '评分 1-5',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价内容',
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_booking`(`booking_id` ASC) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `script_id` bigint(20) NOT NULL,
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_script`(`user_id` ASC, `script_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `shop_id` bigint(20) NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for reservation
-- ----------------------------
DROP TABLE IF EXISTS `reservation`;
CREATE TABLE `reservation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `session_id` bigint(20) NOT NULL COMMENT '关联场次ID',
  `user_id` bigint(20) NOT NULL COMMENT '关联用户ID',
  `reserve_num` int(11) NOT NULL DEFAULT 1 COMMENT '预约人数',
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '0-待确认, 1-已确认, 2-已取消',
  `payment_status` int(11) NOT NULL DEFAULT 0 COMMENT '0-未支付, 1-已支付, 2-已退款',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单号',
  `has_evaluated` int(11) NOT NULL DEFAULT 0 COMMENT '0-未评价, 1-已评价',
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_session_id`(`session_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for script
-- ----------------------------
DROP TABLE IF EXISTS `script`;
CREATE TABLE `script`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `shop_id` bigint(20) NOT NULL COMMENT '所属店家ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '剧本名称',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型: 硬核/情感/欢乐等',
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签: 微恐,古风,校园 (用于推荐)',
  `people_num` int(11) NULL DEFAULT NULL COMMENT '建议人数',
  `min_people` int(11) NULL DEFAULT 6 COMMENT '最小人数',
  `max_people` int(11) NULL DEFAULT 6 COMMENT '最大人数',
  `duration` int(11) NULL DEFAULT NULL COMMENT '时长(分钟)',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '参考价格',
  `cover` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面图',
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '简介',
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_shop_id`(`shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for session
-- ----------------------------
DROP TABLE IF EXISTS `session`;
CREATE TABLE `session`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `script_id` bigint(20) NOT NULL COMMENT '关联剧本ID',
  `shop_id` bigint(20) NOT NULL COMMENT '关联店家ID',
  `session_time` datetime NOT NULL COMMENT '开场时间',
  `total_num` int(11) NOT NULL COMMENT '总人数',
  `remain_num` int(11) NOT NULL COMMENT '剩余名额',
  `price` decimal(10, 2) NOT NULL COMMENT '实际价格',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_script_id`(`script_id` ASC) USING BTREE,
  INDEX `idx_shop_id`(`shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '手机号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'PLAYER' COMMENT '角色: PLAYER/SHOP',
  `gender` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'UNKNOWN' COMMENT '性别: MALE/FEMALE/UNKNOWN',
  `age` int(11) NULL DEFAULT NULL COMMENT '年龄',
  `hobbies` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '兴趣爱好，逗号分隔',
  `create_time` datetime NULL DEFAULT current_timestamp() COMMENT '注册时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_phone`(`phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- View structure for v_order_detail
-- ----------------------------
DROP VIEW IF EXISTS `v_order_detail`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_order_detail` AS select `r`.`id` AS `order_id`,`r`.`order_no` AS `order_no`,date_format(`s`.`session_time`,'%Y-%m-%d') AS `booking_date`,date_format(`s`.`session_time`,'%H:%i:%s') AS `booking_time`,`r`.`reserve_num` AS `player_count`,`r`.`reserve_num` * `s`.`price` AS `final_price`,`r`.`payment_status` AS `payment_status`,`r`.`status` AS `order_status`,`u`.`nickname` AS `user_name`,`u`.`phone` AS `user_phone`,`sc`.`name` AS `script_name`,`sc`.`cover` AS `script_cover`,`shop`.`nickname` AS `shop_name` from ((((`reservation` `r` left join `session` `s` on(`r`.`session_id` = `s`.`id`)) left join `user` `u` on(`r`.`user_id` = `u`.`id`)) left join `script` `sc` on(`s`.`script_id` = `sc`.`id`)) left join `user` `shop` on(`s`.`shop_id` = `shop`.`id`));

-- ----------------------------
-- View structure for v_script_detail
-- ----------------------------
DROP VIEW IF EXISTS `v_script_detail`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_script_detail` AS select `s`.`script_id` AS `script_id`,`s`.`script_name` AS `script_name`,`s`.`script_type` AS `script_type`,`s`.`author` AS `author`,`s`.`player_count_min` AS `player_count_min`,`s`.`player_count_max` AS `player_count_max`,`s`.`duration` AS `duration`,`s`.`difficulty` AS `difficulty`,`s`.`story_background` AS `story_background`,`s`.`rating` AS `rating`,`s`.`rating_count` AS `rating_count`,`s`.`play_count` AS `play_count`,count(`ss`.`store_id`) AS `store_count`,min(`ss`.`price`) AS `min_price`,max(`ss`.`price`) AS `max_price` from (`script_info` `s` left join `store_script` `ss` on(`s`.`script_id` = `ss`.`script_id` and `ss`.`status` = '1')) where `s`.`status` = '1' group by `s`.`script_id`;

-- ----------------------------
-- View structure for v_store_detail
-- ----------------------------
DROP VIEW IF EXISTS `v_store_detail`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_store_detail` AS select `s`.`store_id` AS `store_id`,`s`.`store_name` AS `store_name`,`s`.`phone` AS `phone`,`s`.`city` AS `city`,`s`.`district` AS `district`,`s`.`address` AS `address`,`s`.`business_hours` AS `business_hours`,`s`.`description` AS `description`,`s`.`rating` AS `rating`,`s`.`rating_count` AS `rating_count`,`s`.`status` AS `status`,`u`.`nickname` AS `owner_name`,`u`.`phone` AS `owner_phone` from (`store_info` `s` left join `sys_user` `u` on(`s`.`owner_id` = `u`.`user_id`));

-- ----------------------------
-- Procedure structure for UpdateScriptRating
-- ----------------------------
DROP PROCEDURE IF EXISTS `UpdateScriptRating`;
delimiter ;;
CREATE PROCEDURE `UpdateScriptRating`(IN script_id_param BIGINT)
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    DECLARE review_count INT;
    
    SELECT AVG(script_rating), COUNT(*) 
    INTO avg_rating, review_count
    FROM review 
    WHERE script_id = script_id_param AND status = '1';
    
    UPDATE script_info 
    SET rating = IFNULL(avg_rating, 0.00), 
        rating_count = IFNULL(review_count, 0)
    WHERE script_id = script_id_param;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for UpdateStoreRating
-- ----------------------------
DROP PROCEDURE IF EXISTS `UpdateStoreRating`;
delimiter ;;
CREATE PROCEDURE `UpdateStoreRating`(IN store_id_param BIGINT)
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    DECLARE review_count INT;
    
    SELECT AVG(overall_rating), COUNT(*) 
    INTO avg_rating, review_count
    FROM review 
    WHERE store_id = store_id_param AND status = '1';
    
    UPDATE store_info 
    SET rating = IFNULL(avg_rating, 0.00), 
        rating_count = IFNULL(review_count, 0)
    WHERE store_id = store_id_param;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
