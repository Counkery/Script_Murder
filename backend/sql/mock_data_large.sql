SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 清空旧数据
TRUNCATE TABLE `user`;
TRUNCATE TABLE `script`;
TRUNCATE TABLE `session`;
TRUNCATE TABLE `reservation`;
TRUNCATE TABLE `evaluation`;
TRUNCATE TABLE `favorite`;
TRUNCATE TABLE `notice`;

-- 2. 插入用户数据 (密码统一为 123456 的 MD5 值: e10adc3949ba59abbe56e057f20f883e)
-- 店家 (ID 1)
INSERT INTO `user` (`id`, `phone`, `password`, `nickname`, `avatar`, `role`, `create_time`) VALUES 
(1, '13800000001', 'e10adc3949ba59abbe56e057f20f883e', '迷雾侦探社', 'https://api.dicebear.com/7.x/adventurer/svg?seed=shop1', 'SHOP', NOW());

-- 玩家 (ID 11-30)
INSERT INTO `user` (`id`, `phone`, `password`, `nickname`, `avatar`, `role`, `gender`, `age`, `hobbies`, `create_time`) VALUES 
(11, '13900000001', 'e10adc3949ba59abbe56e057f20f883e', '推理狂人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player1', 'PLAYER', 'MALE', 24, '硬核推理,本格', NOW()),
(12, '13900000002', 'e10adc3949ba59abbe56e057f20f883e', '爱哭小鬼', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player2', 'PLAYER', 'FEMALE', 22, '情感沉浸,古风', NOW()),
(13, '13900000003', 'e10adc3949ba59abbe56e057f20f883e', '欢乐喜剧人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player3', 'PLAYER', 'MALE', 26, '欢乐撕逼,机制', NOW()),
(14, '13900000004', 'e10adc3949ba59abbe56e057f20f883e', '胆小勿入', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player4', 'PLAYER', 'FEMALE', 23, '恐怖,微恐', NOW()),
(15, '13900000005', 'e10adc3949ba59abbe56e057f20f883e', '全能车头', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player5', 'PLAYER', 'MALE', 28, '硬核推理,阵营博弈', NOW()),
(16, '13900000006', 'e10adc3949ba59abbe56e057f20f883e', '路人甲', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player6', 'PLAYER', 'MALE', 25, '新手,欢乐', NOW()),
(17, '13900000007', 'e10adc3949ba59abbe56e057f20f883e', '戏精本精', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player7', 'PLAYER', 'FEMALE', 24, '情感,演绎', NOW()),
(18, '13900000008', 'e10adc3949ba59abbe56e057f20f883e', '逻辑怪', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player8', 'PLAYER', 'MALE', 30, '硬核,还原本', NOW()),
(19, '13900000009', 'e10adc3949ba59abbe56e057f20f883e', '恐怖爱好者', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player9', 'PLAYER', 'FEMALE', 21, '恐怖,变格', NOW()),
(20, '13900000010', 'e10adc3949ba59abbe56e057f20f883e', '社交达人', 'https://api.dicebear.com/7.x/avataaars/svg?seed=player10', 'PLAYER', 'MALE', 27, '机制,阵营', NOW());

-- 3. 插入剧本数据 (ID 1-20)
-- 情感沉浸类
INSERT INTO `script` (`id`, `shop_id`, `name`, `type`, `tags`, `people_num`, `min_people`, `max_people`, `duration`, `price`, `cover`, `intro`, `create_time`) VALUES 
(1, 1, '古木吟', '情感沉浸', '情感,古风,校园', 6, 6, 6, 240, 128.00, 'https://images.unsplash.com/photo-1519074069444-1ba4fff66d16?auto=format&fit=crop&w=400&q=80', '那是一所名为“古木”的高中，关于它的传说有很多...', NOW()),
(2, 1, '告别诗', '情感沉浸', '情感,校园,治愈', 6, 6, 6, 240, 138.00, 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=400&q=80', '我们总是在夏天相遇，在秋天告别...', NOW()),
(3, 1, '月下沙利叶', '情感沉浸', '微恐,情感,现代', 6, 6, 6, 270, 148.00, 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=400&q=80', '天使与魔鬼，只在一念之间。', NOW()),
(4, 1, '涂川', '情感沉浸', '古风,神话,虐恋', 7, 7, 7, 300, 158.00, 'https://images.unsplash.com/photo-1528164344705-475426879887?auto=format&fit=crop&w=400&q=80', '忘川河畔，三生石旁。', NOW());

-- 硬核推理类
INSERT INTO `script` (`id`, `shop_id`, `name`, `type`, `tags`, `people_num`, `min_people`, `max_people`, `duration`, `price`, `cover`, `intro`, `create_time`) VALUES 
(5, 1, '年轮', '硬核推理', '硬核,本格,烧脑', 5, 5, 5, 300, 158.00, 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=400&q=80', '大雪封山，五个人被困在破庙之中...', NOW()),
(6, 1, '病娇男孩的精分日记', '硬核推理', '变格,还原,微恐', 7, 6, 7, 260, 128.00, 'https://images.unsplash.com/photo-1509281373149-e957c6296406?auto=format&fit=crop&w=400&q=80', '我叫萧何，我总是做同一个梦...', NOW()),
(7, 1, '死者在幻夜中醒来', '硬核推理', '本格,暴风雪山庄', 6, 6, 6, 280, 138.00, 'https://images.unsplash.com/photo-1478720568477-152d9b164e63?auto=format&fit=crop&w=400&q=80', '暴风雪山庄模式的经典复刻。', NOW()),
(8, 1, '虚构推理', '硬核推理', '设定,逻辑,反转', 6, 6, 6, 320, 168.00, 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=400&q=80', '当你排除一切不可能，剩下的无论多不可思议，都是真相。', NOW());

-- 欢乐/阵营类
INSERT INTO `script` (`id`, `shop_id`, `name`, `type`, `tags`, `people_num`, `min_people`, `max_people`, `duration`, `price`, `cover`, `intro`, `create_time`) VALUES 
(9, 1, '拆迁', '欢乐撕逼', '欢乐,现代,撕逼', 8, 7, 9, 210, 98.00, 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&w=400&q=80', '为了那一笔拆迁款，全家人都疯了！', NOW()),
(10, 1, '青楼', '阵营博弈', '阵营,古风,机制', 7, 7, 7, 270, 148.00, 'https://images.unsplash.com/photo-1533907650686-705761a08629?auto=format&fit=crop&w=400&q=80', '满纸荒唐言，一把辛酸泪。', NOW()),
(11, 1, '来电', '欢乐撕逼', '欢乐,机制,破冰', 6, 6, 7, 200, 108.00, 'https://images.unsplash.com/photo-1523413651479-597eb2da0ad6?auto=format&fit=crop&w=400&q=80', '诈骗电话接通过，请开始你的表演。', NOW()),
(12, 1, '血染钟楼', '阵营博弈', '机制,狼人杀,多人', 10, 8, 15, 180, 88.00, 'https://images.unsplash.com/photo-1543536448-d209d2d13a1c?auto=format&fit=crop&w=400&q=80', '天黑请闭眼，恶魔在身边。', NOW());

-- 恐怖类
INSERT INTO `script` (`id`, `shop_id`, `name`, `type`, `tags`, `people_num`, `min_people`, `max_people`, `duration`, `price`, `cover`, `intro`, `create_time`) VALUES 
(13, 1, '第二十二条校规', '恐怖', '恐怖,变格,校园', 6, 6, 6, 240, 138.00, 'https://images.unsplash.com/photo-1505635552518-3448ff116af3?auto=format&fit=crop&w=400&q=80', '千万不要触犯第二十二条校规...', NOW()),
(14, 1, '惠子', '恐怖', '日式,恐怖,演绎', 6, 6, 6, 250, 148.00, 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?auto=format&fit=crop&w=400&q=80', '那双眼睛一直在看着你。', NOW()),
(15, 1, '一点半', '恐怖', '微恐,校园,反转', 6, 5, 6, 220, 118.00, 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=400&q=80', '凌晨一点半，不要照镜子。', NOW());

-- 4. 插入场次数据 (Session)
-- 过去场次 (用于评价)
INSERT INTO `session` (`id`, `script_id`, `shop_id`, `session_time`, `total_num`, `remain_num`, `price`) VALUES 
(1, 5, 1, DATE_SUB(NOW(), INTERVAL 10 DAY), 5, 0, 158.00), -- 年轮
(2, 1, 1, DATE_SUB(NOW(), INTERVAL 8 DAY), 6, 0, 128.00), -- 古木吟
(3, 13, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), 6, 0, 138.00), -- 校规
(4, 9, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), 8, 0, 98.00), -- 拆迁
(5, 6, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 7, 1, 128.00), -- 病娇
(6, 2, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), 6, 0, 138.00); -- 告别诗

-- 未来场次 (用于预约)
INSERT INTO `session` (`id`, `script_id`, `shop_id`, `session_time`, `total_num`, `remain_num`, `price`) VALUES 
(7, 1, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 6, 6, 128.00),
(8, 5, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), 5, 3, 158.00),
(9, 10, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 7, 7, 148.00),
(10, 12, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 12, 10, 88.00),
(11, 4, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 7, 5, 158.00),
(12, 7, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), 6, 6, 138.00),
(13, 8, 1, DATE_ADD(NOW(), INTERVAL 4 DAY), 6, 6, 168.00);

-- 5. 插入预约记录 (Reservation)
-- 历史订单
INSERT INTO `reservation` (`session_id`, `user_id`, `reserve_num`, `status`, `payment_status`, `order_no`, `has_evaluated`, `create_time`) VALUES 
(1, 11, 1, 1, 1, 'ORD_HIST_01', 1, DATE_SUB(NOW(), INTERVAL 11 DAY)), -- 推理狂人 -> 年轮
(1, 18, 1, 1, 1, 'ORD_HIST_02', 1, DATE_SUB(NOW(), INTERVAL 11 DAY)), -- 逻辑怪 -> 年轮
(2, 12, 1, 1, 1, 'ORD_HIST_03', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)), -- 爱哭小鬼 -> 古木吟
(2, 17, 1, 1, 1, 'ORD_HIST_04', 1, DATE_SUB(NOW(), INTERVAL 9 DAY)), -- 戏精本精 -> 古木吟
(3, 14, 1, 1, 1, 'ORD_HIST_05', 0, DATE_SUB(NOW(), INTERVAL 8 DAY)), -- 胆小勿入 -> 校规
(4, 13, 2, 1, 1, 'ORD_HIST_06', 1, DATE_SUB(NOW(), INTERVAL 6 DAY)); -- 欢乐喜剧人 -> 拆迁

-- 未来订单
INSERT INTO `reservation` (`session_id`, `user_id`, `reserve_num`, `status`, `payment_status`, `order_no`, `has_evaluated`, `create_time`) VALUES 
(8, 15, 2, 1, 1, 'ORD_FUT_01', 0, NOW()), -- 全能车头 -> 年轮
(10, 20, 2, 0, 0, 'ORD_FUT_02', 0, NOW()), -- 社交达人 -> 血染钟楼
(11, 17, 2, 1, 1, 'ORD_FUT_03', 0, NOW()); -- 戏精本精 -> 涂川

-- 6. 插入评价数据
INSERT INTO `evaluation` (`script_id`, `user_id`, `booking_id`, `score`, `content`, `create_time`) VALUES 
(5, 11, 1, 5, '不愧是硬核神作，核诡太惊艳了！', NOW()),
(5, 18, 2, 4, '逻辑严密，但是需要耐心盘。', NOW()),
(1, 12, 3, 5, '哭到崩溃，我的顾川学长呜呜呜...', NOW()),
(1, 17, 4, 5, '情感沉浸天花板，店家演绎很棒！', NOW()),
(9, 13, 6, 4, '太欢乐了，撕逼撕得很爽，解压神器！', NOW());

-- 7. 插入收藏数据
INSERT INTO `favorite` (`user_id`, `script_id`, `create_time`) VALUES 
(11, 8, NOW()), -- 推理狂人 收藏 虚构推理
(12, 2, NOW()), -- 爱哭小鬼 收藏 告别诗
(12, 4, NOW()), -- 爱哭小鬼 收藏 涂川
(14, 15, NOW()), -- 胆小勿入 收藏 一点半
(15, 5, NOW()); -- 全能车头 收藏 年轮

-- 8. 插入公告
INSERT INTO `notice` (`shop_id`, `content`, `create_time`) VALUES 
(1, '新店开业大酬宾，全场8折起！', NOW()),
(1, '本周末举办《血染钟楼》水友赛，欢迎报名！', NOW()),
(1, '店内新到一批独家本，硬核玩家速来挑战！', NOW());

SET FOREIGN_KEY_CHECKS = 1;
