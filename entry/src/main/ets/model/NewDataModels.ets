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
  recordType: 'give' | 'receive'; // 记录类型：'give'送礼 或 'receive'收礼
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
  images: Resource[]; // 本地示例图片资源
  stepImages?: Resource[]; // 步骤图片
  resultImages?: Resource[]; // 成果展示图片
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
  precautions?: string[]; // 注意事项
  alternatives?: string[]; // 替代方案
  inspiration?: string; // 创意来源
  personalizedTips?: string[]; // 个性化建议
  seasonality?: string; // 季节性建议
  giftWrapIdeas?: string[]; // 包装建议
  presentationTips?: string[]; // 赠送技巧
  followUpSuggestions?: string[]; // 后续建议
  relatedInspirations?: string[]; // 相关灵感ID
  viewCount?: number; // 浏览次数
  favoriteCount?: number; // 收藏次数
  rating?: number; // 评分
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

// 心愿优先级
export enum WishPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}

// 心愿状态
export enum WishStatus {
  ACTIVE = 'active',        // 活跃的心愿
  ACHIEVED = 'achieved',    // 已实现
  CANCELLED = 'cancelled',  // 已取消
  POSTPONED = 'postponed'   // 已推迟
}

// 心愿分类
export enum WishCategory {
  GIFT = 'gift',           // 礼物心愿
  EXPERIENCE = 'experience', // 体验心愿
  TRAVEL = 'travel',       // 旅行心愿
  LEARNING = 'learning',   // 学习心愿
  HEALTH = 'health',       // 健康心愿
  CAREER = 'career',       // 事业心愿
  RELATIONSHIP = 'relationship', // 关系心愿
  HOBBY = 'hobby',         // 爱好心愿
  OTHER = 'other'          // 其他
}

// 我的心愿数据模型
export interface MyWish {
  id?: string;
  title: string;                    // 心愿标题
  description: string;              // 详细描述
  category: WishCategory;           // 心愿分类
  priority: WishPriority;           // 优先级
  status: WishStatus;               // 状态
  targetDate?: string;              // 期望实现日期
  estimatedCost?: number;           // 预估费用
  actualCost?: number;              // 实际费用
  tags: string[];                   // 标签
  images: string[];                 // 相关图片
  notes?: string;                   // 备注
  progress: number;                 // 进度百分比 (0-100)
  relatedContacts?: string[];       // 相关联系人ID
  inspirationSource?: string;       // 灵感来源
  achievedDate?: string;            // 实现日期
  achievementNotes?: string;        // 实现心得
  reminderEnabled: boolean;         // 是否启用提醒
  reminderDate?: string;            // 提醒日期
  isPublic: boolean;                // 是否公开（预留功能）
  createdAt?: string;
  updatedAt?: string;
}

// 心愿进度记录
export interface WishProgress {
  id?: string;
  wishId: string;                   // 心愿ID
  progressValue: number;            // 进度值 (0-100)
  description: string;              // 进度描述
  images?: string[];                // 进度图片
  notes?: string;                   // 进度备注
  createdAt?: string;
}

// 心愿统计
export interface WishStats {
  totalWishes: number;              // 总心愿数
  activeWishes: number;             // 活跃心愿数
  achievedWishes: number;           // 已实现心愿数
  totalEstimatedCost: number;       // 总预估费用
  totalActualCost: number;          // 总实际费用
  averageAchievementTime: number;   // 平均实现时间（天）
  categoryStats: Map<string, number>; // 分类统计
  priorityStats: Map<string, number>; // 优先级统计
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

// 礼物故事模型
export interface GiftStory {
  id?: string;
  giftEventId: string; // 关联的礼物记录ID
  giftEventTitle: string; // 礼物记录标题（冗余字段，便于显示）
  contactName: string; // 收礼人姓名（冗余字段）
  title: string; // 故事标题
  content: string; // 故事内容
  images: string[]; // 最多3张照片的本地路径
  emotion: string; // 当时的心情/感受
  reason: string; // 选择这个礼物的原因
  scene: string; // 当时的情景描述
  tags: string[]; // 标签
  createdAt?: string;
  updatedAt?: string;
}

// 成就系统模型
// 成就模板（固定的成就定义）
export interface Achievement {
  id: string;
  name: string; // 成就名称
  description: string; // 成就描述
  icon: string; // 成就图标
  type: AchievementType; // 成就类型
  conditionType: AchievementType; // 条件类型
  targetValue: number; // 目标值
  timeWindow?: number; // 时间窗口（天数），用于连续性成就
  specificValue?: string; // 特定值，如"非常开心"
}

// 成就类型枚举
export enum AchievementType {
  GIFT_COUNT = 'gift_count', // 送礼次数
  FEEDBACK_QUALITY = 'feedback_quality', // 反馈质量
  BUDGET_CONTROL = 'budget_control', // 预算控制
  PLANNING_AHEAD = 'planning_ahead' // 提前规划
}

// 用户成就进度（每个用户的个人成就状态）
export interface UserAchievementProgress {
  id: string;
  userId: string;
  achievementId: string;
  currentProgress: number;
  isUnlocked: boolean;
  unlockedAt?: string;
  lastUpdated: string;
}

// 用户成就详情（包含模板信息和个人进度）
export interface UserAchievementDetail {
  template: Achievement; // 成就模板
  progress: UserAchievementProgress; // 个人进度
  progressPercentage: number; // 进度百分比
}

// 成就里程碑
export interface AchievementMilestone {
  date: string;
  description: string;
  relatedEventId?: string; // 相关事件ID
}

// 成就统计
export interface AchievementStats {
  total: number;
  unlocked: number;
  progress: number;
}