// 关系类型枚举
export enum RelationshipType {
  FAMILY = 'family',      // 家人
  FRIEND = 'friend',      // 朋友
  RELATIVE = 'relative',  // 亲戚
  COLLEAGUE = 'colleague', // 同事
  CLASSMATE = 'classmate', // 同学
  OTHER = 'other'         // 其他
}

// 关系类型显示名称映射
export const RelationshipTypeNames: Record<RelationshipType, string> = {
  [RelationshipType.FAMILY]: '家人',
  [RelationshipType.FRIEND]: '朋友',
  [RelationshipType.RELATIVE]: '亲戚',
  [RelationshipType.COLLEAGUE]: '同事',
  [RelationshipType.CLASSMATE]: '同学',
  [RelationshipType.OTHER]: '其他'
};

// 关系类型颜色映射 - 浅色系列，参考首页灵感标签颜色
export const RelationshipTypeColors: Record<RelationshipType, string> = {
  [RelationshipType.FAMILY]: '#FFE5E5',    // 浅粉色 - 家人（温馨感）
  [RelationshipType.FRIEND]: '#FFF5F0',    // 浅橙色 - 朋友（温暖感）
  [RelationshipType.RELATIVE]: '#F0F8FF',  // 浅蓝色 - 亲戚（清新感）
  [RelationshipType.COLLEAGUE]: '#F5F5F5', // 浅灰色 - 同事（专业感）
  [RelationshipType.CLASSMATE]: '#F0FFF0', // 浅绿色 - 同学（活力感）
  [RelationshipType.OTHER]: '#F8F8F8'      // 极浅灰色 - 其他（中性色）
};

// 关系类型前景文字颜色映射 - 与浅色背景形成良好对比度
export const RelationshipTypeTextColors: Record<RelationshipType, string> = {
  [RelationshipType.FAMILY]: '#D63384',    // 深粉色 - 与浅粉色背景对比
  [RelationshipType.FRIEND]: '#FD7E14',    // 深橙色 - 与浅橙色背景对比
  [RelationshipType.RELATIVE]: '#0D6EFD',  // 深蓝色 - 与浅蓝色背景对比
  [RelationshipType.COLLEAGUE]: '#6C757D', // 深灰色 - 与浅灰色背景对比
  [RelationshipType.CLASSMATE]: '#198754', // 深绿色 - 与浅绿色背景对比
  [RelationshipType.OTHER]: '#6C757D'      // 深灰色 - 与极浅灰色背景对比
};

// 关系类型选项接口
export interface RelationshipTypeOption {
  value: RelationshipType;
  label: string;
}

// 获取所有关系类型选项
export function getAllRelationshipTypes(): Array<RelationshipTypeOption> {
  const options: Array<RelationshipTypeOption> = [];
  Object.values(RelationshipType).forEach(type => {
    const option: RelationshipTypeOption = {
      value: type,
      label: RelationshipTypeNames[type]
    };
    options.push(option);
  });
  return options;
}

// 根据关系类型获取显示名称
export function getRelationshipTypeName(type: RelationshipType): string {
  return RelationshipTypeNames[type] || '其他';
}

// 根据关系类型获取背景颜色
export function getRelationshipTypeColor(type: RelationshipType): string {
  return RelationshipTypeColors[type] || '#A0A0A0';
}

// 根据关系类型获取前景文字颜色
export function getRelationshipTypeTextColor(type: RelationshipType): string {
  return RelationshipTypeTextColors[type] || '#6C757D';
}