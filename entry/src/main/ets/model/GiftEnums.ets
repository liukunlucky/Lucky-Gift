// 礼物相关枚举定义

// 送给谁 - 收礼人类型
export enum RecipientType {
  FATHER = 'father',           // 父亲
  MOTHER = 'mother',           // 母亲
  GRANDFATHER = 'grandfather', // 爷爷/外公
  GRANDMOTHER = 'grandmother', // 奶奶/外婆
  ELDER_RELATIVE = 'elder_relative', // 其他长辈
  BOYFRIEND = 'boyfriend',     // 男朋友
  GIRLFRIEND = 'girlfriend',   // 女朋友
  HUSBAND = 'husband',         // 丈夫
  WIFE = 'wife',              // 妻子
  BESTIE = 'bestie',          // 闺蜜
  FRIEND = 'friend',          // 朋友
  COLLEAGUE = 'colleague',     // 同事
  BOSS = 'boss',              // 领导
  TEACHER = 'teacher',        // 老师
  CHILD = 'child',            // 小朋友
  SIBLING = 'sibling',        // 兄弟姐妹
  CLASSMATE = 'classmate',    // 同学
  NEIGHBOR = 'neighbor',      // 邻居
  CLIENT = 'client',          // 客户
  OTHER = 'other'             // 其他
}

// 什么场合 - 送礼场合
export enum OccasionType {
  BIRTHDAY = 'birthday',           // 生日
  ANNIVERSARY = 'anniversary',     // 纪念日
  WEDDING_ANNIVERSARY = 'wedding_anniversary', // 结婚纪念日
  VALENTINE_DAY = 'valentine_day', // 情人节
  CHRISTMAS = 'christmas',         // 圣诞节
  NEW_YEAR = 'new_year',          // 新年
  SPRING_FESTIVAL = 'spring_festival', // 春节
  MOTHERS_DAY = 'mothers_day',    // 母亲节
  FATHERS_DAY = 'fathers_day',    // 父亲节
  TEACHERS_DAY = 'teachers_day',  // 教师节
  GRADUATION = 'graduation',       // 毕业典礼
  PROMOTION = 'promotion',         // 升职加薪
  NEW_JOB = 'new_job',            // 新工作
  HOUSEWARMING = 'housewarming',  // 乔迁之喜
  WEDDING = 'wedding',            // 婚礼
  BABY_SHOWER = 'baby_shower',    // 迎婴派对
  GET_WELL = 'get_well',          // 康复祝福
  APOLOGY = 'apology',            // 道歉
  THANK_YOU = 'thank_you',        // 感谢
  ENCOURAGEMENT = 'encouragement', // 鼓励
  JUST_BECAUSE = 'just_because',  // 无特殊原因
  OTHER = 'other'                 // 其他
}

// 预算范围
export enum BudgetRange {
  UNDER_50 = 'under_50',         // 50元以下
  RANGE_50_100 = 'range_50_100', // 50-100元
  RANGE_100_200 = 'range_100_200', // 100-200元
  RANGE_200_500 = 'range_200_500', // 200-500元
  RANGE_500_1000 = 'range_500_1000', // 500-1000元
  RANGE_1000_2000 = 'range_1000_2000', // 1000-2000元
  OVER_2000 = 'over_2000'        // 2000元以上
}

// 礼物类型
export enum GiftType {
  DIY_HANDMADE = 'diy_handmade',     // DIY手作
  EXPERIENCE = 'experience',          // 体验服务
  DAILY_ITEMS = 'daily_items',       // 日用实物
  CREATIVE_NOVEL = 'creative_novel', // 创意新奇
  TECH_DIGITAL = 'tech_digital',     // 科技数码
  BEAUTY_SKINCARE = 'beauty_skincare', // 美妆护肤
  BOOKS_STATIONERY = 'books_stationery', // 书籍文具
  CLOTHING_ACCESSORIES = 'clothing_accessories', // 服装配饰
  FOOD_BEVERAGE = 'food_beverage',   // 食品饮料
  HOME_DECOR = 'home_decor',         // 家居装饰
  SPORTS_FITNESS = 'sports_fitness', // 运动健身
  TRAVEL_OUTDOOR = 'travel_outdoor', // 旅行户外
  JEWELRY = 'jewelry',               // 珠宝首饰
  FLOWERS_PLANTS = 'flowers_plants', // 鲜花植物
  COLLECTIBLES = 'collectibles',     // 收藏品
  OTHER = 'other'                    // 其他
}

// 收礼人类型显示名称映射
export const RecipientTypeNames: Record<RecipientType, string> = {
  [RecipientType.FATHER]: '父亲',
  [RecipientType.MOTHER]: '母亲',
  [RecipientType.GRANDFATHER]: '爷爷/外公',
  [RecipientType.GRANDMOTHER]: '奶奶/外婆',
  [RecipientType.ELDER_RELATIVE]: '其他长辈',
  [RecipientType.BOYFRIEND]: '男朋友',
  [RecipientType.GIRLFRIEND]: '女朋友',
  [RecipientType.HUSBAND]: '丈夫',
  [RecipientType.WIFE]: '妻子',
  [RecipientType.BESTIE]: '闺蜜',
  [RecipientType.FRIEND]: '朋友',
  [RecipientType.COLLEAGUE]: '同事',
  [RecipientType.BOSS]: '领导',
  [RecipientType.TEACHER]: '老师',
  [RecipientType.CHILD]: '小朋友',
  [RecipientType.SIBLING]: '兄弟姐妹',
  [RecipientType.CLASSMATE]: '同学',
  [RecipientType.NEIGHBOR]: '邻居',
  [RecipientType.CLIENT]: '客户',
  [RecipientType.OTHER]: '其他'
};

// 场合类型显示名称映射
export const OccasionTypeNames: Record<OccasionType, string> = {
  [OccasionType.BIRTHDAY]: '生日',
  [OccasionType.ANNIVERSARY]: '纪念日',
  [OccasionType.WEDDING_ANNIVERSARY]: '结婚纪念日',
  [OccasionType.VALENTINE_DAY]: '情人节',
  [OccasionType.CHRISTMAS]: '圣诞节',
  [OccasionType.NEW_YEAR]: '新年',
  [OccasionType.SPRING_FESTIVAL]: '春节',
  [OccasionType.MOTHERS_DAY]: '母亲节',
  [OccasionType.FATHERS_DAY]: '父亲节',
  [OccasionType.TEACHERS_DAY]: '教师节',
  [OccasionType.GRADUATION]: '毕业典礼',
  [OccasionType.PROMOTION]: '升职加薪',
  [OccasionType.NEW_JOB]: '新工作',
  [OccasionType.HOUSEWARMING]: '乔迁之喜',
  [OccasionType.WEDDING]: '婚礼',
  [OccasionType.BABY_SHOWER]: '迎婴派对',
  [OccasionType.GET_WELL]: '康复祝福',
  [OccasionType.APOLOGY]: '道歉',
  [OccasionType.THANK_YOU]: '感谢',
  [OccasionType.ENCOURAGEMENT]: '鼓励',
  [OccasionType.JUST_BECAUSE]: '无特殊原因',
  [OccasionType.OTHER]: '其他'
};

// 预算范围显示名称映射
export const BudgetRangeNames: Record<BudgetRange, string> = {
  [BudgetRange.UNDER_50]: '50元以下',
  [BudgetRange.RANGE_50_100]: '50-100元',
  [BudgetRange.RANGE_100_200]: '100-200元',
  [BudgetRange.RANGE_200_500]: '200-500元',
  [BudgetRange.RANGE_500_1000]: '500-1000元',
  [BudgetRange.RANGE_1000_2000]: '1000-2000元',
  [BudgetRange.OVER_2000]: '2000元以上'
};

// 礼物类型显示名称映射
export const GiftTypeNames: Record<GiftType, string> = {
  [GiftType.DIY_HANDMADE]: 'DIY手作',
  [GiftType.EXPERIENCE]: '体验服务',
  [GiftType.DAILY_ITEMS]: '日用实物',
  [GiftType.CREATIVE_NOVEL]: '创意新奇',
  [GiftType.TECH_DIGITAL]: '科技数码',
  [GiftType.BEAUTY_SKINCARE]: '美妆护肤',
  [GiftType.BOOKS_STATIONERY]: '书籍文具',
  [GiftType.CLOTHING_ACCESSORIES]: '服装配饰',
  [GiftType.FOOD_BEVERAGE]: '食品饮料',
  [GiftType.HOME_DECOR]: '家居装饰',
  [GiftType.SPORTS_FITNESS]: '运动健身',
  [GiftType.TRAVEL_OUTDOOR]: '旅行户外',
  [GiftType.JEWELRY]: '珠宝首饰',
  [GiftType.FLOWERS_PLANTS]: '鲜花植物',
  [GiftType.COLLECTIBLES]: '收藏品',
  [GiftType.OTHER]: '其他'
};

// 收礼人类型颜色映射 - 统一使用蓝色系（送给谁类别）
export const RecipientTypeColors: Record<RecipientType, string> = {
  [RecipientType.FATHER]: '#74B9FF',      // 蓝色 - 父亲
  [RecipientType.MOTHER]: '#74B9FF',      // 蓝色 - 母亲
  [RecipientType.GRANDFATHER]: '#74B9FF', // 蓝色 - 爷爷/外公
  [RecipientType.GRANDMOTHER]: '#74B9FF', // 蓝色 - 奶奶/外婆
  [RecipientType.ELDER_RELATIVE]: '#74B9FF', // 蓝色 - 其他长辈
  [RecipientType.BOYFRIEND]: '#74B9FF',   // 蓝色 - 男朋友
  [RecipientType.GIRLFRIEND]: '#74B9FF',  // 蓝色 - 女朋友
  [RecipientType.HUSBAND]: '#74B9FF',     // 蓝色 - 丈夫
  [RecipientType.WIFE]: '#74B9FF',        // 蓝色 - 妻子
  [RecipientType.BESTIE]: '#74B9FF',      // 蓝色 - 闺蜜
  [RecipientType.FRIEND]: '#74B9FF',      // 蓝色 - 朋友
  [RecipientType.COLLEAGUE]: '#74B9FF',   // 蓝色 - 同事
  [RecipientType.BOSS]: '#74B9FF',        // 蓝色 - 领导
  [RecipientType.TEACHER]: '#74B9FF',     // 蓝色 - 老师
  [RecipientType.CHILD]: '#74B9FF',       // 蓝色 - 小朋友
  [RecipientType.SIBLING]: '#74B9FF',     // 蓝色 - 兄弟姐妹
  [RecipientType.CLASSMATE]: '#74B9FF',   // 蓝色 - 同学
  [RecipientType.NEIGHBOR]: '#74B9FF',    // 蓝色 - 邻居
  [RecipientType.CLIENT]: '#74B9FF',      // 蓝色 - 客户
  [RecipientType.OTHER]: '#74B9FF'        // 蓝色 - 其他
};

// 场合类型颜色映射 - 统一使用绿色系（场合类别）
export const OccasionTypeColors: Record<OccasionType, string> = {
  [OccasionType.BIRTHDAY]: '#00B894',         // 绿色 - 生日
  [OccasionType.ANNIVERSARY]: '#00B894',      // 绿色 - 纪念日
  [OccasionType.WEDDING_ANNIVERSARY]: '#00B894', // 绿色 - 结婚纪念日
  [OccasionType.VALENTINE_DAY]: '#00B894',    // 绿色 - 情人节
  [OccasionType.CHRISTMAS]: '#00B894',        // 绿色 - 圣诞节
  [OccasionType.NEW_YEAR]: '#00B894',         // 绿色 - 新年
  [OccasionType.SPRING_FESTIVAL]: '#00B894',  // 绿色 - 春节
  [OccasionType.MOTHERS_DAY]: '#00B894',      // 绿色 - 母亲节
  [OccasionType.FATHERS_DAY]: '#00B894',      // 绿色 - 父亲节
  [OccasionType.TEACHERS_DAY]: '#00B894',     // 绿色 - 教师节
  [OccasionType.GRADUATION]: '#00B894',       // 绿色 - 毕业典礼
  [OccasionType.PROMOTION]: '#00B894',        // 绿色 - 升职加薪
  [OccasionType.NEW_JOB]: '#00B894',          // 绿色 - 新工作
  [OccasionType.HOUSEWARMING]: '#00B894',     // 绿色 - 乔迁之喜
  [OccasionType.WEDDING]: '#00B894',          // 绿色 - 婚礼
  [OccasionType.BABY_SHOWER]: '#00B894',      // 绿色 - 迎婴派对
  [OccasionType.GET_WELL]: '#00B894',         // 绿色 - 康复祝福
  [OccasionType.APOLOGY]: '#00B894',          // 绿色 - 道歉
  [OccasionType.THANK_YOU]: '#00B894',        // 绿色 - 感谢
  [OccasionType.ENCOURAGEMENT]: '#00B894',    // 绿色 - 鼓励
  [OccasionType.JUST_BECAUSE]: '#00B894',     // 绿色 - 无特殊原因
  [OccasionType.OTHER]: '#00B894'             // 绿色 - 其他
};

// 预算范围颜色映射 - 统一使用紫色系（预算类别）
export const BudgetRangeColors: Record<BudgetRange, string> = {
  [BudgetRange.UNDER_50]: '#6C5CE7',          // 紫色 - 50元以下
  [BudgetRange.RANGE_50_100]: '#6C5CE7',      // 紫色 - 50-100元
  [BudgetRange.RANGE_100_200]: '#6C5CE7',     // 紫色 - 100-200元
  [BudgetRange.RANGE_200_500]: '#6C5CE7',     // 紫色 - 200-500元
  [BudgetRange.RANGE_500_1000]: '#6C5CE7',    // 紫色 - 500-1000元
  [BudgetRange.RANGE_1000_2000]: '#6C5CE7',   // 紫色 - 1000-2000元
  [BudgetRange.OVER_2000]: '#6C5CE7'          // 紫色 - 2000元以上
};

// 礼物类型颜色映射 - 统一使用橙色系（礼物类型类别）
export const GiftTypeColors: Record<GiftType, string> = {
  [GiftType.DIY_HANDMADE]: '#E17055',         // 橙色 - DIY手作
  [GiftType.EXPERIENCE]: '#E17055',           // 橙色 - 体验服务
  [GiftType.DAILY_ITEMS]: '#E17055',          // 橙色 - 日用实物
  [GiftType.CREATIVE_NOVEL]: '#E17055',       // 橙色 - 创意新奇
  [GiftType.TECH_DIGITAL]: '#E17055',         // 橙色 - 科技数码
  [GiftType.BEAUTY_SKINCARE]: '#E17055',      // 橙色 - 美妆护肤
  [GiftType.BOOKS_STATIONERY]: '#E17055',     // 橙色 - 书籍文具
  [GiftType.CLOTHING_ACCESSORIES]: '#E17055', // 橙色 - 服装配饰
  [GiftType.FOOD_BEVERAGE]: '#E17055',        // 橙色 - 食品饮料
  [GiftType.HOME_DECOR]: '#E17055',           // 橙色 - 家居装饰
  [GiftType.SPORTS_FITNESS]: '#E17055',       // 橙色 - 运动健身
  [GiftType.TRAVEL_OUTDOOR]: '#E17055',       // 橙色 - 旅行户外
  [GiftType.JEWELRY]: '#E17055',              // 橙色 - 珠宝首饰
  [GiftType.FLOWERS_PLANTS]: '#E17055',       // 橙色 - 鲜花植物
  [GiftType.COLLECTIBLES]: '#E17055',         // 橙色 - 收藏品
  [GiftType.OTHER]: '#E17055'                 // 橙色 - 其他
};

// 枚举选项接口
export interface EnumOption<T> {
  value: T;
  label: string;
  color: string;
}

// 获取收礼人类型选项
export function getRecipientTypeOptions(): Array<EnumOption<RecipientType>> {
  const options: Array<EnumOption<RecipientType>> = [];
  Object.values(RecipientType).forEach(type => {
    const option: EnumOption<RecipientType> = {
      value: type,
      label: RecipientTypeNames[type],
      color: RecipientTypeColors[type]
    };
    options.push(option);
  });
  return options;
}

// 获取场合类型选项
export function getOccasionTypeOptions(): Array<EnumOption<OccasionType>> {
  const options: Array<EnumOption<OccasionType>> = [];
  Object.values(OccasionType).forEach(type => {
    const option: EnumOption<OccasionType> = {
      value: type,
      label: OccasionTypeNames[type],
      color: OccasionTypeColors[type]
    };
    options.push(option);
  });
  return options;
}

// 获取预算范围选项
export function getBudgetRangeOptions(): Array<EnumOption<BudgetRange>> {
  const options: Array<EnumOption<BudgetRange>> = [];
  Object.values(BudgetRange).forEach(type => {
    const option: EnumOption<BudgetRange> = {
      value: type,
      label: BudgetRangeNames[type],
      color: BudgetRangeColors[type]
    };
    options.push(option);
  });
  return options;
}

// 获取礼物类型选项
export function getGiftTypeOptions(): Array<EnumOption<GiftType>> {
  const options: Array<EnumOption<GiftType>> = [];
  Object.values(GiftType).forEach(type => {
    const option: EnumOption<GiftType> = {
      value: type,
      label: GiftTypeNames[type],
      color: GiftTypeColors[type]
    };
    options.push(option);
  });
  return options;
}

// 工具函数：根据类型获取显示名称
export function getRecipientTypeName(type: RecipientType): string {
  return RecipientTypeNames[type] || '其他';
}

export function getOccasionTypeName(type: OccasionType): string {
  return OccasionTypeNames[type] || '其他';
}

export function getBudgetRangeName(type: BudgetRange): string {
  return BudgetRangeNames[type] || '未知';
}

export function getGiftTypeName(type: GiftType): string {
  return GiftTypeNames[type] || '其他';
}

// 工具函数：根据类型获取颜色
export function getRecipientTypeColor(type: RecipientType): string {
  return RecipientTypeColors[type] || '#B2BEC3';
}

export function getOccasionTypeColor(type: OccasionType): string {
  return OccasionTypeColors[type] || '#B2BEC3';
}

export function getBudgetRangeColor(type: BudgetRange): string {
  return BudgetRangeColors[type] || '#B2BEC3';
}

export function getGiftTypeColor(type: GiftType): string {
  return GiftTypeColors[type] || '#B2BEC3';
}

// 反向映射函数：根据显示名称获取枚举值
export function getRecipientTypeByName(name: string): RecipientType | null {
  const entries = Object.entries(RecipientTypeNames);
  for (let i = 0; i < entries.length; i++) {
    const entry = entries[i];
    const enumValue = entry[0] as RecipientType;
    const displayName = entry[1];
    if (displayName === name) {
      return enumValue;
    }
  }
  return null;
}

export function getOccasionTypeByName(name: string): OccasionType | null {
  const entries = Object.entries(OccasionTypeNames);
  for (let i = 0; i < entries.length; i++) {
    const entry = entries[i];
    const enumValue = entry[0] as OccasionType;
    const displayName = entry[1];
    if (displayName === name) {
      return enumValue;
    }
  }
  return null;
}

export function getGiftTypeByName(name: string): GiftType | null {
  const entries = Object.entries(GiftTypeNames);
  for (let i = 0; i < entries.length; i++) {
    const entry = entries[i];
    const enumValue = entry[0] as GiftType;
    const displayName = entry[1];
    if (displayName === name) {
      return enumValue;
    }
  }
  return null;
}

// 标签类型枚举 - 用于区分不同的标签类别
export enum TagCategory {
  RECIPIENT = 'recipient',   // 收礼人
  OCCASION = 'occasion',     // 场合
  BUDGET = 'budget',         // 预算
  GIFT_TYPE = 'gift_type'    // 礼物类型
}

// 通用标签接口
export interface TagInfo {
  category: TagCategory;
  value: string;
  label: string;
  color: string;
}

// 根据标签值和类别获取标签信息
export function getTagInfo(category: TagCategory, value: string): TagInfo | null {
  let label = '';
  let color = '#B2BEC3';
  
  switch (category) {
    case TagCategory.RECIPIENT:
      const recipientType = value as RecipientType;
      label = getRecipientTypeName(recipientType);
      color = getRecipientTypeColor(recipientType);
      break;
    case TagCategory.OCCASION:
      const occasionType = value as OccasionType;
      label = getOccasionTypeName(occasionType);
      color = getOccasionTypeColor(occasionType);
      break;
    case TagCategory.BUDGET:
      const budgetRange = value as BudgetRange;
      label = getBudgetRangeName(budgetRange);
      color = getBudgetRangeColor(budgetRange);
      break;
    case TagCategory.GIFT_TYPE:
      const giftType = value as GiftType;
      label = getGiftTypeName(giftType);
      color = getGiftTypeColor(giftType);
      break;
    default:
      return null;
  }
  
  const tagInfo: TagInfo = {
    category: category,
    value: value,
    label: label,
    color: color
  };
  return tagInfo;
}