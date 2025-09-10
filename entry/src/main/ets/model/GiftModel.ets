// 礼物数据模型
export interface Gift {
  id: string;
  name: string;
  description: string;
  category: GiftCategory;
  price: number;
  priceRange: PriceRange;
  imageUrl: string;
  tags: string[];
  scenarios: Scenario[];
  targetGroups: TargetGroup[];
  meaning: string;
  culturalBackground?: string;
  rating: number;
  reviewCount: number;
  brand?: string;
  availability: boolean;
  purchaseLinks: PurchaseLink[];
}

// 礼物分类
export enum GiftCategory {
  JEWELRY = 'jewelry',
  ELECTRONICS = 'electronics',
  BOOKS = 'books',
  FLOWERS = 'flowers',
  COSMETICS = 'cosmetics',
  CLOTHING = 'clothing',
  FOOD = 'food',
  TOYS = 'toys',
  SPORTS = 'sports',
  HOME = 'home',
  ART = 'art',
  EXPERIENCE = 'experience'
}

// 价格区间
export enum PriceRange {
  BUDGET = 'budget',      // 0-100
  MODERATE = 'moderate',  // 100-500
  PREMIUM = 'premium',    // 500-1000
  LUXURY = 'luxury'       // 1000+
}

// 送礼场景
export enum Scenario {
  BIRTHDAY = 'birthday',
  ANNIVERSARY = 'anniversary',
  VALENTINE = 'valentine',
  CHRISTMAS = 'christmas',
  GRADUATION = 'graduation',
  WEDDING = 'wedding',
  APOLOGY = 'apology',
  THANK_YOU = 'thank_you',
  CONGRATULATIONS = 'congratulations',
  GET_WELL = 'get_well',
  HOUSEWARMING = 'housewarming',
  PROMOTION = 'promotion'
}

// 目标人群
export interface TargetGroup {
  gender: Gender;
  ageRange: AgeRange;
  relationship: Relationship;
  interests: Interest[];
}

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  UNISEX = 'unisex'
}

export enum AgeRange {
  CHILD = 'child',        // 0-12
  TEEN = 'teen',          // 13-17
  YOUNG_ADULT = 'young_adult', // 18-30
  ADULT = 'adult',        // 31-50
  SENIOR = 'senior'       // 50+
}

export enum Relationship {
  FAMILY = 'family',
  FRIEND = 'friend',
  ROMANTIC = 'romantic',
  COLLEAGUE = 'colleague',
  TEACHER = 'teacher',
  BOSS = 'boss',
  ACQUAINTANCE = 'acquaintance'
}

export enum Interest {
  TECHNOLOGY = 'technology',
  FASHION = 'fashion',
  SPORTS = 'sports',
  MUSIC = 'music',
  READING = 'reading',
  COOKING = 'cooking',
  TRAVEL = 'travel',
  ART = 'art',
  GAMING = 'gaming',
  FITNESS = 'fitness',
  BEAUTY = 'beauty',
  PHOTOGRAPHY = 'photography'
}

// 购买链接
export interface PurchaseLink {
  platform: string;
  url: string;
  price: number;
  inStock: boolean;
}

// 礼物推荐请求
export interface GiftRecommendationRequest {
  scenario?: Scenario;
  targetGroup?: TargetGroup;
  priceRange?: PriceRange;
  category?: GiftCategory;
  keywords?: string[];
  excludeIds?: string[];
}

// 礼物推荐响应
export interface GiftRecommendationResponse {
  gifts: Gift[];
  totalCount: number;
  recommendationReason: string;
}