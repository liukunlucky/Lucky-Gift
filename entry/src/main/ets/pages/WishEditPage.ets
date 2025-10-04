import router from '@ohos.router';
import { MyWish, WishCategory, WishPriority, WishStatus } from '../model/NewDataModels';
import { NewDatabaseManager } from '../database/NewDatabaseManager';
import { MyWishDAO } from '../database/MyWishDAO';
import { common } from '@kit.AbilityKit';

interface WishEditParams {
  isEdit?: boolean;
  wishId?: string;
  wish?: MyWish;
  prefilledTitle?: string;
  prefilledDescription?: string;
}

@Entry
@Component
struct WishEditPage {
  @State isEdit: boolean = false;
  @State wishId: string = '';
  @State formTitle: string = '';
  @State formDescription: string = '';
  @State formCategory: WishCategory = WishCategory.GIFT;
  @State formPriority: WishPriority = WishPriority.MEDIUM;
  @State formTargetDate: string = '';
  @State formEstimatedCost: number = 0;
  @State formTags: string = '';
  @State formNotes: string = '';
  @State isLoading: boolean = false;

  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private wishDAO: MyWishDAO = new MyWishDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);
    
    const params = router.getParams() as WishEditParams;

    if (params) {
      this.isEdit = params.isEdit || false;
      this.wishId = params.wishId || '';
      
      if (params.wish) {
        this.loadWishData(params.wish);
      } else if (this.isEdit && this.wishId) {
        await this.loadWishFromDatabase();
      }
      
      // 处理预填充数据
      if (params.prefilledTitle) {
        this.formTitle = params.prefilledTitle;
      }
      if (params.prefilledDescription) {
        this.formDescription = params.prefilledDescription;
      }
    }
  }

  loadWishData(wish: MyWish) {
    this.formTitle = wish.title;
    this.formDescription = wish.description;
    this.formCategory = wish.category;
    this.formPriority = wish.priority;
    this.formTargetDate = wish.targetDate || '';
    this.formEstimatedCost = wish.estimatedCost || 0;
    this.formTags = wish.tags?.join(', ') || '';
    this.formNotes = wish.notes || '';
  }

  async loadWishFromDatabase() {
    try {
      this.isLoading = true;
      const wish = await this.wishDAO.getWishById(this.wishId);
      if (wish) {
        this.loadWishData(wish);
      }
    } catch (error) {
      console.error('加载心愿数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async saveWish() {
    if (!this.formTitle.trim()) {
      return;
    }

    try {
      this.isLoading = true;
      
      const wishData: MyWish = {
        id: this.isEdit ? this.wishId : Date.now().toString(),
        title: this.formTitle.trim(),
        description: this.formDescription.trim(),
        category: this.formCategory,
        priority: this.formPriority,
        status: WishStatus.ACTIVE,
        targetDate: this.formTargetDate || undefined,
        estimatedCost: this.formEstimatedCost,
        tags: this.formTags.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0),
        notes: this.formNotes.trim(),
        progress: 0,
        images: [],
        reminderEnabled: false,
        isPublic: false,
        createdAt: this.isEdit ? undefined : new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      if (this.isEdit) {
        await this.wishDAO.updateWish(this.wishId, wishData);
      } else {
        await this.wishDAO.createWish(wishData);
      }

      router.back();
    } catch (error) {
      console.error('保存心愿失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async deleteWish() {
    if (!this.isEdit || !this.wishId) return;

    try {
      this.isLoading = true;
      await this.wishDAO.deleteWish(this.wishId);
      router.back();
    } catch (error) {
      console.error('删除心愿失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  getCategoryName(category: WishCategory): string {
    switch (category) {
      case WishCategory.GIFT:
        return '礼物心愿';
      case WishCategory.EXPERIENCE:
        return '体验心愿';
      case WishCategory.TRAVEL:
        return '旅行心愿';
      case WishCategory.LEARNING:
        return '学习心愿';
      case WishCategory.HEALTH:
        return '健康心愿';
      case WishCategory.CAREER:
        return '事业心愿';
      case WishCategory.RELATIONSHIP:
        return '关系心愿';
      case WishCategory.HOBBY:
        return '爱好心愿';
      case WishCategory.OTHER:
        return '其他';
      default:
        return '其他';
    }
  }

  getPriorityName(priority: WishPriority): string {
    switch (priority) {
      case WishPriority.LOW:
        return '低';
      case WishPriority.MEDIUM:
        return '中';
      case WishPriority.HIGH:
        return '高';
      case WishPriority.URGENT:
        return '紧急';
      default:
        return '中';
    }
  }

  getCategoryIndex(category: WishCategory): number {
    const categories = [
      WishCategory.GIFT,
      WishCategory.EXPERIENCE,
      WishCategory.TRAVEL,
      WishCategory.LEARNING,
      WishCategory.HEALTH,
      WishCategory.CAREER,
      WishCategory.RELATIONSHIP,
      WishCategory.HOBBY,
      WishCategory.OTHER
    ];
    return categories.indexOf(category);
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(60)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })
        
        Text(this.isEdit ? '编辑心愿' : '新增心愿')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('保存')
          .fontSize(16)
          .fontColor('#007DFF')
          .backgroundColor(Color.Transparent)
          .enabled(!this.isLoading && this.formTitle.trim().length > 0)
          .onClick(() => this.saveWish())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 表单内容
      Scroll() {
        Column() {
          this.WishForm()
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // 底部操作栏（仅编辑模式显示删除按钮）
      if (this.isEdit) {
        Row() {
          Button('删除心愿')
            .fontSize(16)
            .fontColor('#FF4444')
            .backgroundColor('#FFEBEE')
            .width('100%')
            .height(48)
            .enabled(!this.isLoading)
            .onClick(() => {
              // 显示确认删除对话框
              AlertDialog.show({
                title: '确认删除',
                message: '确定要删除这个心愿吗？此操作不可撤销。',
                primaryButton: {
                  value: '取消',
                  action: () => {}
                },
                secondaryButton: {
                  value: '删除',
                  fontColor: '#FF4444',
                  action: () => {
                    this.deleteWish();
                  }
                }
              });
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 心愿表单
  @Builder WishForm() {
    Column({ space: 16 }) {
      // 标题
      Column({ space: 8 }) {
        Text('心愿标题')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '输入心愿标题', text: this.formTitle })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.formTitle = value;
          })
      }

      // 描述
      Column({ space: 8 }) {
        Text('详细描述')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextArea({ placeholder: '详细描述你的心愿...', text: this.formDescription })
          .width('100%')
          .height(100)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(12)
          .onChange((value: string) => {
            this.formDescription = value;
          })
      }

      // 分类和优先级
      Row({ space: 12 }) {
        Column({ space: 8 }) {
          Text('分类')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)

          Select([
            { value: '礼物心愿' },
            { value: '体验心愿' },
            { value: '旅行心愿' },
            { value: '学习心愿' },
            { value: '健康心愿' },
            { value: '事业心愿' },
            { value: '关系心愿' },
            { value: '爱好心愿' },
            { value: '其他' }
          ])
            .selected(this.getCategoryIndex(this.formCategory))
            .value(this.getCategoryName(this.formCategory))
            .backgroundColor('#FFFFFF')
            .onSelect((index: number) => {
              const categories = [
                WishCategory.GIFT,
                WishCategory.EXPERIENCE,
                WishCategory.TRAVEL,
                WishCategory.LEARNING,
                WishCategory.HEALTH,
                WishCategory.CAREER,
                WishCategory.RELATIONSHIP,
                WishCategory.HOBBY,
                WishCategory.OTHER
              ];
              this.formCategory = categories[index];
            })
        }
        .layoutWeight(1)

        Column({ space: 8 }) {
          Text('优先级')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)

          Select([
            { value: '低' },
            { value: '中' },
            { value: '高' },
            { value: '紧急' }
          ])
            .selected(Object.values(WishPriority).indexOf(this.formPriority))
            .value(this.getPriorityName(this.formPriority))
            .backgroundColor('#FFFFFF')
            .onSelect((index: number) => {
              this.formPriority = Object.values(WishPriority)[index];
            })
        }
        .layoutWeight(1)
      }

      // 目标日期
      Column({ space: 8 }) {
        Text('目标日期')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        DatePicker({
          start: new Date('2024-01-01'),
          end: new Date('2030-12-31'),
          selected: this.formTargetDate ? new Date(this.formTargetDate) : new Date()
        })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .onDateChange((value: Date) => {
            this.formTargetDate = value.toISOString().split('T')[0];
          })
      }

      // 预估费用
      Column({ space: 8 }) {
        Text('预估费用')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextInput({ 
          placeholder: '输入预估费用', 
          text: this.formEstimatedCost > 0 ? this.formEstimatedCost.toString() : '' 
        })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.formEstimatedCost = parseFloat(value) || 0;
          })
      }

      // 标签
      Column({ space: 8 }) {
        Text('标签')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '输入标签，用逗号分隔', text: this.formTags })
          .width('100%')
          .height(44)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.formTags = value;
          })
      }

      // 备注
      Column({ space: 8 }) {
        Text('备注')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextArea({ placeholder: '其他备注信息...', text: this.formNotes })
          .width('100%')
          .height(80)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding(12)
          .onChange((value: string) => {
            this.formNotes = value;
          })
      }
    }
  }
}