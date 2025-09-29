import router from '@ohos.router';
import { Contact } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import { common } from '@kit.AbilityKit';
import { RelationshipType, RelationshipTypeNames, getAllRelationshipTypes, RelationshipTypeOption } from '../../model/RelationshipType';

@Entry
@Component
struct ContactFormPage {
  @State contact: Contact = {
    id: '',
    name: '',
    relationship: '',
    avatar: '',
    birthday: '',
    notes: '',
    importantDates: [],
    preferences: [],
    createdAt: '',
    updatedAt: ''
  };
  @State isEdit: boolean = false;
  @State nameError: string = '';
  @State relationshipError: string = '';
  @State isLoading: boolean = false;
  @State showDeleteDialog: boolean = false;
  @State showRelationshipDropdown: boolean = false;
  @State returnToTimeline: boolean = false;

  private dbManager: NewDatabaseManager = new NewDatabaseManager();
  private contactDAO: ContactDAO = new ContactDAO(this.dbManager);

  async aboutToAppear() {
    // 初始化数据库
    const context = getContext(this) as common.UIAbilityContext;
    await this.dbManager.initDatabase(context);

    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;

    if (params?.contact) {
      this.contact = params.contact as Contact;
    } else {
      // 新建模式，生成ID
      this.contact.id = Date.now().toString();
    }
    if (params?.isEdit) {
      this.isEdit = params.isEdit as boolean;
    } else {
      this.isEdit = false;
    }

    if (params?.returnToTimeline) {
      this.returnToTimeline = params.returnToTimeline as boolean;
    }
  }

  private validateForm(): boolean {
    this.nameError = '';
    this.relationshipError = '';
    
    let isValid = true;
    
    if (!this.contact.name.trim()) {
      this.nameError = '请输入姓名';
      isValid = false;
    }
    
    if (!this.contact.relationship.trim()) {
      this.relationshipError = '请选择关系';
      isValid = false;
    } else if (!Object.values(RelationshipType).includes(this.contact.relationship as RelationshipType)) {
      this.relationshipError = '请选择有效的关系类型';
      isValid = false;
    }
    
    return isValid;
  }

  private async handleConfirm() {
    if (!this.validateForm()) {
      return;
    }

    this.isLoading = true;
    try {
      if (this.isEdit) {
        await this.contactDAO.updateContact(this.contact);
        router.back();
      } else {
        await this.contactDAO.createContact(this.contact);
        
        // 如果是从时间轴创建联系人，直接跳转到该联系人的时间轴
        if (this.returnToTimeline) {
          router.replaceUrl({
            url: 'pages/EmotionalTimelinePage',
            params: {
              selectedContact: this.contact
            }
          });
        } else {
          router.back();
        }
      }
    } catch (error) {
      console.error('保存联系人失败:', error);
      // 这里可以添加错误提示
    } finally {
      this.isLoading = false;
      AppStorage.setOrCreate('refreshHomePage', Date.now());
    }
  }

  private handleCancel() {
    router.back();
  }

  private async handleDelete() {
    this.isLoading = true;
    try {
      await this.contactDAO.deleteContact(this.contact.id);
      // 返回上一页
      router.back();
    } catch (error) {
      console.error('删除联系人失败:', error);
      // 这里可以添加错误提示
    } finally {
      this.isLoading = false;
      this.showDeleteDialog = false;
    }
  }

  private confirmDelete() {
    this.showDeleteDialog = true;
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.handleCancel())

        Text(this.isEdit ? '编辑联系人' : '添加联系人')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button(this.isEdit ? '保存' : '添加')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .enabled(!this.isLoading)
          .onClick(() => this.handleConfirm())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 1 }, color: '#E5E5E5' })

      // 表单内容
      Column({ space: 20 }) {
        // 表单字段
        Column({ space: 16 }) {
          // 姓名输入
          Column({ space: 8 }) {
            Row() {
              Text('姓名')
                .fontSize(16)
                .fontColor('#333333')
              Text('*')
                .fontSize(16)
                .fontColor('#FF6B6B')
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            TextInput({ placeholder: '请输入姓名', text: this.contact.name })
              .width('100%')
              .height(48)
              .fontSize(16)
              .borderRadius(8)
              .backgroundColor('#F8F9FA')
              .border({ width: 1, color: this.nameError ? '#FF6B6B' : '#E9ECEF' })
              .onChange((value: string) => {
                this.contact.name = value;
                if (this.nameError) {
                  this.nameError = '';
                }
              })

            if (this.nameError) {
              Text(this.nameError)
                .fontSize(14)
                .fontColor('#FF6B6B')
                .width('100%')
            }
          }

          // 关系选择
          Column({ space: 8 }) {
            Row() {
              Text('关系')
                .fontSize(16)
                .fontColor('#333333')
              Text('*')
                .fontSize(16)
                .fontColor('#FF6B6B')
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Row() {
              Text(this.contact.relationship ? RelationshipTypeNames[this.contact.relationship as RelationshipType] || this.contact.relationship : '请选择关系')
                .fontSize(16)
                .fontColor(this.contact.relationship ? '#333333' : '#999999')
                .layoutWeight(1)

              Image($r('app.media.ic_arrow_down'))
                .width(16)
                .height(16)
                .fillColor('#666666')
            }
            .width('100%')
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({ width: 1, color: this.relationshipError ? '#FF6B6B' : '#E9ECEF' })
            .onClick(() => {
              this.showRelationshipDropdown = true;
            })

            if (this.relationshipError) {
              Text(this.relationshipError)
                .fontSize(14)
                .fontColor('#FF6B6B')
                .width('100%')
            }
          }

          // 生日输入
          Column({ space: 8 }) {
            Text('生日')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({ placeholder: '请输入生日（如：1990-01-01）', text: this.contact.birthday || '' })
              .width('100%')
              .height(48)
              .fontSize(16)
              .borderRadius(8)
              .backgroundColor('#F8F9FA')
              .border({ width: 1, color: '#E9ECEF' })
              .onChange((value: string) => {
                this.contact.birthday = value;
              })
          }

          // 备注输入
          Column({ space: 8 }) {
            Text('备注')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Start)

            TextArea({ placeholder: '请输入备注信息', text: this.contact.notes || '' })
              .width('100%')
              .height(120)
              .fontSize(16)
              .borderRadius(8)
              .backgroundColor('#F8F9FA')
              .border({ width: 1, color: '#E9ECEF' })
              .onChange((value: string) => {
                this.contact.notes = value;
              })
          }
        }

        // 删除按钮（仅在编辑模式下显示）
        if (this.isEdit) {
          Button('删除联系人')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FF6B6B')
            .backgroundColor('#FFF5F5')
            .border({ width: 1, color: '#FF6B6B' })
            .borderRadius(8)
            .margin({ top: 40 })
            .enabled(!this.isLoading)
            .onClick(() => this.confirmDelete())
        }
      }
      .width('100%')
      .padding(20)
      .justifyContent(FlexAlign.Start)
      .bindSheet($$this.showRelationshipDropdown, this.relationshipDropdownBuilder(), {
        height: 400,
        dragBar: true,
        showClose: false,
        backgroundColor: Color.White,
        onDisappear: () => {
          this.showRelationshipDropdown = false;
        },
        preferType:SheetType.CENTER
      })

      // 加载状态
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#007AFF')
          Text('保存中...')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F8F9FA')
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#FFFFFF')
    .bindContentCover(this.showDeleteDialog, this.deleteConfirmDialog, {
      modalTransition: ModalTransition.NONE,
      backgroundColor: 'rgba(0, 0, 0, 0.5)'
    })
  }

  @Builder
  deleteConfirmDialog() {
    Column() {
      Column({ space: 20 }) {
        Text('确认删除')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(`确定要删除联系人"${this.contact.name}"吗？此操作不可撤销。`)
          .fontSize(16)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .lineHeight(24)

        Row({ space: 12 }) {
          Button('取消')
            .width(120)
            .height(44)
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F8F9FA')
            .border({ width: 1, color: '#E9ECEF' })
            .borderRadius(8)
            .onClick(() => {
              this.showDeleteDialog = false;
            })

          Button('删除')
            .width(120)
            .height(44)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B6B')
            .borderRadius(8)
            .enabled(!this.isLoading)
            .onClick(() => this.handleDelete())
        }
        .justifyContent(FlexAlign.Center)
      }
      .width(280)
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  relationshipDropdownBuilder() {
    Column() {
      // 标题
      Row() {
        Text('选择关系')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        
        Button('取消')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showRelationshipDropdown = false;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .border({ width: { bottom: 1 }, color: '#E5E5E5' })

      // 关系选项列表
      List() {
        ForEach(getAllRelationshipTypes(), (item: RelationshipTypeOption) => {
          ListItem() {
            Row() {
              Text(item.label)
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)
              
              if (this.contact.relationship === item.value) {
                Image($r('app.media.ic_check'))
                  .width(20)
                  .height(20)
                  .fillColor('#007AFF')
              }
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.contact.relationship = item.value;
              if (this.relationshipError) {
                this.relationshipError = '';
              }
              this.showRelationshipDropdown = false;
            })
          }
          .backgroundColor(this.contact.relationship === item.value ? '#F0F8FF' : Color.White)
        }, (item: RelationshipTypeOption) => item.value)
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}