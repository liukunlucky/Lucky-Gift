import router from '@ohos.router';
import { Contact, GiftEvent } from '../../model/NewDataModels';
import { ContactDAO } from '../../database/ContactDAO';
import { GiftEventDAO } from '../../database/GiftEventDAO';
import { NewDatabaseManager } from '../../database/NewDatabaseManager';
import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@ohos.base';

interface ReminderItem {
  id: string;
  contactId: string;
  contactName: string;
  title: string;
  content: string;
  dateTime: string;
  type: 'birthday' | 'anniversary' | 'custom';
  isCompleted: boolean;
  isEnabled: boolean;
  createdAt: string;
  reminderId?: number; // 系统提醒ID
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
  @State selectedType: string = 'birthday';
  @State selectedContactId: string = '';
  @State reminderTitle: string = '';
  @State reminderContent: string = '';
  @State reminderDate: string = '';
  @State reminderTime: string = '09:00';
  @State editingReminder: ReminderItem | null = null;
  
  private dbManager = new NewDatabaseManager();
  private contactDao = new ContactDAO(this.dbManager);
  private giftEventDao = new GiftEventDAO(this.dbManager);
  
  aboutToAppear() {
    this.loadData();
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 加载联系人数据
      this.contacts = await this.contactDao.getAllContacts();
      
      // 加载提醒数据（这里模拟数据，实际应该从数据库加载）
      this.loadReminders();
      
    } catch (error) {
      console.error('加载提醒数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  loadReminders() {
    // 模拟提醒数据，实际应该从数据库加载
    this.reminders = [
      {
        id: '1',
        contactId: '1',
        contactName: '张三',
        title: '张三的生日',
        content: '记得准备生日礼物',
        dateTime: '2024-03-15 09:00',
        type: 'birthday',
        isEnabled: true,
        isCompleted: false,
        createdAt: '2024-01-01 00:00:00'
      },
      {
        id: '2',
        contactId: '2',
        contactName: '李四',
        title: '结婚纪念日',
        content: '李四夫妇的结婚纪念日',
        dateTime: '2024-04-20 10:00',
        type: 'anniversary',
        isEnabled: true,
        isCompleted: false,
        createdAt: '2024-01-01 00:00:00'
      }
    ];
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
    
    // 更新状态
    this.reminders = [...this.reminders];
  }
  
  showAddReminderDialog() {
    this.editingReminder = null;
    this.selectedType = 'birthday';
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
      this.editingReminder.type = this.selectedType as 'birthday' | 'anniversary' | 'custom';
      
      // 如果提醒已启用，需要重新创建系统提醒
      if (this.editingReminder.isEnabled) {
        if (this.editingReminder.reminderId) {
          await this.cancelSystemReminder(this.editingReminder.reminderId);
        }
        const reminderId = await this.createSystemReminder(this.editingReminder);
        this.editingReminder.reminderId = reminderId || undefined;
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
        type: this.selectedType as 'birthday' | 'anniversary' | 'custom',
        isEnabled: true,
        isCompleted: false,
        createdAt: new Date().toISOString()
      };
      
      // 创建系统提醒
      const reminderId = await this.createSystemReminder(newReminder);
      newReminder.reminderId = reminderId || undefined;
      
      this.reminders.push(newReminder);
    }
    
    this.reminders = [...this.reminders];
    this.showAddDialog = false;
  }
  
  async deleteReminder(reminder: ReminderItem) {
    // 取消系统提醒
    if (reminder.reminderId) {
      await this.cancelSystemReminder(reminder.reminderId);
    }
    
    // 从列表中移除
    this.reminders = this.reminders.filter(r => r.id !== reminder.id);
  }
  
  getTypeIcon(type: string): Resource {
    switch (type) {
      case 'birthday': return $r('app.media.icon_happy');
      case 'anniversary': return $r('app.media.icon_memory');
      default: return $r('app.media.icon_rq');
    }
  }
  
  getTypeName(type: string): string {
    switch (type) {
      case 'birthday': return '生日';
      case 'anniversary': return '纪念日';
      case 'custom': return '自定义';
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
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_arrow_right'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
        
        Text('礼物提醒')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
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
            Image($r('app.media.icon_rq'))
              .width(80)
              .height(80)
              .fillColor('#CCCCCC')
            
            Text('暂无提醒')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 16 })
            
            Text('点击右上角添加提醒')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 8 })
            
            Button('添加提醒')
              .width(120)
              .height(40)
              .backgroundColor('#FF6B35')
              .fontColor(Color.White)
              .borderRadius(20)
              .margin({ top: 24 })
              .onClick(() => {
                this.showAddReminderDialog();
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 提醒列表
          Scroll() {
            Column() {
              ForEach(this.reminders, (reminder: ReminderItem) => {
                Row() {
                  // 类型图标
                  Image(this.getTypeIcon(reminder.type))
                    .width(24)
                    .height(24)
                    .fillColor('#FF6B35')
                    .margin({ right: 12 })
                  
                  // 提醒信息
                  Column() {
                    Row() {
                      Text(reminder.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .layoutWeight(1)
                      
                      Text(this.formatDateTime(reminder.dateTime))
                        .fontSize(12)
                        .fontColor('#FF6B35')
                        .backgroundColor('#FFF0ED')
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(10)
                    }
                    .width('100%')
                    
                    Text(`${reminder.contactName} · ${this.getTypeName(reminder.type)}`)
                      .fontSize(12)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                    
                    if (reminder.content) {
                      Text(reminder.content)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 2 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  
                  // 开关和操作
                  Column() {
                    Toggle({ type: ToggleType.Switch, isOn: reminder.isEnabled })
                      .width(40)
                      .height(20)
                      .selectedColor('#FF6B35')
                      .onChange((isOn: boolean) => {
                        this.toggleReminder(reminder);
                      })
                    
                    Row() {
                      Image($r('app.media.ic_settings'))
                        .width(16)
                        .height(16)
                        .fillColor('#666666')
                        .margin({ right: 8 })
                        .onClick(() => {
                          this.showEditReminderDialog(reminder);
                        })
                      
                      Image($r('app.media.icon_delete'))
                        .width(16)
                        .height(16)
                        .fillColor('#FF4444')
                        .onClick(() => {
                          this.deleteReminder(reminder);
                        })
                    }
                    .margin({ top: 8 })
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 8, left: 16, right: 16 })
              })
            }
            .width('100%')
            .padding({ bottom: 20 })
          }
          .layoutWeight(1)
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
      dragBar: true
    })
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
          // 提醒类型
          Column() {
            Text('提醒类型')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            Row() {
              ForEach(['birthday', 'anniversary', 'custom'], (type: string) => {
                Text(this.getTypeName(type))
                  .fontSize(14)
                  .fontColor(this.selectedType === type ? Color.White : '#666666')
                  .backgroundColor(this.selectedType === type ? '#FF6B35' : '#F0F0F0')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .borderRadius(16)
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.selectedType = type;
                  })
              }, (type: string) => type)
            }
            .width('100%')
          }
          .width('100%')
          .margin({ bottom: 16 })
          
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
            
            TextArea({ placeholder: '请输入提醒内容（可选）', text: this.reminderContent })
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
                const month = value.month !== undefined ? value.month + 1 : 1;
                const day = value.day !== undefined ? value.day : 1;
                this.reminderDate = `${value.year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
              })
          }
          .width('100%')
          .margin({ bottom: 16 })
          
          // 提醒时间
          Column() {
            Text('提醒时间')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TimePicker({
              selected: new Date(`2024-01-01 ${this.reminderTime}`)
            })
              .onChange((value: TimePickerResult) => {
                this.reminderTime = `${String(value.hour).padStart(2, '0')}:${String(value.minute).padStart(2, '0')}`;
              })
          }
          .width('100%')
          .margin({ bottom: 24 })
        }
      }
      .layoutWeight(1)
      
      // 操作按钮
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
        
        Button(this.editingReminder ? '保存' : '添加')
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
    .width('100%')
    .padding(24)
  }
}