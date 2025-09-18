// 统一的Mock数据管理文件
import { Inspiration, GiftEvent, Contact, BudgetRange } from '../model/NewDataModels';
import { RecipientType, OccasionType, GiftType, BudgetRange as BudgetRangeEnum } from '../model/GiftEnums';

/**
 * Mock数据管理类
 * 统一管理应用中所有的模拟数据
 */
export class MockData {
  
  /**
   * 获取Mock灵感数据
   * @returns Inspiration[] 灵感数据数组
   */
  static getMockInspirations(): Inspiration[] {
    return [
      // 按对象送 - 10条
      {
        id: '1',
        title: '给女朋友的浪漫惊喜',
        description: '精心准备的生日礼物套装，包含定制相册、手写情书和她最爱的小饰品',
        detailedDescription: '这是一份充满心意的生日礼物套装，通过收集你们的美好回忆，制作成精美的定制相册，配上手写的情书，再加上她平时提到过想要的小饰品，让这份礼物既有纪念意义又实用贴心。',
        tags: [RecipientType.GIRLFRIEND, OccasionType.BIRTHDAY, GiftType.JEWELRY],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        images: [$r('app.media.romantic_surprise_for_girlfriend')],
        targetAudience: ['女朋友'],
        occasions: ['生日'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '2-3小时',
        materials: [
          '定制相册（A4大小）',
          '精美信纸和信封',
          '彩色笔或钢笔',
          '小饰品（项链、手链或耳环）',
          '包装盒和丝带',
          '贴纸和装饰材料'
        ],
        steps: [
          '收集你们的合照，选择20-30张最有意义的照片',
          '按时间顺序整理照片，为每张照片写上简短的回忆描述',
          '制作相册，可以添加一些手绘元素或贴纸装饰',
          '写一封情书，表达你对她的爱意和生日祝福',
          '选择一件她喜欢的小饰品，可以是她之前提到过的',
          '精心包装所有物品，用漂亮的盒子和丝带'
        ],
        tips: [
          '提前观察她平时的喜好，选择合适的饰品风格',
          '在相册中加入一些只有你们知道的小秘密或内部笑话',
          '情书要手写，字迹工整，表达真挚情感',
          '包装要精美，第一印象很重要'
        ],
        precautions: [
          '确保饰品的材质不会引起过敏',
          '相册制作时注意照片的保护，避免损坏',
          '情书内容要积极正面，避免提及不愉快的回忆'
        ],
        giftWrapIdeas: [
          '使用她喜欢的颜色包装纸',
          '在包装上贴上小卡片写上"生日快乐"',
          '用丝带打一个漂亮的蝴蝶结'
        ],
        presentationTips: [
          '选择一个浪漫的环境赠送，比如烛光晚餐后',
          '先给相册，让她感受回忆的美好，再给饰品作为惊喜',
          '准备一些温馨的话语，解释每个礼物的意义'
        ],
        personalizedTips: [
          '如果她喜欢音乐，可以在相册中加入你们共同喜欢的歌词',
          '如果她是文艺女生，可以在情书中引用她喜欢的诗句',
          '根据她的性格选择饰品：活泼的选择亮色，优雅的选择简约款'
        ],
        isRecommended: true
      },
      {
        id: '2',
        title: '送给妈妈的温馨礼物',
        description: '表达孝心的实用礼品，让妈妈感受到贴心关怀',
        detailedDescription: '为妈妈精心挑选的温馨礼物套装，包含实用的生活用品和贴心的健康关怀产品。通过这些日常能用到的礼品，让妈妈在使用时时刻感受到你的关爱和孝心，提升她的生活品质和幸福感。',
        tags: [RecipientType.MOTHER, OccasionType.MOTHERS_DAY, GiftType.DAILY_ITEMS],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [$r('app.media.warm_gift_for_mom')],
        targetAudience: ['妈妈'],
        occasions: ['母亲节'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '保温杯（优质不锈钢材质）',
          '蚕丝眼罩（助眠用）',
          '护手霜（滋润型）',
          '足浴包（中药配方）',
          '按摩梳（天然木质）',
          '精美包装盒',
          '贺卡和信封',
          '丝带装饰'
        ],
        steps: [
          '了解妈妈的日常习惯和需求，选择最适合的产品',
          '选购优质的保温杯，确保保温效果好且安全无毒',
          '挑选舒适的蚕丝眼罩，帮助妈妈改善睡眠质量',
          '选择温和滋润的护手霜，呵护妈妈的双手',
          '购买中药足浴包，让妈妈在家享受足疗放松',
          '配上天然木质按摩梳，方便日常头部按摩',
          '精心包装所有物品，写上温馨的祝福卡片'
        ],
        tips: [
          '选择知名品牌的产品，确保质量和安全性',
          '考虑妈妈的年龄和身体状况，选择适合的产品',
          '在贺卡上写下感谢妈妈的话语，表达真挚情感',
          '可以根据季节调整礼品内容，如冬天加入暖宫贴等'
        ],
        precautions: [
          '确认妈妈对护肤品成分无过敏反应',
          '足浴包使用前要仔细阅读说明，注意水温',
          '保温杯要选择食品级材质，确保饮水安全'
        ],
        giftWrapIdeas: [
          '使用温馨的粉色或米色包装纸',
          '在包装盒上贴上"妈妈专属"的标签',
          '用金色丝带打蝴蝶结，显得优雅大方'
        ],
        presentationTips: [
          '选择妈妈心情好的时候赠送，如周末的下午',
          '亲自为妈妈介绍每个礼品的用途和好处',
          '可以陪妈妈一起试用，增进亲子感情',
          '承诺会经常关心妈妈的健康和生活'
        ],
        personalizedTips: [
          '如果妈妈喜欢花茶，可以加入优质花茶包',
          '如果妈妈有颈椎问题，可以加入颈部按摩器',
          '根据妈妈的喜好选择护手霜的香味，如玫瑰或薰衣草',
          '如果妈妈注重养生，可以加入燕窝或阿胶等滋补品'
        ],
        isRecommended: true
      },
      {
        id: '3',
        title: '给爸爸的实用好物',
        description: '贴心实用的父亲节礼物',
        detailedDescription: '为爸爸精心挑选的实用好物套装，包含高品质的保温杯、多功能工具包、舒适的颈枕和护眼台灯。这些礼物既实用又贴心，体现了对爸爸日常生活的关怀，让他在工作和生活中都能感受到子女的爱意。',
        tags: [RecipientType.FATHER, OccasionType.FATHERS_DAY, GiftType.DAILY_ITEMS],
        budgetRange: { min: 150, max: 400, label: '150-400元' },
        images: [$r('app.media.practical_gift_for_dad')],
        targetAudience: ['爸爸'],
        occasions: ['父亲节'],
        interests: [],
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '高品质保温杯（500ml）',
          '多功能工具包（螺丝刀、扳手等）',
          '记忆棉颈枕',
          'LED护眼台灯',
          '商务笔记本',
          '高档钢笔',
          '精美包装盒',
          '祝福贺卡'
        ],
        steps: [
          '了解爸爸的工作性质和日常需求，选择最实用的物品',
          '选购品质可靠的保温杯，确保保温效果和安全性',
          '挑选多功能工具包，满足爸爸的DIY需求',
          '选择舒适的颈枕，缓解爸爸的颈部疲劳',
          '购买护眼台灯，保护爸爸的视力健康',
          '配上商务笔记本和钢笔，提升工作效率',
          '精心包装所有物品，写上感谢爸爸的话语'
        ],
        tips: [
          '选择知名品牌的产品，确保质量和耐用性',
          '考虑爸爸的使用习惯，选择操作简单的产品',
          '在贺卡上表达对爸爸辛苦工作的感谢',
          '可以根据爸爸的兴趣爱好调整礼品内容'
        ],
        precautions: [
          '确认工具包的规格适合爸爸的使用需求',
          '台灯要选择无频闪的LED光源，保护视力',
          '保温杯要选择食品级不锈钢材质'
        ],
        giftWrapIdeas: [
          '使用深蓝色或黑色的商务风包装',
          '在包装上贴上"爸爸专属"的标签',
          '用银色丝带装饰，显得稳重大方'
        ],
        presentationTips: [
          '选择爸爸休息的时候赠送，如周末的晚上',
          '亲自为爸爸介绍每个礼品的功能和用途',
          '可以和爸爸一起试用工具包，增进父子感情',
          '承诺会经常关心爸爸的身体健康'
        ],
        isRecommended: true
      },
      {
        id: '4',
        title: '闺蜜生日惊喜',
        description: '和闺蜜一起度过难忘生日，制作专属友谊纪念品',
        detailedDescription: '为闺蜜精心策划的生日惊喜，包含手工制作的友谊相册、定制的闺蜜手链，以及一场温馨的生日聚会。通过亲手制作的礼物和用心安排的庆祝活动，让这个生日成为你们友谊中最珍贵的回忆。',
        tags: [RecipientType.BESTIE, OccasionType.BIRTHDAY, GiftType.DIY_HANDMADE],
        budgetRange: { min: 100, max: 250, label: '100-250元' },
        images: [$r('app.media.bestie_birthday_surprise')],
        targetAudience: ['闺蜜'],
        occasions: ['生日'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '3-4小时',
        materials: [
          '友谊相册本（精装版）',
          '彩色打印照片',
          '手链制作材料（珠子、线绳）',
          '装饰贴纸和胶带',
          '彩色笔和马克笔',
          '生日蛋糕（小号）',
          '气球和拉花装饰',
          '精美包装盒'
        ],
        steps: [
          '收集你们的合照和有趣的聊天截图，选择最有纪念意义的',
          '制作友谊相册，为每张照片配上回忆文字和装饰',
          '制作专属闺蜜手链，可以选择你们都喜欢的颜色',
          '准备生日聚会场地，用气球和拉花装饰',
          '订购或制作小型生日蛋糕',
          '将手工礼物精美包装，准备惊喜环节',
          '邀请其他共同朋友参与，增加惊喜感'
        ],
        tips: [
          '在相册中加入你们的"友谊宣言"或内部笑话',
          '手链可以做成情侣款式，象征永恒友谊',
          '选择她最喜欢的蛋糕口味，体现贴心',
          '可以准备一些小游戏，增加聚会的趣味性'
        ],
        precautions: [
          '确认她的生日当天有空，避免时间冲突',
          '制作手链时注意尺寸，确保佩戴舒适',
          '相册制作要仔细，避免照片损坏'
        ],
        giftWrapIdeas: [
          '使用粉色或她喜欢的颜色包装',
          '在包装上贴上"Best Friends Forever"的标签',
          '用蝴蝶结和小装饰品美化包装'
        ],
        presentationTips: [
          '先给相册，让她回忆美好时光',
          '再给手链，强调友谊的珍贵',
          '最后切蛋糕，和大家一起庆祝',
          '记录下她收到礼物时的表情，作为新的回忆'
        ],
        personalizedTips: [
          '如果她喜欢韩风，可以用韩式装饰风格',
          '如果她是文艺女生，可以加入手写诗句',
          '根据她的兴趣爱好选择相册主题色调',
          '可以邀请她的其他好朋友一起参与制作'
        ],
        isRecommended: true
      },
      {
        id: '5',
        title: '给男朋友的创意礼物',
        description: '独特的纪念日礼品，定制专属回忆盒子',
        detailedDescription: '为男朋友制作的创意纪念日礼物，包含定制的回忆盒子、手写情书集、你们的专属地图，以及一些有纪念意义的小物件。这份礼物不仅创意十足，更承载着你们共同的美好回忆，让他感受到你的用心和爱意。',
        tags: [RecipientType.BOYFRIEND, OccasionType.ANNIVERSARY, GiftType.CREATIVE_NOVEL],
        budgetRange: { min: 150, max: 350, label: '150-350元' },
        images: [$r('app.media.creative_gift_for_boyfriend')],
        targetAudience: ['男朋友'],
        occasions: ['纪念日'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '4-5小时',
        materials: [
          '木质收纳盒（可定制刻字）',
          '高质量相纸和照片',
          '地图打印纸',
          '精美信纸和信封',
          '小装饰品（钥匙扣、徽章等）',
          '丝带和包装材料',
          '马克笔和彩色笔',
          '透明收纳袋',
          '小卡片和标签'
        ],
        steps: [
          '选择一个有意义的木质盒子，可以刻上你们的名字和纪念日期',
          '制作"我们的地图"，标记你们去过的重要地点',
          '收集你们的照片，按时间顺序整理并写上回忆',
          '写一系列小情书，每张纸条记录一个美好瞬间',
          '收集有纪念意义的小物件，如电影票、餐厅收据等',
          '将所有物品分类装入透明袋，贴上标签',
          '精心布置盒子内部，让每样东西都有合适的位置'
        ],
        tips: [
          '在地图上用不同颜色标记不同类型的地点（约会、旅行、重要事件）',
          '情书可以写成"100个爱你的理由"或"我们的100个第一次"',
          '加入一些他的兴趣爱好相关的小物件',
          '可以录制一段语音，用二维码的形式放在盒子里'
        ],
        precautions: [
          '确保所有纸质物品都做好防潮处理',
          '小物件要固定好，避免在盒子里散乱',
          '情书内容要积极正面，避免提及争吵或不愉快的回忆'
        ],
        giftWrapIdeas: [
          '用他喜欢的颜色包装纸包装盒子',
          '在包装上贴上"我们的回忆宝盒"标签',
          '用黑色或深蓝色丝带，显得成熟稳重'
        ],
        presentationTips: [
          '选择一个安静浪漫的环境，如家里的客厅',
          '先让他猜猜盒子里有什么，增加神秘感',
          '陪他一起打开，一件件介绍每个物品的意义',
          '最后一起回忆这些美好时光，增进感情'
        ],
        personalizedTips: [
          '如果他喜欢游戏，可以加入游戏相关的纪念品',
          '如果他是运动爱好者，可以加入你们一起运动的照片',
          '如果他喜欢音乐，可以制作你们的专属歌单二维码',
          '根据他的性格选择盒子风格：文艺型选木质，现代型选金属'
        ],
        isRecommended: false
      },
      {
        id: '6',
        title: '给老师的感谢礼',
        description: '表达感激之情的礼物',
        detailedDescription: '为辛勤工作的老师准备的感谢礼物，包含实用的办公用品、护嗓茶品和精美的感谢卡片。这些礼物既实用又贴心，能够在老师的日常工作中发挥作用，同时表达学生和家长的感激之情。',
        tags: [RecipientType.TEACHER, OccasionType.TEACHERS_DAY, GiftType.DAILY_ITEMS],
        budgetRange: { min: 80, max: 200, label: '80-200元' },
        images: [$r('app.media.thank_you_gift_for_teacher')],
        targetAudience: ['老师'],
        occasions: ['教师节'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '高品质钢笔或签字笔套装',
          '护嗓茶包（胖大海、金银花等）',
          '精美笔记本或备课本',
          '护手霜（温和滋润型）',
          '感谢卡片和信封',
          '小型绿植（如多肉植物）',
          '礼品包装盒',
          '丝带装饰'
        ],
        steps: [
          '选择质量好的钢笔或签字笔，确保书写流畅',
          '购买护嗓茶包，帮助老师保护嗓子',
          '挑选实用的笔记本，可选择有励志语句的款式',
          '准备温和的护手霜，呵护老师因粉笔而干燥的双手',
          '写一张真诚的感谢卡片，表达对老师的感激',
          '选择易养护的小绿植，为办公室增添生机',
          '将所有物品精心包装，体现对老师的尊重'
        ],
        tips: [
          '选择中性色彩的文具，适合各年龄段老师使用',
          '护嗓茶要选择天然无添加的产品',
          '感谢卡片内容要真诚，可以提及具体的感谢事例',
          '绿植要选择好养活的品种，避免给老师增加负担'
        ],
        precautions: [
          '避免选择过于昂贵的礼品，以免给老师造成负担',
          '确认学校是否有收礼规定，遵守相关制度',
          '礼品要实用为主，避免华而不实的装饰品'
        ],
        giftWrapIdeas: [
          '使用简洁大方的包装纸，如米色或浅蓝色',
          '在包装上贴上"感谢老师"的标签',
          '用深色丝带装饰，显得庄重得体'
        ],
        presentationTips: [
          '选择合适的时机赠送，如教师节当天或课后',
          '可以代表全班同学一起赠送，增加意义',
          '简单说明每件礼品的用途和寓意',
          '表达感谢时要真诚，避免过于正式'
        ],
        isRecommended: false
      },
      {
        id: '7',
        title: '给同事的友谊礼品',
        description: '增进同事关系的小礼物',
        detailedDescription: '为办公室同事准备的贴心小礼物，包含实用的办公用品、健康零食和舒缓疲劳的小物件。这些礼物既不会给对方造成负担，又能在日常工作中体现关怀，有助于建立良好的同事关系。',
        tags: [RecipientType.COLLEAGUE, OccasionType.JUST_BECAUSE, GiftType.DAILY_ITEMS],
        budgetRange: { min: 50, max: 150, label: '50-150元' },
        images: [$r('app.media.friendship_gift_for_colleague')],
        targetAudience: ['同事'],
        occasions: ['日常'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '精美马克杯或保温杯',
          '优质咖啡包或茶包',
          '护眼贴或眼罩',
          '健康坚果零食',
          '可爱便签纸',
          '桌面小绿植',
          '简约包装袋',
          '小卡片'
        ],
        steps: [
          '选择实用且不过于私人的马克杯或保温杯',
          '搭配优质的咖啡包或茶包，适合办公室饮用',
          '准备护眼贴，帮助缓解长时间看电脑的疲劳',
          '选择健康的坚果零食，作为工作间隙的小点心',
          '加入可爱的便签纸，增加办公趣味',
          '选择小型易养的绿植，美化办公环境',
          '用简约的包装袋装好，写上友好的小卡片'
        ],
        tips: [
          '选择中性设计的物品，适合各种性格的同事',
          '零食要选择包装精美、保质期长的产品',
          '绿植要选择不需要频繁浇水的品种',
          '卡片内容要轻松友好，避免过于正式'
        ],
        precautions: [
          '了解同事的饮食习惯，避免过敏食物',
          '礼物价值要适中，不要让对方有压力',
          '选择办公室适用的物品，避免过于私人'
        ],
        giftWrapIdeas: [
          '使用简洁的牛皮纸袋或白色包装袋',
          '用彩色丝带简单装饰',
          '贴上"工作愉快"或"友谊长存"的小标签'
        ],
        presentationTips: [
          '选择轻松的时机赠送，如午休时间',
          '简单说明是想和大家分享好东西',
          '不要在正式会议或忙碌时打扰',
          '保持轻松愉快的态度'
        ],
        isRecommended: false
      },
      {
        id: '8',
        title: '给孩子的成长礼物',
        description: '陪伴孩子成长的礼品',
        detailedDescription: '为孩子精心挑选的成长礼物，包含益智玩具、启发创意的手工材料和有教育意义的图书。这些礼物不仅能带给孩子快乐，更能在玩乐中促进智力发展，培养动手能力和想象力，是陪伴孩子健康成长的好伙伴。',
        tags: [RecipientType.CHILD, OccasionType.BIRTHDAY, GiftType.CREATIVE_NOVEL],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [$r('app.media.growth_gift_for_child')],
        targetAudience: ['孩子'],
        occasions: ['生日'],
        interests: ['学习'],
        giftType: '体验之旅',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '益智拼图或积木套装',
          '彩色画笔和画纸',
          '儿童科普图书',
          '手工制作材料包',
          '小型实验器材',
          '成长记录册',
          '彩色包装纸',
          '可爱贴纸'
        ],
        steps: [
          '根据孩子年龄选择合适难度的益智玩具',
          '准备丰富的绘画材料，激发艺术天赋',
          '挑选适合年龄段的科普读物，培养求知欲',
          '选择安全的手工材料，锻炼动手能力',
          '准备简单的科学实验器材，满足好奇心',
          '制作成长记录册，记录孩子的进步',
          '用孩子喜欢的卡通图案包装礼物'
        ],
        tips: [
          '选择符合孩子兴趣爱好的礼物类型',
          '确保所有材料都是安全无毒的',
          '可以和孩子一起使用，增进亲子关系',
          '在成长册中写下对孩子的祝福和期望'
        ],
        precautions: [
          '检查玩具是否有3C认证，确保安全',
          '避免有小零件的玩具，防止误食',
          '选择适合孩子年龄的难度，避免挫败感'
        ],
        giftWrapIdeas: [
          '使用色彩鲜艳的包装纸',
          '贴上孩子喜欢的卡通贴纸',
          '用彩色丝带打蝴蝶结'
        ],
        presentationTips: [
          '在孩子精神状态好的时候赠送',
          '可以设计小游戏来揭晓礼物',
          '陪伴孩子一起探索新礼物',
          '鼓励孩子分享使用感受'
        ],
        isRecommended: true
      },
      {
        id: '9',
        title: '给长辈的孝心礼',
        description: '表达孝心的传统礼品',
        detailedDescription: '为长辈精心准备的孝心礼物，包含养生保健品、舒适的生活用品和传统文化元素。这些礼物既体现了对长辈身体健康的关心，又传承了尊老敬老的传统美德，让长辈感受到晚辈的孝心和关爱。',
        tags: [RecipientType.ELDER_RELATIVE, OccasionType.SPRING_FESTIVAL, GiftType.DAILY_ITEMS],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        images: [$r('app.media.filial_gift_for_elder')],
        targetAudience: ['长辈'],
        occasions: ['节日'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '养生茶叶或保健品',
          '舒适的保暖用品',
          '按摩器具（颈椎、足部）',
          '传统文化书籍或字画',
          '高品质羊毛围巾',
          '电子血压计或体温计',
          '精美礼盒包装',
          '祝福卡片'
        ],
        steps: [
          '了解长辈的身体状况和喜好偏向',
          '选择适合的养生茶叶或经过认证的保健品',
          '挑选质量好的保暖用品，如羊毛围巾或保暖内衣',
          '选择操作简单的按摩器具，缓解长辈疲劳',
          '准备传统文化相关的书籍或装饰品',
          '配备实用的健康监测设备',
          '用传统红色或金色包装，寓意吉祥',
          '写上表达孝心的祝福卡片'
        ],
        tips: [
          '选择知名品牌的保健品，确保质量安全',
          '保暖用品要选择天然材质，舒适透气',
          '按摩器具要操作简单，适合长辈使用',
          '可以选择长辈年轻时喜欢的文化元素'
        ],
        precautions: [
          '保健品要查看成分，避免与长辈正在服用的药物冲突',
          '电器类产品要选择操作简单、安全性高的',
          '了解长辈的过敏史，避免不适合的材质'
        ],
        giftWrapIdeas: [
          '使用传统的红色或金色包装纸',
          '配上中国结或福字装饰',
          '用丝带打成传统的蝴蝶结'
        ],
        presentationTips: [
          '选择家庭聚会或节日当天赠送',
          '亲自说明每件礼品的用途和关怀',
          '可以全家一起参与赠送仪式',
          '表达对长辈健康长寿的祝愿'
        ],
        isRecommended: true
      },
      {
        id: '10',
        title: '给宠物的爱心礼物',
        description: '让宠物开心的小惊喜',
        detailedDescription: '为心爱的宠物准备的贴心礼物，包含舒适的用品、健康的零食和有趣的玩具。这些礼物能够提升宠物的生活品质，增进主人与宠物之间的感情，让毛孩子感受到满满的爱意和关怀。',
        tags: [RecipientType.OTHER, GiftType.DAILY_ITEMS],
        budgetRange: { min: 50, max: 150, label: '50-150元' },
        images: [$r('app.media.loving_gift_for_pet')],
        targetAudience: ['宠物'],
        occasions: [],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '舒适的宠物窝或垫子',
          '健康的宠物零食',
          '互动玩具（球类、绳结等）',
          '宠物专用洗护用品',
          '可爱的宠物服装',
          '宠物食具（碗、水壶）',
          '宠物美容工具',
          '宠物身份牌'
        ],
        steps: [
          '根据宠物种类和大小选择合适的用品',
          '挑选宠物喜欢的健康零食，注意成分安全',
          '选择适合宠物年龄和活跃度的玩具',
          '准备温和的宠物专用洗护产品',
          '如果宠物适应，可以选择可爱的小衣服',
          '更换或添置新的食具，保持卫生',
          '准备美容工具，帮助宠物保持清洁',
          '制作个性化的身份牌，确保安全'
        ],
        tips: [
          '选择无毒无害的材质，确保宠物安全',
          '零食要适量，避免影响正常饮食',
          '玩具大小要合适，避免误食风险',
          '观察宠物的喜好，选择它们感兴趣的类型'
        ],
        precautions: [
          '检查所有用品是否有尖锐边缘或小零件',
          '新食物要逐渐添加，观察是否过敏',
          '服装要确保不会限制宠物活动',
          '定期检查玩具磨损情况，及时更换'
        ],
        giftWrapIdeas: [
          '使用宠物主题的包装纸',
          '贴上可爱的动物贴纸',
          '用彩色丝带装饰'
        ],
        presentationTips: [
          '在宠物精神状态好的时候介绍新物品',
          '让宠物先闻一闻，熟悉新物品',
          '陪伴宠物一起试用新玩具',
          '用温柔的声音鼓励宠物接受新礼物'
        ],
        isRecommended: false
      },
      
      // 按场合送 - 5条
      {
        id: '11',
        title: '生日派对策划',
        description: '难忘的生日庆祝活动',
        detailedDescription: '为朋友精心策划的生日派对，包含主题装饰、生日蛋糕、聚会游戏和纪念品制作。通过周密的策划和用心的准备，为寿星创造一个难忘的生日回忆，让所有参与的朋友都能感受到温馨和快乐。',
        tags: [OccasionType.BIRTHDAY, GiftType.EXPERIENCE, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 300, max: 800, label: '300-800元' },
        images: [$r('app.media.birthday_party_planning')],
        targetAudience: ['朋友'],
        occasions: ['生日'],
        interests: [],
        giftType: '体验之旅',
        difficulty: 'hard',
        timeRequired: '1天',
        materials: [
          '主题装饰用品（气球、拉花、横幅）',
          '定制生日蛋糕',
          '聚会游戏道具',
          '音响设备',
          '拍照背景墙材料',
          '小礼品和纪念品',
          '餐具和饮料',
          '生日帽和生日徽章'
        ],
        steps: [
          '确定派对主题和参与人数，选择合适的场地',
          '制作邀请函，提前一周邀请朋友参加',
          '采购装饰用品和聚会所需物品',
          '布置派对现场，营造生日氛围',
          '准备聚会游戏和互动环节',
          '安排拍照环节，记录美好时刻',
          '准备惊喜环节，如生日祝福视频',
          '清理现场，整理照片和视频分享给大家'
        ],
        tips: [
          '提前了解寿星的喜好，选择合适的主题',
          '准备一些小游戏增加互动性',
          '安排专人负责拍照记录',
          '准备一些备用活动以防冷场'
        ],
        precautions: [
          '确认场地的使用时间和规定',
          '注意音量控制，避免影响邻居',
          '准备一些过敏友好的食物选择'
        ],
        giftWrapIdeas: [
          '制作主题横幅和标语',
          '用彩色气球装饰空间',
          '设置专门的礼物展示区'
        ],
        presentationTips: [
          '在寿星到达前完成所有布置',
          '安排朋友们躲起来准备惊喜',
          '用温馨的话语开场，营造感动氛围',
          '鼓励每个人分享对寿星的祝福'
        ],
        isRecommended: true
      },
      {
        id: '12',
        title: '毕业纪念册制作',
        description: '记录美好校园时光',
        detailedDescription: '为即将毕业的同学制作一本珍贵的纪念册，收集同窗好友的照片、留言和美好回忆。通过精心的设计和制作，将校园生活的点点滴滴永久保存，成为友谊和青春的见证。',
        tags: [OccasionType.GRADUATION, GiftType.DIY_HANDMADE, BudgetRangeEnum.RANGE_100_200],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [$r('app.media.record_beautiful_campus_time')],
        targetAudience: ['朋友'],
        occasions: ['毕业'],
        interests: ['手工爱好者'],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '5小时',
        materials: [
          '精装相册本',
          '同学们的照片',
          '彩色打印纸',
          '装饰贴纸和胶带',
          '彩色笔和马克笔',
          '剪刀和胶水',
          '校园地图和纪念品',
          '透明保护膜'
        ],
        steps: [
          '收集同学们的照片和联系方式',
          '设计纪念册的整体布局和主题',
          '邀请同学们写下毕业留言和祝福',
          '按时间顺序或主题分类整理照片',
          '制作每一页的内容，添加装饰元素',
          '为每位同学制作专属页面',
          '添加校园地图和重要时间节点',
          '装订成册并添加保护膜'
        ],
        tips: [
          '提前收集照片，确保每个人都有',
          '设计统一的页面风格，保持美观',
          '留出足够空间给同学们写留言',
          '可以加入一些校园内部的小笑话'
        ],
        precautions: [
          '确保照片质量清晰，避免模糊',
          '使用无酸纸张，保证长期保存',
          '小心处理照片，避免损坏'
        ],
        giftWrapIdeas: [
          '用学校主题色的包装纸',
          '在封面贴上班级合影',
          '用金色丝带装饰，象征珍贵友谊'
        ],
        presentationTips: [
          '在毕业典礼或聚会时赠送',
          '邀请所有同学一起翻看',
          '分享制作过程中的有趣故事',
          '鼓励大家保持联系，延续友谊'
        ],
        isRecommended: true
      },
      {
        id: '13',
        title: '结婚祝福礼品',
        description: '新人的美好祝愿',
        detailedDescription: '为新婚夫妇精心挑选的祝福礼品套装，包含实用的家居用品、浪漫的装饰品和寓意美好的纪念品。每一件礼品都承载着对新人幸福生活的美好祝愿，希望他们的婚姻生活甜蜜美满。',
        tags: [OccasionType.WEDDING, GiftType.DAILY_ITEMS, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        images: [$r('app.media.wedding_blessing_gift')],
        targetAudience: ['朋友'],
        occasions: ['婚礼'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '情侣餐具套装',
          '香薰蜡烛',
          '结婚纪念相框',
          '高档床上用品',
          '红酒和酒杯套装',
          '装饰花瓶',
          '祝福贺卡',
          '精美包装盒'
        ],
        steps: [
          '了解新人的喜好和家居风格',
          '选择实用且有纪念意义的礼品',
          '挑选高品质的情侣用品',
          '准备浪漫的装饰元素',
          '选择寓意美好的纪念品',
          '精心包装所有礼品',
          '写下真挚的祝福话语',
          '在婚礼当天或之前送达'
        ],
        tips: [
          '选择经典款式，不易过时',
          '考虑新人的实际需求',
          '在贺卡上写下对新人的祝福',
          '可以选择可以刻字的纪念品'
        ],
        precautions: [
          '确认新人的家居风格偏好',
          '避免选择过于个性化的物品',
          '注意礼品的实用性和质量'
        ],
        giftWrapIdeas: [
          '使用红色或金色的喜庆包装',
          '在包装上贴上"新婚快乐"的标签',
          '用红色丝带打中国结，寓意美好'
        ],
        presentationTips: [
          '在婚礼仪式前或婚宴时赠送',
          '亲自向新人表达祝福',
          '可以在婚礼上分享选择礼品的用心',
          '祝愿新人百年好合，白头偕老'
        ],
        isRecommended: true
      },
      {
        id: '14',
        title: '节日庆祝活动',
        description: '传统节日的庆祝方式',
        detailedDescription: '为家人策划的传统节日庆祝活动，包含节日美食制作、传统游戏和家庭聚会。通过传承传统文化和增进家庭感情，让每个节日都充满温馨和意义，创造美好的家庭回忆。',
        tags: [OccasionType.SPRING_FESTIVAL, GiftType.FOOD_BEVERAGE, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 150, max: 400, label: '150-400元' },
        images: [$r('app.media.holiday_celebration_activity')],
        targetAudience: ['家人'],
        occasions: ['节日'],
        interests: ['美食家'],
        giftType: '美食礼品',
        difficulty: 'medium',
        timeRequired: '3小时',
        materials: [
          '节日传统食材',
          '装饰用品（灯笼、对联）',
          '传统游戏道具',
          '节日音乐播放设备',
          '拍照道具',
          '节日礼品袋',
          '传统服装（可选）',
          '节日贺卡'
        ],
        steps: [
          '提前规划节日活动安排',
          '采购节日所需的食材和用品',
          '布置节日氛围，营造传统感',
          '准备传统节日美食',
          '安排家庭聚会和游戏活动',
          '拍照记录节日时光',
          '分享节日故事和传统文化',
          '整理照片，制作节日纪念册'
        ],
        tips: [
          '提前了解节日的传统习俗',
          '让每个家庭成员都参与其中',
          '准备一些传统小游戏增加乐趣',
          '可以邀请亲戚朋友一起庆祝'
        ],
        precautions: [
          '注意食品安全和卫生',
          '考虑家庭成员的饮食禁忌',
          '确保活动安全，特别是有老人小孩时'
        ],
        giftWrapIdeas: [
          '使用传统节日色彩的装饰',
          '制作节日主题的装饰品',
          '用传统包装方式包装礼品'
        ],
        presentationTips: [
          '在节日当天举行庆祝活动',
          '让长辈讲述节日的传统故事',
          '鼓励年轻一代了解传统文化',
          '创造温馨和谐的家庭氛围'
        ],
        isRecommended: true
      },
      {
        id: '15',
        title: '升职庆祝礼品',
        description: '庆祝职业成就的礼物',
        detailedDescription: '为朋友升职成功精心准备的庆祝礼品，包含高档办公用品、庆祝晚餐和励志书籍。通过这些有意义的礼物，表达对朋友职业成就的祝贺和对未来发展的美好祝愿。',
        tags: [OccasionType.PROMOTION, GiftType.EXPERIENCE, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 200, max: 600, label: '200-600元' },
        images: [$r('app.media.promotion_celebration_gift')],
        targetAudience: ['朋友'],
        occasions: ['升职'],
        interests: [],
        giftType: '体验之旅',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '高档钢笔套装',
          '商务笔记本',
          '办公桌装饰品',
          '励志书籍',
          '庆祝香槟',
          '精美名片夹',
          '办公室绿植',
          '祝贺贺卡'
        ],
        steps: [
          '了解朋友的新职位和工作需求',
          '选择实用的高档办公用品',
          '挑选适合的励志或职场书籍',
          '准备庆祝用的香槟或红酒',
          '选择办公室装饰用品',
          '精心包装所有礼品',
          '写下祝贺和鼓励的话语',
          '安排庆祝聚餐或活动'
        ],
        tips: [
          '选择实用且有纪念意义的办公用品',
          '考虑朋友的职业特点选择礼品',
          '在贺卡上表达对朋友的祝贺',
          '可以组织朋友们一起庆祝'
        ],
        precautions: [
          '确认朋友的办公环境和需求',
          '选择适合商务场合的礼品',
          '注意礼品的品质和实用性'
        ],
        giftWrapIdeas: [
          '使用商务风格的包装',
          '在包装上贴上"升职快乐"的标签',
          '用金色丝带装饰，象征成功'
        ],
        presentationTips: [
          '在朋友升职后及时送上祝贺',
          '可以在庆祝聚会上赠送',
          '表达对朋友能力的认可',
          '祝愿朋友在新职位上取得更大成就'
        ],
        isRecommended: false
      },
      
      // 按预算送 - 5条
      {
        id: '16',
        title: '经济实惠小礼品',
        description: '50元以下的贴心礼物',
        detailedDescription: '用有限的预算制作充满心意的小礼品，包含手工制作的书签、个性化钥匙扣和温馨小卡片。虽然成本不高，但每一件都承载着真挚的友谊和用心的制作，证明礼物的价值不在于价格而在于心意。',
        tags: [BudgetRangeEnum.UNDER_50, GiftType.DIY_HANDMADE, RecipientType.FRIEND],
        budgetRange: { min: 20, max: 50, label: '20-50元' },
        images: [$r('app.media.affordable_small_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '彩色卡纸',
          '装饰贴纸',
          '彩色笔和马克笔',
          '钥匙扣配件',
          '丝带和绳子',
          '小装饰品（珠子、亮片）',
          '胶水和双面胶',
          '透明保护膜'
        ],
        steps: [
          '设计礼品的整体风格和主题',
          '制作个性化书签，加上朋友喜欢的元素',
          '制作钥匙扣，可以是朋友的名字或特殊符号',
          '写一张温馨的小卡片，表达友谊',
          '用彩色笔装饰所有物品',
          '添加保护膜，确保耐用性',
          '用丝带包装，增加精美感',
          '准备一个小袋子装所有礼品'
        ],
        tips: [
          '选择朋友喜欢的颜色作为主色调',
          '在书签上写上励志或友谊的话语',
          '钥匙扣可以做成朋友的生肖或星座',
          '用心写卡片，表达真挚的友谊'
        ],
        precautions: [
          '确保所有材料安全无毒',
          '小装饰品要粘贴牢固，避免脱落',
          '书签大小要适合放在书中'
        ],
        giftWrapIdeas: [
          '用彩色纸袋装所有小礼品',
          '在袋子上贴上手绘的小图案',
          '用彩色丝带扎成蝴蝶结'
        ],
        presentationTips: [
          '在朋友心情好的时候赠送',
          '解释每个小礼品的制作用意',
          '强调虽然简单但充满心意',
          '鼓励朋友日常使用这些小物品'
        ],
        isRecommended: true
      },
      {
        id: '17',
        title: '中等预算礼品',
        description: '100-200元的精选礼物',
        detailedDescription: '在合理预算范围内精心挑选的实用礼品套装，包含护肤品、文具用品和小装饰品。这个价位的礼物既有实用价值又不会给对方造成负担，是日常送礼的理想选择。',
        tags: [BudgetRangeEnum.RANGE_100_200, GiftType.DAILY_ITEMS, RecipientType.FRIEND],
        budgetRange: { min: 100, max: 200, label: '100-200元' },
        images: [$r('app.media.medium_budget_gift')],
        targetAudience: ['朋友'],
        occasions: ['生日'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '护手霜或面膜套装',
          '精美笔记本',
          '高品质钢笔',
          '小型装饰摆件',
          '香薰蜡烛',
          '保温杯',
          '精美包装盒',
          '祝福贺卡'
        ],
        steps: [
          '了解朋友的日常需求和喜好',
          '选择实用的护肤或日用品',
          '挑选高品质的文具用品',
          '选择适合的小装饰品',
          '确保所有物品质量可靠',
          '精心搭配礼品组合',
          '用精美包装盒包装',
          '写上温馨的祝福话语'
        ],
        tips: [
          '选择知名品牌的产品，确保质量',
          '考虑朋友的肤质选择护肤品',
          '文具选择简约实用的款式',
          '装饰品要符合朋友的审美'
        ],
        precautions: [
          '确认朋友对护肤品成分无过敏',
          '选择适合的香薰味道',
          '保温杯要选择安全材质'
        ],
        giftWrapIdeas: [
          '使用优雅的包装盒',
          '在盒子上贴上精美的标签',
          '用丝带装饰，增加仪式感'
        ],
        presentationTips: [
          '在朋友生日当天或聚会时赠送',
          '介绍每个物品的用途和选择理由',
          '表达对朋友的关心和祝福',
          '鼓励朋友在日常生活中使用'
        ],
        isRecommended: true
      },
      {
        id: '18',
        title: '高端定制礼品',
        description: '500元以上的奢华礼物',
        detailedDescription: '为特殊的人准备的高端定制礼品，包含定制首饰、高档护肤品和个性化纪念品。这类礼物通常用于重要的纪念日或特殊场合，体现了对收礼人的重视和深厚感情。',
        tags: [BudgetRangeEnum.RANGE_500_1000, GiftType.JEWELRY, RecipientType.GIRLFRIEND],
        budgetRange: { min: 500, max: 1000, label: '500-1000元' },
        images: [$r('app.media.luxury_custom_gift')],
        targetAudience: ['恋人'],
        occasions: ['纪念日'],
        interests: [],
        giftType: '精美饰品',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '定制首饰（项链、手链或戒指）',
          '高档护肤品套装',
          '个性化相框',
          '定制香水',
          '奢华包装盒',
          '丝绸包装布',
          '定制贺卡',
          '鲜花装饰'
        ],
        steps: [
          '提前了解对方的喜好和尺寸',
          '选择信誉良好的定制商家',
          '设计个性化的首饰款式',
          '选择高品质的护肤品牌',
          '定制专属的相框和贺卡',
          '安排精美的包装服务',
          '选择合适的赠送时机',
          '准备浪漫的赠送仪式'
        ],
        tips: [
          '提前1-2周预订定制商品',
          '选择经典款式，不易过时',
          '在首饰上刻上特殊的日期或话语',
          '护肤品要选择适合的肤质类型'
        ],
        precautions: [
          '确认首饰的材质和过敏情况',
          '保留购买凭证和保修卡',
          '选择正规渠道购买，确保品质'
        ],
        giftWrapIdeas: [
          '使用奢华的包装盒和丝绸布',
          '在包装上加上定制的标签',
          '用鲜花和丝带装饰'
        ],
        presentationTips: [
          '选择特殊的日子或浪漫的场所',
          '营造仪式感，表达重视',
          '亲自为对方佩戴首饰',
          '表达对这段感情的珍视'
        ],
        isRecommended: true
      },
      {
        id: '19',
        title: '学生党友好礼品',
        description: '适合学生预算的礼物',
        detailedDescription: '专为学生群体设计的经济实用礼品，包含学习用品、生活小物和手工制作元素。在有限的预算内，通过巧妙的搭配和用心的制作，创造出既实用又有纪念意义的礼物。',
        tags: [BudgetRangeEnum.RANGE_50_100, GiftType.DIY_HANDMADE, RecipientType.FRIEND],
        budgetRange: { min: 30, max: 80, label: '30-80元' },
        images: [$r('app.media.student_friendly_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '2小时',
        materials: [
          '实用文具（笔、本子、便利贴）',
          '手工制作材料',
          '小型绿植或多肉',
          '个性化书签',
          '学习计划表模板',
          '小零食或茶包',
          '装饰贴纸',
          '简约包装袋'
        ],
        steps: [
          '了解朋友的学习需求和喜好',
          '选择实用的学习文具',
          '制作个性化的学习计划表',
          '手工制作专属书签',
          '选择适合宿舍的小绿植',
          '搭配一些健康小零食',
          '用心包装所有物品',
          '写一张鼓励学习的小卡片'
        ],
        tips: [
          '选择性价比高的文具品牌',
          '绿植要选择好养活的品种',
          '零食选择健康营养的类型',
          '在卡片上写上学习鼓励的话语'
        ],
        precautions: [
          '确认宿舍是否允许养植物',
          '选择无香味的文具，避免过敏',
          '零食要注意保质期'
        ],
        giftWrapIdeas: [
          '使用简约的牛皮纸袋',
          '在袋子上画上手绘图案',
          '用麻绳扎成简单的装饰'
        ],
        presentationTips: [
          '在期末考试前或新学期开始时赠送',
          '鼓励朋友好好学习',
          '分享一些学习经验和方法',
          '约定一起努力学习的目标'
        ],
        isRecommended: false
      },
      {
        id: '20',
        title: 'DIY手工礼物',
        description: '用心制作的独特礼品',
        detailedDescription: '完全手工制作的独特礼品，包含编织物品、手绘作品和拼贴艺术。这类礼物需要投入大量时间和精力，但正因为独一无二的手工制作，使其具有无法替代的情感价值。',
        tags: [GiftType.DIY_HANDMADE, BudgetRangeEnum.RANGE_50_100, RecipientType.FRIEND],
        budgetRange: { min: 30, max: 100, label: '30-100元' },
        images: [$r('app.media.diy_handmade_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['手工爱好者'],
        giftType: 'DIY手作',
        difficulty: 'hard',
        timeRequired: '6小时',
        materials: [
          '编织毛线或棉线',
          '画布和颜料',
          '拼贴材料（杂志、彩纸）',
          '编织针或钩针',
          '画笔套装',
          '胶水和剪刀',
          '装饰珠子和亮片',
          '保护喷雾'
        ],
        steps: [
          '选择要制作的手工项目类型',
          '准备所有必需的材料和工具',
          '设计作品的整体风格和色彩',
          '开始制作主体部分（编织/绘画/拼贴）',
          '添加细节装饰和个性化元素',
          '完善作品并进行最后修饰',
          '使用保护喷雾保护作品',
          '制作配套的说明卡片'
        ],
        tips: [
          '选择自己擅长的手工技能',
          '提前练习复杂的技巧',
          '准备备用材料以防出错',
          '记录制作过程，可以分享给朋友'
        ],
        precautions: [
          '使用工具时注意安全',
          '选择无毒的材料，特别是颜料',
          '保持工作环境整洁'
        ],
        giftWrapIdeas: [
          '用手工纸包装，保持手作风格',
          '在包装上加上制作过程的小照片',
          '用天然材料如麻绳装饰'
        ],
        presentationTips: [
          '亲自交付，分享制作的故事',
          '解释作品中的特殊含义',
          '教朋友如何保养手工作品',
          '表达制作过程中对友谊的思考'
        ],
        isRecommended: true
      },
      
      // 按类型送 - 5条
      {
        id: '21',
        title: '实用型生活好物',
        description: '提升生活品质的实用礼品',
        detailedDescription: '精选的实用生活好物，包含高品质的日用品、便民小工具和生活提升用品。这类礼物注重实用性和品质，能够在日常生活中发挥实际作用，提升收礼人的生活品质和便利性。',
        tags: [GiftType.DAILY_ITEMS, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 80, max: 250, label: '80-250元' },
        images: [$r('app.media.practical_life_goods')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '高品质保温杯',
          '多功能收纳盒',
          '便携式充电宝',
          '舒适眼罩',
          '实用小夜灯',
          '优质毛巾套装',
          '精美包装盒',
          '使用说明卡'
        ],
        steps: [
          '了解朋友的日常生活习惯',
          '选择高品质的日用品品牌',
          '挑选多功能的实用工具',
          '确保所有物品质量可靠',
          '搭配不同功能的生活用品',
          '检查产品的安全认证',
          '精心包装所有物品',
          '准备详细的使用指南'
        ],
        tips: [
          '选择知名品牌确保质量',
          '考虑朋友的生活场景和需求',
          '优先选择多功能的产品',
          '注意产品的保修和售后服务'
        ],
        precautions: [
          '确认电子产品的安全认证',
          '选择适合的尺寸和规格',
          '注意材质的安全性和环保性'
        ],
        giftWrapIdeas: [
          '使用简约实用的包装风格',
          '在包装上标注产品的主要功能',
          '用环保材料包装体现品质感'
        ],
        presentationTips: [
          '介绍每个物品的实用功能',
          '分享选择这些物品的考虑',
          '鼓励朋友在日常生活中使用',
          '询问使用后的感受和建议'
        ],
        isRecommended: true
      },
      {
        id: '22',
        title: '创意趣味礼品',
        description: '充满创意和乐趣的礼物',
        detailedDescription: '富有创意和趣味性的礼品，包含互动游戏、创意装饰和有趣的小物件。这类礼物能够带来欢乐和惊喜，激发收礼人的创造力和想象力，适合喜欢新奇有趣事物的朋友。',
        tags: [GiftType.DIY_HANDMADE, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        images: [$r('app.media.creative_fun_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '3小时',
        materials: [
          '创意拼图或积木',
          '互动桌游',
          'DIY手工套装',
          '趣味装饰品',
          '创意文具',
          '有趣的小玩具',
          '彩色包装材料',
          '游戏说明书'
        ],
        steps: [
          '了解朋友的兴趣爱好和性格',
          '选择适合的创意游戏或玩具',
          '准备DIY手工制作材料',
          '设计有趣的互动环节',
          '制作个性化的装饰元素',
          '测试所有游戏和玩具的功能',
          '用创意方式包装礼品',
          '准备详细的使用和游戏说明'
        ],
        tips: [
          '选择适合朋友年龄和兴趣的物品',
          '确保游戏规则简单易懂',
          '添加个人定制元素增加特色',
          '考虑多人互动的可能性'
        ],
        precautions: [
          '确保所有小零件的安全性',
          '检查材料是否无毒环保',
          '避免过于复杂的操作说明'
        ],
        giftWrapIdeas: [
          '使用鲜艳的色彩和有趣的图案',
          '在包装上加上小游戏或谜题',
          '用创意材料制作立体装饰'
        ],
        presentationTips: [
          '现场演示游戏的玩法',
          '邀请朋友一起体验互动环节',
          '分享创意设计的灵感来源',
          '鼓励朋友发挥创造力'
        ],
        isRecommended: true
      },
      {
        id: '23',
        title: '纪念收藏类礼品',
        description: '具有纪念价值的收藏品',
        detailedDescription: '具有特殊纪念意义和收藏价值的礼品，包含限量版物品、个性化定制品和具有历史意义的纪念品。这类礼物承载着深厚的情感价值，适合在重要的纪念日或里程碑时刻赠送。',
        tags: [GiftType.JEWELRY, BudgetRangeEnum.RANGE_200_500, OccasionType.ANNIVERSARY],
        budgetRange: { min: 100, max: 400, label: '100-400元' },
        images: [$r('app.media.commemorative_collectible_gift')],
        targetAudience: ['朋友'],
        occasions: ['纪念日'],
        interests: [],
        giftType: '精美饰品',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '限量版纪念品',
          '个性化定制饰品',
          '纪念币或徽章',
          '定制相框',
          '收藏盒或展示架',
          '证书或说明卡',
          '高档包装盒',
          '保护材料'
        ],
        steps: [
          '确定纪念的特殊意义和主题',
          '选择有收藏价值的物品',
          '定制个性化的纪念元素',
          '准备相关的证书或说明',
          '选择合适的收藏和展示方式',
          '确保物品的保存条件',
          '用高档材料精心包装',
          '准备详细的收藏指南'
        ],
        tips: [
          '选择有升值潜力的收藏品',
          '确保物品的真实性和品质',
          '添加个人定制元素增加独特性',
          '考虑收藏品的保存和展示需求'
        ],
        precautions: [
          '验证收藏品的真伪和来源',
          '了解收藏品的保养要求',
          '选择信誉良好的商家购买'
        ],
        giftWrapIdeas: [
          '使用高档的收藏盒包装',
          '添加防护材料保护物品',
          '在包装上标注收藏信息'
        ],
        presentationTips: [
          '在特殊的纪念日赠送',
          '详细介绍收藏品的价值和意义',
          '分享选择这件收藏品的原因',
          '提供收藏和保养的建议'
        ],
        isRecommended: false
      },
      {
        id: '24',
        title: '体验服务类礼品',
        description: '难忘的体验服务和体验',
        detailedDescription: '提供难忘体验和服务的礼品，包含SPA护理、美食体验、娱乐活动和学习课程。这类礼物注重过程和感受，能够创造美好的回忆，适合喜欢新体验和享受生活的朋友。',
        tags: [GiftType.EXPERIENCE, BudgetRangeEnum.RANGE_200_500, OccasionType.ANNIVERSARY],
        budgetRange: { min: 200, max: 600, label: '200-600元' },
        images: [$r('app.media.experience_service_gift')],
        targetAudience: ['朋友'],
        occasions: ['纪念日'],
        interests: [],
        giftType: '体验之旅',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '体验券或预约凭证',
          '详细的体验说明',
          '交通指南',
          '注意事项清单',
          '推荐搭配服务',
          '精美的体验手册',
          '纪念品或小礼品',
          '体验后的反馈卡'
        ],
        steps: [
          '了解朋友的兴趣和时间安排',
          '选择合适的体验项目和服务商',
          '预约体验时间和确认细节',
          '准备详细的体验指南',
          '安排交通和其他配套服务',
          '准备体验过程中的小惊喜',
          '制作精美的体验券和说明',
          '跟进体验后的感受和反馈'
        ],
        tips: [
          '选择口碑好的服务商',
          '确认体验项目的时间灵活性',
          '考虑朋友的身体状况和偏好',
          '准备备选方案以防意外'
        ],
        precautions: [
          '确认服务商的资质和安全保障',
          '了解取消和改期的政策',
          '确认体验项目的适用人群'
        ],
        giftWrapIdeas: [
          '制作精美的体验券包装',
          '添加体验相关的小道具',
          '用主题色彩设计包装'
        ],
        presentationTips: [
          '详细介绍体验的内容和亮点',
          '分享选择这个体验的原因',
          '提供贴心的准备建议',
          '约定一起分享体验后的感受'
        ],
        isRecommended: true
      },
      {
        id: '25',
        title: '美容护肤礼品',
        description: '呵护肌肤的美容产品',
        detailedDescription: '精心挑选的美容护肤产品，包含面膜、精华、乳液和护肤工具。这类礼物体现了对女性朋友美丽的关注和呵护，适合注重护肤保养的朋友，能够在日常护理中感受到你的贴心关怀。',
        tags: [GiftType.BEAUTY_SKINCARE, BudgetRangeEnum.RANGE_200_500, RecipientType.FRIEND],
        budgetRange: { min: 150, max: 400, label: '150-400元' },
        images: [$r('app.media.beauty_skincare_gift')],
        targetAudience: ['女性朋友'],
        occasions: ['生日'],
        interests: ['美容护肤'],
        giftType: '美容护肤',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '面膜或面膜套装',
          '精华液或精华素',
          '保湿乳液或面霜',
          '洁面产品',
          '护肤工具（美容仪、洁面刷等）',
          '眼霜或眼部护理产品',
          '防晒霜',
          '精美的化妆包'
        ],
        steps: [
          '了解朋友的肌肤类型和需求',
          '选择适合的护肤品牌和产品',
          '搭配不同功效的护肤产品',
          '准备护肤工具或配件',
          '制作护肤使用指南',
          '选择精美的包装盒',
          '添加个性化的护肤建议',
          '在合适的时机赠送'
        ],
        tips: [
          '选择知名品牌和口碑好的产品',
          '考虑朋友的肌肤敏感性',
          '搭配不同步骤的护肤产品',
          '添加护肤工具增加实用性'
        ],
        precautions: [
          '确认产品的保质期和生产日期',
          '了解朋友是否有过敏史',
          '选择适合朋友肌肤类型的产品'
        ],
        giftWrapIdeas: [
          '使用粉色或白色的精美包装',
          '添加蝴蝶结和花朵装饰',
          '用透明盒子展示产品'
        ],
        presentationTips: [
          '介绍每个产品的功效和使用方法',
          '分享护肤心得和建议',
          '建议建立护肤routine',
          '约定一起分享使用效果'
        ],
        isRecommended: true
      },
      
      // 按兴趣送 - 5条
      {
        id: '26',
        title: '美食爱好者礼品',
        description: '满足味蕾的美食礼物',
        detailedDescription: '为美食爱好者精心准备的美食礼品，包含特色小食、精品茶叶、咖啡豆和烹饪用具。这类礼物能够满足味蕾的享受，适合热爱美食、喜欢烹饪或品尝各地特色的朋友。',
        tags: [GiftType.FOOD_BEVERAGE, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [$r('app.media.food_lover_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['美食家'],
        giftType: '美食礼品',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '特色零食或小食',
          '精品茶叶或咖啡豆',
          '调味料或香料套装',
          '烹饪工具或餐具',
          '美食制作材料包',
          '特色酱料或蜂蜜',
          '精美的食品包装盒',
          '美食制作说明书'
        ],
        steps: [
          '了解朋友的口味偏好和饮食习惯',
          '选择高品质的美食产品',
          '搭配不同类型的美食组合',
          '准备烹饪工具或餐具',
          '制作美食品尝指南',
          '选择精美的包装和容器',
          '添加个性化的美食推荐',
          '在合适的时机分享美食'
        ],
        tips: [
          '选择有特色和口碑的美食品牌',
          '考虑朋友的饮食禁忌和过敏',
          '搭配不同口味和类型的美食',
          '添加制作工具增加互动性'
        ],
        precautions: [
          '确认食品的保质期和储存条件',
          '了解朋友的饮食限制',
          '选择包装完好的正品食品'
        ],
        giftWrapIdeas: [
          '使用食品级的精美包装盒',
          '添加美食主题的装饰元素',
          '用透明窗口展示美食'
        ],
        presentationTips: [
          '介绍每种美食的特色和来源',
          '分享品尝和制作的建议',
          '约定一起品尝或制作美食',
          '交流美食心得和体验'
        ],
        isRecommended: true
      },
      {
        id: '27',
        title: '运动健身礼品',
        description: '支持健康生活的运动用品',
        detailedDescription: '为运动健身爱好者准备的实用运动用品，包含健身器材、运动服饰、营养补充品和运动配件。这类礼物体现了对朋友健康生活的支持和鼓励，适合热爱运动、注重健身的朋友。',
        tags: [GiftType.SPORTS_FITNESS, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 80, max: 250, label: '80-250元' },
        images: [$r('app.media.sports_fitness_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['运动健身'],
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '健身器材（哑铃、瑜伽垫等）',
          '运动服饰或运动鞋',
          '运动水杯或保温杯',
          '健身手套或护具',
          '运动毛巾',
          '蛋白粉或营养补充品',
          '运动计步器或智能手环',
          '运动背包或收纳袋'
        ],
        steps: [
          '了解朋友的运动类型和健身习惯',
          '选择适合的运动器材或用品',
          '考虑运动服饰的尺码和款式',
          '准备实用的运动配件',
          '制作健身计划或建议',
          '选择运动主题的包装',
          '添加健身励志元素',
          '在运动相关的时机赠送'
        ],
        tips: [
          '选择质量好的运动品牌',
          '考虑朋友的运动水平和需求',
          '搭配不同类型的运动用品',
          '添加个性化的健身建议'
        ],
        precautions: [
          '确认运动用品的质量和安全性',
          '了解朋友的身体状况和运动限制',
          '选择合适的尺码和规格'
        ],
        giftWrapIdeas: [
          '使用运动主题的包装设计',
          '添加活力色彩的装饰',
          '用运动元素进行包装'
        ],
        presentationTips: [
          '介绍运动用品的功能和使用方法',
          '分享健身心得和建议',
          '约定一起运动或健身',
          '鼓励坚持健康的生活方式'
        ],
        isRecommended: true
      },
      {
        id: '28',
        title: '读书爱好者礼品',
        description: '书香气息的文化礼物',
        detailedDescription: '为读书爱好者精心挑选的文化礼品，包含精装书籍、文具用品、阅读配件和书房装饰。这类礼物充满书香气息，适合热爱阅读、喜欢文学或学习的朋友，能够丰富他们的精神世界。',
        tags: [GiftType.BOOKS_STATIONERY, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        images: [$r('app.media.book_lover_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['阅读'],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '精装书籍或经典名著',
          '高质量的笔记本或日记本',
          '精美的书签',
          '阅读灯或台灯',
          '书立或书架',
          '文具套装（钢笔、铅笔等）',
          '读书杯或茶具',
          '书房装饰品'
        ],
        steps: [
          '了解朋友的阅读偏好和兴趣',
          '选择高质量的书籍或文具',
          '搭配实用的阅读配件',
          '准备书房装饰元素',
          '制作阅读推荐清单',
          '选择文艺风格的包装',
          '添加个性化的阅读寄语',
          '在安静的环境中赠送'
        ],
        tips: [
          '选择经典或口碑好的书籍',
          '考虑朋友的阅读水平和兴趣',
          '搭配实用的阅读工具',
          '添加文艺气息的装饰元素'
        ],
        precautions: [
          '确认书籍的版本和印刷质量',
          '了解朋友已有的书籍收藏',
          '选择适合的阅读难度'
        ],
        giftWrapIdeas: [
          '使用书香风格的包装纸',
          '添加文艺元素的装饰',
          '用书签作为包装装饰'
        ],
        presentationTips: [
          '介绍书籍的内容和价值',
          '分享阅读心得和推荐理由',
          '约定一起讨论阅读感受',
          '鼓励培养良好的阅读习惯'
        ],
        isRecommended: true
      },
      {
        id: '29',
        title: '音乐爱好者礼品',
        description: '音乐相关的精美礼物',
        detailedDescription: '为音乐爱好者准备的音乐相关礼品，包含音响设备、乐器配件、音乐周边和数字音乐服务。这类礼物能够提升音乐体验，适合热爱音乐、演奏乐器或收集音乐的朋友。',
        tags: [GiftType.TECH_DIGITAL, BudgetRangeEnum.RANGE_200_500, RecipientType.FRIEND],
        budgetRange: { min: 100, max: 400, label: '100-400元' },
        images: [$r('app.media.music_lover_gift')],
        targetAudience: ['朋友'],
        occasions: ['生日'],
        interests: ['音乐'],
        giftType: '数码产品',
        difficulty: 'easy',
        timeRequired: '30分钟',
        materials: [
          '高品质耳机或音响',
          '乐器配件（琴弦、拨片等）',
          '音乐主题装饰品',
          '黑胶唱片或CD',
          '音乐会门票',
          '乐谱或音乐书籍',
          '音乐制作软件',
          '个性化音乐播放列表'
        ],
        steps: [
          '了解朋友的音乐偏好和乐器',
          '选择高质量的音乐设备',
          '搭配相关的音乐配件',
          '准备音乐主题的装饰',
          '制作个性化的音乐推荐',
          '选择音乐风格的包装',
          '添加音乐相关的寄语',
          '在音乐相关的场合赠送'
        ],
        tips: [
          '选择知名品牌的音乐设备',
          '考虑朋友的音乐类型偏好',
          '搭配实用的音乐配件',
          '添加个性化的音乐元素'
        ],
        precautions: [
          '确认音乐设备的兼容性',
          '了解朋友现有的音乐设备',
          '选择适合的音质和功能'
        ],
        giftWrapIdeas: [
          '使用音乐主题的包装设计',
          '添加音符和乐器装饰',
          '用音乐色彩进行包装'
        ],
        presentationTips: [
          '介绍音乐设备的特色功能',
          '分享音乐心得和推荐',
          '约定一起欣赏或演奏音乐',
          '鼓励继续音乐爱好的发展'
        ],
        isRecommended: true
      },
      {
        id: '30',
        title: '旅行爱好者礼品',
        description: '陪伴旅途的贴心用品',
        detailedDescription: '为旅行爱好者精心准备的旅行用品，包含行李箱、旅行配件、便携用品和旅行纪念品。这类礼物实用性强，能够让旅行更加便利和舒适，适合热爱旅行、经常出行的朋友。',
        tags: [GiftType.TRAVEL_OUTDOOR, BudgetRangeEnum.RANGE_200_500, RecipientType.FRIEND],
        budgetRange: { min: 120, max: 350, label: '120-350元' },
        images: [$r('app.media.travel_enthusiast_gift')],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['旅行'],
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '1小时',
        materials: [
          '旅行箱或背包',
          '护照夹或证件包',
          '便携充电宝',
          '旅行洗漱包',
          '颈枕或眼罩',
          '旅行转换插头',
          '便携水杯',
          '旅行日记本'
        ],
        steps: [
          '了解朋友的旅行习惯和需求',
          '选择实用的旅行装备',
          '搭配便携的旅行配件',
          '准备旅行安全用品',
          '制作旅行攻略或建议',
          '选择旅行主题的包装',
          '添加旅行祝福和寄语',
          '在出行前或旅行相关时机赠送'
        ],
        tips: [
          '选择轻便耐用的旅行用品',
          '考虑朋友的旅行方式和目的地',
          '搭配多功能的便携配件',
          '添加个性化的旅行元素'
        ],
        precautions: [
          '确认旅行用品的质量和安全性',
          '了解航空公司的行李规定',
          '选择符合旅行需求的尺寸'
        ],
        giftWrapIdeas: [
          '使用地图或旅行主题包装',
          '添加世界各地的装饰元素',
          '用旅行色彩进行包装'
        ],
        presentationTips: [
          '介绍旅行用品的实用功能',
          '分享旅行经验和建议',
          '约定分享旅行照片和故事',
          '祝愿旅途愉快和平安'
        ],
        isRecommended: false
      }
    ];
  }
  
  /**
   * 获取Mock礼物事件数据
   * @returns GiftEvent[] 礼物事件数据数组
   */
  static getMockGiftEvents(): GiftEvent[] {
    return [
      {
        id: '1',
        contactId: '1',
        contactName: '小美',
        recordType: 'give',
        occasion: '生日',
        date: '2024-01-15T00:00:00.000Z',
        giftIdea: '手工制作的相册',
        actualGift: '定制相册',
        budget: 200,
        actualCost: 180,
        images: [],
        story: '花了一个周末的时间整理照片，制作了一本记录我们友谊的相册。',
        reaction: '非常感动，说这是收到过最有意义的礼物',
        mood: '开心',
        tags: ['手工', '纪念', '友谊'],
        reminderSet: true,
        reminderDate: '2024-01-10T00:00:00.000Z',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-16T00:00:00.000Z'
      },
      {
        id: '2',
        contactId: '2',
        contactName: '妈妈',
        recordType: 'give',
        occasion: '母亲节',
        date: '2024-05-12T00:00:00.000Z',
        giftIdea: '按摩椅垫',
        actualGift: '按摩椅垫',
        budget: 500,
        actualCost: 450,
        images: [],
        story: '妈妈平时工作很辛苦，希望这个按摩椅垫能让她放松一下。',
        reaction: '很实用，每天下班都会用',
        mood: '满足',
        tags: ['实用', '健康', '孝心'],
        reminderSet: true,
        reminderDate: '2024-05-05T00:00:00.000Z',
        createdAt: '2024-04-20T00:00:00.000Z',
        updatedAt: '2024-05-13T00:00:00.000Z'
      },
      {
        id: '3',
        contactId: '3',
        contactName: '李明',
        recordType: 'give',
        occasion: '纪念日',
        date: '2024-03-20T00:00:00.000Z',
        giftIdea: '情侣手表',
        actualGift: '情侣手表',
        budget: 800,
        actualCost: 750,
        images: [],
        story: '我们交往一周年的纪念日，选择了一对简约的情侣手表。',
        reaction: '很喜欢，说要每天都戴着',
        mood: '浪漫',
        tags: ['纪念', '情侣', '时尚'],
        reminderSet: true,
        reminderDate: '2024-03-15T00:00:00.000Z',
        createdAt: '2024-03-01T00:00:00.000Z',
        updatedAt: '2024-03-21T00:00:00.000Z'
      }
    ];
  }
  
  /**
   * 获取Mock联系人数据
   * @returns Contact[] 联系人数据数组
   */
  static getMockContacts(): Contact[] {
    return [
      {
        id: '1',
        name: '小美',
        relationship: '闺蜜',
        avatar: '',
        birthday: '1995-01-15',
        importantDates: [
          {
            id: '1',
            contactId: '1',
            name: '生日',
            date: '1995-01-15',
            isRecurring: true,
            reminderEnabled: true,
            reminderDays: 7
          }
        ],
        preferences: [
          {
            id: '1',
            contactId: '1',
            category: '兴趣',
            content: '摄影、旅行',
            priority: 'high'
          }
        ],
        notes: '喜欢手工制品，对有纪念意义的礼物很感兴趣',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-01T00:00:00.000Z'
      },
      {
        id: '2',
        name: '妈妈',
        relationship: '母亲',
        avatar: '',
        birthday: '1970-08-20',
        importantDates: [
          {
            id: '2',
            contactId: '2',
            name: '生日',
            date: '1970-08-20',
            isRecurring: true,
            reminderEnabled: true,
            reminderDays: 10
          },
          {
            id: '3',
            contactId: '2',
            name: '母亲节',
            date: '2024-05-12',
            isRecurring: true,
            reminderEnabled: true,
            reminderDays: 7
          }
        ],
        preferences: [
          {
            id: '2',
            contactId: '2',
            category: '兴趣',
            content: '园艺、烹饪',
            priority: 'high'
          },
          {
            id: '3',
            contactId: '2',
            category: '喜好',
            content: '实用的生活用品',
            priority: 'medium'
          }
        ],
        notes: '注重实用性，喜欢能改善生活质量的礼物',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-01T00:00:00.000Z'
      },
      {
        id: '3',
        name: '李明',
        relationship: '男朋友',
        avatar: '',
        birthday: '1993-03-10',
        importantDates: [
          {
            id: '4',
            contactId: '3',
            name: '生日',
            date: '1993-03-10',
            isRecurring: true,
            reminderEnabled: true,
            reminderDays: 7
          },
          {
            id: '5',
            contactId: '3',
            name: '恋爱纪念日',
            date: '2023-03-20',
            isRecurring: true,
            reminderEnabled: true,
            reminderDays: 5
          }
        ],
        preferences: [
          {
            id: '4',
            contactId: '3',
            category: '兴趣',
            content: '数码产品、运动',
            priority: 'high'
          },
          {
            id: '5',
            contactId: '3',
            category: '风格',
            content: '简约、实用',
            priority: 'medium'
          }
        ],
        notes: '喜欢科技感的礼物，对品质要求较高',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-01T00:00:00.000Z'
      }
    ];
  }
  
  /**
   * 根据分类筛选灵感数据
   * @param category 分类名称
   * @returns Inspiration[] 筛选后的灵感数据
   */
  static getInspirationsByCategory(category: string): Inspiration[] {
    const allInspirations = MockData.getMockInspirations();
    
    switch (category) {
      case '按对象送':
        return allInspirations.slice(0, 10);
      case '按场合送':
        return allInspirations.slice(10, 15);
      case '按预算送':
        return allInspirations.slice(15, 20);
      case '按类型送':
        return allInspirations.slice(20, 25);
      case '按兴趣送':
        return allInspirations.slice(25, 30);
      default:
        return allInspirations;
    }
  }
  
  /**
   * 根据预算范围筛选灵感数据
   * @param minBudget 最小预算
   * @param maxBudget 最大预算
   * @returns Inspiration[] 筛选后的灵感数据
   */
  static getInspirationsByBudget(minBudget: number, maxBudget: number): Inspiration[] {
    return MockData.getMockInspirations().filter(inspiration => 
      inspiration.budgetRange.min >= minBudget && inspiration.budgetRange.max <= maxBudget
    );
  }
  
  /**
   * 根据目标受众筛选灵感数据
   * @param audience 目标受众
   * @returns Inspiration[] 筛选后的灵感数据
   */
  static getInspirationsByAudience(audience: string): Inspiration[] {
    return MockData.getMockInspirations().filter(inspiration => 
      inspiration.targetAudience.includes(audience)
    );
  }
  
  /**
   * 根据场合筛选灵感数据
   * @param occasion 场合
   * @returns Inspiration[] 筛选后的灵感数据
   */
  static getInspirationsByOccasion(occasion: string): Inspiration[] {
    return MockData.getMockInspirations().filter(inspiration => 
      inspiration.occasions.includes(occasion)
    );
  }
  
  /**
   * 获取推荐的灵感数据
   * @returns Inspiration[] 推荐的灵感数据
   */
  static getRecommendedInspirations(): Inspiration[] {
    return MockData.getMockInspirations().filter(inspiration => inspiration.isRecommended);
  }
  
  /**
   * 获取所有灵感数据（为了兼容BrowsePage）
   * @returns Inspiration[] 所有灵感数据
   */
  static getAllInspirations(): Inspiration[] {
    return MockData.getMockInspirations();
  }

  // 收藏相关的静态数据和方法
  private static favoriteInspirationIds: Set<string> = new Set(); // 收藏数据，初始为空

  /**
   * 添加到收藏
   */
  static addToFavorites(inspirationId: string): void {
    MockData.favoriteInspirationIds.add(inspirationId);
  }

  /**
   * 从收藏中移除
   */
  static removeFromFavorites(inspirationId: string): void {
    MockData.favoriteInspirationIds.delete(inspirationId);
  }

  /**
   * 检查是否已收藏
   */
  static isFavorite(inspirationId: string): boolean {
    return MockData.favoriteInspirationIds.has(inspirationId);
  }

  /**
   * 获取收藏的灵感列表
   */
  static getFavoriteInspirations(): Inspiration[] {
    const allInspirations = MockData.getAllInspirations();
    return allInspirations.filter(inspiration => 
      inspiration.id && MockData.favoriteInspirationIds.has(inspiration.id)
    );
  }

  /**
   * 添加新的灵感
   */
  static addInspiration(inspiration: Inspiration): void {
    // 在实际应用中，这里会添加到数据源
    // 目前只是模拟，不实际添加到静态数组
    console.info('添加新灵感:', inspiration.title);
  }

  /**
   * 更新灵感
   */
  static updateInspiration(id: string, updates: Inspiration): void {
    // 在实际应用中，这里会更新数据源
    // 目前只是模拟
    console.info('更新灵感:', id, updates.title);
  }

  /**
   * 删除灵感
   */
  static deleteInspiration(id: string): void {
    // 在实际应用中，这里会从数据源删除
    // 目前只是模拟
    console.info('删除灵感:', id);
    // 同时从收藏中移除
    MockData.removeFromFavorites(id);
  }
}