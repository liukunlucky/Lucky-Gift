import router from '@ohos.router';
import { Inspiration, BudgetRange } from '../model/NewDataModels';
import { MyInspirationDAO } from '../database/MyInspirationDAO';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { GiftType, GiftTypeNames, RecipientType, RecipientTypeNames, OccasionType, OccasionTypeNames, getRecipientTypeByName, getOccasionTypeByName, getGiftTypeByName } from '../model/GiftEnums';

@Entry
@Component
struct AddInspirationPage {
  // 基本信息
  @State title: string = '';
  @State description: string = '';
  @State detailedDescription: string = '';
  
  // 分类信息
  @State selectedTargetAudience: string = '';
  @State selectedOccasions: string = '';
  
  // 预算信息
  @State budgetMin: number = 0;
  @State budgetMax: number = 100;
  @State budgetLabel: string = '0-100元';
  
  // 类型和难度
  @State giftType: string = '';
  @State difficulty: 'easy' | 'medium' | 'hard' = 'easy';
  @State timeRequired: string = '';
  
  // 详细信息
  @State materials: string[] = [];
  @State steps: string[] = [];
  @State tips: string[] = [];
  
  // 临时输入
  @State newMaterial: string = '';
  @State newStep: string = '';
  @State newTip: string = '';
  
  // 数据库相关
  private dbManager: NewDatabaseManager | null = null;
  private myInspirationDAO: MyInspirationDAO | null = null;
  
  // 编辑模式
  @State isEditMode: boolean = false;
  @State editingId: string = '';
  
  // 预定义选项
  private readonly targetAudienceOptions: string[] = [
    RecipientTypeNames[RecipientType.FATHER],
    RecipientTypeNames[RecipientType.MOTHER],
    RecipientTypeNames[RecipientType.BOYFRIEND],
    RecipientTypeNames[RecipientType.GIRLFRIEND],
    RecipientTypeNames[RecipientType.FRIEND],
    RecipientTypeNames[RecipientType.COLLEAGUE],
    RecipientTypeNames[RecipientType.CHILD],
    RecipientTypeNames[RecipientType.ELDER_RELATIVE],
    RecipientTypeNames[RecipientType.BESTIE],
    RecipientTypeNames[RecipientType.SIBLING],
    RecipientTypeNames[RecipientType.TEACHER]
  ];
  
  private readonly occasionOptions: string[] = [
    OccasionTypeNames[OccasionType.BIRTHDAY],
    OccasionTypeNames[OccasionType.ANNIVERSARY],
    OccasionTypeNames[OccasionType.WEDDING],
    OccasionTypeNames[OccasionType.VALENTINE_DAY],
    OccasionTypeNames[OccasionType.CHRISTMAS],
    OccasionTypeNames[OccasionType.GRADUATION],
    OccasionTypeNames[OccasionType.APOLOGY],
    OccasionTypeNames[OccasionType.THANK_YOU],
    OccasionTypeNames[OccasionType.PROMOTION],
    OccasionTypeNames[OccasionType.HOUSEWARMING],
    OccasionTypeNames[OccasionType.GET_WELL]
  ];
  
  private readonly giftTypeOptions: string[] = [
    GiftTypeNames[GiftType.DIY_HANDMADE],
    GiftTypeNames[GiftType.EXPERIENCE],
    GiftTypeNames[GiftType.DAILY_ITEMS],
    GiftTypeNames[GiftType.CREATIVE_NOVEL],
    GiftTypeNames[GiftType.TECH_DIGITAL],
    GiftTypeNames[GiftType.BEAUTY_SKINCARE],
    GiftTypeNames[GiftType.BOOKS_STATIONERY],
    GiftTypeNames[GiftType.CLOTHING_ACCESSORIES],
    GiftTypeNames[GiftType.HOME_DECOR],
    GiftTypeNames[GiftType.SPORTS_FITNESS],
    GiftTypeNames[GiftType.TRAVEL_OUTDOOR],
    GiftTypeNames[GiftType.JEWELRY],
    GiftTypeNames[GiftType.FLOWERS_PLANTS],
    GiftTypeNames[GiftType.COLLECTIBLES]
  ];

  async aboutToAppear() {
    // 初始化数据库
    this.dbManager = new NewDatabaseManager();
    await this.dbManager.initDatabase(getContext(this));
    this.myInspirationDAO = new MyInspirationDAO(this.dbManager);
    
    // 检查是否为编辑模式
    const params = router.getParams() as Record<string, string | number>;
    if (params && params.inspirationId) {
      this.isEditMode = true;
      this.editingId = String(params.inspirationId);
      await this.loadInspirationForEdit(String(params.inspirationId));
    }
  }

  // 加载要编辑的灵感数据
  async loadInspirationForEdit(id: string) {
    try {
      if (!this.myInspirationDAO) return;
      
      const inspiration = await this.myInspirationDAO.getMyInspirationById(id);
      if (inspiration) {
        this.title = inspiration.title;
        this.description = inspiration.description;
        this.detailedDescription = inspiration.detailedDescription || '';
        this.selectedTargetAudience = inspiration.targetAudience?.[0] || '';
    this.selectedOccasions = inspiration.occasions?.[0] || '';
        this.budgetMin = inspiration.budgetRange.min;
        this.budgetMax = inspiration.budgetRange.max;
        this.budgetLabel = inspiration.budgetRange.label;
        this.giftType = inspiration.giftType;
        this.difficulty = inspiration.difficulty;
        this.timeRequired = inspiration.timeRequired || '';
        this.materials = inspiration.materials || [];
        this.steps = inspiration.steps || [];
        this.tips = inspiration.tips || [];
      }
    } catch (error) {
      console.error('加载灵感数据失败:', error);
    }
  }

  // 保存灵感
  async saveInspiration() {
    // 验证必填字段
    if (!this.title.trim()) {
      AlertDialog.show({
        title: '提示',
        message: '请输入灵感标题',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return;
    }

    if (!this.description.trim()) {
      AlertDialog.show({
        title: '提示',
        message: '请输入简短描述',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return;
    }

    try {
      if (!this.myInspirationDAO) {
        console.error('数据库未初始化');
        return;
      }

      const budgetRange: BudgetRange = {
        min: this.budgetMin,
        max: this.budgetMax,
        label: this.budgetLabel
      };

      // 构建tags数组，包含所有选择的标签信息
      const tags: string[] = [];
      if (this.selectedTargetAudience) {
        // 将显示名称转换为枚举值
        const recipientType = getRecipientTypeByName(this.selectedTargetAudience);
        if (recipientType) {
          tags.push(recipientType);
        }
      }
      if (this.selectedOccasions) {
        // 将显示名称转换为枚举值
        const occasionType = getOccasionTypeByName(this.selectedOccasions);
        if (occasionType) {
          tags.push(occasionType);
        }
      }
      if (this.giftType) {
        // 将显示名称转换为枚举值
        const giftTypeEnum = getGiftTypeByName(this.giftType);
        if (giftTypeEnum) {
          tags.push(giftTypeEnum);
        }
      }
      // 添加难度标签
      const difficultyLabel = this.difficulty === 'easy' ? '简单' : this.difficulty === 'medium' ? '中等' : '困难';
      tags.push(difficultyLabel);

      const inspiration: Inspiration = {
        id: this.isEditMode ? this.editingId : undefined,
        title: this.title.trim(),
        description: this.description.trim(),
        detailedDescription: this.detailedDescription.trim(),
        images: [],
        tags: tags,
        targetAudience: this.selectedTargetAudience ? [this.selectedTargetAudience] : [],
      occasions: this.selectedOccasions ? [this.selectedOccasions] : [],
        interests: [],
        budgetRange: budgetRange,
        giftType: this.giftType,
        difficulty: this.difficulty,
        timeRequired: this.timeRequired,
        materials: this.materials,
        steps: this.steps,
        tips: this.tips,
        isRecommended: false
      };

      if (this.isEditMode) {
        await this.myInspirationDAO.updateMyInspiration(this.editingId, inspiration);
      } else {
        await this.myInspirationDAO.createMyInspiration(inspiration);
      }

      // 通知灵感页面刷新数据
      AppStorage.setOrCreate('refreshInspirationData', Date.now());

      // 返回上一页
      router.back();
    } catch (error) {
      console.error('保存灵感失败:', error);
    }
  }

  // 删除灵感
  async deleteInspiration() {
    if (!this.isEditMode || !this.editingId) return;
    
    try {
      if (!this.myInspirationDAO) return;
      
      await this.myInspirationDAO.deleteMyInspiration(this.editingId);
      
      // 触发BrowsePage的数据刷新
      AppStorage.setOrCreate('refreshInspirationData', Date.now());
      
      // 返回上一页
      router.back();
    } catch (error) {
      console.error('删除灵感失败:', error);
    }
  }

  // 添加材料
  addMaterial() {
    if (this.newMaterial.trim()) {
      this.materials.push(this.newMaterial.trim());
      this.newMaterial = '';
    }
  }

  // 添加步骤
  addStep() {
    if (this.newStep.trim()) {
      this.steps.push(this.newStep.trim());
      this.newStep = '';
    }
  }

  // 添加小贴士
  addTip() {
    if (this.newTip.trim()) {
      this.tips.push(this.newTip.trim());
      this.newTip = '';
    }
  }

  // 移除项目
  removeItem(array: string[], index: number) {
    array.splice(index, 1);
  }

  // 切换选择状态
  toggleSelection(array: string[], item: string) {
    const index = array.indexOf(item);
    if (index > -1) {
      array.splice(index, 1);
    } else {
      array.push(item);
    }
  }

  // 获取难度标签
  getDifficultyLabel(level: string): string {
    if (level === 'easy') {
      return '简单';
    } else if (level === 'medium') {
      return '中等';
    } else if (level === 'hard') {
      return '困难';
    }
    return '';
  }



  // 构建列表编辑器
  @Builder
  buildListEditor(title: string, items: string[], newItem: string, 
                  onNewItemChange: (value: string) => void, onAdd: () => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      // 添加新项目
      TextInput({ placeholder: `添加${title}` })
        .width('100%')
        .fontSize(14)
        .height(80)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onChange(onNewItemChange)
        .onSubmit(() => {
          onAdd();
        })

      // 显示已添加的项目
      if (items.length > 0) {
        Column({ space: 4 }) {
          ForEach(items, (item: string, index: number) => {
            Row() {
              Text(`${index + 1}. ${item}`)
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1)

              Button('删除')
                .fontSize(12)
                .height(28)
                .backgroundColor('#F44336')
                .fontColor('#FFFFFF')
                .borderRadius(6)
                .onClick(() => {
                  this.removeItem(items, index);
                })
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
          }, (item: string, index: number) => `${index}_${item}`)
        }
      }
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })

        Text(this.isEditMode ? '编辑灵感' : '添加灵感')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor('#FF6B35')
          .onClick(() => {
            this.saveInspiration();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Divider()
        .color('#E0E0E0')

      // 内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 基本信息
          Column({ space: 12 }) {
            Text('基本信息')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Row() {
              Text('标题')
                .fontSize(14)
                .fontColor('#333333')
              Text('*')
                .fontSize(14)
                .fontColor('#F44336')
            }
            .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入灵感标题' })
              .fontSize(16)
              .height(48)
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.title = value;
              })

            Row() {
              Text('简短描述')
                .fontSize(14)
                .fontColor('#333333')
              Text('*')
                .fontSize(14)
                .fontColor('#F44336')
            }
            .alignSelf(ItemAlign.Start)

            TextArea({ placeholder: '请输入简短描述' })
              .fontSize(14)
              .height(80)
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onChange((value: string) => {
                this.description = value;
              })

            TextArea({ placeholder: '请输入详细描述（可选）' })
              .fontSize(14)
              .height(120)
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onChange((value: string) => {
                this.detailedDescription = value;
              })
          }

          Divider().color('#E0E0E0')

          // 目标受众
          Column({ space: 8 }) {
            Text('目标受众')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.targetAudienceOptions, (option: string) => {
                Text(option)
                  .fontSize(14)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.selectedTargetAudience === option ? '#FF6B35' : '#F0F0F0')
                  .fontColor(this.selectedTargetAudience === option ? '#FFFFFF' : '#666666')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    console.info('目标受众标签点击:', option);
                    this.selectedTargetAudience = option;
                    console.info('更新后的目标受众:', this.selectedTargetAudience);
                  })
              }, (option: string) => option)
            }
            .margin({ top: 8 })
          }

          Divider().color('#E0E0E0')

          // 适合场合
          Column({ space: 8 }) {
            Text('适合场合')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.occasionOptions, (option: string) => {
                Text(option)
                  .fontSize(14)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.selectedOccasions === option ? '#FF6B35' : '#F0F0F0')
                  .fontColor(this.selectedOccasions === option ? '#FFFFFF' : '#666666')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    console.info('适合场合标签点击:', option);
                    this.selectedOccasions = option;
                    console.info('更新后的适合场合:', this.selectedOccasions);
                  })
              }, (option: string) => option)
            }
            .margin({ top: 8 })
          }

          Divider().color('#E0E0E0')

          // 礼物类型
          Column({ space: 8 }) {
            Text('礼物类型')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.giftTypeOptions, (option: string) => {
                Text(option)
                  .fontSize(14)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.giftType === option ? '#FF6B35' : '#F0F0F0')
                  .fontColor(this.giftType === option ? '#FFFFFF' : '#666666')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    console.log('lucky礼物类型 tag selector is ' + option)
                    this.giftType = option;
                  })
              }, (option: string) => option)
            }
            .margin({ top: 8 })
          }

          Divider().color('#E0E0E0')

          // 难度和时间
          Column({ space: 12 }) {
            Text('难度和时间')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Row({ space: 12 }) {
              Text('难度:')
                .fontSize(14)
                .fontColor('#666666')

              Row({ space: 8 }) {
                ForEach(['easy', 'medium', 'hard'], (level: string) => {
                  Text(this.getDifficultyLabel(level))
                    .fontSize(14)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.difficulty === level ? '#FF6B35' : '#F0F0F0')
                    .fontColor(this.difficulty === level ? '#FFFFFF' : '#666666')
                    .borderRadius(16)
                    .onClick(() => {
                      this.difficulty = level as 'easy' | 'medium' | 'hard';
                    })
                }, (level: string) => level)
              }
            }

            TextInput({ placeholder: '所需时间（如：2小时）' })
              .fontSize(14)
              .height(40)
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.timeRequired = value;
              })
          }

          Divider().color('#E0E0E0')

          // 预算范围
          Column({ space: 12 }) {
            Text('预算范围')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Row({ space: 12 }) {
              Column() {
                Text('最低预算')
                  .fontSize(12)
                  .fontColor('#666666')
                TextInput({ placeholder: '0' })
                  .fontSize(14)
                  .height(40)
                  .backgroundColor('#F8F8F8')
                  .borderRadius(8)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.budgetMin = Number(value) || 0;
                    this.budgetLabel = `${this.budgetMin}-${this.budgetMax}元`;
                  })
              }
              .layoutWeight(1)

              Text('至')
                .fontSize(14)
                .fontColor('#666666')

              Column() {
                Text('最高预算')
                  .fontSize(12)
                  .fontColor('#666666')
                TextInput({ placeholder: '100' })
                  .fontSize(14)
                  .height(40)
                  .backgroundColor('#F8F8F8')
                  .borderRadius(8)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.budgetMax = Number(value) || 100;
                    this.budgetLabel = `${this.budgetMin}-${this.budgetMax}元`;
                  })
              }
              .layoutWeight(1)
            }

            Text(`预算范围: ${this.budgetLabel}`)
              .fontSize(14)
              .fontColor('#FF6B35')
          }

          Divider().color('#E0E0E0')

          // 所需材料
          this.buildListEditor('所需材料', this.materials, this.newMaterial, 
            (value: string) => { this.newMaterial = value; }, 
            () => { this.addMaterial(); })

          Divider().color('#E0E0E0')

          // 制作步骤
          this.buildListEditor('制作步骤', this.steps, this.newStep, 
            (value: string) => { this.newStep = value; }, 
            () => { this.addStep(); })

          Divider().color('#E0E0E0')

          // 小贴士
          this.buildListEditor('小贴士', this.tips, this.newTip, 
            (value: string) => { this.newTip = value; }, 
            () => { this.addTip(); })
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      }
      .layoutWeight(1)

      // 底部删除按钮区域
      if (this.isEditMode) {
        Column() {
          Divider()
            .color('#E0E0E0')

          Button('删除灵感')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#F44336')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .margin({ top: 16, bottom: 16 })
            .onClick(() => {
              this.deleteInspiration();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}