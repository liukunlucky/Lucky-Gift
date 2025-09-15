// 新架构数据模型定义

// 联系人/关系网络模型
export interface Contact {
  id: string;
  name: string;
  relationship: string; // 父母、恋人、朋友、同事等
  avatar?: string;
  birthday?: string;
  importantDates: ImportantDate[];
  preferences: ContactPreference[];
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

// 重要日期
export interface ImportantDate {
  id: string;
  contactId: string;
  name: string; // 生日、纪念日等
  date: string;
  isRecurring: boolean; // 是否每年重复
  reminderEnabled: boolean;
  reminderDays: number; // 提前几天提醒
}

// 联系人偏好
export interface ContactPreference {
  id: string;
  contactId: string;
  category: string; // 兴趣、喜好、厌恶等
  content: string;
  priority: 'high' | 'medium' | 'low';
}

// 礼物事件（时间轴核心数据）
export interface GiftEvent {
  id?: string;
  contactId: string;
  contactName: string;
  occasion: string; // 场合：生日、纪念日、节日等
  date: string;
  giftIdea: string; // 礼物创意描述
  actualGift?: string; // 实际送的礼物
  budget: number;
  actualCost?: number;
  images: string[]; // 本地图片路径
  story?: string; // 送礼故事
  reaction?: string; // 对方反应
  mood?: string; // 自己的心情
  tags: string[];
  reminderSet: boolean;
  reminderDate?: string;
  createdAt?: string;
  updatedAt?: string;
}

// 灵感分类模型
export interface InspirationCategory {
  id?: string;
  name: string;
  description: string;
  icon: string;
  color: string;
  orderIndex: number;
  isActive: boolean;
  createdAt?: string;
}

// 灵感标签模型
export interface InspirationTag {
  id?: string;
  name: string;
  category: string;
  color: string;
  isPopular: boolean;
  createdAt?: string;
}

// 灵感创意模型
export interface Inspiration {
  id?: string;
  title: string;
  description: string;
  detailedDescription?: string;
  images: string[]; // 本地示例图片路径
  tags: string[];
  targetAudience: string[]; // 适合对象：父母、恋人等
  occasions: string[]; // 适合场合：生日、纪念日等
  interests: string[]; // 适合兴趣：美食、读书等
  budgetRange: BudgetRange;
  giftType: string; // DIY手作、体验之旅等
  difficulty: 'easy' | 'medium' | 'hard';
  timeRequired?: string; // 所需时间
  materials?: string[]; // 所需材料
  steps?: string[]; // 制作步骤
  tips?: string[]; // 小贴士
  isRecommended: boolean;
  createdAt?: string;
}

// 预算范围
export interface BudgetRange {
  min: number;
  max: number;
  label: string; // "50元以下"、"50-200元"等
}

// 收藏的灵感
export interface FavoriteInspiration {
  id: string;
  inspirationId: string;
  userId: string; // 预留字段
  notes?: string; // 用户备注
  createdAt: string;
}

// 礼物卡模板
export interface GiftCardTemplate {
  id: string;
  name: string;
  previewImage: string;
  templatePath: string; // 模板文件路径
  category: string;
  isDefault: boolean;
}

// 用户创建的礼物卡
export interface UserGiftCard {
  id: string;
  templateId: string;
  title: string;
  message: string;
  recipientName?: string;
  senderName?: string;
  createdAt: string;
  imagePath?: string; // 生成的卡片图片路径
}

// 节日信息
export interface Holiday {
  id: string;
  name: string;
  date: string; // 固定日期或计算规则
  isRecurring: boolean;
  description?: string;
  giftSuggestions: string[];
  icon?: string;
}

// 提醒通知
export interface Reminder {
  id: string;
  type: 'gift_event' | 'important_date' | 'holiday';
  relatedId: string; // 关联的事件ID
  contactId?: string; // 联系人ID
  title: string;
  message: string;
  content?: string; // 提醒内容
  reminderDate: string;
  dateTime?: string; // 提醒日期时间
  isActive: boolean;
  isEnabled?: boolean; // 是否启用
  isTriggered: boolean;
  isCompleted?: boolean; // 是否完成
  createdAt: string;
  reminderId?: number; // 系统提醒ID
}

// 应用设置
export interface AppSettings {
  id: string;
  defaultReminderDays: number;
  enableNotifications: boolean;
  dataBackupEnabled: boolean;
  lastBackupDate?: string;
  themeMode: 'light' | 'dark' | 'auto';
  language: string;
  privacyMode: boolean;
}

// 数据统计
export interface DataStats {
  totalContacts: number;
  totalGiftEvents: number;
  totalFavoriteInspirations: number;
  totalSpent: number;
  averageGiftCost: number;
  mostFrequentOccasion: string;
  mostGiftedContact: string;
  lastUpdated: string;
}

// 导出数据结构
export interface ExportDataV2 {
  version: string;
  exportDate: string;
  contacts: Contact[];
  giftEvents: GiftEvent[];
  favoriteInspirations: FavoriteInspiration[];
  userGiftCards: UserGiftCard[];
  reminders: Reminder[];
  settings: AppSettings;
  stats: DataStats;
}

// 分类枚举
export enum GiftCategory {
  BY_RECIPIENT = 'by_recipient', // 按对象送
  BY_OCCASION = 'by_occasion',   // 按场合送
  BY_INTEREST = 'by_interest',   // 按兴趣送
  BY_BUDGET = 'by_budget',       // 按预算送
  BY_TYPE = 'by_type'            // 按类型送
}

export enum RelationshipType {
  FAMILY = 'family',
  ROMANTIC = 'romantic',
  FRIEND = 'friend',
  COLLEAGUE = 'colleague',
  OTHER = 'other'
}

export enum OccasionType {
  BIRTHDAY = 'birthday',
  ANNIVERSARY = 'anniversary',
  WEDDING = 'wedding',
  GRADUATION = 'graduation',
  HOLIDAY = 'holiday',
  APOLOGY = 'apology',
  CELEBRATION = 'celebration',
  OTHER = 'other'
}

export enum InterestType {
  FOODIE = 'foodie',
  READER = 'reader',
  TECH = 'tech',
  TRAVEL = 'travel',
  FITNESS = 'fitness',
  ART = 'art',
  MUSIC = 'music',
  FASHION = 'fashion',
  OTHER = 'other'
}

export enum GiftType {
  DIY = 'diy',
  EXPERIENCE = 'experience',
  PRACTICAL = 'practical',
  SURPRISE = 'surprise',
  LUXURY = 'luxury',
  PERSONALIZED = 'personalized'
}

// 预算计算模型
export interface BudgetCalculation {
  id: string;
  name: string;
  title?: string;
  totalBudget: number;
  numberOfPeople?: number;
  budgetPerPerson?: number;
  items: BudgetItem[];
  createdAt: string;
}

export interface BudgetItem {
  id: string;
  name: string;
  estimatedCost: number;
  actualCost?: number;
  category: string;
  priority: 'high' | 'medium' | 'low';
}

// 节日倒计时模型
export interface HolidayCountdown {
  id: string;
  name: string;
  date: string;
  description?: string;
  isImportant: boolean;
  reminderDays: number;
  daysUntil?: number;
  createdAt: string;
}

// 快速筛选器模型
export interface QuickFilter {
  name: string;
  tags: string[];
  color: string;
}