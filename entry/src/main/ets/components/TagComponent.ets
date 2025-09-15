// 通用标签组件
import { TagInfo, TagCategory } from '../model/GiftEnums';

@Component
export struct TagComponent {
  @Prop tagInfo: TagInfo = {
    category: TagCategory.RECIPIENT,
    value: '',
    label: '',
    color: '#B2BEC3'
  };
  @Prop tagFontSize: number = 12;
  @Prop tagPadding: number = 8;
  @Prop tagBorderRadius: number = 16;
  @Prop tagClickable: boolean = false;
  @Prop tagSelected: boolean = false;
  
  // 点击事件回调
  onTagClick?: (tagInfo: TagInfo) => void;

  // 计算文字颜色，确保对比度
  private getTextColor(backgroundColor: string): string {
    // 移除#号
    const hex = backgroundColor.replace('#', '');
    
    // 转换为RGB
    const r = parseInt(hex.substr(0, 2), 16);
    const g = parseInt(hex.substr(2, 2), 16);
    const b = parseInt(hex.substr(4, 2), 16);
    
    // 计算亮度 (使用相对亮度公式)
    const brightness = (r * 299 + g * 587 + b * 114) / 1000;
    
    // 根据亮度选择文字颜色
    return brightness > 128 ? '#000000' : '#FFFFFF';
  }

  // 获取边框颜色
  private getBorderColor(): string {
    if (this.tagSelected) {
      return this.tagInfo.color;
    }
    return 'transparent';
  }

  // 获取背景颜色
  private getBackgroundColor(): string {
    if (this.tagSelected) {
      return this.tagInfo.color;
    }
    // 未选中时使用半透明背景
    const hex = this.tagInfo.color.replace('#', '');
    const r = parseInt(hex.substr(0, 2), 16);
    const g = parseInt(hex.substr(2, 2), 16);
    const b = parseInt(hex.substr(4, 2), 16);
    return `rgba(${r}, ${g}, ${b}, 0.15)`;
  }

  // 获取文字颜色
  private getFinalTextColor(): string {
    if (this.tagSelected) {
      return this.getTextColor(this.tagInfo.color);
    }
    // 未选中时使用原色
    return this.tagInfo.color;
  }

  build() {
    Text(this.tagInfo.label)
      .fontSize(this.tagFontSize)
      .fontColor(this.getFinalTextColor())
      .padding({
        left: this.tagPadding,
        right: this.tagPadding,
        top: this.tagPadding / 2,
        bottom: this.tagPadding / 2
      })
      .backgroundColor(this.getBackgroundColor())
      .borderRadius(this.tagBorderRadius)
      .border({
        width: this.tagSelected ? 1 : 0,
        color: this.getBorderColor()
      })
      .onClick(() => {
        if (this.tagClickable && this.onTagClick) {
          this.onTagClick(this.tagInfo);
        }
      })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })
  }
}

// 标签列表组件
@Component
export struct TagListComponent {
  @Prop tags: TagInfo[] = [];
  @Prop selectedTags: string[] = [];
  @Prop multiSelect: boolean = true;
  @Prop maxRows: number = 3;
  @Prop spacing: number = 8;
  
  // 标签点击事件回调
  onTagSelected?: (tagValue: string, selected: boolean) => void;

  // 判断标签是否被选中
  private isTagSelected(tagValue: string): boolean {
    return this.selectedTags.includes(tagValue);
  }

  // 处理标签点击
  private handleTagClick = (tagInfo: TagInfo) => {
    const isSelected = this.isTagSelected(tagInfo.value);
    if (this.onTagSelected) {
      this.onTagSelected(tagInfo.value, !isSelected);
    }
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Start
    }) {
      ForEach(this.tags, (tag: TagInfo, index: number) => {
        TagComponent({
          tagInfo: tag,
          tagClickable: true,
          tagSelected: this.isTagSelected(tag.value),
          onTagClick: this.handleTagClick
        })
          .margin({
            right: index < this.tags.length - 1 ? this.spacing : 0,
            bottom: this.spacing
          })
      }, (tag: TagInfo) => tag.value)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}

// 分类标签组件 - 按类别分组显示
@Component
export struct CategoryTagsComponent {
  @Prop recipientTags: TagInfo[] = [];
  @Prop occasionTags: TagInfo[] = [];
  @Prop budgetTags: TagInfo[] = [];
  @Prop giftTypeTags: TagInfo[] = [];
  @Prop selectedTags: string[] = [];
  
  // 标签选择回调
  onTagSelected?: (tagValue: string, selected: boolean) => void;

  // 创建分类标题
  @Builder CategoryTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor('#333333')
      .margin({ top: 16, bottom: 8, left: 16, right: 16 })
  }

  build() {
    Column() {
      // 送给谁
      if (this.recipientTags.length > 0) {
        this.CategoryTitle('送给谁')
        TagListComponent({
          tags: this.recipientTags,
          selectedTags: this.selectedTags,
          onTagSelected: this.onTagSelected
        })
      }

      // 什么场合
      if (this.occasionTags.length > 0) {
        this.CategoryTitle('什么场合')
        TagListComponent({
          tags: this.occasionTags,
          selectedTags: this.selectedTags,
          onTagSelected: this.onTagSelected
        })
      }

      // 预算范围
      if (this.budgetTags.length > 0) {
        this.CategoryTitle('预算范围')
        TagListComponent({
          tags: this.budgetTags,
          selectedTags: this.selectedTags,
          onTagSelected: this.onTagSelected
        })
      }

      // 礼物类型
      if (this.giftTypeTags.length > 0) {
        this.CategoryTitle('礼物类型')
        TagListComponent({
          tags: this.giftTypeTags,
          selectedTags: this.selectedTags,
          onTagSelected: this.onTagSelected
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}