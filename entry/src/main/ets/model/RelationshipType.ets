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

// 关系类型颜色映射
export const RelationshipTypeColors: Record<RelationshipType, string> = {
  [RelationshipType.FAMILY]: '#FF6B6B',    // 红色 - 家人
  [RelationshipType.FRIEND]: '#4ECDC4',    // 青色 - 朋友
  [RelationshipType.RELATIVE]: '#45B7D1',  // 蓝色 - 亲戚
  [RelationshipType.COLLEAGUE]: '#96CEB4', // 绿色 - 同事
  [RelationshipType.CLASSMATE]: '#FECA57', // 黄色 - 同学
  [RelationshipType.OTHER]: '#A0A0A0'      // 灰色 - 其他
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

// 根据关系类型获取颜色
export function getRelationshipTypeColor(type: RelationshipType): string {
  return RelationshipTypeColors[type] || '#A0A0A0';
}