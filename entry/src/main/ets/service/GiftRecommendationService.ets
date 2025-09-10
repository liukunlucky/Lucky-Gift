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
        imageUrl: 'jewelry_necklace_1.jpg',
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
        imageUrl: 'electronics_airpods.jpg',
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
        imageUrl: 'flowers_preserved.jpg',
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
      }
      // 可以继续添加更多礼物数据...
    ];
  }
}