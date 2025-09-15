import { GiftEvent, Contact, Inspiration, Reminder } from '../../model/NewDataModels';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { ContactDAO } from '../../database/ContactDAO';
import { InspirationDAO } from '../../database/InspirationDAO';
import { ReminderDAO } from '../../database/ReminderDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import router from '@ohos.router';
import picker from '@ohos.file.picker';
import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';
// 兼容的TextPickerResult类型定义
interface CompatibleTextPickerResult {
  index: number | number[];
  value: string | string[];
}

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
  @State recipientName: string = '';
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
  @State showOccasionDialog: boolean = false;
  @State customOccasion: string = '';
  
  // 添加联系人对话框相关
  @State showAddContactDialog: boolean = false;
  
  private dbManager = new NewDatabaseManager();
  private giftEventDAO: GiftEventDAO = new GiftEventDAO(this.dbManager);
  private contactDAO: ContactDAO = new ContactDAO(this.dbManager);
  private inspirationDAO: InspirationDAO = new InspirationDAO(this.dbManager);
  private reminderDAO: ReminderDAO = new ReminderDAO(this.dbManager);

  private getIconByMood(mood: string): Resource {
    if (mood==='开心') {
      return $r('app.media.icon_happy');
    }
    if (mood==='兴奋') {
      return $r('app.media.icon_xf');
    }
    if (mood==='感动') {
      return $r('app.media.icon_gd');
    }
    if (mood==='紧张') {
      return $r('app.media.icon_jz');
    }
    if (mood==='期待') {
      return $r('app.media.icon_qd');
    }
    if (mood==='满足') {
      return $r('app.media.icon_mz');
    }
    if (mood==='温暖') {
      return $r('app.media.icon_wn');
    }
    return $r('app.media.icon_other');
  }
  async aboutToAppear() {
    const params: PageParams = router.getParams() as PageParams || {}
    
    if (params.eventId) {
      this.eventId = params.eventId;
      this.isEditMode = true;
    }
    
    if (params.isEdit !== undefined) {
      this.isEditMode = params.isEdit;
    }
    
    // 确保数据库已初始化
    try {
      await this.dbManager.initDatabase(getContext(this));
      console.log('数据库初始化成功');
    } catch (error) {
      console.error('数据库初始化失败:', error);
    }
    
    this.loadData(params);
  }
  
  // 页面显示时刷新联系人列表
  async onPageShow() {
    try {
      // 重新加载联系人列表，以获取可能新增的联系人
      const updatedContacts = await this.contactDAO.getAllContacts();
      this.contacts = updatedContacts;
      console.log('联系人列表已刷新，当前联系人数量:', this.contacts.length);
    } catch (error) {
      console.error('刷新联系人列表失败:', error);
    }
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
    this.recipientName = event.contactName || '';
    this.eventTitle = event.occasion + ' - ' + event.contactName; // 组合事件标题
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
    
    // 加载联系人 - 修复收礼人显示问题
    const contact = this.contacts.find(c => c.id === event.contactId);
    if (contact) {
      this.selectedContact = contact;
      // 确保recipientName与selectedContact保持一致
      this.recipientName = contact.name;
    } else {
      // 如果找不到联系人，创建一个临时联系人对象以保持数据一致性
        console.warn('未找到对应的联系人，contactId:', event.contactId);
        if (event.contactName) {
          const tempContact: Contact = {
            id: String(event.contactId || 0),
            name: event.contactName,
            relationship: '',
            avatar: '',
            birthday: '',
            importantDates: [],
            preferences: [],
            notes: '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
          };
          this.selectedContact = tempContact;
          this.recipientName = tempContact.name;
        }
    }
  }
  
  async selectImages() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 3 - this.selectedImages.length;
      
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
  
  showDatePicker() {
    DatePickerDialog.show({
      start: new Date('1900-1-1'),
      end: new Date('2100-12-31'),
      selected: new Date(this.eventDate),
      onAccept: (value: DatePickerResult) => {
        const selectedDate = new Date(value.year!, value.month! + 1, value.day!);
        this.eventDate = selectedDate.toISOString().split('T')[0];
      }
    });
  }
  
  showOccasionPicker() {
    this.showOccasionDialog = true;
  }
  
  showReminderDatePicker() {
    DatePickerDialog.show({
      start: new Date(),
      end: new Date('2100-12-31'),
      selected: this.reminderDate ? new Date(this.reminderDate) : new Date(),
      onAccept: (value: DatePickerResult) => {
        const selectedDate = new Date(value.year!, value.month! + 1, value.day!);
        this.reminderDate = selectedDate.toISOString().split('T')[0];
      }
    });
  }
  
  async saveEvent() {
    if (!this.validateForm()) {
      console.log('表单验证失败');
      return;
    }
    
    try {
      this.isSaving = true;
      console.log('开始保存事件...');
      
      const eventData: GiftEvent = {
        contactId: '', // 不再需要contactId
        contactName: this.recipientName,
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
      
      console.log('事件数据:', JSON.stringify(eventData));
      
      let eventId: string;
      if (this.isEditMode) {
        console.log('更新事件:', this.eventId);
        await this.giftEventDAO.updateGiftEvent(this.eventId, eventData);
        eventId = this.eventId;
      } else {
        console.log('创建新事件');
        const newId = await this.giftEventDAO.createGiftEvent(eventData as GiftEvent);
        console.log('创建成功，ID:', newId);
        eventId = newId;
      }

      // 创建系统提醒和数据库提醒记录
      if (this.reminderEnabled && this.reminderDate) {
        const reminderId = await this.createSystemReminder(eventData);
        if (reminderId) {
          // 保存提醒到数据库
          const reminderData: Reminder = {
            id: `reminder_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            type: 'gift_event',
            relatedId: eventId,
            title: `送礼提醒：${eventData.contactName}`,
            message: `${eventData.occasion} - ${eventData.giftIdea || '准备礼物'}`,
            reminderDate: new Date(this.reminderDate).toISOString(),
            isActive: true,
            isTriggered: false,
            createdAt: new Date().toISOString()
          };
          
          try {
            await this.reminderDAO.createReminder(reminderData);
            console.log('提醒已保存到数据库');
          } catch (error) {
            console.error('保存提醒到数据库失败:', error);
          }
          console.log('系统提醒创建成功，ID:', reminderId);
        }
      }
      
      console.log('保存成功，返回记录页面');
      // 返回主页面并切换到记录tab，触发数据刷新
      router.replaceUrl({
        url: 'pages/MainTabsPage',
        params: {
          targetTab: 1 // 切换到记录tab
        }
      });
    } catch (error) {
      console.error('保存事件失败:', error);
      // 显示错误提示给用户
      AlertDialog.show({
        title: '保存失败',
        message: '保存记录时出现错误，请重试',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
    } finally {
      this.isSaving = false;
    }
  }
  
  // 导航到添加联系人页面
  navigateToAddContact() {
    router.pushUrl({
      url: 'pages/profile/ContactFormPage',
      params: {
        isEdit: false
      }
    });
  }
  
  // 选择联系人
  selectContact(contact: Contact) {
    this.selectedContact = contact;
    this.recipientName = contact.name;
  }
  
  // 显示收礼人选择器
  showRecipientPicker() {
    if (this.contacts.length === 0) {
      AlertDialog.show({
        title: '提示',
        message: '暂无联系人，请先添加联系人',
        primaryButton: {
          value: '添加联系人',
          action: () => {
            this.navigateToAddContact();
          }
        },
        secondaryButton: {
          value: '取消',
          action: () => {}
        }
      });
      return;
    }
    
    const contactNames = this.contacts.map(contact => contact.name);
    
    // 确保contactNames不为空
    if (contactNames.length === 0) {
      console.error('联系人列表为空，无法显示选择器');
      return;
    }
    
    let selectedIndex = 0;
    if (this.selectedContact) {
      const foundIndex = this.contacts.findIndex(contact => contact.id === this.selectedContact!.id);
      selectedIndex = foundIndex >= 0 ? foundIndex : 0;
    }
    
    // 确保selectedIndex在有效范围内
    selectedIndex = Math.max(0, Math.min(selectedIndex, contactNames.length - 1));
    
    TextPickerDialog.show({
      range: contactNames,
      selected: selectedIndex,
      canLoop: false,
      onAccept: (value: CompatibleTextPickerResult) => {
        let index: number = 0;
        if (Array.isArray(value.index)) {
          if (value.index.length > 0) {
            // 使用forEach避免索引访问
            value.index.forEach((item: number, i: number) => {
              if (i === 0) {
                index = item;
              }
            });
          }
        } else {
          index = value.index as number;
        }
        if (index >= 0 && index < this.contacts.length) {
          let selectedContact: Contact | undefined;
          for (let i = 0; i < this.contacts.length; i++) {
            if (i === index) {
              selectedContact = this.contacts[i];
              break;
            }
          }
          // 避免重复选择同一联系人导致的循环
          if (selectedContact && (!this.selectedContact || this.selectedContact.id !== selectedContact.id)) {
            this.selectContact(selectedContact);
          }
        }
      },
      onCancel: () => {
        console.log('取消选择收礼人');
      }
    });
  }

  // 创建系统提醒
  async createSystemReminder(eventData: GiftEvent): Promise<number | null> {
    if (!this.reminderEnabled || !this.reminderDate) {
      return null;
    }

    try {
      const reminderDateTime = new Date(this.reminderDate);
      
      const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: reminderDateTime.getFullYear(),
          month: reminderDateTime.getMonth() + 1,
          day: reminderDateTime.getDate(),
          hour: 9, // 默认上午9点提醒
          minute: 0
        },
        title: `送礼提醒：${eventData.contactName}`,
        content: `${eventData.occasion} - ${eventData.giftIdea || '准备礼物'}`,
        expiredContent: '提醒已过期',
        snoozeContent: '稍后提醒',
        notificationId: 100,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
      };
      
      const reminderId = await reminderAgentManager.publishReminder(reminderRequest);
      console.info('创建系统提醒成功，ID:', reminderId);
      return reminderId;
    } catch (error) {
      console.error('创建系统提醒失败:', error);
      return null;
    }
  }
  
  validateForm(): boolean {
    if (!this.selectedContact) {
      console.log('收礼人不能为空');
      AlertDialog.show({
        title: '提示',
        message: '请选择收礼人',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return false;
    }
    
    if (!this.occasion) {
      console.log('场合不能为空');
      AlertDialog.show({
        title: '提示',
        message: '请选择送礼场合',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return false;
    }
    
    console.log('表单验证通过');
    return true;
  }
  
  goBack() {
    router.back();
  }
  
  showDeleteConfirmDialog() {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条记录吗？删除后无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF4444',
        action: () => {
          this.deleteEvent();
        }
      }
    });
  }
  
  async deleteEvent() {
    try {
      this.isSaving = true;
      console.log('删除事件:', this.eventId);
      
      await this.giftEventDAO.deleteGiftEvent(this.eventId);
      
      console.log('删除成功，返回记录页面');
      // 返回主页面并切换到记录tab，触发数据刷新
      router.replaceUrl({
        url: 'pages/MainTabsPage',
        params: {
          targetTab: 1 // 切换到记录tab
        }
      });
    } catch (error) {
      console.error('删除事件失败:', error);
      AlertDialog.show({
        title: '删除失败',
        message: '删除记录时出现错误，请重试',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
    } finally {
      this.isSaving = false;
    }
  }
  
  build() {
    Stack() {
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
        
        Row() {
          // 删除按钮（仅编辑模式显示）
          if (this.isEditMode) {
            Button() {
              Text('删除')
                .fontSize(14)
                .fontColor('#FF4444')
            }
            .width(50)
            .height(32)
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: '#FF4444' })
            .borderRadius(16)
            .margin({ right: 8 })
            .onClick(() => this.showDeleteConfirmDialog())
          }
          
          // 保存按钮
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
        .justifyContent(FlexAlign.End)
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
                  
                  if (this.contacts.length > 0) {
                    // 有联系人时显示下拉框
                    Button() {
                      Row() {
                        Text(this.selectedContact ? this.selectedContact.name : '选择收礼人')
                          .fontSize(16)
                          .fontColor(this.selectedContact ? '#333333' : '#999999')
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
                      this.showRecipientPicker();
                    })
                  } else {
                    // 没有联系人时显示提示
                    Column() {
                      Button() {
                        Row() {
                          Text('暂无联系人，请先添加关系')
                            .fontSize(16)
                            .fontColor('#999999')
                            .layoutWeight(1)
                          
                          Text('添加')
                            .fontSize(14)
                            .fontColor('#FF6B35')
                        }
                      }
                      .width('100%')
                      .height(48)
                      .backgroundColor('#FFF5F0')
                      .borderRadius(8)
                      .padding({ left: 16, right: 16 })
                      .border({ width: 1, color: '#FF6B35', style: BorderStyle.Dashed })
                      .onClick(() => {
                        this.navigateToAddContact();
                      })
                    }
                  }
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
                  
                  TextInput({ placeholder: '为这次送礼起个名字', text: this.eventTitle })
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
                        this.showDatePicker();
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
                        this.showOccasionPicker();
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
                  
                  TextArea({ placeholder: '描述你的礼物创意...', text: this.giftIdea })
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
                  
                  TextInput({ placeholder: '输入实际花费金额（单位：元）', text: this.actualCost > 0 ? this.actualCost.toString() : '' })
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
                    
                    if (this.selectedImages.length < 3) {
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
                        .border({ width: 1, color: '#CCCCCC', style: BorderStyle.Dashed })
                        .onClick(() => this.selectImages())
                      }
                    }
                  }
                  .columnsTemplate('1fr 1fr 1fr')
                  .columnsGap(8)
                  .rowsGap(8)
                  .margin({ bottom: 16 })
                } else {
                  Button('最多添加3张照片')
                    .fontSize(16)
                    .fontColor('#FF6B35')
                    .backgroundColor('#FFF5F0')
                    .borderRadius(8)
                    .border({ width: 1, color: '#FF6B35', style: BorderStyle.Dashed })
                    .onClick(() => this.selectImages())
                }
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
                  
                  TextArea({ placeholder: '记录送礼的过程和背景...', text: this.story })
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
                  
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.moods, (mood: string) => {
                      Button() {
                        Row() {
                          Image(this.getIconByMood(mood))
                            .width(14)
                            .height(14)
                            .margin({ right: 4 })
                          Text(mood)
                            .fontSize(14)
                        }
                      }
                      .fontColor(this.reaction === mood ? '#FFFFFF' : '#666666')
                      .backgroundColor(this.reaction === mood ? '#FF6B35' : '#F5F5F5')
                      .borderRadius(16)
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .margin({ right: 8, bottom: 8 })
                      .onClick(() => {
                        this.reaction = this.reaction === mood ? '' : mood;
                      })
                    })
                  }
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
                      Button() {
                        Row() {
                          Image(this.getIconByMood(mood))
                            .width(14)
                            .height(14)
                            .margin({ right: 4 })
                          Text(mood)
                            .fontSize(14)
                        }
                      }
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
                        this.showReminderDatePicker();
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
    .bindSheet($$this.showOccasionDialog, this.occasionPickerSheet(), {
      height: 400,
      dragBar: true,
      backgroundColor: '#FFFFFF'
    })


    }
  }
  
  @Builder
  occasionPickerSheet() {
    Column() {
      Text('选择场合')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20, bottom: 20 })
      
      List() {
        ForEach(this.occasions, (occasion: string) => {
          ListItem() {
            Row() {
              Text(occasion)
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)
              
              if (this.occasion === occasion) {
                Text('✓')
                  .fontSize(16)
                  .fontColor('#FF6B35')
              }
            }
            .width('100%')
            .height(48)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              if (occasion === '其他') {
                // 显示自定义输入
                this.occasion = '';
                this.showCustomOccasionInput();
              } else {
                this.occasion = occasion;
                this.showOccasionDialog = false;
              }
            })
          }
        })
      }
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
      
      if (this.occasion === '' && this.customOccasion !== '') {
        Column() {
          Text('自定义场合')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 10 })
          
          TextInput({ placeholder: '请输入自定义场合', text: this.customOccasion })
            .fontSize(16)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .margin({ bottom: 20 })
            .onChange((value: string) => {
              this.customOccasion = value;
            })
          
          Button('确定')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B35')
            .borderRadius(8)
            .width('100%')
            .height(44)
            .onClick(() => {
              if (this.customOccasion.trim()) {
                this.occasion = this.customOccasion.trim();
                this.showOccasionDialog = false;
                this.customOccasion = '';
              }
            })
        }
        .padding({ left: 20, right: 20 })
      }
    }
    .width('100%')
  }

  showCustomOccasionInput() {
    this.customOccasion = '';
  }
}