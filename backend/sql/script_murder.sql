/*
 Navicat Premium Dump SQL

 Source Server         : armbian
 Source Server Type    : MariaDB
 Source Server Version : 110803 (11.8.3-MariaDB-ubu2404)
 Source Host           : 192.168.1.109:3306
 Source Schema         : script_murder

 Target Server Type    : MariaDB
 Target Server Version : 110803 (11.8.3-MariaDB-ubu2404)
 File Encoding         : 65001

 Date: 27/02/2026 01:50:01
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
  `booking_id` bigint(20) NULL DEFAULT NULL COMMENT '关联的预约ID',
  `score` int(11) NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `script_id` bigint(20) NOT NULL,
  `create_time` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for reservation
-- ----------------------------
DROP TABLE IF EXISTS `reservation`;
CREATE TABLE `reservation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `session_id` bigint(20) NULL DEFAULT NULL,
  `user_id` bigint(20) NULL DEFAULT NULL,
  `reserve_num` int(11) NULL DEFAULT NULL,
  `status` int(11) NULL DEFAULT 0 COMMENT '0-待确认, 1-已确认, 2-已取消',
  `create_time` datetime NULL DEFAULT NULL,
  `has_evaluated` int(11) NULL DEFAULT 0 COMMENT '0-未评价, 1-已评价',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for script
-- ----------------------------
DROP TABLE IF EXISTS `script`;
CREATE TABLE `script`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `shop_id` bigint(20) NULL DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `people_num` int(11) NULL DEFAULT NULL,
  `duration` int(11) NULL DEFAULT NULL,
  `price` decimal(10, 2) NULL DEFAULT NULL,
  `cover` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `min_people` int(11) NULL DEFAULT 6,
  `max_people` int(11) NULL DEFAULT 6,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for session
-- ----------------------------
DROP TABLE IF EXISTS `session`;
CREATE TABLE `session`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `script_id` bigint(20) NULL DEFAULT NULL,
  `shop_id` bigint(20) NULL DEFAULT NULL,
  `session_time` datetime NULL DEFAULT NULL,
  `total_num` int(11) NULL DEFAULT NULL,
  `remain_num` int(11) NULL DEFAULT NULL,
  `price` decimal(10, 2) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'PLAYER',
  `create_time` datetime NULL DEFAULT NULL,
  `gender` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'UNKNOWN' COMMENT '性别: MALE/FEMALE/UNKNOWN',
  `age` int(11) NULL DEFAULT NULL COMMENT '年龄',
  `hobbies` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '兴趣爱好，简单描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- View structure for v_order_detail
-- ----------------------------
DROP VIEW IF EXISTS `v_order_detail`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_order_detail` AS select `o`.`order_id` AS `order_id`,`o`.`order_no` AS `order_no`,`o`.`booking_date` AS `booking_date`,`o`.`booking_time` AS `booking_time`,`o`.`player_count` AS `player_count`,`o`.`final_price` AS `final_price`,`o`.`payment_status` AS `payment_status`,`o`.`order_status` AS `order_status`,`u`.`nickname` AS `user_name`,`u`.`phone` AS `user_phone`,`s`.`store_name` AS `store_name`,`s`.`phone` AS `store_phone`,`sc`.`script_name` AS `script_name` from (((`booking_order` `o` left join `sys_user` `u` on(`o`.`user_id` = `u`.`user_id`)) left join `store_info` `s` on(`o`.`store_id` = `s`.`store_id`)) left join `script_info` `sc` on(`o`.`script_id` = `sc`.`script_id`));

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
