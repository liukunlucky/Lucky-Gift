import { Inspiration, InspirationCategory, InspirationTag, QuickFilter } from '../model/NewDataModels';
import { InspirationDAO } from './InspirationDAO';
import { NewDatabaseManager } from './NewDatabaseManager';

export class InspirationDataInitializer {
  private inspirationDAO: InspirationDAO;

  constructor() {
    const dbManager = new NewDatabaseManager();
    this.inspirationDAO = new InspirationDAO(dbManager);
  }

  // 初始化所有预置数据
  async initializeAllData(): Promise<void> {
    try {
      // 检查是否已经初始化过
      const existingInspirations = await this.inspirationDAO.getAllInspirations();
      if (existingInspirations.length > 0) {
        console.log('灵感数据已存在，跳过初始化');
        return;
      }

      console.log('开始初始化灵感数据库...');
      
      // 初始化分类
      await this.initializeCategories();
      
      // 初始化标签
      await this.initializeTags();
      
      // 初始化灵感内容
      await this.initializeInspirations();
      
      console.log('灵感数据库初始化完成');
    } catch (error) {
      console.error('初始化灵感数据库失败:', error);
      throw new Error(`初始化灵感数据库失败: ${error}`);
    }
  }

  // 初始化分类
  private async initializeCategories(): Promise<void> {
    const categories: InspirationCategory[] = [
      {
        name: '按对象送',
        description: '根据收礼人的身份和关系选择礼物',
        icon: '👥',
        color: '#4CAF50',
        orderIndex: 1,
        isActive: true
      },
      {
        name: '按场合送',
        description: '根据特殊场合和节日选择礼物',
        icon: '🎉',
        color: '#E91E63',
        orderIndex: 2,
        isActive: true
      },
      {
        name: '按兴趣送',
        description: '根据收礼人的兴趣爱好选择礼物',
        icon: '🎨',
        color: '#FF9800',
        orderIndex: 3,
        isActive: true
      },
      {
        name: '按预算送',
        description: '根据预算范围选择合适的礼物',
        icon: '💰',
        color: '#2196F3',
        orderIndex: 4,
        isActive: true
      },
      {
        name: '按类型送',
        description: '根据礼物类型和特点选择',
        icon: '🎁',
        color: '#9C27B0',
        orderIndex: 5,
        isActive: true
      }
    ];

    for (const category of categories) {
      await this.inspirationDAO.createCategory(category);
    }
  }

  // 初始化标签
  private async initializeTags(): Promise<void> {
    const tags: InspirationTag[] = [
      // 对象标签
      { name: '父母', category: '按对象送', color: '#4CAF50', isPopular: true },
      { name: '恋人', category: '按对象送', color: '#E91E63', isPopular: true },
      { name: '朋友', category: '按对象送', color: '#FF9800', isPopular: true },
      { name: '同事', category: '按对象送', color: '#2196F3', isPopular: false },
      { name: '孩子', category: '按对象送', color: '#9C27B0', isPopular: true },
      { name: '长辈', category: '按对象送', color: '#607D8B', isPopular: false },
      { name: '老师', category: '按对象送', color: '#795548', isPopular: false },
      { name: '闺蜜', category: '按对象送', color: '#E91E63', isPopular: true },
      { name: '兄弟', category: '按对象送', color: '#2196F3', isPopular: false },
      
      // 场合标签
      { name: '生日', category: '按场合送', color: '#FF6B35', isPopular: true },
      { name: '纪念日', category: '按场合送', color: '#E91E63', isPopular: true },
      { name: '婚礼', category: '按场合送', color: '#9C27B0', isPopular: false },
      { name: '节日', category: '按场合送', color: '#4CAF50', isPopular: true },
      { name: '毕业', category: '按场合送', color: '#FF9800', isPopular: false },
      { name: '道歉', category: '按场合送', color: '#F44336', isPopular: false },
      { name: '感谢', category: '按场合送', color: '#4CAF50', isPopular: false },
      { name: '升职', category: '按场合送', color: '#2196F3', isPopular: false },
      { name: '搬家', category: '按场合送', color: '#607D8B', isPopular: false },
      { name: '康复', category: '按场合送', color: '#4CAF50', isPopular: false },
      
      // 兴趣标签
      { name: '美食家', category: '按兴趣送', color: '#FF6B35', isPopular: true },
      { name: '读书人', category: '按兴趣送', color: '#795548', isPopular: true },
      { name: '科技迷', category: '按兴趣送', color: '#2196F3', isPopular: true },
      { name: '旅行家', category: '按兴趣送', color: '#4CAF50', isPopular: true },
      { name: '健身达人', category: '按兴趣送', color: '#FF9800', isPopular: false },
      { name: '音乐爱好者', category: '按兴趣送', color: '#9C27B0', isPopular: false },
      { name: '摄影师', category: '按兴趣送', color: '#607D8B', isPopular: false },
      { name: '游戏玩家', category: '按兴趣送', color: '#E91E63', isPopular: false },
      { name: '手工爱好者', category: '按兴趣送', color: '#FF6B35', isPopular: false },
      { name: '园艺爱好者', category: '按兴趣送', color: '#4CAF50', isPopular: false },
      
      // 预算标签
      { name: '50元以下', category: '按预算送', color: '#4CAF50', isPopular: true },
      { name: '50-200元', category: '按预算送', color: '#FF9800', isPopular: true },
      { name: '200-500元', category: '按预算送', color: '#2196F3', isPopular: true },
      { name: '500-1000元', category: '按预算送', color: '#9C27B0', isPopular: false },
      { name: '1000元以上', category: '按预算送', color: '#F44336', isPopular: false },
      
      // 类型标签
      { name: 'DIY手作', category: '按类型送', color: '#FF6B35', isPopular: true },
      { name: '体验之旅', category: '按类型送', color: '#4CAF50', isPopular: true },
      { name: '贴心日用', category: '按类型送', color: '#2196F3', isPopular: true },
      { name: '搞怪惊喜', category: '按类型送', color: '#E91E63', isPopular: false },
      { name: '实用工具', category: '按类型送', color: '#607D8B', isPopular: false },
      { name: '装饰摆件', category: '按类型送', color: '#9C27B0', isPopular: false },
      { name: '美容护肤', category: '按类型送', color: '#E91E63', isPopular: true },
      { name: '数码产品', category: '按类型送', color: '#2196F3', isPopular: true },
      { name: '服装配饰', category: '按类型送', color: '#9C27B0', isPopular: true }
    ];

    for (const tag of tags) {
      await this.inspirationDAO.createTag(tag);
    }
  }

  // 初始化灵感内容
  private async initializeInspirations(): Promise<void> {
    const inspirations: Inspiration[] = [
      {
        title: '为她定制一本专属故事书',
        description: '收集你们的照片和回忆，制作成精美的相册或故事书。可以加入手写的文字，记录每个重要时刻的感受。',
        detailedDescription: '这是一份充满回忆的礼物，展现了你对这段关系的珍视。可以选择在线定制服务，也可以自己手工制作，关键是要用心收集素材和编排故事。',
        images: [$r('app.media.romantic_surprise_for_girlfriend')],
        tags: ['恋人', '纪念日', 'DIY手作', '200-500元'],
        targetAudience: ['恋人'],
        occasions: ['纪念日'],
        interests: [],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '2-3天',
        isRecommended: true
      },
      {
        title: '亲手制作的美食大餐',
        description: '学习制作TA最喜欢的菜肴，准备一顿丰盛的家庭晚餐。从采购食材到精心摆盘，每个细节都体现你的用心。',
        detailedDescription: '美食是表达爱意的最直接方式。可以提前练习几次，确保味道完美。记得准备蜡烛和音乐，营造浪漫氛围。',
        images: [$r('app.media.holiday_celebration_activity')],
        tags: ['恋人', '父母', '生日', '美食家', '50-200元', '贴心日用'],
        targetAudience: ['恋人', '父母'],
        occasions: ['生日'],
        interests: ['美食家'],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: '贴心日用',
        difficulty: 'medium',
        timeRequired: '1天',
        isRecommended: true
      },
      {
        title: '智能手环健康管家',
        description: '选择一款功能齐全的智能手环，帮助TA监测健康数据，养成良好的运动习惯。',
        detailedDescription: '现代人越来越注重健康管理，智能手环可以监测心率、步数、睡眠质量等。选择时要考虑兼容性和续航能力。',
        images: [$r('app.media.affordable_small_gift')],
        tags: ['朋友', '同事', '健身达人', '科技迷', '200-500元', '数码产品'],
        targetAudience: ['朋友', '同事'],
        occasions: [],
        interests: ['健身达人', '科技迷'],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: '数码产品',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      },
      {
        title: '精选书籍配咖啡礼盒',
        description: '根据TA的阅读喜好，精心挑选几本好书，搭配优质咖啡豆，打造完美的阅读时光。',
        detailedDescription: '了解TA最近关注的话题或作者，选择相关书籍。咖啡可以选择单品豆或拼配豆，包装要精美。',
        images: [$r('app.media.record_beautiful_campus_time')],
        tags: ['朋友', '读书人', '美食家', '感谢', '200-500元', '贴心日用'],
        targetAudience: ['朋友'],
        occasions: ['感谢'],
        interests: ['读书人', '美食家'],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '2小时',
        isRecommended: true
      },
      {
        title: '手工编织围巾',
        description: '亲手编织一条温暖的围巾，选择TA喜欢的颜色和款式。每一针每一线都承载着你的心意。',
        detailedDescription: '编织需要耐心和时间，但成品会非常有意义。可以选择简单的针法，重点是颜色搭配和长度设计。',
        images: [$r('app.media.travel_enthusiast_gift')],
        tags: ['恋人', '父母', '长辈', '冬季', 'DIY手作', '50-200元'],
        targetAudience: ['恋人', '父母', '长辈'],
        occasions: ['冬季'],
        interests: [],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: 'DIY手作',
        difficulty: 'hard',
        timeRequired: '1-2周',
        isRecommended: false
      },
      {
        title: '多肉植物组合盆栽',
        description: '精心搭配不同品种的多肉植物，制作一个小型花园。既美观又好养护，寓意生活美好。',
        detailedDescription: '多肉植物容易养护，适合忙碌的现代人。可以选择不同形状和颜色的品种，搭配精美的花盆。',
        images: [$r('app.media.romantic_surprise_for_girlfriend')],
        tags: ['朋友', '同事', '园艺爱好者', '搬家', '50-200元', '装饰摆件'],
        targetAudience: ['朋友', '同事'],
        occasions: ['搬家'],
        interests: ['园艺爱好者'],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: '装饰摆件',
        difficulty: 'easy',
        timeRequired: '2小时',
        isRecommended: false
      },
      {
        title: '定制星空投影灯',
        description: '选择一款高质量的星空投影灯，可以投射出美丽的星空效果，营造浪漫氛围。',
        detailedDescription: '星空投影灯适合卧室使用，可以帮助放松心情，改善睡眠质量。有些产品还支持音乐播放功能。',
        images: [$r('app.media.holiday_celebration_activity')],
        tags: ['恋人', '孩子', '科技迷', '生日', '200-500元', '数码产品'],
        targetAudience: ['恋人', '孩子'],
        occasions: ['生日'],
        interests: ['科技迷'],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: '数码产品',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      {
        title: '香薰蜡烛制作套装',
        description: '购买蜡烛制作材料，和TA一起制作个性化的香薰蜡烛。选择喜欢的香味和颜色。',
        detailedDescription: '这是一个很好的互动体验，制作过程本身就很有趣。成品可以用来装饰家居，实用性很强。',
        images: [$r('app.media.affordable_small_gift')],
        tags: ['朋友', '恋人', '手工爱好者', 'DIY手作', '体验之旅', '50-200元'],
        targetAudience: ['朋友', '恋人'],
        occasions: [],
        interests: ['手工爱好者'],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '3-4小时',
        isRecommended: false
      },
      {
        title: '复古拍立得相机',
        description: '选择一款经典的拍立得相机，让TA可以随时记录美好瞬间，拍出有温度的照片。',
        detailedDescription: '拍立得照片有独特的质感和仪式感，适合喜欢摄影或怀旧的人。记得准备足够的相纸。',
        images: [$r('app.media.record_beautiful_campus_time')],
        tags: ['朋友', '恋人', '摄影师', '旅行家', '纪念日', '200-500元', '数码产品'],
        targetAudience: ['朋友', '恋人'],
        occasions: ['纪念日'],
        interests: ['摄影师', '旅行家'],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: '数码产品',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        title: '精油按摩套装',
        description: '选择天然精油和按摩工具，为TA准备一套完整的居家SPA体验。',
        detailedDescription: '现代人工作压力大，居家按摩可以很好地缓解疲劳。选择温和的精油，注意过敏测试。',
        images: [$r('app.media.travel_enthusiast_gift')],
        tags: ['恋人', '父母', '美容护肤', '贴心日用', '感谢', '200-500元'],
        targetAudience: ['恋人', '父母'],
        occasions: ['感谢'],
        interests: [],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: '美容护肤',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      },
      {
        title: '个性化马克杯',
        description: '定制一个印有特殊意义图案或文字的马克杯，每次使用都能想起你的心意。',
        detailedDescription: '可以印上照片、名字、纪念日期或特殊的话语。选择质量好的陶瓷材质，确保图案持久。',
        images: [$r('app.media.romantic_surprise_for_girlfriend')],
        tags: ['朋友', '同事', '老师', '感谢', '50元以下', '贴心日用'],
        targetAudience: ['朋友', '同事', '老师'],
        occasions: ['感谢'],
        interests: [],
        budgetRange: { min: 0, max: 50, label: '50元以下' },
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      },
      {
        title: '手工巧克力制作',
        description: '学习制作手工巧克力，可以做成各种形状和口味，包装精美后送给TA。',
        detailedDescription: '巧克力制作需要控制温度，但过程很有趣。可以加入坚果、果干等配料，增加层次感。',
        images: [$r('app.media.holiday_celebration_activity')],
        tags: ['恋人', '朋友', '美食家', 'DIY手作', '生日', '50-200元'],
        targetAudience: ['恋人', '朋友'],
        occasions: ['生日'],
        interests: ['美食家'],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '4-5小时',
        isRecommended: false
      },
      {
        title: '蓝牙音响音乐盒',
        description: '选择一款设计精美的蓝牙音响，让TA随时享受高质量的音乐体验。',
        detailedDescription: '音质是关键，同时要考虑便携性和续航能力。可以预先在里面存储一些TA喜欢的歌曲。',
        images: [$r('app.media.affordable_small_gift')],
        tags: ['朋友', '音乐爱好者', '科技迷', '数码产品', '200-500元'],
        targetAudience: ['朋友'],
        occasions: [],
        interests: ['音乐爱好者', '科技迷'],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        giftType: '数码产品',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: false
      },
      {
        title: '温馨夜灯小夜灯',
        description: '选择一款温暖柔和的小夜灯，为TA的卧室增添温馨氛围，方便夜间使用。',
        detailedDescription: '夜灯的光线要柔和不刺眼，最好有调光功能。造型可以选择可爱或简约的设计。',
        images: [$r('app.media.record_beautiful_campus_time')],
        tags: ['孩子', '恋人', '贴心日用', '装饰摆件', '50-200元'],
        targetAudience: ['孩子', '恋人'],
        occasions: [],
        interests: [],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: '装饰摆件',
        difficulty: 'easy',
        timeRequired: '15分钟',
        isRecommended: false
      },
      {
        title: '旅行收纳整理包',
        description: '为经常出差或旅行的TA准备一套实用的收纳包，让行李整理变得简单有序。',
        detailedDescription: '包括衣物收纳袋、洗漱包、数码配件包等。材质要轻便耐用，设计要合理实用。',
        images: [$r('app.media.travel_enthusiast_gift')],
        tags: ['朋友', '同事', '旅行家', '实用工具', '贴心日用', '50-200元'],
        targetAudience: ['朋友', '同事'],
        occasions: [],
        interests: ['旅行家'],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      }
    ];

    for (const inspiration of inspirations) {
      await this.inspirationDAO.createInspiration(inspiration);
    }
  }

  // 获取预置的热门标签
  getPopularTags(): string[] {
    return [
      '生日', '恋人', '朋友', '父母', '纪念日',
      'DIY手作', '美食家', '科技迷', '50-200元', '200-500元'
    ];
  }

  // 获取快速筛选器配置
  getQuickFilters(): QuickFilter[] {
    return [
      {
        name: '生日礼物',
        tags: ['生日'],
        color: '#FF6B35'
      },
      {
        name: '给父母',
        tags: ['父母'],
        color: '#4CAF50'
      },
      {
        name: '500元内',
        tags: ['50元以下', '50-200元', '200-500元'],
        color: '#2196F3'
      },
      {
        name: 'DIY手作',
        tags: ['DIY手作'],
        color: '#E91E63'
      },
      {
        name: '科技产品',
        tags: ['科技迷', '数码产品'],
        color: '#9C27B0'
      }
    ];
  }
}