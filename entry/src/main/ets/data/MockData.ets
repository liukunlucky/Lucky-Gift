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
        description: '精心准备的生日礼物套装',
        tags: [RecipientType.GIRLFRIEND, OccasionType.BIRTHDAY, GiftType.JEWELRY],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        images: [],
        targetAudience: ['女朋友'],
        occasions: ['生日'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '2小时',
        isRecommended: true
      },
      {
        id: '2',
        title: '送给妈妈的温馨礼物',
        description: '表达孝心的实用礼品',
        tags: [RecipientType.MOTHER, OccasionType.MOTHERS_DAY, GiftType.DAILY_ITEMS],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [],
        targetAudience: ['妈妈'],
        occasions: ['母亲节'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '3',
        title: '给爸爸的实用好物',
        description: '贴心实用的父亲节礼物',
        tags: [RecipientType.FATHER, OccasionType.FATHERS_DAY, GiftType.DAILY_ITEMS],
        budgetRange: { min: 150, max: 400, label: '150-400元' },
        images: [],
        targetAudience: ['爸爸'],
        occasions: ['父亲节'],
        interests: [],
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      {
        id: '4',
        title: '闺蜜生日惊喜',
        description: '和闺蜜一起度过难忘生日',
        tags: [RecipientType.BESTIE, OccasionType.BIRTHDAY, GiftType.DIY_HANDMADE],
        budgetRange: { min: 100, max: 250, label: '100-250元' },
        images: [],
        targetAudience: ['闺蜜'],
        occasions: ['生日'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '3小时',
        isRecommended: true
      },
      {
        id: '5',
        title: '给男朋友的创意礼物',
        description: '独特的纪念日礼品',
        tags: [RecipientType.BOYFRIEND, OccasionType.ANNIVERSARY, GiftType.CREATIVE_NOVEL],
        budgetRange: { min: 150, max: 350, label: '150-350元' },
        images: [],
        targetAudience: ['男朋友'],
        occasions: ['纪念日'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '4小时',
        isRecommended: false
      },
      {
        id: '6',
        title: '给老师的感谢礼',
        description: '表达感激之情的礼物',
        tags: [RecipientType.TEACHER, OccasionType.TEACHERS_DAY, GiftType.DAILY_ITEMS],
        budgetRange: { min: 80, max: 200, label: '80-200元' },
        images: [],
        targetAudience: ['老师'],
        occasions: ['教师节'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      },
      {
        id: '7',
        title: '给同事的友谊礼品',
        description: '增进同事关系的小礼物',
        tags: [RecipientType.COLLEAGUE, OccasionType.JUST_BECAUSE, GiftType.DAILY_ITEMS],
        budgetRange: { min: 50, max: 150, label: '50-150元' },
        images: [],
        targetAudience: ['同事'],
        occasions: ['日常'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: false
      },
      {
        id: '8',
        title: '给孩子的成长礼物',
        description: '陪伴孩子成长的礼品',
        tags: [RecipientType.CHILD, OccasionType.BIRTHDAY, GiftType.CREATIVE_NOVEL],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [],
        targetAudience: ['孩子'],
        occasions: ['生日'],
        interests: ['学习'],
        giftType: '体验之旅',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '9',
        title: '给长辈的孝心礼',
        description: '表达孝心的传统礼品',
        tags: [RecipientType.ELDER_RELATIVE, OccasionType.SPRING_FESTIVAL, GiftType.DAILY_ITEMS],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        images: [],
        targetAudience: ['长辈'],
        occasions: ['节日'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '10',
        title: '给宠物的爱心礼物',
        description: '让宠物开心的小惊喜',
        tags: [RecipientType.OTHER, GiftType.DAILY_ITEMS],
        budgetRange: { min: 50, max: 150, label: '50-150元' },
        images: [],
        targetAudience: ['宠物'],
        occasions: [],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: false
      },
      
      // 按场合送 - 5条
      {
        id: '11',
        title: '生日派对策划',
        description: '难忘的生日庆祝活动',
        tags: [OccasionType.BIRTHDAY, GiftType.EXPERIENCE, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 300, max: 800, label: '300-800元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['生日'],
        interests: [],
        giftType: '体验之旅',
        difficulty: 'hard',
        timeRequired: '1天',
        isRecommended: true
      },
      {
        id: '12',
        title: '毕业纪念册制作',
        description: '记录美好校园时光',
        tags: [OccasionType.GRADUATION, GiftType.DIY_HANDMADE, BudgetRangeEnum.RANGE_100_200],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['毕业'],
        interests: ['手工爱好者'],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '5小时',
        isRecommended: true
      },
      {
        id: '13',
        title: '结婚祝福礼品',
        description: '新人的美好祝愿',
        tags: [OccasionType.WEDDING, GiftType.DAILY_ITEMS, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 200, max: 500, label: '200-500元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['婚礼'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '14',
        title: '节日庆祝活动',
        description: '传统节日的庆祝方式',
        tags: [OccasionType.SPRING_FESTIVAL, GiftType.FOOD_BEVERAGE, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 150, max: 400, label: '150-400元' },
        images: [],
        targetAudience: ['家人'],
        occasions: ['节日'],
        interests: ['美食家'],
        giftType: '美食礼品',
        difficulty: 'medium',
        timeRequired: '3小时',
        isRecommended: true
      },
      {
        id: '15',
        title: '升职庆祝礼品',
        description: '庆祝职业成就的礼物',
        tags: [OccasionType.PROMOTION, GiftType.EXPERIENCE, BudgetRangeEnum.RANGE_200_500],
        budgetRange: { min: 200, max: 600, label: '200-600元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['升职'],
        interests: [],
        giftType: '体验之旅',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      },
      
      // 按预算送 - 5条
      {
        id: '16',
        title: '经济实惠小礼品',
        description: '50元以下的贴心礼物',
        tags: [BudgetRangeEnum.UNDER_50, GiftType.DIY_HANDMADE, RecipientType.FRIEND],
        budgetRange: { min: 20, max: 50, label: '20-50元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '17',
        title: '中等预算礼品',
        description: '100-200元的精选礼物',
        tags: [BudgetRangeEnum.RANGE_100_200, GiftType.DAILY_ITEMS, RecipientType.FRIEND],
        budgetRange: { min: 100, max: 200, label: '100-200元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['生日'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '18',
        title: '高端定制礼品',
        description: '500元以上的奢华礼物',
        tags: [BudgetRangeEnum.RANGE_500_1000, GiftType.JEWELRY, RecipientType.GIRLFRIEND],
        budgetRange: { min: 500, max: 1000, label: '500-1000元' },
        images: [],
        targetAudience: ['恋人'],
        occasions: ['纪念日'],
        interests: [],
        giftType: '精美饰品',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      {
        id: '19',
        title: '学生党友好礼品',
        description: '适合学生预算的礼物',
        tags: [BudgetRangeEnum.RANGE_50_100, GiftType.DIY_HANDMADE, RecipientType.FRIEND],
        budgetRange: { min: 30, max: 80, label: '30-80元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '2小时',
        isRecommended: false
      },
      {
        id: '20',
        title: 'DIY手工礼物',
        description: '用心制作的独特礼品',
        tags: [GiftType.DIY_HANDMADE, BudgetRangeEnum.RANGE_50_100, RecipientType.FRIEND],
        budgetRange: { min: 30, max: 100, label: '30-100元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['手工爱好者'],
        giftType: 'DIY手作',
        difficulty: 'hard',
        timeRequired: '6小时',
        isRecommended: true
      },
      
      // 按类型送 - 5条
      {
        id: '21',
        title: '实用型生活好物',
        description: '提升生活品质的实用礼品',
        tags: [GiftType.DAILY_ITEMS, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 80, max: 250, label: '80-250元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      {
        id: '22',
        title: '创意趣味礼品',
        description: '充满创意和乐趣的礼物',
        tags: [GiftType.DIY_HANDMADE, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: [],
        giftType: 'DIY手作',
        difficulty: 'medium',
        timeRequired: '3小时',
        isRecommended: true
      },
      {
        id: '23',
        title: '纪念收藏类礼品',
        description: '具有纪念价值的收藏品',
        tags: [GiftType.JEWELRY, BudgetRangeEnum.RANGE_200_500, OccasionType.ANNIVERSARY],
        budgetRange: { min: 100, max: 400, label: '100-400元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['纪念日'],
        interests: [],
        giftType: '精美饰品',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: false
      },
      {
        id: '24',
        title: '体验服务类礼品',
        description: '难忘的体验和服务',
        tags: [GiftType.EXPERIENCE, BudgetRangeEnum.RANGE_200_500, OccasionType.ANNIVERSARY],
        budgetRange: { min: 200, max: 600, label: '200-600元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['纪念日'],
        interests: [],
        giftType: '体验之旅',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '25',
        title: '美容护肤礼品',
        description: '呵护肌肤的美容产品',
        tags: [GiftType.BEAUTY_SKINCARE, BudgetRangeEnum.RANGE_200_500, RecipientType.FRIEND],
        budgetRange: { min: 150, max: 400, label: '150-400元' },
        images: [],
        targetAudience: ['女性朋友'],
        occasions: ['生日'],
        interests: ['美容护肤'],
        giftType: '美容护肤',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      
      // 按兴趣送 - 5条
      {
        id: '26',
        title: '美食爱好者礼品',
        description: '满足味蕾的美食礼物',
        tags: [GiftType.FOOD_BEVERAGE, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 100, max: 300, label: '100-300元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['美食家'],
        giftType: '美食礼品',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '27',
        title: '运动健身礼品',
        description: '支持健康生活的运动用品',
        tags: [GiftType.SPORTS_FITNESS, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 80, max: 250, label: '80-250元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['运动健身'],
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      {
        id: '28',
        title: '读书爱好者礼品',
        description: '书香气息的文化礼物',
        tags: [GiftType.BOOKS_STATIONERY, BudgetRangeEnum.RANGE_100_200, RecipientType.FRIEND],
        budgetRange: { min: 50, max: 200, label: '50-200元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['阅读'],
        giftType: '贴心日用',
        difficulty: 'easy',
        timeRequired: '1小时',
        isRecommended: true
      },
      {
        id: '29',
        title: '音乐爱好者礼品',
        description: '音乐相关的精美礼物',
        tags: [GiftType.TECH_DIGITAL, BudgetRangeEnum.RANGE_200_500, RecipientType.FRIEND],
        budgetRange: { min: 100, max: 400, label: '100-400元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['生日'],
        interests: ['音乐'],
        giftType: '数码产品',
        difficulty: 'easy',
        timeRequired: '30分钟',
        isRecommended: true
      },
      {
        id: '30',
        title: '旅行爱好者礼品',
        description: '陪伴旅途的贴心用品',
        tags: [GiftType.TRAVEL_OUTDOOR, BudgetRangeEnum.RANGE_200_500, RecipientType.FRIEND],
        budgetRange: { min: 120, max: 350, label: '120-350元' },
        images: [],
        targetAudience: ['朋友'],
        occasions: ['日常'],
        interests: ['旅行'],
        giftType: '实用工具',
        difficulty: 'easy',
        timeRequired: '1小时',
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