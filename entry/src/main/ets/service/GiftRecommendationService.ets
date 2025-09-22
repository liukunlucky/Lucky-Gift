import { Gift, GiftRecommendationRequest, GiftRecommendationResponse, Scenario, GiftCategory, PriceRange, Gender, AgeRange, Relationship, Interest, TargetGroup } from '../model/GiftModel';

// 礼物推荐服务
export class GiftRecommendationService {
  private static instance: GiftRecommendationService;
  private giftDatabase: Gift[] = [];

  private constructor() {
    this.initializeGiftDatabase();
  }

  public static getInstance(): GiftRecommendationService {
    if (!GiftRecommendationService.instance) {
      GiftRecommendationService.instance = new GiftRecommendationService();
    }
    return GiftRecommendationService.instance;
  }

  // 获取礼物推荐
  public getRecommendations(request: GiftRecommendationRequest): GiftRecommendationResponse {
    let filteredGifts = this.giftDatabase.filter(gift => {
      // 场景筛选
      if (request.scenario && !gift.scenarios.includes(request.scenario)) {
        return false;
      }

      // 价格区间筛选
      if (request.priceRange && gift.priceRange !== request.priceRange) {
        return false;
      }

      // 分类筛选
      if (request.category && gift.category !== request.category) {
        return false;
      }

      // 目标人群筛选
      if (request.targetGroup) {
        const matchesTarget = gift.targetGroups.some(target => {
          if (request.targetGroup?.gender && target.gender !== Gender.UNISEX && target.gender !== request.targetGroup.gender) {
            return false;
          }
          if (request.targetGroup?.ageRange && target.ageRange !== request.targetGroup.ageRange) {
            return false;
          }
          if (request.targetGroup?.relationship && target.relationship !== request.targetGroup.relationship) {
            return false;
          }
          return true;
        });
        if (!matchesTarget) {
          return false;
        }
      }

      // 关键词筛选
      if (request.keywords && request.keywords.length > 0) {
        const matchesKeyword = request.keywords.some(keyword => 
          gift.name.toLowerCase().includes(keyword.toLowerCase()) ||
          gift.description.toLowerCase().includes(keyword.toLowerCase()) ||
          gift.tags.some(tag => tag.toLowerCase().includes(keyword.toLowerCase()))
        );
        if (!matchesKeyword) {
          return false;
        }
      }

      // 排除指定ID
      if (request.excludeIds && request.excludeIds.includes(gift.id)) {
        return false;
      }

      return gift.availability;
    });

    // 按评分和评价数量排序
    filteredGifts.sort((a, b) => {
      const scoreA = a.rating * Math.log(a.reviewCount + 1);
      const scoreB = b.rating * Math.log(b.reviewCount + 1);
      return scoreB - scoreA;
    });

    // 生成推荐理由
    const reason = this.generateRecommendationReason(request, filteredGifts.length);

    return {
      gifts: filteredGifts.slice(0, 20), // 限制返回数量
      totalCount: filteredGifts.length,
      recommendationReason: reason
    };
  }

  // 根据ID获取礼物详情
  public getGiftById(id: string): Gift | undefined {
    return this.giftDatabase.find(gift => gift.id === id);
  }

  // 获取热门礼物
  public getPopularGifts(limit: number = 10): Gift[] {
    return this.giftDatabase
      .filter(gift => gift.availability)
      .sort((a, b) => b.reviewCount - a.reviewCount)
      .slice(0, limit);
  }

  // 获取相似礼物
  public getSimilarGifts(giftId: string, limit: number = 5): Gift[] {
    const targetGift = this.getGiftById(giftId);
    if (!targetGift) return [];

    interface SimilarityItem {
      gift: Gift;
      similarity: number;
    }
    
    const similarityItems: SimilarityItem[] = this.giftDatabase
      .filter(gift => gift.id !== giftId && gift.availability)
      .map(gift => {
        const item: SimilarityItem = {
          gift: gift,
          similarity: this.calculateSimilarity(targetGift, gift)
        };
        return item;
      });
    
    return similarityItems
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, limit)
      .map(item => item.gift);
  }

  // 计算礼物相似度
  private calculateSimilarity(gift1: Gift, gift2: Gift): number {
    let score = 0;

    // 分类相同加分
    if (gift1.category === gift2.category) score += 0.3;

    // 价格区间相同加分
    if (gift1.priceRange === gift2.priceRange) score += 0.2;

    // 场景重叠加分
    const commonScenarios = gift1.scenarios.filter(s => gift2.scenarios.includes(s));
    score += commonScenarios.length * 0.1;

    // 标签重叠加分
    const commonTags = gift1.tags.filter(tag => gift2.tags.includes(tag));
    score += commonTags.length * 0.05;

    // 目标人群重叠加分
    const targetOverlap = gift1.targetGroups.some(t1 => 
      gift2.targetGroups.some(t2 => 
        t1.gender === t2.gender && t1.ageRange === t2.ageRange
      )
    );
    if (targetOverlap) score += 0.2;

    return Math.min(score, 1.0);
  }

  // 生成推荐理由
  private generateRecommendationReason(request: GiftRecommendationRequest, resultCount: number): string {
    if (resultCount === 0) {
      return '抱歉，没有找到符合条件的礼物推荐。请尝试调整筛选条件。';
    }

    let reason = `为您找到了 ${resultCount} 个精选礼物推荐`;
    
    if (request.scenario) {
      let scenarioName = '';
      switch (request.scenario) {
        case Scenario.BIRTHDAY:
          scenarioName = '生日';
          break;
        case Scenario.ANNIVERSARY:
          scenarioName = '纪念日';
          break;
        case Scenario.VALENTINE:
          scenarioName = '情人节';
          break;
        case Scenario.CHRISTMAS:
          scenarioName = '圣诞节';
          break;
        case Scenario.GRADUATION:
          scenarioName = '毕业';
          break;
        case Scenario.WEDDING:
          scenarioName = '婚礼';
          break;
        case Scenario.APOLOGY:
          scenarioName = '道歉';
          break;
        case Scenario.THANK_YOU:
          scenarioName = '感谢';
          break;
        case Scenario.CONGRATULATIONS:
          scenarioName = '祝贺';
          break;
        case Scenario.GET_WELL:
          scenarioName = '康复';
          break;
        case Scenario.HOUSEWARMING:
          scenarioName = '乔迁';
          break;
        case Scenario.PROMOTION:
          scenarioName = '升职';
          break;
        default:
          scenarioName = '特殊';
          break;
      }
      reason += `，特别适合${scenarioName}场合`;
    }

    if (request.targetGroup?.gender) {
      let genderName = '';
      switch (request.targetGroup.gender) {
        case Gender.MALE:
          genderName = '男性';
          break;
        case Gender.FEMALE:
          genderName = '女性';
          break;
        case Gender.UNISEX:
          genderName = '通用';
          break;
        default:
          genderName = '通用';
          break;
      }
      reason += `，专为${genderName}精选`;
    }

    return reason + '。';
  }

  // 初始化礼物数据库
  private initializeGiftDatabase(): void {
    this.giftDatabase = [
      {
        id: '1',
        name: '施华洛世奇水晶项链',
        description: '经典水晶吊坠项链，闪耀迷人，适合各种场合佩戴',
        category: GiftCategory.JEWELRY,
        price: 299,
        priceRange: PriceRange.MODERATE,
        imageUrl: $r('app.media.shlsq'),
        tags: ['水晶', '项链', '时尚', '经典'],
        scenarios: [Scenario.BIRTHDAY, Scenario.ANNIVERSARY, Scenario.VALENTINE],
        targetGroups: [{
          gender: Gender.FEMALE,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.ROMANTIC,
          interests: [Interest.FASHION, Interest.BEAUTY]
        }],
        meaning: '水晶象征纯洁与永恒，表达对爱情的美好祝愿',
        culturalBackground: '水晶在西方文化中被认为具有净化心灵的力量',
        rating: 4.8,
        reviewCount: 1250,
        brand: '施华洛世奇',
        availability: true,
        purchaseLinks: [
          { platform: '天猫', url: 'https://tmall.com', price: 299, inStock: true },
          { platform: '京东', url: 'https://jd.com', price: 309, inStock: true }
        ]
      },
      {
        id: '2',
        name: 'AirPods Pro 无线耳机',
        description: '苹果最新款无线耳机，主动降噪，音质出色',
        category: GiftCategory.ELECTRONICS,
        price: 1899,
        priceRange: PriceRange.LUXURY,
        imageUrl: $r('app.media.airpod'),
        tags: ['苹果', '耳机', '无线', '降噪'],
        scenarios: [Scenario.BIRTHDAY, Scenario.GRADUATION, Scenario.PROMOTION],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.TECHNOLOGY, Interest.MUSIC]
        }],
        meaning: '科技产品代表对未来的期许和对品质生活的追求',
        rating: 4.7,
        reviewCount: 8900,
        brand: 'Apple',
        availability: true,
        purchaseLinks: [
          { platform: '苹果官网', url: 'https://apple.com', price: 1899, inStock: true },
          { platform: '京东', url: 'https://jd.com', price: 1799, inStock: true }
        ]
      },
      {
        id: '3',
        name: '永生花玻璃罩礼盒',
        description: '精美永生花装在透明玻璃罩中，永不凋谢的美丽',
        category: GiftCategory.FLOWERS,
        price: 168,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.ysh'),
        tags: ['永生花', '浪漫', '装饰', '纪念'],
        scenarios: [Scenario.VALENTINE, Scenario.ANNIVERSARY, Scenario.APOLOGY],
        targetGroups: [{
          gender: Gender.FEMALE,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.ROMANTIC,
          interests: [Interest.ART, Interest.BEAUTY]
        }],
        meaning: '永生花象征永恒不变的爱情和美好回忆',
        culturalBackground: '花朵在各种文化中都代表着美好和爱意',
        rating: 4.6,
        reviewCount: 2100,
        availability: true,
        purchaseLinks: [
          { platform: '淘宝', url: 'https://taobao.com', price: 168, inStock: true }
        ]
      },
      // 圣诞节礼物推荐
      {
        id: '4',
        name: '圣诞主题香薰蜡烛套装',
        description: '温馨的圣诞香氛，营造节日氛围，包含肉桂、松针等经典圣诞香味',
        category: GiftCategory.HOME,
        price: 89,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.shengdan'),
        tags: ['香薰', '圣诞', '温馨', '氛围'],
        scenarios: [Scenario.CHRISTMAS],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.ART, Interest.TRAVEL]
        }],
        meaning: '香薰蜡烛代表温暖和光明，为节日增添温馨氛围',
        culturalBackground: '蜡烛在圣诞节象征着希望之光和家庭温暖',
        rating: 4.5,
        reviewCount: 890,
        availability: true,
        purchaseLinks: [
          { platform: '天猫', url: 'https://tmall.com', price: 89, inStock: true }
        ]
      },
      {
        id: '5',
        name: '圣诞雪花球音乐盒',
        description: '精美的圣诞主题雪花球，内置音乐盒，播放经典圣诞歌曲',
        category: GiftCategory.TOYS,
        price: 128,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.yyh'),
        tags: ['雪花球', '音乐盒', '圣诞', '装饰'],
        scenarios: [Scenario.CHRISTMAS],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.CHILD,
          relationship: Relationship.FAMILY,
          interests: [Interest.MUSIC, Interest.ART]
        }],
        meaning: '雪花球象征着纯洁和美好愿望，音乐带来节日欢乐',
        culturalBackground: '雪花球是西方圣诞节的经典装饰品',
        rating: 4.7,
        reviewCount: 1200,
        availability: true,
        purchaseLinks: [
          { platform: '京东', url: 'https://jd.com', price: 128, inStock: true }
        ]
      },
      {
        id: '6',
        name: '圣诞毛绒玩具礼盒',
        description: '可爱的圣诞老人和驯鹿毛绒玩具套装，柔软舒适，适合各年龄段',
        category: GiftCategory.TOYS,
        price: 158,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.sdwj'),
        tags: ['毛绒玩具', '圣诞老人', '驯鹿', '可爱'],
        scenarios: [Scenario.CHRISTMAS],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.CHILD,
          relationship: Relationship.FAMILY,
          interests: [Interest.ART, Interest.GAMING]
        }],
        meaning: '毛绒玩具代表温暖的陪伴和童真的快乐',
        culturalBackground: '圣诞老人是西方圣诞节的象征人物',
        rating: 4.8,
        reviewCount: 2100,
        availability: true,
        purchaseLinks: [
          { platform: '淘宝', url: 'https://taobao.com', price: 158, inStock: true }
        ]
      },
      {
        id: '7',
        name: '圣诞热红酒香料包',
        description: '正宗德式圣诞热红酒香料包，包含肉桂、丁香等香料，温暖过冬',
        category: GiftCategory.FOOD,
        price: 68,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.rhj'),
        tags: ['热红酒', '香料', '温暖', '德式'],
        scenarios: [Scenario.CHRISTMAS],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.COOKING, Interest.TRAVEL]
        }],
        meaning: '热红酒是圣诞节的传统饮品，象征温暖和团聚',
        culturalBackground: '热红酒起源于欧洲，是圣诞市集的经典饮品',
        rating: 4.4,
        reviewCount: 650,
        availability: true,
        purchaseLinks: [
          { platform: '天猫', url: 'https://tmall.com', price: 68, inStock: true }
        ]
      },
      // 感谢礼物推荐
      {
        id: '8',
        name: '手写感谢卡片套装',
        description: '精美的手工感谢卡片，配有信封和贴纸，表达真挚谢意',
        category: GiftCategory.BOOKS,
        price: 35,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.gxk'),
        tags: ['感谢卡', '手写', '真挚', '贴心'],
        scenarios: [Scenario.THANK_YOU],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.ADULT,
          relationship: Relationship.COLLEAGUE,
          interests: [Interest.READING, Interest.ART]
        }],
        meaning: '手写卡片传达最真挚的感谢之情，心意比价值更重要',
        culturalBackground: '手写信件在数字时代显得格外珍贵和用心',
        rating: 4.6,
        reviewCount: 890,
        availability: true,
        purchaseLinks: [
          { platform: '淘宝', url: 'https://taobao.com', price: 35, inStock: true }
        ]
      },
      {
        id: '9',
        name: '精品茶叶礼盒',
        description: '优质乌龙茶礼盒装，包装精美，适合表达感谢之情',
        category: GiftCategory.FOOD,
        price: 128,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.cylh'),
        tags: ['茶叶', '乌龙茶', '礼盒', '健康'],
        scenarios: [Scenario.THANK_YOU],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.ADULT,
          relationship: Relationship.COLLEAGUE,
          interests: [Interest.COOKING, Interest.TRAVEL]
        }],
        meaning: '茶叶代表清香淡雅，表达对对方的尊重和感谢',
        culturalBackground: '茶文化在中华文化中象征着礼仪和尊重',
        rating: 4.7,
        reviewCount: 1500,
        availability: true,
        purchaseLinks: [
          { platform: '京东', url: 'https://jd.com', price: 128, inStock: true }
        ]
      },
      {
        id: '10',
        name: '多肉植物组合盆栽',
        description: '精心搭配的多肉植物组合，易养护，寓意生机勃勃',
        category: GiftCategory.FLOWERS,
        price: 88,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.drzw'),
        tags: ['多肉', '植物', '易养', '生机'],
        scenarios: [Scenario.THANK_YOU],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.ART, Interest.TRAVEL]
        }],
        meaning: '植物象征生命力和成长，感谢对方给予的帮助和支持',
        culturalBackground: '绿植在现代生活中代表健康和自然',
        rating: 4.5,
        reviewCount: 1100,
        availability: true,
        purchaseLinks: [
          { platform: '淘宝', url: 'https://taobao.com', price: 88, inStock: true }
        ]
      },
      {
        id: '11',
        name: '定制感谢巧克力礼盒',
        description: '可定制文字的精美巧克力礼盒，甜蜜表达感谢之情',
        category: GiftCategory.FOOD,
        price: 98,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.qkllh'),
        tags: ['巧克力', '定制', '甜蜜', '感谢'],
        scenarios: [Scenario.THANK_YOU],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.COOKING, Interest.BEAUTY]
        }],
        meaning: '巧克力的甜蜜如同感谢的心情，定制文字更显用心',
        culturalBackground: '巧克力在西方文化中是表达情感的经典礼品',
        rating: 4.6,
        reviewCount: 780,
        availability: true,
        purchaseLinks: [
          { platform: '天猫', url: 'https://tmall.com', price: 98, inStock: true }
        ]
      },
      // 婚礼礼物推荐
      {
        id: '12',
        name: '情侣对杯套装',
        description: '精美陶瓷情侣对杯，一对装，寓意成双成对，白头偕老',
        category: GiftCategory.HOME,
        price: 168,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.qldb'),
        tags: ['对杯', '情侣', '陶瓷', '成双成对'],
        scenarios: [Scenario.WEDDING],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.COOKING, Interest.ART]
        }],
        meaning: '对杯象征夫妻恩爱，共饮一杯茶，共度一生情',
        culturalBackground: '成双成对的物品在中华文化中寓意美满婚姻',
        rating: 4.7,
        reviewCount: 1800,
        availability: true,
        purchaseLinks: [
          { platform: '京东', url: 'https://jd.com', price: 168, inStock: true }
        ]
      },
      {
        id: '13',
        name: '新婚床品四件套',
        description: '高品质纯棉婚庆床品四件套，大红色喜庆款式，寓意红红火火',
        category: GiftCategory.HOME,
        price: 299,
        priceRange: PriceRange.MODERATE,
        imageUrl: $r('app.media.sjt'),
        tags: ['床品', '四件套', '婚庆', '红色'],
        scenarios: [Scenario.WEDDING],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FAMILY,
          interests: [Interest.FASHION, Interest.ART]
        }],
        meaning: '红色床品寓意新婚生活红红火火，幸福美满',
        culturalBackground: '红色在中华文化中是喜庆和吉祥的象征',
        rating: 4.8,
        reviewCount: 2200,
        availability: true,
        purchaseLinks: [
          { platform: '天猫', url: 'https://tmall.com', price: 299, inStock: true }
        ]
      },
      {
        id: '14',
        name: '水晶相框对装',
        description: '精美水晶相框一对，可放置新人婚纱照，永久保存美好回忆',
        category: GiftCategory.HOME,
        price: 188,
        priceRange: PriceRange.BUDGET,
        imageUrl: $r('app.media.sjxk'),
        tags: ['相框', '水晶', '对装', '回忆'],
        scenarios: [Scenario.WEDDING],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.PHOTOGRAPHY, Interest.ART]
        }],
        meaning: '相框保存美好回忆，水晶象征纯洁透明的爱情',
        culturalBackground: '相框在现代家庭中是展示幸福时光的重要装饰',
        rating: 4.6,
        reviewCount: 1300,
        availability: true,
        purchaseLinks: [
          { platform: '淘宝', url: 'https://taobao.com', price: 188, inStock: true }
        ]
      },
      {
        id: '15',
        name: '高档餐具套装',
        description: '精美骨瓷餐具套装，包含盘子、碗、杯子等，适合新婚夫妇使用',
        category: GiftCategory.HOME,
        price: 588,
        priceRange: PriceRange.MODERATE,
        imageUrl: $r('app.media.gdcj'),
        tags: ['餐具', '骨瓷', '套装', '实用'],
        scenarios: [Scenario.WEDDING],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FAMILY,
          interests: [Interest.COOKING, Interest.ART]
        }],
        meaning: '餐具套装寓意新人共同用餐，分享生活的点点滴滴',
        culturalBackground: '精美餐具是建立温馨家庭的重要元素',
        rating: 4.9,
        reviewCount: 950,
        availability: true,
        purchaseLinks: [
          { platform: '京东', url: 'https://jd.com', price: 588, inStock: true }
        ]
      },
      {
        id: '16',
        name: '情侣香薰机套装',
        description: '智能香薰机一对，可定时定量释放香氛，营造浪漫家居氛围',
        category: GiftCategory.ELECTRONICS,
        price: 398,
        priceRange: PriceRange.MODERATE,
        imageUrl: $r('app.media.qlxxj'),
        tags: ['香薰机', '智能', '情侣', '浪漫'],
        scenarios: [Scenario.WEDDING],
        targetGroups: [{
          gender: Gender.UNISEX,
          ageRange: AgeRange.YOUNG_ADULT,
          relationship: Relationship.FRIEND,
          interests: [Interest.TECHNOLOGY, Interest.ART]
        }],
        meaning: '香薰营造温馨氛围，智能科技提升生活品质',
        culturalBackground: '香薰在现代生活中代表品质生活和放松心情',
        rating: 4.5,
        reviewCount: 1600,
        availability: true,
        purchaseLinks: [
          { platform: '天猫', url: 'https://tmall.com', price: 398, inStock: true }
        ]
      }
    ];
  }
}