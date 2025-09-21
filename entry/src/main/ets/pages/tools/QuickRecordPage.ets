import router from '@ohos.router';
import { QuickRecordService, QuickRecord } from '../../service/QuickRecordService';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';

@Entry
@Component
struct QuickRecordPage {
  @State records: QuickRecord[] = [];
  @State showEditDialog: boolean = false;
  @State editingRecord: QuickRecord | null = null;
  @State newRecordType: string = 'idea';
  @State newRecordTitle: string = '';
  @State newRecordContent: string = '';
  @State selectedTags: string[] = [];
  @State availableTags: string[] = ['礼物想法', '重要日期', '预算记录', '购买清单'];
  @State titleError: string = '';
  @State showTitleError: boolean = false;

  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private quickRecordService: QuickRecordService | null = null;

  async aboutToAppear() {
    // 初始化数据库
    await this.dbManager.initDatabase(getContext(this));
    this.quickRecordService = new QuickRecordService(this.dbManager);
    
    // 加载记录
    await this.loadRecords();
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
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('备忘')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Image($r('app.media.ic_add'))
            .width(36)
            .height(36)
            .fillColor('#FF6B35')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          // 直接打开编辑对话框进行新增
          this.editingRecord = null;
          this.newRecordType = 'idea';
          this.newRecordTitle = '';
          this.newRecordContent = '';
          this.selectedTags = [];
          this.showEditDialog = true;
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 记录列表
      if (this.records.length === 0) {
        Column() {
          Image($r('app.media.icon_empty'))
            .width(173)
            .height(128)

          Text('还没有记录')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 16 })

          Text('点击右上角按钮开始记录')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .bindSheet($$this.showEditDialog, this.buildEditDialog(), {
          height: 500,
          showClose: false,
          dragBar: true,
          preferType:SheetType.CENTER
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.records, (record: QuickRecord) => {
            ListItem() {
              this.buildRecordItem(record)
            }
            .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
          }, (record: QuickRecord) => record.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 60 })
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#F8F9FA')
        .bindSheet($$this.showEditDialog, this.buildEditDialog(), {
          height: 500,
          showClose: false,
          dragBar: true,
          preferType:SheetType.CENTER
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildQuickButton(icon: string, title: string, action: () => void) {
    Column() {
      Text(icon)
        .fontSize(24)
        .margin({ bottom: 8 })

      Text(title)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width(80)
    .height(80)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .onClick(action)
  }

  @Builder
  buildRecordItem(record: QuickRecord) {
    Stack() {
      Column() {
        Row() {
          Column() {
            Text(record.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Text(this.formatDateTime(record.date))
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 4 })
              .alignSelf(ItemAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        if (record.content) {
          Text(record.content)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .alignSelf(ItemAlign.Start)
        }

        if (record.tags.length > 0) {
          Row() {
            ForEach(record.tags, (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF6B35')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
                .margin({ right: 8 })
            })
          }
          .width('100%')
          .margin({ top: 12 })
        }
      }
      .width('100%')
      .padding(16)

    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderWidth(1)
    .borderColor('#E5E5E5')
    .borderRadius(12)
    .onClick(() => {
      this.editRecord(record);
    })
  }

  @Builder
  buildEditDialog() {
    Column() {
      Row() {
        Button('删除')
          .fontSize(14)
          .fontColor('#FF4444')
          .backgroundColor(Color.Transparent)
          .visibility(Visibility.Hidden)
        Text(this.editingRecord ? '编辑记录' : '添加新记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        // 只有编辑模式才显示删除按钮
        Button('删除')
          .fontSize(14)
          .fontColor('#FF4444')
          .backgroundColor(Color.Transparent)
          .visibility(this.editingRecord? Visibility.Visible: Visibility.Hidden)
          .onClick(() => {
            if (this.editingRecord) {
              this.showDeleteConfirmDialog();
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })

      // 标题输入
      Row() {
        Text('标题')
          .fontSize(14)
          .fontColor('#333333')
        
        Text('*')
          .fontSize(14)
          .fontColor('#FF4444')
          .margin({ left: 2 })
      }
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: 8 })

      TextInput({ text: this.newRecordTitle, placeholder: '请输入标题（必填）' })
        .width('100%')
        .height(40)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .borderWidth(this.showTitleError ? 1 : 0)
        .borderColor(this.showTitleError ? '#FF4444' : Color.Transparent)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.newRecordTitle = value;
          // 输入时清除错误状态
          if (this.showTitleError && value.trim()) {
            this.showTitleError = false;
            this.titleError = '';
          }
        })
        .margin({ bottom: this.showTitleError ? 4 : 16 })

      // 错误提示文本
      if (this.showTitleError) {
        Text(this.titleError)
          .fontSize(12)
          .fontColor('#FF4444')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })
      }

      // 内容输入
      Text('内容')
        .fontSize(14)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      TextArea({ text: this.newRecordContent, placeholder: '请输入详细内容...' })
        .width('100%')
        .height(100)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.newRecordContent = value;
        })
        .margin({ bottom: 16 })

      // 标签选择
      Text('标签')
        .fontSize(14)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.availableTags, (tag: string) => {
          Text(tag)
            .fontSize(12)
            .fontColor(this.selectedTags.includes(tag) ? Color.White : '#666666')
            .backgroundColor(this.selectedTags.includes(tag) ? '#FF6B35' : '#F0F0F0')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.toggleTag(tag);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 24 })

      // 底部按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(25)
          .layoutWeight(1)
          .height(50)
          .margin({ right: 8 })
          .onClick(() => {
            this.resetEditDialog();
          })

        Button('保存')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#FF6B35')
          .borderRadius(25)
          .layoutWeight(1)
          .height(50)
          .margin({ left: 8 })
          .onClick(() => {
            // 先验证标题
            if (!this.validateTitle()) {
              return;
            }
            
            if (this.editingRecord) {
              this.updateRecord();
            } else {
              this.saveRecord();
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
  }



  @Builder
  buildTypeOption(type: string, icon: string, title: string) {
    Column() {
      Text(icon)
        .fontSize(20)
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontColor(this.newRecordType === type ? '#FF6B35' : '#666666')
    }
    .width(70)
    .height(60)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.newRecordType === type ? '#FFF5F0' : '#F8F9FA')
    .borderRadius(8)
    .border({
      width: 1,
      color: this.newRecordType === type ? '#FF6B35' : '#F0F0F0'
    })
    .onClick(() => {
      this.newRecordType = type;
    })
  }

  private toggleTag(tag: string): void {
    const index = this.selectedTags.indexOf(tag);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    } else {
      this.selectedTags.push(tag);
    }
  }

  private async saveRecord(): Promise<void> {
    if (!this.quickRecordService) {
      return;
    }

    const now = new Date();
    const newRecord: QuickRecord = {
      id: this.dbManager.generateId(),
      type: this.newRecordType,
      title: this.newRecordTitle,
      content: this.newRecordContent,
      date: now.toISOString(),
      tags: this.selectedTags.slice()
    };

    try {
      const success = await this.quickRecordService.saveRecord(newRecord);
      if (success) {
        this.records.unshift(newRecord);
        this.resetEditDialog();
      } else {
        console.error('保存记录失败');
      }
    } catch (error) {
      console.error('保存记录时发生错误:', error);
    }
  }

  private async deleteRecord(recordId: string): Promise<void> {
    if (!this.quickRecordService) {
      return;
    }

    try {
      const success = await this.quickRecordService.deleteRecord(recordId);
      if (success) {
        const index = this.records.findIndex(record => record.id === recordId);
        if (index > -1) {
          // 添加删除动画效果
          animateTo({
            duration: 300,
            curve: Curve.EaseInOut,
            onFinish: () => {
              this.records.splice(index, 1);
            }
          }, () => {
            // 动画期间可以添加一些视觉效果，这里通过数组操作触发UI更新
          });
        }
      } else {
        console.error('删除记录失败');
      }
    } catch (error) {
      console.error('删除记录时发生错误:', error);
    }
  }

  private showDeleteConfirmDialog(): void {
    if (!this.editingRecord) {
      return;
    }

    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除记录"${this.editingRecord.title}"吗？此操作不可撤销。`,
      primaryButton: {
        value: '取消',
        action: () => {
          // 取消删除，不做任何操作
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF4444',
        action: () => {
          if (this.editingRecord) {
            this.deleteRecord(this.editingRecord.id);
            this.resetEditDialog();
          }
        }
      }
    });
  }

  private editRecord(record: QuickRecord): void {
    this.editingRecord = record;
    this.newRecordType = record.type;
    this.newRecordTitle = record.title;
    this.newRecordContent = record.content;
    this.selectedTags = record.tags.slice();
    this.titleError = '';
    this.showTitleError = false;
    this.showEditDialog = true;
  }



  private resetEditDialog(): void {
    this.showEditDialog = false;
    this.editingRecord = null;
    this.newRecordType = 'idea';
    this.newRecordTitle = '';
    this.newRecordContent = '';
    this.selectedTags = [];
    this.titleError = '';
    this.showTitleError = false;
  }

  private validateTitle(): boolean {
    if (!this.newRecordTitle.trim()) {
      this.titleError = '标题不能为空';
      this.showTitleError = true;
      return false;
    }
    this.titleError = '';
    this.showTitleError = false;
    return true;
  }

  private async updateRecord(): Promise<void> {
    if (!this.editingRecord || !this.quickRecordService) {
      return;
    }

    const updatedRecord: QuickRecord = {
      id: this.editingRecord.id,
      type: this.newRecordType,
      title: this.newRecordTitle,
      content: this.newRecordContent,
      date: this.editingRecord.date,
      tags: this.selectedTags.slice()
    };

    try {
      const success = await this.quickRecordService.updateRecord(updatedRecord);
      if (success) {
        const index = this.records.findIndex(record => record.id === this.editingRecord!.id);
        if (index > -1) {
          this.records[index] = updatedRecord;
        }
        this.resetEditDialog();
      } else {
        console.error('更新记录失败');
      }
    } catch (error) {
      console.error('更新记录时发生错误:', error);
    }
  }

  private async loadRecords(): Promise<void> {
    if (!this.quickRecordService) {
      console.error('QuickRecordService未初始化');
      return;
    }

    try {
      this.records = await this.quickRecordService.getAllRecords();
    } catch (error) {
      console.error('加载备忘失败:', error);
      this.records = [];
    }
  }

  private formatDateTime(dateString: string): string {
    try {
      const date = new Date(dateString);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      const seconds = String(date.getSeconds()).padStart(2, '0');
      
      return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    } catch (error) {
      console.error('时间格式化失败:', error);
      return dateString; // 如果格式化失败，返回原始字符串
    }
  }
}