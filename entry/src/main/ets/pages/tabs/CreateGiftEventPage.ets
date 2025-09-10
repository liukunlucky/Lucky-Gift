import { GiftEvent, Contact, Inspiration } from '../../model/NewDataModels';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { ContactDAO } from '../../database/ContactDAO';
import { InspirationDAO } from '../../database/InspirationDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import router from '@ohos.router';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';

// 页面参数接口
interface PageParams {
  contactId?: string;
  eventId?: string;
  isEdit?: boolean;
  inspirationId?: string;
}

@Entry
@Component
struct CreateGiftEventPage {
  @State eventId: string = '';
  @State isEditMode: boolean = false;
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;
  
  // 表单数据
  @State selectedContact: Contact | null = null;
  @State eventTitle: string = '';
  @State eventDate: string = new Date().toISOString().split('T')[0];
  @State occasion: string = '';
  @State giftIdea: string = '';
  @State actualCost: number = 0;
  @State story: string = '';
  @State reaction: string = '';
  @State mood: string = '';
  @State selectedImages: string[] = [];
  @State reminderEnabled: boolean = false;
  @State reminderDate: string = '';
  @State selectedInspiration: Inspiration | null = null;
  
  // 选项数据
  @State contacts: Contact[] = [];
  @State occasions: string[] = [
    '生日', '纪念日', '节日', '毕业', '升职', '结婚', '生子', 
    '道歉', '感谢', '惊喜', '安慰', '庆祝', '其他'
  ];
  @State moods: string[] = [
    '开心', '兴奋', '感动', '紧张', '期待', '满足', '温暖', '其他'
  ];
  
  private dbManager = new NewDatabaseManager();
  private giftEventDAO: GiftEventDAO = new GiftEventDAO(this.dbManager);
  private contactDAO: ContactDAO = new ContactDAO(this.dbManager);
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  
  aboutToAppear() {
    const params: PageParams = router.getParams() as PageParams || {}
    
    if (params.eventId) {
      this.eventId = params.eventId;
      this.isEditMode = true;
    }
    
    this.loadData(params);
  }
  
  async loadData(params: PageParams) {
    try {
      this.isLoading = true;
      
      // 加载联系人列表
      this.contacts = await this.contactDAO.getAllContacts();
      
      // 如果是编辑模式，加载现有数据
      if (this.isEditMode && this.eventId) {
        const event = await this.giftEventDAO.getGiftEventById(this.eventId);
        if (event) {
          this.loadEventData(event);
        }
      } else {
        // 新建模式，处理传入的参数
        if (params.contactId) {
          const contact = await this.contactDAO.getContactById(params.contactId);
          if (contact) {
            this.selectedContact = contact;
          }
        }
        
        if (params.inspirationId) {
          const inspiration = await this.inspirationDAO.getInspirationById(params.inspirationId);
          if (inspiration) {
            this.selectedInspiration = inspiration;
            this.giftIdea = inspiration.title;
            this.actualCost = inspiration.budgetRange.min || 0;
          }
        }
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  loadEventData(event: GiftEvent) {
    this.eventTitle = event.giftIdea;
    this.eventDate = event.date.split('T')[0];
    this.occasion = event.occasion;
    this.giftIdea = event.giftIdea;
    this.actualCost = event.actualCost || 0;
    this.story = event.story || '';
    this.reaction = event.reaction || '';
    this.mood = event.mood || '';
    this.selectedImages = event.images || [];
    this.reminderEnabled = !!event.reminderDate;
    this.reminderDate = event.reminderDate ? event.reminderDate.split('T')[0] : '';
    
    // 加载联系人
    const contact = this.contacts.find(c => c.id === event.contactId);
    if (contact) {
      this.selectedContact = contact;
    }
  }
  
  async selectImages() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 5 - this.selectedImages.length;
      
      const photoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
      
      if (photoSelectResult && photoSelectResult.photoUris) {
        this.selectedImages = [...this.selectedImages, ...photoSelectResult.photoUris];
      }
    } catch (error) {
      console.error('选择图片失败:', error);
    }
  }
  
  removeImage(index: number) {
    this.selectedImages.splice(index, 1);
  }
  
  async saveEvent() {
    if (!this.validateForm()) {
      return;
    }
    
    try {
      this.isSaving = true;
      
      const eventData: GiftEvent = {
        contactId: this.selectedContact!.id,
        contactName: this.selectedContact!.name,
        date: new Date(this.eventDate).toISOString(),
        occasion: this.occasion,
        giftIdea: this.giftIdea,
        budget: this.actualCost,
        actualCost: this.actualCost,
        story: this.story,
        reaction: this.reaction,
        mood: this.mood,
        images: this.selectedImages,
        tags: [],
        reminderSet: this.reminderEnabled,
        reminderDate: this.reminderEnabled && this.reminderDate ? 
          new Date(this.reminderDate).toISOString() : undefined
      };
      
      if (this.isEditMode) {
        await this.giftEventDAO.updateGiftEvent(this.eventId, eventData);
      } else {
        await this.giftEventDAO.createGiftEvent(eventData as GiftEvent);
      }
      
      // 返回记录页面
      router.back();
    } catch (error) {
      console.error('保存事件失败:', error);
    } finally {
      this.isSaving = false;
    }
  }
  
  validateForm(): boolean {
    if (!this.selectedContact) {
      // 显示错误提示
      return false;
    }
    
    if (!this.eventTitle.trim()) {
      // 显示错误提示
      return false;
    }
    
    if (!this.occasion) {
      // 显示错误提示
      return false;
    }
    
    return true;
  }
  
  goBack() {
    router.back();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text(this.isEditMode ? '编辑记录' : '创建记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button() {
          if (this.isSaving) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color('#FF6B35')
          } else {
            Text('保存')
              .fontSize(16)
              .fontColor('#FF6B35')
          }
        }
        .width(60)
        .height(40)
        .backgroundColor(Color.Transparent)
        .enabled(!this.isSaving)
        .onClick(() => this.saveEvent())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF6B35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 基本信息
            Column() {
              Text('基本信息')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 16 })
              
              Column() {
                // 收礼人选择
                Column() {
                  Row() {
                    Text('收礼人')
                      .fontSize(14)
                      .fontColor('#666666')
                    
                    Text('*')
                      .fontSize(14)
                      .fontColor('#FF4444')
                      .margin({ left: 2 })
                  }
                  .margin({ bottom: 8 })
                  
                  Button() {
                    Row() {
                      Text(this.selectedContact ? this.selectedContact.name : '选择收礼人')
                        .fontSize(16)
                        .fontColor(this.selectedContact ? '#333333' : '#999999')
                        .layoutWeight(1)
                      
                      Text('→')
                        .fontSize(16)
                        .fontColor('#CCCCCC')
                    }
                  }
                  .width('100%')
                  .height(48)
                  .backgroundColor('#F8F9FA')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onClick(() => {
                    // 显示联系人选择弹窗
                  })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
                
                // 事件标题
                Column() {
                  Row() {
                    Text('事件标题')
                      .fontSize(14)
                      .fontColor('#666666')
                    
                    Text('*')
                      .fontSize(14)
                      .fontColor('#FF4444')
                      .margin({ left: 2 })
                  }
                  .margin({ bottom: 8 })
                  
                  TextInput({ placeholder: '为这次送礼起个名字' })
                    .fontSize(16)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(8)
                    .padding({ left: 16, right: 16 })
                    .onChange((value: string) => {
                      this.eventTitle = value;
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
                
                // 日期和场合
                Row() {
                  Column() {
                    Column() {
                      Row() {
                        Text('日期')
                          .fontSize(14)
                          .fontColor('#666666')
                        
                        Text('*')
                          .fontSize(14)
                          .fontColor('#FF4444')
                          .margin({ left: 2 })
                      }
                      .margin({ bottom: 8 })
                      
                      Button() {
                        Text(this.eventDate)
                          .fontSize(16)
                          .fontColor('#333333')
                      }
                      .width('100%')
                      .height(48)
                      .backgroundColor('#F8F9FA')
                      .borderRadius(8)
                      .onClick(() => {
                        // 显示日期选择器
                      })
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                    .margin({ bottom: 16 })
                  }
                  .layoutWeight(1)
                  .margin({ right: 8 })
                  
                  Column() {
                    Column() {
                      Row() {
                        Text('场合')
                          .fontSize(14)
                          .fontColor('#666666')
                        
                        Text('*')
                          .fontSize(14)
                          .fontColor('#FF4444')
                          .margin({ left: 2 })
                      }
                      .margin({ bottom: 8 })
                      
                      Button() {
                        Row() {
                          Text(this.occasion || '选择场合')
                            .fontSize(16)
                            .fontColor(this.occasion ? '#333333' : '#999999')
                            .layoutWeight(1)
                          
                          Text('▼')
                            .fontSize(12)
                            .fontColor('#999999')
                        }
                      }
                      .width('100%')
                      .height(48)
                      .backgroundColor('#F8F9FA')
                      .borderRadius(8)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => {
                        // 显示场合选择弹窗
                      })
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                    .margin({ bottom: 16 })
                  }
                  .layoutWeight(1)
                  .margin({ left: 8 })
                }
                .width('100%')
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
            
            // 礼物信息
            Column() {
              Text('礼物信息')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 16 })
              
              Column() {
                // 礼物创意
                Column() {
                  Row() {
                    Text('礼物创意')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .margin({ bottom: 8 })
                  
                  if (this.selectedInspiration) {
                    Row() {
                      if (this.selectedInspiration.images?.[0]) {
                        Image(this.selectedInspiration.images[0])
                          .width(60)
                          .height(60)
                          .borderRadius(8)
                          .objectFit(ImageFit.Cover)
                          .margin({ right: 12 })
                      } else {
                        Text('💡')
                          .fontSize(24)
                          .width(60)
                          .height(60)
                          .textAlign(TextAlign.Center)
                          .backgroundColor('#F8F9FA')
                          .borderRadius(8)
                          .margin({ right: 12 })
                      }
                      
                      Column() {
                        Text(this.selectedInspiration.title)
                          .fontSize(16)
                          .fontColor('#333333')
                          .fontWeight(FontWeight.Medium)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        
                        Text(this.selectedInspiration.description)
                          .fontSize(14)
                          .fontColor('#666666')
                          .margin({ top: 4 })
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      
                      Button('移除')
                        .fontSize(12)
                        .fontColor('#FF4444')
                        .backgroundColor('#FFF5F5')
                        .borderRadius(4)
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .onClick(() => {
                          this.selectedInspiration = null;
                        })
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(8)
                    .margin({ bottom: 16 })
                  }
                  
                  TextArea({ placeholder: '描述你的礼物创意...' })
                    .fontSize(16)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(8)
                    .padding(16)
                    .height(80)
                    .onChange((value: string) => {
                      this.giftIdea = value;
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
                
                // 实际花费
                Column() {
                  Row() {
                    Text('实际花费')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .margin({ bottom: 8 })
                  
                  TextInput({ placeholder: '输入实际花费金额' })
                    .fontSize(16)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(8)
                    .padding({ left: 16, right: 16 })
                    .type(InputType.Number)
                    .onChange((value: string) => {
                      this.actualCost = parseFloat(value) || 0;
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
            
            // 照片记录
            Column() {
              Text('照片记录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 16 })
              
              Column() {
                if (this.selectedImages.length > 0) {
                  Grid() {
                    ForEach(this.selectedImages, (imageUri: string, index: number) => {
                      GridItem() {
                        Stack() {
                          Image(imageUri)
                            .width('100%')
                            .height('100%')
                            .borderRadius(8)
                            .objectFit(ImageFit.Cover)
                          
                          Button() {
                            Text('×')
                              .fontSize(16)
                              .fontColor('#FFFFFF')
                          }
                          .width(24)
                          .height(24)
                          .backgroundColor('#FF4444')
                          .borderRadius(12)
                          .position({ x: '90%', y: '5%' })
                          .translate({ x: '-50%', y: '0%' })
                          .onClick(() => this.removeImage(index))
                        }
                        .width('100%')
                        .height(80)
                      }
                    })
                    
                    if (this.selectedImages.length < 5) {
                      GridItem() {
                        Button() {
                          Column() {
                            Text('+')
                              .fontSize(24)
                              .fontColor('#CCCCCC')
                            
                            Text('添加照片')
                              .fontSize(12)
                              .fontColor('#CCCCCC')
                              .margin({ top: 4 })
                          }
                        }
                        .width('100%')
                        .height(80)
                        .backgroundColor('#F8F9FA')
                        .borderRadius(8)
                        .border({ width: 1, color: '#EEEEEE', style: BorderStyle.Dashed })
                        .onClick(() => this.selectImages())
                      }
                    }
                  }
                  .columnsTemplate('1fr 1fr 1fr')
                  .columnsGap(8)
                  .rowsGap(8)
                  .margin({ bottom: 16 })
                }
                
                Button('添加照片')
                  .fontSize(16)
                  .fontColor('#FF6B35')
                  .backgroundColor('#FFF5F0')
                  .borderRadius(8)
                  .border({ width: 1, color: '#FF6B35', style: BorderStyle.Dashed })
                  .onClick(() => this.selectImages())
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
            
            // 情感记录
            Column() {
              Text('情感记录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 16 })
              
              Column() {
                // 送礼故事
                Column() {
                  Row() {
                    Text('送礼故事')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .margin({ bottom: 8 })
                  
                  TextArea({ placeholder: '记录送礼的过程和背景...' })
                    .fontSize(16)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(8)
                    .padding(16)
                    .height(80)
                    .onChange((value: string) => {
                      this.story = value;
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
                
                // 对方反应
                Column() {
                  Row() {
                    Text('对方反应')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .margin({ bottom: 8 })
                  
                  TextArea({ placeholder: '记录对方收到礼物时的反应...' })
                    .fontSize(16)
                    .backgroundColor('#F8F9FA')
                    .borderRadius(8)
                    .padding(16)
                    .height(80)
                    .onChange((value: string) => {
                      this.reaction = value;
                    })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
                
                // 我的心情
                Column() {
                  Row() {
                    Text('我的心情')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .margin({ bottom: 8 })
                  
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.moods, (mood: string) => {
                      Button(mood)
                        .fontSize(14)
                        .fontColor(this.mood === mood ? '#FFFFFF' : '#666666')
                        .backgroundColor(this.mood === mood ? '#FF6B35' : '#F5F5F5')
                        .borderRadius(16)
                        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                        .margin({ right: 8, bottom: 8 })
                        .onClick(() => {
                          this.mood = this.mood === mood ? '' : mood;
                        })
                    })
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .margin({ bottom: 16 })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
            
            // 提醒设置
            Column() {
              Text('提醒设置')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 16 })
              
              Column() {
                Row() {
                  Column() {
                    Text('明年提醒')
                      .fontSize(16)
                      .fontColor('#333333')
                    
                    Text('在指定日期前提醒我准备礼物')
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
                    .selectedColor('#FF6B35')
                    .onChange((isOn: boolean) => {
                      this.reminderEnabled = isOn;
                    })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                
                if (this.reminderEnabled) {
                  Column() {
                    Column() {
                      Row() {
                        Text('提醒日期')
                          .fontSize(14)
                          .fontColor('#666666')
                      }
                      .margin({ bottom: 8 })
                      
                      Button() {
                        Text(this.reminderDate || '选择提醒日期')
                          .fontSize(16)
                          .fontColor(this.reminderDate ? '#333333' : '#999999')
                      }
                      .width('100%')
                      .height(48)
                      .backgroundColor('#F8F9FA')
                      .borderRadius(8)
                      .onClick(() => {
                        // 显示日期选择器
                      })
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                    .margin({ bottom: 16 })
                  }
                  .margin({ top: 16 })
                }
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .padding(16)
            .margin({ bottom: 16 })
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}