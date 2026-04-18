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

 Date: 03/03/2026 09:51:32
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
-- Records of evaluation
-- ----------------------------
INSERT INTO `evaluation` VALUES (1, 5, 11, 1, 5, '不愧是硬核神作，核诡太惊艳了！', '2026-02-26 19:01:28');
INSERT INTO `evaluation` VALUES (2, 5, 18, 2, 4, '逻辑严密，但是需要耐心盘。', '2026-02-26 19:01:28');
INSERT INTO `evaluation` VALUES (3, 1, 12, 3, 5, '哭到崩溃，我的顾川学长呜呜呜...', '2026-02-26 19:01:28');
INSERT INTO `evaluation` VALUES (4, 1, 17, 4, 5, '情感沉浸天花板，店家演绎很棒！', '2026-02-26 19:01:28');
INSERT INTO `evaluation` VALUES (5, 9, 13, 6, 4, '太欢乐了，撕逼撕得很爽，解压神器！', '2026-02-26 19:01:28');

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
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (1, 11, 8, '2026-02-26 19:01:28');
INSERT INTO `favorite` VALUES (2, 12, 2, '2026-02-26 19:01:28');
INSERT INTO `favorite` VALUES (3, 12, 4, '2026-02-26 19:01:28');
INSERT INTO `favorite` VALUES (4, 14, 15, '2026-02-26 19:01:28');
INSERT INTO `favorite` VALUES (5, 15, 5, '2026-02-26 19:01:28');

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
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, 1, '新店开业大酬宾，全场8折起！', '2026-02-26 19:01:28');
INSERT INTO `notice` VALUES (2, 1, '本周末举办《血染钟楼》水友赛，欢迎报名！', '2026-02-26 19:01:28');
INSERT INTO `notice` VALUES (3, 1, '店内新到一批独家本，硬核玩家速来挑战！', '2026-02-26 19:01:28');

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
-- Records of reservation
-- ----------------------------
INSERT INTO `reservation` VALUES (1, 1, 11, 1, 1, 1, 'ORD_HIST_01', 1, '2026-02-15 19:01:28');
INSERT INTO `reservation` VALUES (2, 1, 18, 1, 1, 1, 'ORD_HIST_02', 1, '2026-02-15 19:01:28');
INSERT INTO `reservation` VALUES (3, 2, 12, 1, 1, 1, 'ORD_HIST_03', 1, '2026-02-17 19:01:28');
INSERT INTO `reservation` VALUES (4, 2, 17, 1, 1, 1, 'ORD_HIST_04', 1, '2026-02-17 19:01:28');
INSERT INTO `reservation` VALUES (5, 3, 14, 1, 1, 1, 'ORD_HIST_05', 0, '2026-02-18 19:01:28');
INSERT INTO `reservation` VALUES (6, 4, 13, 2, 1, 1, 'ORD_HIST_06', 1, '2026-02-20 19:01:28');
INSERT INTO `reservation` VALUES (7, 8, 15, 2, 1, 1, 'ORD_FUT_01', 0, '2026-02-26 19:01:28');
INSERT INTO `reservation` VALUES (8, 10, 20, 2, 0, 0, 'ORD_FUT_02', 0, '2026-02-26 19:01:28');
INSERT INTO `reservation` VALUES (9, 11, 17, 2, 1, 1, 'ORD_FUT_03', 0, '2026-02-26 19:01:28');

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
-- Records of script
-- ----------------------------
INSERT INTO `script` VALUES (1, 1, '古木吟', '情感沉浸', '情感,古风,校园', 6, 6, 6, 240, 128.00, 'https://images.unsplash.com/photo-1519074069444-1ba4fff66d16?auto=format&fit=crop&w=400&q=80', '那是一所名为“古木”的高中，关于它的传说有很多...', '2026-02-26 19:01:27');
INSERT INTO `script` VALUES (2, 1, '告别诗', '情感沉浸', '情感,校园,治愈', 6, 6, 6, 240, 138.00, 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=400&q=80', '我们总是在夏天相遇，在秋天告别...', '2026-02-26 19:01:27');
INSERT INTO `script` VALUES (3, 1, '月下沙利叶', '情感沉浸', '微恐,情感,现代', 6, 6, 6, 270, 148.00, 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=400&q=80', '天使与魔鬼，只在一念之间。', '2026-02-26 19:01:27');
INSERT INTO `script` VALUES (4, 1, '涂川', '情感沉浸', '古风,神话,虐恋', 7, 7, 7, 300, 158.00, 'http://192.168.1.109:9000/script-murder/20260227/52944b358bcc4a1b848f4500a49e3070.png', '忘川河畔，三生石旁。', '2026-02-26 19:01:27');
INSERT INTO `script` VALUES (5, 1, '年轮', '硬核推理', '硬核,本格,烧脑', 5, 5, 5, 300, 158.00, 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=400&q=80', '大雪封山，五个人被困在破庙之中...', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (6, 1, '病娇男孩的精分日记', '硬核推理', '变格,还原,微恐', 7, 6, 7, 260, 128.00, 'https://images.unsplash.com/photo-1509281373149-e957c6296406?auto=format&fit=crop&w=400&q=80', '我叫萧何，我总是做同一个梦...', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (7, 1, '死者在幻夜中醒来', '硬核推理', '本格,暴风雪山庄', 6, 6, 6, 280, 138.00, 'http://192.168.1.109:9000/script-murder/20260227/85b1c1b49f2b4c2cb45c6a3987d82b65.png', '暴风雪山庄模式的经典复刻。', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (8, 1, '虚构推理', '硬核推理', '设定,逻辑,反转', 6, 6, 6, 320, 168.00, 'http://192.168.1.109:9000/script-murder/20260227/e2cc85e6f6744eadb875683478fda449.png', '当你排除一切不可能，剩下的无论多不可思议，都是真相。', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (9, 1, '拆迁', '欢乐撕逼', '欢乐,现代,撕逼', 8, 7, 9, 210, 98.00, 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&w=400&q=80', '为了那一笔拆迁款，全家人都疯了！', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (10, 1, '青楼', '阵营博弈', '阵营,古风,机制', 7, 7, 7, 270, 148.00, 'http://192.168.1.109:9000/script-murder/20260227/d4428b2a360347da84d8c5ba908b6d02.png', '满纸荒唐言，一把辛酸泪。', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (11, 1, '来电', '欢乐撕逼', '欢乐,机制,破冰', 6, 6, 7, 200, 108.00, 'https://images.unsplash.com/photo-1523413651479-597eb2da0ad6?auto=format&fit=crop&w=400&q=80', '诈骗电话接通过，请开始你的表演。', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (12, 1, '血染钟楼', '阵营博弈', '机制,狼人杀,多人', 10, 8, 15, 180, 88.00, 'https://images.unsplash.com/photo-1543536448-d209d2d13a1c?auto=format&fit=crop&w=400&q=80', '天黑请闭眼，恶魔在身边。', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (13, 1, '第二十二条校规', '恐怖', '恐怖,变格,校园', 6, 6, 6, 240, 138.00, 'https://images.unsplash.com/photo-1505635552518-3448ff116af3?auto=format&fit=crop&w=400&q=80', '千万不要触犯第二十二条校规...', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (14, 1, '惠子', '恐怖', '日式,恐怖,演绎', 6, 6, 6, 250, 148.00, 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?auto=format&fit=crop&w=400&q=80', '那双眼睛一直在看着你。', '2026-02-26 19:01:28');
INSERT INTO `script` VALUES (15, 1, '一点半', '恐怖', '微恐,校园,反转', 6, 5, 6, 220, 118.00, 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=400&q=80', '凌晨一点半，不要照镜子。', '2026-02-26 19:01:28');

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
-- Records of session
-- ----------------------------
INSERT INTO `session` VALUES (1, 5, 1, '2026-02-16 19:01:28', 5, 0, 158.00);
INSERT INTO `session` VALUES (2, 1, 1, '2026-02-18 19:01:28', 6, 0, 128.00);
INSERT INTO `session` VALUES (3, 13, 1, '2026-02-19 19:01:28', 6, 0, 138.00);
INSERT INTO `session` VALUES (4, 9, 1, '2026-02-21 19:01:28', 8, 0, 98.00);
INSERT INTO `session` VALUES (5, 6, 1, '2026-02-23 19:01:28', 7, 1, 128.00);
INSERT INTO `session` VALUES (6, 2, 1, '2026-02-24 19:01:28', 6, 0, 138.00);
INSERT INTO `session` VALUES (7, 1, 1, '2026-02-27 19:01:28', 6, 6, 128.00);
INSERT INTO `session` VALUES (8, 5, 1, '2026-02-27 19:01:28', 5, 3, 158.00);
INSERT INTO `session` VALUES (9, 10, 1, '2026-02-28 19:01:28', 7, 7, 148.00);
INSERT INTO `session` VALUES (10, 12, 1, '2026-02-28 19:01:28', 12, 10, 88.00);
INSERT INTO `session` VALUES (11, 4, 1, '2026-03-01 19:01:28', 7, 5, 158.00);
INSERT INTO `session` VALUES (12, 7, 1, '2026-03-01 19:01:28', 6, 6, 138.00);
INSERT INTO `session` VALUES (13, 8, 1, '2026-03-02 19:01:28', 6, -1, 168.00);

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
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, '13800000001', 'e10adc3949ba59abbe56e057f20f883e', '迷雾侦探社', 'https://api.dicebear.com/7.x/adventurer/svg?seed=shop1', 'SHOP', 'UNKNOWN', NULL, NULL, '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (11, '13900000001', 'e10adc3949ba59abbe56e057f20f883e', '推理狂人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player1', 'PLAYER', 'MALE', 24, '硬核推理,本格', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (12, '13900000002', 'e10adc3949ba59abbe56e057f20f883e', '爱哭小鬼', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player2', 'PLAYER', 'FEMALE', 22, '情感沉浸,古风', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (13, '13900000003', 'e10adc3949ba59abbe56e057f20f883e', '欢乐喜剧人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player3', 'PLAYER', 'MALE', 26, '欢乐撕逼,机制', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (14, '13900000004', 'e10adc3949ba59abbe56e057f20f883e', '胆小勿入', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player4', 'PLAYER', 'FEMALE', 23, '恐怖,微恐', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (15, '13900000005', 'e10adc3949ba59abbe56e057f20f883e', '全能车头', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player5', 'PLAYER', 'MALE', 28, '硬核推理,阵营博弈', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (16, '13900000006', 'e10adc3949ba59abbe56e057f20f883e', '路人甲', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player6', 'PLAYER', 'MALE', 25, '新手,欢乐', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (17, '13900000007', 'e10adc3949ba59abbe56e057f20f883e', '戏精本精', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player7', 'PLAYER', 'FEMALE', 24, '情感,演绎', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (18, '13900000008', 'e10adc3949ba59abbe56e057f20f883e', '逻辑怪', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player8', 'PLAYER', 'MALE', 30, '硬核,还原本', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (19, '13900000009', 'e10adc3949ba59abbe56e057f20f883e', '恐怖爱好者', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player9', 'PLAYER', 'FEMALE', 21, '恐怖,变格', '2026-02-26 19:01:27');
INSERT INTO `user` VALUES (20, '13900000010', 'e10adc3949ba59abbe56e057f20f883e', '社交达人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player10', 'PLAYER', 'MALE', 27, '机制,阵营', '2026-02-26 19:01:27');

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
