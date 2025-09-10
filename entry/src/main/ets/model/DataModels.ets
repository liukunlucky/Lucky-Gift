// 本地数据模型定义

// 价格范围接口
export interface PriceRange {
  min: number;
  max: number;
}

// 购买链接接口
export interface PurchaseLink {
  platform: string;
  url: string;
  price: number;
  inStock: boolean;
}

// 用户评价接口
export interface UserReview {
  id: string;
  userName: string;
  avatar: string;
  rating: number;
  comment: string;
  date: string;
  images?: string[];
}

// 礼物数据模型
export interface Gift {
  id: string;
  name: string;
  description: string;
  category: string;
  subcategory?: string;
  price: number;
  priceRange: PriceRange;
  imageUrl: string;
  images?: string[];
  brand?: string;
  rating: number;
  reviewCount: number;
  tags: string[]; // ['浪漫', '实用', '创意', '奢华']
  scenarios: string[]; // ['生日', '情人节', '纪念日', '道歉']
  targetGender: string; // 'male', 'female', 'unisex'
  targetAge: string; // '18-25', '26-35', '36-45', '46+'
  relationship: string[]; // ['恋人', '朋友', '家人', '同事']
  meaning: string; // 礼物寓意
  culturalBackground?: string;
  availability: boolean;
  purchaseLinks: PurchaseLink[];
  createdAt: string;
  updatedAt: string;
}

// 用户偏好数据模型
export interface UserPreferences {
  id: string;
  userId: string;
  preferredCategories: string[];
  preferredPriceRange: string;
  preferredBrands: string[];
  preferredTags: string[];
  blacklistedCategories?: string[];
  targetProfiles: TargetProfile[];
  createdAt: string;
  updatedAt: string;
}

// 目标人群画像
export interface TargetProfile {
  id: string;
  name: string; // '女朋友', '妈妈', '好友小李'
  gender: string;
  age: string;
  relationship: string;
  interests: string[];
  preferredGifts: string[]; // 礼物ID列表
  notes?: string;
}

// 收藏记录
export interface FavoriteRecord {
  id: string;
  userId: string;
  giftId: string;
  createdAt: string;
  notes?: string;
}

// 浏览历史
export interface BrowsingHistory {
  id: string;
  userId: string;
  giftId: string;
  viewedAt: string;
  viewDuration?: number; // 浏览时长（秒）
}

// 搜索历史
export interface SearchHistory {
  id: string;
  userId: string;
  keyword: string;
  filters?: SearchFilters;
  resultCount: number;
  searchedAt: string;
}

// 搜索筛选条件
export interface SearchFilters {
  category?: string;
  priceRange?: string;
  brand?: string;
  rating?: number;
  tags?: string[];
  scenarios?: string[];
  targetGender?: string;
  targetAge?: string;
  relationship?: string;
}

// 预算管理
export interface Budget {
  id: string;
  userId: string;
  name: string; // '情人节预算', '生日预算'
  totalAmount: number;
  usedAmount: number;
  category?: string;
  startDate: string;
  endDate: string;
  isActive: boolean;
  createdAt: string;
}

// 消费记录
export interface ExpenseRecord {
  id: string;
  userId: string;
  budgetId?: string;
  giftId: string;
  amount: number;
  recipient: string; // 收礼人
  occasion: string; // 场合
  purchaseDate: string;
  notes?: string;
}

// 节日提醒
export interface HolidayReminder {
  id: string;
  userId: string;
  name: string; // '女朋友生日', '情人节'
  date: string;
  recipient: string;
  reminderDays: number; // 提前几天提醒
  isRecurring: boolean; // 是否每年重复
  isActive: boolean;
  createdAt: string;
}

// 用户数据
export interface User {
  id: string;
  nickname: string;
  avatar?: string;
  gender?: string;
  age?: string;
  createdAt: string;
  lastLoginAt: string;
}

// 礼物分类
export interface GiftCategory {
  id: string;
  name: string;
  parentId?: string; // 父分类ID
  icon: string;
  description?: string;
  sortOrder: number;
  isActive: boolean;
}

// 应用设置
export interface AppSettings {
  id: string;
  userId: string;
  theme: string; // 'light', 'dark', 'auto'
  language: string; // 'zh-CN', 'en-US'
  notifications: NotificationSettings;
  privacy: PrivacySettings;
  updatedAt: string;
}

// 通知设置
export interface NotificationSettings {
  holidayReminders: boolean;
  budgetAlerts: boolean;
  newGiftRecommendations: boolean;
  priceDropAlerts: boolean;
}

// 隐私设置
export interface PrivacySettings {
  shareUsageData: boolean;
  personalizedRecommendations: boolean;
  saveSearchHistory: boolean;
  saveBrowsingHistory: boolean;
}

// 数据库表名接口
interface TableNames {
  GIFTS: string;
  USER_PREFERENCES: string;
  TARGET_PROFILES: string;
  FAVORITE_RECORDS: string;
  BROWSING_HISTORY: string;
  SEARCH_HISTORY: string;
  BUDGETS: string;
  EXPENSE_RECORDS: string;
  HOLIDAY_REMINDERS: string;
  USERS: string;
  GIFT_CATEGORIES: string;
  APP_SETTINGS: string;
}

// 数据库表名常量
export const TABLE_NAMES: TableNames = {
  GIFTS: 'gifts',
  USER_PREFERENCES: 'user_preferences',
  TARGET_PROFILES: 'target_profiles',
  FAVORITE_RECORDS: 'favorite_records',
  BROWSING_HISTORY: 'browsing_history',
  SEARCH_HISTORY: 'search_history',
  BUDGETS: 'budgets',
  EXPENSE_RECORDS: 'expense_records',
  HOLIDAY_REMINDERS: 'holiday_reminders',
  USERS: 'users',
  GIFT_CATEGORIES: 'gift_categories',
  APP_SETTINGS: 'app_settings'
};

// 常量接口
interface Constants {
  PRICE_RANGES: string[];
  GIFT_CATEGORIES: string[];
  SCENARIOS: string[];
  RELATIONSHIPS: string[];
  GENDERS: string[];
  AGE_RANGES: string[];
  TAGS: string[];
}

// 常量定义
export const CONSTANTS: Constants = {
  PRICE_RANGES: ['0-50', '50-200', '200-500', '500-1000', '1000+'],
  GIFT_CATEGORIES: ['首饰', '数码', '服装', '美妆', '家居', '运动', '书籍', '美食', '体验', '其他'],
  SCENARIOS: ['生日', '情人节', '纪念日', '节日', '道歉', '感谢', '求婚', '毕业', '升职', '其他'],
  RELATIONSHIPS: ['恋人', '配偶', '父母', '子女', '朋友', '同事', '老师', '其他'],
  GENDERS: ['male', 'female', 'unisex'],
  AGE_RANGES: ['18-25', '26-35', '36-45', '46-55', '55+'],
  TAGS: ['浪漫', '实用', '创意', '奢华', '简约', '可爱', '个性', '经典', '时尚', '温馨']
};