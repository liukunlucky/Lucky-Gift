import router from '@ohos.router';
import { Contact, GiftEvent, Reminder } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { ReminderDAO } from '../../database/ReminderDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@ohos.base';
import { common } from '@kit.AbilityKit';

interface ReminderItem {
  id: string;
  contactId: string;
  contactName: string;
  title: string;
  content: string;
  dateTime: string;
  type: 'gift_event' | 'important_date' | 'holiday';
  isCompleted: boolean;
  isEnabled: boolean;
  createdAt: string;
  reminderId?: number; // 系统提醒ID
  relatedId?: string; // 关联的事件ID
  isLinkedToGiftEvent?: boolean; // 是否关联收礼事件
}

interface SelectOption {
  value: string;
  id: string;
}

@Entry
@Component
struct GiftReminderPage {
  @State reminders: ReminderItem[] = [];
  @State contacts: Contact[] = [];
  @State isLoading: boolean = true;
  @State showAddDialog: boolean = false;
  @State selectedType: string = 'gift_event';
  @State selectedContactId: string = '';
  @State reminderTitle: string = '';
  @State reminderContent: string = '';
  @State reminderDate: string = '';
  @State reminderTime: string = '09:00';
  @State private editingReminder: ReminderItem | null = null;
  @State private deletingReminder: ReminderItem | null = null;
  
  private dbManager = new NewDatabaseManager();
  private contactDao = new ContactDAO(this.dbManager);
  private giftEventDao = new GiftEventDAO(this.dbManager);
  private reminderDao = new ReminderDAO(this.dbManager);
  
  async aboutToAppear() {
    try {
      // 初始化数据库
      const context = getContext(this) as common.UIAbilityContext;
      await this.dbManager.initDatabase(context);
      
      // 加载数据
      await this.loadData();
    } catch (error) {
      console.error('页面初始化失败:', error);
      this.isLoading = false;
    }
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载联系人数据
      this.contacts = await this.contactDao.getAllContacts();
      
      // 加载提醒数据
      await this.loadReminders();
      
    } catch (error) {
      console.error('加载提醒数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async loadReminders() {
    try {
      const dbReminders = await this.reminderDao.getAllReminders();
      this.reminders = await Promise.all(dbReminders.map(async (reminder): Promise<ReminderItem> => {
        // 判断是否关联收礼事件
        let isLinkedToGiftEvent = false;
        let contactName = '未知联系人';
        
        // 首先尝试检查是否真正关联了收礼事件
        // 只有当reminder.relatedId确实对应一个存在的收礼事件时，才认为是关联的
        if (reminder.type === 'gift_event' && reminder.relatedId) {
          try {
            const giftEvent = await this.giftEventDao.getGiftEventById(reminder.relatedId);
            if (giftEvent) {
              // 确实找到了对应的收礼事件，说明是关联的
              isLinkedToGiftEvent = true;
              contactName = giftEvent.contactName;
            } else {
              // 没有找到对应的收礼事件，说明relatedId存储的是contactId
              isLinkedToGiftEvent = false;
              // 从联系人表获取信息
              const contact = this.contacts.find(c => c.id === reminder.relatedId);
              if (contact) {
                contactName = contact.name;
              } else {
                // 如果在当前联系人列表中找不到，尝试从数据库重新获取
                try {
                  const dbContact = await this.contactDao.getContactById(reminder.relatedId);
                  if (dbContact) {
                    contactName = dbContact.name;
                    // 同时更新本地联系人列表
                    this.contacts.push(dbContact);
                  }
                } catch (error) {
                  console.error('获取联系人信息失败:', error);
                }
              }
            }
          } catch (error) {
            console.error('检查关联事件失败:', error);
            // 出错时默认认为不是关联的，从联系人表获取信息
            isLinkedToGiftEvent = false;
            const contact = this.contacts.find(c => c.id === reminder.relatedId);
            if (contact) {
              contactName = contact.name;
            } else {
              try {
                const dbContact = await this.contactDao.getContactById(reminder.relatedId);
                if (dbContact) {
                  contactName = dbContact.name;
                  this.contacts.push(dbContact);
                }
              } catch (error) {
                console.error('获取联系人信息失败:', error);
              }
            }
          }
        } else {
          // 其他类型的提醒，从联系人表获取信息
          // reminder.relatedId 存储的就是 contactId
          const contact = this.contacts.find(c => c.id === reminder.relatedId);
          if (contact) {
            contactName = contact.name;
          } else {
            // 如果在当前联系人列表中找不到，可能是新添加的联系人，尝试从数据库重新获取
            try {
              const dbContact = await this.contactDao.getContactById(reminder.relatedId);
              if (dbContact) {
                contactName = dbContact.name;
                // 同时更新本地联系人列表
                this.contacts.push(dbContact);
              }
            } catch (error) {
              console.error('获取联系人信息失败:', error);
            }
          }
        }
        
        const reminderItem: ReminderItem = {
          id: reminder.id,
          contactId: reminder.relatedId,
          contactName: contactName,
          title: reminder.title,
          content: reminder.message || '',
          dateTime: reminder.reminderDate,
          type: reminder.type,
          isEnabled: reminder.isActive,
          isCompleted: reminder.isTriggered,
          createdAt: reminder.createdAt,
          reminderId: undefined,
          relatedId: reminder.relatedId,
          isLinkedToGiftEvent: isLinkedToGiftEvent
        };
        return reminderItem;
      }));
    } catch (error) {
      console.error('加载提醒数据失败:', error);
      this.reminders = [];
    }
  }
  
  async createSystemReminder(reminder: ReminderItem): Promise<number | null> {
    try {
      const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: parseInt(reminder.dateTime.split('-')[0]),
          month: parseInt(reminder.dateTime.split('-')[1]),
          day: parseInt(reminder.dateTime.split('-')[2].split(' ')[0]),
          hour: parseInt(reminder.dateTime.split(' ')[1].split(':')[0]),
          minute: parseInt(reminder.dateTime.split(' ')[1].split(':')[1])
        },
        title: reminder.title,
        content: reminder.content,
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
  
  async cancelSystemReminder(reminderId: number) {
    try {
      await reminderAgentManager.cancelReminder(reminderId);
      console.info('取消系统提醒成功，ID:', reminderId);
    } catch (error) {
      console.error('取消系统提醒失败:', error);
    }
  }
  
  async toggleReminder(reminder: ReminderItem) {
    if (reminder.isEnabled) {
      // 禁用提醒
      if (reminder.reminderId) {
        await this.cancelSystemReminder(reminder.reminderId);
        reminder.reminderId = undefined;
      }
      reminder.isEnabled = false;
    } else {
      // 启用提醒
      const reminderId = await this.createSystemReminder(reminder);
      if (reminderId) {
        reminder.reminderId = reminderId;
        reminder.isEnabled = true;
      }
    }
    
    // 更新数据库
    try {
      await this.reminderDao.updateReminder({
        id: reminder.id,
        type: reminder.type,
        relatedId: reminder.contactId,
        title: reminder.title,
        message: reminder.content,
        reminderDate: reminder.dateTime,
        isActive: reminder.isEnabled,
        isTriggered: reminder.isCompleted,
        createdAt: reminder.createdAt
      });
    } catch (error) {
      console.error('更新提醒失败:', error);
    }
    
    // 更新状态
    this.reminders = [...this.reminders];
  }
  
  showAddReminderDialog() {
    this.editingReminder = null;
    this.selectedType = 'gift_event';
    this.selectedContactId = '';
    this.reminderTitle = '';
    this.reminderContent = '';
    this.reminderDate = '';
    this.reminderTime = '09:00';
    this.showAddDialog = true;
  }
  
  showEditReminderDialog(reminder: ReminderItem) {
    this.editingReminder = reminder;
    this.selectedType = reminder.type;
    this.selectedContactId = reminder.contactId;
    this.reminderTitle = reminder.title;
    this.reminderContent = reminder.content;
    const dateTimeParts = reminder.dateTime.split(' ');
    const date = dateTimeParts[0];
    const time = dateTimeParts[1];
    this.reminderDate = date;
    this.reminderTime = time;
    this.showAddDialog = true;
  }
  
  async saveReminder() {
    if (!this.selectedContactId || !this.reminderTitle || !this.reminderDate) {
      return;
    }
    
    const contact = this.contacts.find(c => c.id === this.selectedContactId);
    if (!contact) return;
    
    const dateTime = `${this.reminderDate} ${this.reminderTime}`;
    
    if (this.editingReminder) {
      // 编辑现有提醒
      this.editingReminder.contactId = this.selectedContactId;
      this.editingReminder.contactName = contact.name;
      this.editingReminder.title = this.reminderTitle;
      this.editingReminder.content = this.reminderContent;
      this.editingReminder.dateTime = dateTime;
      this.editingReminder.type = this.selectedType as 'gift_event' | 'important_date' | 'holiday';
      
      // 如果提醒已启用，需要重新创建系统提醒
      if (this.editingReminder.isEnabled) {
        if (this.editingReminder.reminderId) {
          await this.cancelSystemReminder(this.editingReminder.reminderId);
        }
        const reminderId = await this.createSystemReminder(this.editingReminder);
        this.editingReminder.reminderId = reminderId || undefined;
      }
      
      // 更新数据库
      try {
        await this.reminderDao.updateReminder({
          id: this.editingReminder.id,
          type: this.editingReminder.type,
          relatedId: this.editingReminder.contactId,
          title: this.editingReminder.title,
          message: this.editingReminder.content,
          reminderDate: this.editingReminder.dateTime,
          isActive: this.editingReminder.isEnabled,
          isTriggered: this.editingReminder.isCompleted,
          createdAt: this.editingReminder.createdAt
        });
      } catch (error) {
        console.error('更新提醒失败:', error);
      }
    } else {
      // 创建新提醒
      const newReminder: ReminderItem = {
        id: Date.now().toString(),
        contactId: this.selectedContactId,
        contactName: contact.name,
        title: this.reminderTitle,
        content: this.reminderContent,
        dateTime: dateTime,
        type: this.selectedType as 'gift_event' | 'important_date' | 'holiday',
        isEnabled: true,
        isCompleted: false,
        createdAt: new Date().toISOString()
      };
      
      // 创建系统提醒
      const reminderId = await this.createSystemReminder(newReminder);
      newReminder.reminderId = reminderId || undefined;
      
      // 保存到数据库
      try {
        const savedReminder = await this.reminderDao.createReminder({
          id: newReminder.id,
          type: newReminder.type,
          relatedId: newReminder.contactId,
          title: newReminder.title,
          message: newReminder.content,
          reminderDate: newReminder.dateTime,
          isActive: newReminder.isEnabled,
          isTriggered: newReminder.isCompleted,
          createdAt: newReminder.createdAt
        });
        this.reminders.push(newReminder);
      } catch (error) {
        console.error('保存提醒失败:', error);
        // 如果保存失败，取消系统提醒
        if (reminderId) {
          await this.cancelSystemReminder(reminderId);
        }
        return;
      }
    }
    
    this.reminders = [...this.reminders];
    this.showAddDialog = false;
  }
  
  getTypeIcon(type: string): Resource {
    switch (type) {
      case 'gift_event': return $r('app.media.icon_happy');
      case 'important_date': return $r('app.media.icon_memory');
      case 'holiday': return $r('app.media.icon_rq');
      default: return $r('app.media.icon_rq');
    }
  }
  
  getTypeName(type: string): string {
    switch (type) {
      case 'gift_event': return '礼物事件';
      case 'important_date': return '重要日期';
      case 'holiday': return '节日';
      default: return '其他';
    }
  }
  
  formatDateTime(dateTime: string): string {
    const date = new Date(dateTime);
    const now = new Date();
    const diffDays = Math.ceil((date.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      return '今天';
    } else if (diffDays === 1) {
      return '明天';
    } else if (diffDays > 0) {
      return `${diffDays}天后`;
    } else {
      return '已过期';
    }
  }

  formatSpecificDate(dateTime: string): string {
    const date = new Date(dateTime);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  goBack() {
    router.back();
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
          this.goBack()
        })
        
        Text('礼物提醒')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Image($r('app.media.ic_add'))
          .width(36)
          .height(36)
          .fillColor('#FF6B35')
          .onClick(() => {
            this.showAddReminderDialog();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#FF6B35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        if (this.reminders.length === 0) {
          // 空状态
          Column() {
            Image($r('app.media.icon_empty'))
              .width(173)
              .height(128)

            Text('暂无提醒')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 16 })
            
            Text('点击右上角按钮添加提醒')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 提醒列表
          Scroll() {
            Column() {
              List() {
                ForEach(this.reminders, (reminder: ReminderItem) => {
                  ListItem() {
                    Column() {
                      // 第一行：送给：联系人名字 + 右侧时间显示
                      Row() {
                        Row() {
                          Text('送给：')
                            .fontSize(14)
                            .fontColor('#666666')
                          Text(reminder.contactName)
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor('#333333')
                        }
                        .layoutWeight(1)
                        
                        Text(this.formatDateTime(reminder.dateTime))
                          .fontSize(14)
                          .fontColor('#FF6B35')
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                      
                      // 第二行：根据提醒类型决定是否显示标题
                      if (!reminder.isLinkedToGiftEvent && reminder.title && reminder.title.trim() !== '') {
                        Text(reminder.title)
                          .fontSize(14)
                          .fontColor('#666666')
                          .width('100%')
                          .margin({ top: 6 })
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      
                      // 第三行：具体提醒日期
                      Text(this.formatSpecificDate(reminder.dateTime))
                        .fontSize(14)
                        .fontColor('#999999')
                        .width('100%')
                        .margin({ top: 6 })
                      
                      // 第四行：是否关联收礼
                      Row() {
                        Image($r('app.media.icon_check'))
                          .width(12)
                          .height(12)
                          .fillColor('#4CAF50')
                          .margin({ right: 4 })
                        Text('已关联')
                          .fontSize(12)
                          .fontColor('#4CAF50')
                      }
                      .width('100%')
                      .visibility(reminder.isLinkedToGiftEvent? Visibility.Visible: Visibility.None)
                      .alignItems(VerticalAlign.Center)
                      .margin({ top: 6 })
                    }
                    .width('100%')
                    .padding(16)
                    .backgroundColor(Color.White)
                    .borderRadius(12)
                    .alignItems(HorizontalAlign.Start)
                    .onClick(() => {
                      // 暂时去掉编辑功能
                      // this.showEditReminderDialog(reminder);
                    })
                  }
                  .swipeAction({ end: this.buildSwipeAction(reminder) })
                  .margin({ bottom: 8, left: 16, right: 16 })
                })
              }
              .scrollBar(BarState.Off)
            }
            .width('100%')
            .padding({ bottom: 60, top: 20, left: 10, right: 10 })
          }
          .scrollBar(BarState.Off)
          .margin({ top: 8 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showAddDialog, this.buildAddReminderDialog(), {
      height: 600,
      dragBar: true,
      showClose: false
    })
  }
  
  // 构建左滑删除操作按钮
  @Builder
  buildSwipeAction(reminder: ReminderItem) {
    Row() {
      Button() {
        Column() {
          Image($r('app.media.icon_delete'))
            .width(24)
            .height(24)
            .fillColor('#FF4444')
          Text('删除')
            .fontSize(12)
            .fontColor('#FF4444')
            .margin({ top: 4 })
        }
      }
      .width(80)
      .backgroundColor(Color.Transparent)
      .height('100%')
      .borderRadius(0)
      .onClick(() => {
        this.showDeleteConfirmDialog(reminder);
      })
    }
    .height('100%')
  }
  
  showDeleteConfirmDialog(reminder: ReminderItem) {
    this.deletingReminder = reminder;
    AlertDialog.show({
      title: '删除提醒',
      message: `确定要删除提醒"${reminder.title}"吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
          this.deletingReminder = null;
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF4444',
        action: () => {
          this.deleteReminder();
        }
      }
    });
  }
  
  async deleteReminder() {
    if (!this.deletingReminder) return;
    
    try {
      // 如果有系统提醒ID，先取消系统提醒
      if (this.deletingReminder.reminderId) {
        await reminderAgentManager.cancelReminder(this.deletingReminder.reminderId);
      }
      
      // 从数据库删除
      await this.reminderDao.deleteReminder(this.deletingReminder.id);
      
      // 从本地列表中移除
      const index = this.reminders.findIndex(r => r.id === this.deletingReminder!.id);
      if (index > -1) {
        this.reminders.splice(index, 1);
      }
      
      this.deletingReminder = null;
    } catch (error) {
      console.error('删除提醒失败:', error);
    }
  }
  
  @Builder
  buildAddReminderDialog() {
    Column() {
      Text(this.editingReminder ? '编辑提醒' : '添加提醒')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 24 })
      
      Scroll() {
        Column() {
          // 选择联系人
          Column() {
            Text('选择联系人')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            Select(this.contacts.map(c => {
              const option: SelectOption = { value: c.name, id: c.id };
              return option;
            }))
              .selected(this.contacts.findIndex(c => c.id === this.selectedContactId))
              .value(this.contacts.find(c => c.id === this.selectedContactId)?.name || '请选择联系人')
              .font({ size: 14 })
              .fontColor('#333333')
              .selectedOptionFont({ size: 14 })
              .optionFont({ size: 14 })
              .onSelect((index: number) => {
                this.selectedContactId = this.contacts[index].id;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
          
          // 提醒标题
          Column() {
            Text('提醒标题')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '请输入提醒标题', text: this.reminderTitle })
              .fontSize(14)
              .fontColor('#333333')
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .padding(12)
              .onChange((value: string) => {
                this.reminderTitle = value;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
          
          // 提醒内容
          Column() {
            Text('提醒内容')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TextArea({ placeholder: '请输入提醒内容', text: this.reminderContent })
              .fontSize(14)
              .fontColor('#333333')
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .padding(12)
              .height(80)
              .onChange((value: string) => {
                this.reminderContent = value;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
          
          // 提醒日期
          Column() {
            Text('提醒日期')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            DatePicker({
              start: new Date('2024-01-01'),
              end: new Date('2030-12-31'),
              selected: this.reminderDate ? new Date(this.reminderDate) : new Date()
            })
              .onChange((value: DatePickerResult) => {
                const month = value.month !== undefined ? value.month : 1;
                const day = value.day !== undefined ? value.day : 1;
                this.reminderDate = `${value.year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
        }
      }
      .layoutWeight(1)
      
      // 操作按钮
      if (this.editingReminder) {
        // 编辑模式：取消、删除、保存
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#F0F0F0')
            .fontColor('#333333')
            .borderRadius(22)
            .margin({ right: 4 })
            .onClick(() => {
              this.showAddDialog = false;
            })
          
          Button('删除')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#FF4444')
            .fontColor(Color.White)
            .borderRadius(22)
            .margin({ left: 4, right: 4 })
            .onClick(() => {
              this.showAddDialog = false;
              this.showDeleteConfirmDialog(this.editingReminder!);
            })
          
          Button('保存')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(22)
            .margin({ left: 4 })
            .onClick(() => {
              this.saveReminder();
            })
        }
        .width('100%')
      } else {
        // 添加模式：取消、添加
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#F0F0F0')
            .fontColor('#333333')
            .borderRadius(22)
            .margin({ right: 8 })
            .onClick(() => {
              this.showAddDialog = false;
            })
          
          Button('添加')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(22)
            .margin({ left: 8 })
            .onClick(() => {
              this.saveReminder();
            })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(24)
  }

}